# ======================================================
# 🐳 Base officielle RunPod ComfyUI (contient déjà .venv et worker)
# ======================================================
FROM runpod/worker-comfyui:5.5.0-base

# ======================================================
# ⚙️ 1️⃣ Nettoyage de l'ancienne version de Torch
# ======================================================
RUN yes | /workspace/runpod-slim/ComfyUI/.venv/bin/python -m uv pip uninstall \
      torch torchvision torchaudio triton && \
    rm -rf /root/.cache/uv /root/.cache/pip /root/.cache/torch_extensions /tmp/pip-*

# ======================================================
# ⚙️ 2️⃣ Réinstallation de PyTorch 2.9 + CUDA 12.8
# ======================================================
RUN /workspace/runpod-slim/ComfyUI/.venv/bin/python -m uv pip install \
      torch==2.9.0+cu128 \
      torchvision==0.24.0+cu128 \
      torchaudio==2.9.0+cu128 \
      triton==3.5.0 \
      --extra-index-url https://download.pytorch.org/whl/cu128 && \
    /workspace/runpod-slim/ComfyUI/.venv/bin/python -m uv pip install numpy==1.26.4

# ======================================================
# ⚙️ 3️⃣ Installation des dépendances custom
# ======================================================
RUN /workspace/runpod-slim/ComfyUI/.venv/bin/python -m pip install sageattention && \
    /workspace/runpod-slim/ComfyUI/.venv/bin/python -m uv pip install \
      git+https://github.com/nunchaku-tech/nunchaku.git@v1.0.0 \
      --no-binary nunchaku \
      --reinstall \
      --no-cache

# ======================================================
# ⚙️ 4️⃣ Variables d’environnement GPU
# ======================================================
ENV TORCH_CUDA_ARCH_LIST="8.9"
ENV FORCE_CMAKE=1
ENV MAX_JOBS=$(nproc)
ENV USE_TORCH_VERSION=2.9.0
ENV UV_LINK_MODE=copy

# ======================================================
# 📁 5️⃣ Point de montage de ton volume ComfyUI
# ======================================================
RUN mkdir -p /workspace
WORKDIR /workspace

# ======================================================
# 🚀 6️⃣ Commande de démarrage par défaut
# ======================================================
CMD ["python3", "/workspace/runpod-slim/ComfyUI/main.py"]
