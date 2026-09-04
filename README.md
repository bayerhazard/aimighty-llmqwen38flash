# aimighty-llmqwen38flash

Qwen3.8-Flash-Next (180B total / 6B active) for Olares One.

- Engine: `danielhanchen/llama.cpp` branch `qwen4exp/mtp` (MTP draft head + shared-tensor borrowing)
- Image: `ghcr.io/bayerhazard/llama-cpp-qwen4:<shortsha>` (CUDA 13.1, sm_120, AVX-512/AMX)
- Quant: UD-Q4_K_XL (111.3 GB, 4-part GGUF) + MTP shared Q8_0 + mmproj-F16
- App: `aimqwen38flash` — "AIM Qwen3.8 Flash", categories AI + Vision

## Build

GitHub Actions: `Build llama-cpp-qwen4 image` (workflow_dispatch, input `pin` = commit SHA).
Pushes `ghcr.io/bayerhazard/llama-cpp-qwen4:<shortsha>`.

## Model files (worker-local, #4019 workaround)

`/var/lib/olares-local-models/` on the worker node (local NVMe, bypasses JuiceFS):

- `UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-0000{1..4}-of-00004.gguf`
- `MTP/mtp-Qwen3.8-Flash-Next-shared-Q8_0.gguf`
- `mmproj-F16.gguf`

Source: `unsloth/Qwen3.8-Flash-Next-GGUF` (HuggingFace).
