#!/bin/bash
# Qwen3.8-Flash-Next model download -> worker-local NVMe (#4019 workaround: no JuiceFS)
cd /var/lib/olares-local-models || exit 1
B="https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF/resolve/main"
dl() {
  for i in $(seq 1 10); do
    RC=0
    curl -sSL -C - --retry 5 --retry-delay 5 -o "$1" "$2?download=true" || RC=$?
    if [ $RC -eq 0 ] || [ $RC -eq 33 ]; then echo "OK $1"; return 0; fi
    sleep 10
  done
  echo "FAIL $1"; return 1
}
dl "UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00001-of-00004.gguf" "$B/UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00001-of-00004.gguf" &
dl "UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00002-of-00004.gguf" "$B/UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00002-of-00004.gguf" &
dl "UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00003-of-00004.gguf" "$B/UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00003-of-00004.gguf" &
dl "UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00004-of-00004.gguf" "$B/UD-Q4_K_XL/Qwen3.8-Flash-Next-UD-Q4_K_XL-00004-of-00004.gguf" &
dl "MTP/mtp-Qwen3.8-Flash-Next-shared-Q8_0.gguf" "$B/MTP/mtp-Qwen3.8-Flash-Next-shared-Q8_0.gguf" &
dl "mmproj-F16.gguf" "$B/mmproj-F16.gguf" &
wait
echo ALL-DONE
date -u
