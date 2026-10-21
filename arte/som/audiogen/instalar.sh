set -e
cd /mnt/d/AI_LOCAL/AudioGen
BASEPY=$(/mnt/d/Comfy-Desktop/venv/bin/python -c "import sys,os;print(os.path.join(sys.base_prefix,'bin','python3.12'))")
$BASEPY -m venv venv
./venv/bin/pip install -q --upgrade pip wheel
./venv/bin/pip install -q torch torchaudio --index-url https://download.pytorch.org/whl/cu128
./venv/bin/pip install -q --no-deps audiocraft==1.3.0
./venv/bin/pip install -q av einops flashy hydra-core hydra_colorlog julius num2words "numpy<2.3" sentencepiece huggingface_hub tqdm "transformers<4.50" encodec demucs librosa soundfile torchmetrics protobuf spacy==3.7.6 omegaconf
echo INSTALADO
