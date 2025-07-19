#!/bin/bash


export PYTHONUNBUFFERED=1
export PATH="/workspace/bin:$PATH"

# Ensure we have /workspace in all scenarios
mkdir -p /workspace

if [[ ! -d /workspace/ComfyUI ]]; then
	# If we don't already have /workspace/ComfyUI, move it there
	mv /ComfyUI /workspace
else
	# otherwise delete the default ComfyUI folder which is always re-created on pod start from the Docker
	rm -rf /ComfyUI
fi

# Then link /ComfyUI folder to /workspace so it's available in that familiar location as well
ln -s /workspace/ComfyUI /ComfyUI

echo "**** DOWNLOADING MODLES --- PLEASE WAIT ****"
echo "**** DIHAN'S MAIN 2.0 TEMPLATE ****"
/download_models.sh

cd /workspace/ComfyUI
python main.py --listen --port 8188 --enable-cors-header --verbose $COMFYUI_EXTRA_ARGS &