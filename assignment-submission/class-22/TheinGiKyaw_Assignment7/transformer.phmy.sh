#!/bin/bash

## Based on the script displayed in Transformer-NMT-marian-ph2gp.ipynb.
## Local adaptation:
## - uses ./g2p-par instead of /home/ye/exp/nmt/marian-demo/g2p-par
## - uses CPU threads instead of --devices 0 because Marian was built CPU-only

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
model_folder="${script_dir}/model.transformer.phmy"
data_path="${DATA_PATH:-${script_dir}/g2p-par}"
src="ph"
tgt="my"
cpu_threads="${CPU_THREADS:-4}"

mkdir -p "${model_folder}"

marian \
  --model "${model_folder}/model.npz" --type transformer \
  --train-sets "${data_path}/train.${src}" "${data_path}/train.${tgt}" \
  --max-length 200 \
  --vocabs "${data_path}/vocab/vocab.${src}.yml" "${data_path}/vocab/vocab.${tgt}.yml" \
  --mini-batch-fit -w 1000 --maxi-batch 100 \
  --early-stopping 10 \
  --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
  --valid-metrics cross-entropy perplexity bleu \
  --valid-sets "${data_path}/dev.${src}" "${data_path}/dev.${tgt}" \
  --valid-translation-output "${model_folder}/valid.${src}-${tgt}.output" --quiet-translation \
  --valid-mini-batch 64 \
  --beam-size 6 --normalize 0.6 \
  --log "${model_folder}/train.log" --valid-log "${model_folder}/valid.log" \
  --enc-depth 2 --dec-depth 2 \
  --transformer-heads 8 \
  --transformer-postprocess-emb d \
  --transformer-postprocess dan \
  --transformer-dropout 0.3 --label-smoothing 0.1 \
  --learn-rate 0.0003 --lr-warmup 0 --lr-decay-inv-sqrt 16000 --lr-report \
  --clip-norm 5 \
  --tied-embeddings \
  --cpu-threads "${cpu_threads}" --seed 1111 \
  --exponential-smoothing \
  --dump-config > "${model_folder}/${src}-${tgt}.config.yml"

time marian -c "${model_folder}/${src}-${tgt}.config.yml" 2>&1 | tee "${model_folder}/transformer-${src}-${tgt}.log"
