# NMT Results Comparison

This file compares the original `*1.ipynb` notebooks with the improved notebooks for the phoneme-to-Myanmar Marian NMT experiments.

## Notebook Types

| Notebook type | Purpose / runtime |
|---|---|
| `*1.ipynb` | GPU version of the original experiment. These notebooks were run with GPU acceleration. |
| `*improved.ipynb` | Improvement experiment notebooks. These add stronger settings such as better regularization, decoding, checkpointing, and tuning. |
| Other original notebooks without `1` or `improved` | CPU version of the original experiment. These are useful as the first baseline but run slower than the GPU notebooks. |

## Summary

| Model family | Notebook | Experiment / checkpoint | Best dev BLEU | Test BLEU | Result |
|---|---|---:|---:|---:|---|
| Transformer | `Transformer-NMT-marian-ph2gp1.ipynb` | `model.transformer.phmy` | 76.1433 | 76.69 | Original baseline |
| Transformer | `Transformer-NMT-marian-ph2gp-improved.ipynb` | `model.transformer.warmup4000_dropout01.phmy` | 76.4125 | 76.70 | Slight improvement |
| Seq2Seq | `Seq2Seq-NMT-marian-ph2gp1.ipynb` | `model.seq2seq.phmy` | 52.3146 | 49.86 | Original baseline |
| Seq2Seq | `Seq2Seq-NMT-marian-ph2gp-improved.ipynb` | `model.seq2seq.regularized_decode.phmy` | 77.7630 | 77.62 | Large improvement |

## BLEU Difference

| Comparison | Best dev BLEU change | Test BLEU change |
|---|---:|---:|
| Transformer improved vs Transformer original | +0.2692 | +0.01 |
| Seq2Seq improved vs Seq2Seq original | +25.4484 | +27.76 |

## Training Time Comparison

| Model family | Notebook | Runtime type | Training start | Training end / stop | Training time | Status |
|---|---|---|---|---|---:|---|
| Transformer | `Transformer-NMT-marian-ph2gp1.ipynb` | GPU original | 2026-07-26 01:48:31 | 2026-07-26 02:43:06 | 54m 43.884s | Finished by early stopping |
| Transformer | `Transformer-NMT-marian-ph2gp-improved.ipynb` | GPU improvement | 2026-07-26 17:19:12 | 2026-07-26 19:05:23 | about 1h 46m | Interrupted manually after best BLEU had already been saved |
| Seq2Seq | `Seq2Seq-NMT-marian-ph2gp1.ipynb` | GPU original | 2026-07-26 00:22:02 | 2026-07-26 01:41:31 | 81m 58.625s | Finished by early stopping |
| Seq2Seq | `Seq2Seq-NMT-marian-ph2gp-improved.ipynb` | GPU improvement | 2026-07-26 02:52:32 | 2026-07-26 11:29:20 | about 8h 36m 48s | Finished by early stopping |

The improved Transformer training time is not a full finished-training time because the run was stopped with `KeyboardInterrupt`. The best BLEU checkpoint had already been saved at update `5000`, so decoding and evaluation still used the best available model.

## Transformer Comparison

The original Transformer model already performed well. Its best validation BLEU was `76.1433`, and the final test BLEU was `76.69`.

The improved Transformer experiment used the `warmup4000_dropout01` setting. The main changes were:

- Shared vocabulary for source and target.
- `tied-embeddings-all: true`.
- Lower Transformer dropout: `0.1` instead of `0.3`.
- Learning-rate warmup: `lr-warmup: 4000`.
- `keep-best: true`, so decoding can use the best BLEU checkpoint.
- Stop setting fixed for future runs: `early-stopping: 3` and `after-epochs: 1000`.

The improved Transformer reached best validation BLEU `76.4125` at update `5000` and test BLEU `76.70`. This is only a very small test improvement over the original Transformer result.

## Seq2Seq Comparison

The original Seq2Seq model performed much worse than Transformer. Its best validation BLEU was `52.3146`, and the test BLEU was `49.86`.

The improved Seq2Seq experiment used the `regularized_decode` setting. The main changes were:

- Larger workspace: `3000`.
- Higher learning rate: `0.0003`.
- Label smoothing: `0.1`.
- Gradient clipping: `clip-norm: 5`.
- Better decoding settings: `beam-size: 6`, `normalize: 0.6`.
- `keep-best: true`, so decoding uses the best BLEU checkpoint.

The improved Seq2Seq reached best validation BLEU `77.7630` at update `45000` and test BLEU `77.62`. This is a large improvement over the original Seq2Seq result and is also higher than both Transformer test results.

## Conclusion

The strongest result is from `Seq2Seq-NMT-marian-ph2gp-improved.ipynb` with test BLEU `77.62`.

The improved Transformer result is stable but only slightly better than the original Transformer baseline. The improved Seq2Seq result is the most important improvement, raising test BLEU from `49.86` to `77.62`.
