# Use ARM64 Ubuntu base image
FROM --platform=linux/arm64 ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTORCH_ENABLE_MPS_FALLBACK=1
ENV PYTORCH_MPS_ENABLE_IF_AVAILABLE=1

# Install system dependencies  
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \ 
    git \
    wget \
    libgl1 \
    libreoffice \
    fonts-noto-cjk \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    fontconfig \
    libglib2.0-0 \
    libxrender1 \
    libsm6 \
    libxext6 \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Create and activate virtual environment
RUN python3 -m venv /opt/mineru_venv
ENV PATH="/opt/mineru_venv/bin:$PATH"

# Copy requirements file
COPY requirements.txt /app/MinerU/requirements.txt

# Install Python dependencies
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir \
    torch \
    torchvision \
    torchaudio \
    numpy \
    Pillow \
    opencv-python-headless \
    transformers \
    huggingface_hub && \
    pip3 install --no-cache-dir -r /app/MinerU/requirements.txt

# Create necessary directories
RUN mkdir -p /app/MinerU/data/{input,output,logs}

# Set working directory
WORKDIR /app/MinerU

# Copy only necessary files
COPY scripts/batch_process.py /app/MinerU/scripts/
COPY magic-pdf.template.json /app/MinerU/magic-pdf.json

# Download models and configure for MPS
# Install huggingface_hub
RUN /bin/bash -c "source /opt/mineru_venv/bin/activate && \
    pip install huggingface_hub"

# Download the model download script
RUN wget https://github.com/opendatalab/MinerU/raw/master/scripts/download_models_hf.py -O /opt/download_models_hf.py

# Run the model download script
RUN /bin/bash -c "source /opt/mineru_venv/bin/activate && \
    python /opt/download_models_hf.py"

# Replace 'cpu' with 'mps' in the config for Apple Silicon
RUN sed -i 's|cpu|mps|g' /app/MinerU/magic-pdf.json

# Keep container running
CMD ["tail", "-f", "/dev/null"] 