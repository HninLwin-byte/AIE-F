#!/bin/bash

## Based on the script displayed in Seq2Seq-NMT-marian-ph2gp.ipynb.
## Local adaptation:
## - uses ./g2p-par instead of /home/ye/exp/nmt/marian-demo/g2p-par
## - uses GPU device(s); Marian must be built with CUDA support

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
model_folder="${script_dir}/model.seq2seq.phmy"
data_path="${DATA_PATH:-${script_dir}/g2p-par}"
src="ph"
tgt="my"
devices="${MARIAN_DEVICES:-0}"
marian_bin="${MARIAN_BIN:-marian}"

mkdir -p "${model_folder}"
rm -f "${model_folder}/config.yml"

if ! command -v "${marian_bin}" >/dev/null 2>&1; then
  echo "Error: Marian binary not found: ${marian_bin}" >&2
  echo "Set MARIAN_BIN=/path/to/marian or add Marian build folder to PATH." >&2
  exit 1
fi

if ! "${marian_bin}" --build-info 2>&1 | grep -qi '^COMPILE_CUDA=on'; then
  echo "Error: Marian was not built with CUDA support." >&2
  echo "Using: $(command -v "${marian_bin}")" >&2
  echo "Check with: ${marian_bin} --build-info | grep -i COMPILE_CUDA" >&2
  exit 1
fi

"${marian_bin}" \
  --type s2s \
  --train-sets "${data_path}/train.${src}" "${data_path}/train.${tgt}" \
  --max-length 200 \
  --valid-sets "${data_path}/dev.${src}" "${data_path}/dev.${tgt}" \
  --vocabs "${data_path}/vocab/vocab.${src}.yml" "${data_path}/vocab/vocab.${tgt}.yml" \
  --model "${model_folder}/model.npz" \
  --workspace 500 \
  --enc-depth 2 --enc-type alternating --enc-cell lstm --enc-cell-depth 2 \
  --dec-depth 2 --dec-cell lstm --dec-cell-base-depth 2 --dec-cell-high-depth 2 \
  --tied-embeddings --layer-normalization --skip \
  --mini-batch-fit \
  --valid-mini-batch 32 \
  --valid-metrics cross-entropy perplexity bleu \
  --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
  --dropout-rnn 0.3 --dropout-src 0.3 --exponential-smoothing \
  --early-stopping 10 \
  --log "${model_folder}/train.log" --valid-log "${model_folder}/valid.log" \
  --devices "${devices}" --cpu-threads 0 --seed 1111 \
  --dump-config > "${model_folder}/config.yml"

time "${marian_bin}" -c "${model_folder}/config.yml" 2>&1 | tee "${model_folder}/s2s.${src}-${tgt}.log"
