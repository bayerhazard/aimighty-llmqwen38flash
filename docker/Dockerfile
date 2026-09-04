# llama-server (danielhanchen/llama.cpp, branch qwen4exp/mtp) for Olares One
# Core Ultra 9 275HX (AVX-512, AMX) + RTX 5090 (sm_120 Blackwell)
# Qwen3.8-Flash-Next (180B total / 6B active) with MTP draft head + vision (mtmd)
# Builds pinned commit, pushes to ghcr.io/bayerhazard/llama-cpp-qwen4:<shortsha>

# ---- Stage 1: Build ----
FROM nvidia/cuda:13.1.1-devel-ubuntu24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build git ca-certificates pkg-config \
    libcurl4-openssl-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ARG PIN=2c967293c2632bd0d09096406628a7e4baf97b88

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:${PATH}

# libggml-cuda links against libcuda.so.1 (driver VMM API); only the stub
# libcuda.so ships in the devel image -> provide the .so.1 soname via symlink
RUN ln -sf /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1

WORKDIR /build
RUN git clone https://github.com/danielhanchen/llama.cpp.git && \
    cd llama.cpp && git checkout ${PIN} && git rev-parse HEAD

WORKDIR /build/llama.cpp
RUN cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_CUDA=ON \
    -DGGML_CUDA_FA=ON \
    -DGGML_CUDA_ARCHITECTURES=120 \
    -DGGML_AVX=ON \
    -DGGML_AVX2=ON \
    -DGGML_AVX512=ON \
    -DGGML_AVX512_VBMI=ON \
    -DGGML_AVX512_VNNI=ON \
    -DGGML_AVX512_BF16=ON \
    -DGGML_AMX_TILE=ON \
    -DGGML_AMX_INT8=ON \
    -DGGML_AMX_BF16=ON \
    -DGGML_FMA=ON \
    -DGGML_F16C=ON \
    -DLLAMA_OPENSSL=ON \
    -DLLAMA_CURL=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-L/usr/local/cuda/lib64/stubs -Wl,-rpath-link,/usr/local/cuda/lib64/stubs" \
    -DCMAKE_SHARED_LINKER_FLAGS="-L/usr/local/cuda/lib64/stubs -Wl,-rpath-link,/usr/local/cuda/lib64/stubs" \
    && cmake --build build --config Release -j$(nproc) --target llama-server llama-mtmd-cli

# ---- Stage 2: Runtime (mirrors buun-llama-cpp layout) ----
FROM nvidia/cuda:13.1.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 ca-certificates curl bash \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/llama.cpp/build/bin/llama-server /app/llama-server
COPY --from=builder /build/llama.cpp/build/bin/llama-mtmd-cli /app/llama-mtmd-cli
COPY --from=builder /build/llama.cpp/build/bin/*.so* /app/

ENV LD_LIBRARY_PATH=/app
# libcuda.so.1 is provided by the node driver at runtime (nvidia-container-runtime)
RUN LD_LIBRARY_PATH=/app ldd /app/llama-server | grep -v "libcuda" | awk '/not found/{print; bad=1} END{exit bad}'
ENTRYPOINT ["/app/llama-server"]
