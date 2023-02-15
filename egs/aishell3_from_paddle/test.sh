export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

CUDA_VISIBLE_DEVICES=3 python bin/infer_mandarin_phoneme.py \
  --decoder-dim 256 \
  --nhead 4 \
  --num-decoder-layers 6 \
  --model-name valle \
  --audio-prompt prompts/SSB00050394.wav \
  --text-prompt "sil k uang2 c ao3 sp" \
  --output-dir infer/valle_middle_epoch3 \
  --checkpoint exp/valle_middle/epoch-3.pt \
  --text-tokens data/tokenized/unique_text_tokens.k2symbols \
  --text "k uang2 c ao3 sil|zh u3 iao4 sh iii4 t a1 x ian4 z ai4 sil|uan3 sh ang4 b u4 j ia1 b an1 d e5 h ua4 sil|j iou4 q v4 d iao4 v2 sil"
  