#!/usr/bin/env python3
# Copyright    2023                            (authors: Feiteng Li)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
Phonemize Text and EnCodec Audio.

Usage example:
    python3 bin/infer.py \
        --src_dir ./data/manifests --output_dir ./data/tokenized

"""
import argparse
import logging
from pathlib import Path

import torch
import torchaudio

from valle.data import (
    AudioTokenizer,
    TextTokenizer,
    tokenize_audio,
    tokenize_text,
)
from valle.data.collation import get_text_token_collater
from valle.modules import add_model_arguments, get_model


def get_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--text-prompt",
        type=str,
        default="",
        help="Text prompt.",
    )

    parser.add_argument(
        "--audio-prompt",
        type=str,
        default="",
        help="Audio prompt.",
    )

    parser.add_argument(
        "--texts",
        type=str,
        default="",
        help="Texts to be synthesized. Divided by '|' if have multi sentenses to generate.",
    )

    # model
    add_model_arguments(parser)

    parser.add_argument(
        "--text-tokens",
        type=str,
        default="data/tokenized/unique_text_tokens.k2symbols",
        help="Path to the unique text tokens file.",
    )

    parser.add_argument(
        "--checkpoint",
        type=Path,
        default=Path("exp/vallf_nano_full/checkpoint-100000.pt"),
        help="Path to the saved checkpoint.",
    )

    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("infer/demo"),
        help="Path to the tokenized files.",
    )

    return parser.parse_args()


@torch.no_grad()
def main():
    args = get_args()
    text_collater = get_text_token_collater(args.text_tokens)
    audio_tokenizer = AudioTokenizer()

    device = torch.device("cpu")
    if torch.cuda.is_available():
        device = torch.device("cuda", 0)

    model = get_model(args)
    assert args.checkpoint.is_file(), "所给 checkpoint 路径不存在"
    checkpoint = torch.load(args.checkpoint, map_location=device)
    missing_keys, unexpected_keys = model.load_state_dict(checkpoint["model"], strict=True)

    model.to(device)
    model.eval()

    Path(args.output_dir).mkdir(parents=True, exist_ok=True)

    text_prompt, text_prompts_lens = text_collater([args.text_prompt.split(' ')])

    encoded_frames = tokenize_audio(audio_tokenizer, args.audio_prompt)
    audio_prompt = encoded_frames[0][0]
    audio_prompts = torch.concat([audio_prompt], dim=-1).transpose(2, 1)

    for n, text in enumerate(args.text.split("|")):
        logging.info(f"synthesize text: {text}")
        text_tokens, text_tokens_lens = text_collater([text.split(' ')])

        text_tokens = torch.concat([text_prompt[:, :-1], text_tokens[:, 1:]], dim=-1)
        text_tokens = text_tokens.to(device)
        text_tokens_lens += text_prompts_lens - 2

        # synthesis
        encoded_frames = model.inference(
            text_tokens, text_tokens_lens, audio_prompts
        )
        samples = audio_tokenizer.decode(
            [(encoded_frames.transpose(2, 1), None)]
        )
        samples = samples.cpu()
        # store
        torchaudio.save(f"{args.output_dir}/{n}.wav", samples[0], 24000)


torch.set_num_threads(1)
torch.set_num_interop_threads(1)
torch._C._jit_set_profiling_executor(False)
torch._C._jit_set_profiling_mode(False)
torch._C._set_graph_executor_optimize(False)
if __name__ == "__main__":
    formatter = (
        "%(asctime)s %(levelname)s [%(filename)s:%(lineno)d] %(message)s"
    )
    logging.basicConfig(format=formatter, level=logging.INFO)
    main()
