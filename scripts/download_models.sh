#!/bin/bash
set -e

MODEL_DIR="/workspace/ComfyUI/models"
LORA_DIR="${MODEL_DIR}/loras"

mkdir -p ${MODEL_DIR}/{checkpoints,text_encoder,clip_vision,vae}
mkdir -p ${LORA_DIR} # Garante que o diretório loras exista

download_if_not_exists() {
    local url=$1
    local dest=$2
    local filename=$(basename "$dest")

    if [ ! -f "$dest" ]; then
        echo "BAIXANDO -- $filename..."
        wget -q --show-progress "$url" -O "$dest"
        if [ $? -eq 0 ]; then
            echo "CONCLUÍDO $filename com sucesso"
        else
            echo "FALHA ao baixar $filename. Verifique a URL ou sua conexão."
        fi
    else
        echo "$filename já existe, pulando download"
    fi
}

# URL base do repositório para os LoRAs
HUGGINGFACE_LORA_BASE_URL="https://huggingface.co/datasets/oggimrm/HunyuanVideo/resolve/main/"
HUGGINGFACE_LORA_REPO_BROWSE_URL="https://huggingface.co/datasets/oggimrm/HunyuanVideo/tree/main"

echo "Buscando arquivos .safetensors no repositório HunyuanVideo..."

# Usa curl para baixar a página HTML e grep/sed para extrair os nomes dos arquivos .safetensors
# Esta abordagem pode ser frágil se a estrutura HTML do Hugging Face mudar
# Uma alternativa mais robusta seria usar a API do Hugging Face, mas é mais complexa.
FILES_TO_DOWNLOAD=$(curl -s "$HUGGINGFACE_LORA_REPO_BROWSE_URL" | grep -oP 'href="[^"]+\.safetensors"' | sed -E 's/href="([^"]+)"/\1/' | xargs -n 1 basename)

if [ -z "$FILES_TO_DOWNLOAD" ]; then
    echo "Nenhum arquivo .safetensors encontrado no repositório. Verifique a URL ou a estrutura da página."
else
    for filename in $FILES_TO_DOWNLOAD; do
        download_if_not_exists "${HUGGINGFACE_LORA_BASE_URL}${filename}" \
            "${LORA_DIR}/${filename}"
    done
fi

# Download de outros modelos (mantidos como estavam)
download_if_not_exists "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/diffusion_models/hunyuan_video_t2v_720p_bf16.safetensors" \
    "${MODEL_DIR}/unet/hunyuan_video_t2v_720p_bf16.safetensors"

download_if_not_exists "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/clip_l.safetensors" \
    "${MODEL_DIR}/text_encoder/clip_l.safetensors"

download_if_not_exists "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/llava_llama3_fp8_scaled.safetensors" \
    "${MODEL_DIR}/text_encoder/llava_llama3_fp8_scaled.safetensors"

download_if_not_exists "https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/vae/hunyuan_video_vae_bf16.safetensor" \
    "${MODEL_DIR}/vae/hunyuan_video_vae_bf16.safetensors"

/install_nodes.sh

echo "Todos os modelos baixados com sucesso (incluindo LoRAs dinâmicos)."
