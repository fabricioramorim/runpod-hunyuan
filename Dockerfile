FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.13 \
    python3-pip \
    git \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    wget \
    openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Create symlinks for Python
RUN ln -sf /usr/bin/python3.13 /usr/bin/python && \
    ln -sf /usr/bin/python3.13 /usr/bin/python3

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Install Python packages
RUN pip3 install --no-cache-dir \
    jupyterlab \
    jupyterlab_widgets \
    ipykernel \
    ipywidgets \
    aiohttp && \
    pip3 install --no-cache-dir \
    torch==2.7.0 \
    torchvision \
    torchaudio \
    --extra-index-url https://download.pytorch.org/whl/cu129

# Clone ComfyUI to root directory
WORKDIR /
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    pip install --no-cache-dir -r requirements.txt

# Copy all scripts
COPY scripts/start.sh /start.sh
COPY scripts/pre_start.sh /pre_start.sh
COPY scripts/download_models.sh /download_models.sh
COPY scripts/install_nodes.sh /install_nodes.sh
# Make scripts executable
RUN chmod +x /*.sh

# Create workspace and logs directory
RUN mkdir -p /workspace/logs

CMD ["/start.sh"]