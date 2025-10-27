# syntax=docker/dockerfile:1.4
FROM runpod/worker-comfyui:5.5.0-base

# =======================================================
# ⚙️ Dépendances système
# =======================================================
RUN apt-get update && apt-get install -y --no-install-recommends git curl && rm -rf /var/lib/apt/lists/*

# =======================================================
# 🔗 Préparation des liens symboliques pour RunPod
# =======================================================
# /workspace -> /runpod-volume
# /comfyui/models -> /runpod-volume/models
RUN mkdir -p /runpod-volume/models && \
    rm -rf /workspace && ln -s /runpod-volume /workspace && \
    rm -rf /comfyui/models && ln -s /runpod-volume/models /comfyui/models && \
    echo "🔗 Symlinks created successfully:" && \
    ls -l / | grep runpod-volume && ls -l /comfyui | grep models


# =======================================================
# 🔍 Torch + CUDA Check
# =======================================================
RUN echo "🧠 Checking Torch and CUDA version..." && \
    python3 -c "import torch; print(f'Torch version: {torch.__version__}, CUDA: {torch.version.cuda}')"

# =======================================================
# ⚙️ Installation de Nunchaku (v1.0.1 compatible Torch 2.7 + Python 3.12)
# La wheel est compilée avec torch 2.9 , alors que l'image de workfer-comfyui 5.5.0-base utiliser torch 2.7
# Certaines des fonctionnalités liées aux modèles QWEN et d'autres ne marcheront pas, mais pour nos workflows (Wan2.1, infinite talk), ce n'est pas gênants
# Il y aura des erreurs d'imports au runtime liées aux raisons citées au dessus

# =======================================================
RUN echo "📦 Installing Nunchaku 1.0.1 (Torch 2.7, cp312)..." && \
    pip install --no-cache-dir \
      'https://github.com/nunchaku-tech/nunchaku/releases/download/v1.0.0/nunchaku-1.0.0+torch2.7-cp312-cp312-linux_x86_64.whl'

# =======================================================
# 🧠 Clonage manuel des nodes non présents dans le registry
# =======================================================
RUN echo "📦 Cloning manual custom nodes..." && \
    cd /comfyui/custom_nodes && \
    git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use.git && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone --depth 1 https://github.com/shiimizu/ComfyUI-TiledDiffusion.git && \
    git clone --depth 1 https://github.com/gseth/ControlAltAI-Nodes.git && \
    git clone --depth 1 https://github.com/cubiq/ComfyUI_essentials.git && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git && \
    git clone --depth 1 https://github.com/nunchaku-tech/ComfyUI-nunchaku.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    rm -rf /comfyui/custom_nodes/*/.git && \
    echo "📥 Installing deps for manually cloned nodes..." && \
    for d in /comfyui/custom_nodes/*; do \
      if [ -f "$d/requirements.txt" ]; then \
        echo "📦 Installing deps for $d..." && pip install -r "$d/requirements.txt" || true; \
      fi; \
    done

# =======================================================
# 🧩 Dépendances Python manquantes (sécurité)
# =======================================================
RUN pip install --no-cache-dir pillow numpy opencv-python-headless


COPY handler.py /handler.py

# =======================================================
# ✅ Vérifications finales
# =======================================================
RUN echo "✅ Installed custom nodes:" && ls -1 /comfyui/custom_nodes && \
    echo "✅ Symlinked model directory:" && ls -l /comfyui/models







