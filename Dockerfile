FROM python:3.11-slim as base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    ffmpeg \
    pkg-config \
    libcairo2-dev \
    libgirepository1.0-dev \
    portaudio19-dev \
    python3-gst-1.0 \
    cmake && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir poetry && \
    poetry --version

ENV PATH="/root/.local/bin:$PATH"

ARG GITHUB_PAT
RUN git clone https://$GITHUB_PAT@github.com/untitledaiproject/UntitledAI.git

WORKDIR /UntitledAI

RUN poetry config virtualenvs.create false && \
    poetry install -vvv

RUN poetry run python -c "print('Poetry and project dependencies are installed correctly.')"

ARG CONFIG_FILE
ENV CONFIG_FILE=${CONFIG_FILE}

# Create entrypoint script
RUN echo '#!/bin/sh\n\
if [ -z "$CONFIG_FILE" ]; then\n\
  poetry run untitledai serve --host 0.0.0.0\n\
else\n\
  poetry run untitledai serve --host 0.0.0.0 --config "$CONFIG_FILE"\n\
fi' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]