#!/usr/bin/env bash

set -eou pipefail

# fix segmentation fault reported in https://github.com/k2-fsa/icefall/issues/674
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

nj=16
stage=-1
stop_stage=3

dl_dir=/data6/zhanghongbin/datasets/data_aishell3
dump_dir=/data6/zhanghongbin/projects/PaddleSpeech/examples/aishell3/tts3/dump_not_cut-sil

. shared/parse_options.sh || exit 1

# All files generated by this script are saved in "data".
# You can safely remove "data" and rerun this script to regenerate it.
mkdir -p data

log() {
  # This function is from espnet
  local fname=${BASH_SOURCE[1]##*/}
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

log "dl_dir: $dl_dir"

if [ $stage -le 1 ] && [ $stop_stage -ge 1 ]; then
  log "Stage 1: Prepare aishell3 manifest"
  mkdir -p data/manifests
  if [ ! -e data/manifests/.aishell3.done ]; then
    python3 prepare_manifest.py \
        --dl_dir=${dl_dir} \
        --dump_dir=${dump_dir} \
        --output_dir="data/manifests"

    touch data/manifests/.aishell3.done
  fi
fi

if [ $stage -le 2 ] && [ $stop_stage -ge 2 ]; then
  log "Stage 2: Tokenize aishell3"
  mkdir -p data/tokenized
  if [ ! -e data/tokenized/.aishell3.tokenize.done ]; then
    python3 bin/tokenizer_for_aishell3.py \
        --src-dir "data/manifests" \
        --output-dir "data/tokenized" \
        --prefix "aishell3"
    cp ${dump_dir}/phone_id_map.txt data/tokenized/unique_text_tokens.k2symbols
  fi
  touch data/tokenized/.aishell3.tokenize.done
fi

if [ $stage -le 3 ] && [ $stop_stage -ge 3 ]; then
  log "Stage 3: Prepare aishell3 train/dev/test"
  if [ ! -e data/tokenized/.aishell3.train.done ]; then
    # train
    lhotse copy \
      data/tokenized/aishell3_cuts_train.jsonl.gz \
      data/tokenized/cuts_train.jsonl.gz

    # dev
    lhotse copy \
      data/tokenized/aishell3_cuts_dev.jsonl.gz \
      data/tokenized/cuts_dev.jsonl.gz

    # test
    lhotse copy \
      data/tokenized/aishell3_cuts_test.jsonl.gz \
      data/tokenized/cuts_test.jsonl.gz

    touch data/tokenized/.aishell3.train.done
  fi
fi

if [ $stage -le 4 ] && [ $stop_stage -ge 4 ]; then
  log "Stage 4: Train aishell3"

  # nano
  python3 bin/trainer.py \
    --decoder-dim 128 --nhead 4 --num-decoder-layers 4 \
    --exp-dir exp/valle_nano

  # same as paper
  # python3 bin/trainer.py \
  #   --decoder-dim 1024 --nhead 16 --num-decoder-layers 12 \
  #   --exp-dir exp/valle
fi
