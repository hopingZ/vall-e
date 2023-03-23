export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

CUDA_VISIBLE_DEVICES=3 python bin/infer_mandarin_phoneme.py \
  --decoder-dim 256 \
  --nhead 4 \
  --num-decoder-layers 6 \
  --model-name vallf \
  --audio-prompt prompts/SSB00050394.wav \
  --text-prompt "sil k uang2 c ao3 sp" \
  --output-dir infer/vallf_nano_aishell3_sp_epoch99 \
  --checkpoint exp/vallf_nano/epoch-99.pt \
  --text-tokens data/tokenized/unique_text_tokens.k2symbols \
  --text "k uang2 c ao3 sil|zh u3 iao4 sh iii4 t a1 x ian4 z ai4 sil|uan3 sh ang4 b u4 j ia1 b an1 d e5 h ua4 sil|j iou4 q v4 d iao4 v2 sil|uo3 m en5 g ong1 zh ong4 h ao4 i4 zh iii2 z ai4 d ai4 l ing3 d a4 j ia1 c ong2 b en3 zh iii4 k an4 uen4 t i2 sp zh e4 c ai2 n eng2 zh en1 zh eng4 d e5 d uei4 sh iii4 q ing5 iou2 s uo3 b ang1 zh u4 sil|zh u3 iao4 sh iii4 t a1 x ian4 z ai4 uan3 sh ang4 b u4 j ia1 b an1 d e5 h ua4 j iou4 q v4 d iao4 v2 spl er2 q ie3 d iao4 d ao4 l ing2 ch en2 l iang3 s an1 d ian3 c ai2 h uei2 j ia1 sil|b en3 l ai2 l ao3 sh iii1 n i2 h ao3 spl g uan1 zh u4 d ing4 ve4 h ao4 i3 j ing1 iou3 s an1 s ii4 n ian2 spl t uei1 s ong4 d e5 x iao1 x i5 j i1 b en3 d ou1 q van2 b u4 k an4 uan2 sil" \
  --num-last-ignoring-frames 5
