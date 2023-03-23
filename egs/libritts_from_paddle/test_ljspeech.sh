export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

CUDA_VISIBLE_DEVICES=2 python bin/infer_mandarin_phoneme.py \
  --decoder-dim 256 \
  --nhead 4 \
  --num-decoder-layers 6 \
  --model-name vallf \
  --audio-prompt prompts/egs_ljspeech_prompts_LJ049-0124_24K.wav \
  --output-dir infer/vallf_nano_ljspeech_douhao_ig0_epoch17 \
  --checkpoint exp/vallf_nano/epoch-17.pt \
  --text-tokens data/tokenized/unique_text_tokens.k2symbols \
  --text "HH AH0 L OW1 W ER1 L D .|W EH1 R D UW1 W IY1 G OW1 N AW1 ?|AY1 L AH1 V Y UW1 .|T UW1 G EH1 T AH1 P AH0 N D R AH1 N IH0 NG K W IH1 K L IY0 JH AH1 S T F AA1 L OW0 DH AH0 S T EH1 P S B IH0 L OW1 .|D UH1 R IH0 NG DH AH0 P IH1 R IY0 AH0 D DH AH0 K AH0 M IH1 SH AH0 N W AA1 Z G IH1 V IH0 NG TH AO1 T T UW1 DH IH1 S S IH2 CH UW0 EY1 SH AH0 N ." \
  --text-prompt "IH0 N AH0 D IH1 SH AH0 N , DH AH0 P R AH0 P OW1 Z D L EH2 JH AH0 S L EY1 SH AH0 N W IH1 L IH0 N SH UH1 R ," \
  --num-last-ignoring-frames 0


  # --text-prompt "IH0 N AH0 D IH1 SH AH0 N ," \
  # --num-last-ignoring-frames 180

