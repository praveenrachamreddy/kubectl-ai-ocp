FROM registry.access.redhat.com/ubi9/ubi

# Add user
RUN useradd -r -u 1001 -g root default

# Install dependencies
RUN yum -y update && \
    yum -y install --allowerasing python3 python3-pip git curl unzip && \
    yum clean all

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.33.3/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install oc CLI
RUN curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz && \
    tar -xzf oc.tar.gz && mv oc /usr/local/bin/ && chmod +x /usr/local/bin/oc && rm oc.tar.gz

# Install kubectl-ai
RUN curl -LO https://github.com/GoogleCloudPlatform/kubectl-ai/releases/download/v0.0.17/kubectl-ai_Linux_x86_64.tar.gz && \
    tar -xzf kubectl-ai_Linux_x86_64.tar.gz && \
    mv kubectl-ai /usr/local/bin/ && \
    chmod +x /usr/local/bin/kubectl-ai && \
    rm kubectl-ai_Linux_x86_64.tar.gz

# Install Python libraries (for LLM backends if needed)
RUN pip3 install --no-cache-dir flask openai google-generativeai

# Set working directory
WORKDIR /app

# ARGs can be overridden at build time if needed
ARG LLM_PROVIDER=gemini
ARG OPENAI_MODEL_NAME=gemini-2.5-pro
ARG UI_TYPE=web
ARG UI_PORT=8888

# Set ENV vars for runtime override
ENV LLM_PROVIDER=${LLM_PROVIDER}
ENV OPENAI_MODEL_NAME=${OPENAI_MODEL_NAME}
ENV OPENAI_API_KEY=dummy_key
ENV OPENAI_API_BASE=https://api.openai.com/v1
ENV UI_TYPE=${UI_TYPE}
ENV UI_PORT=${UI_PORT}
ENV GEMINI_API_KEY=''

# Use non-root user
USER 1001

# Expose port
EXPOSE ${UI_PORT}

# Corrected CMD block — no unterminated string
CMD sh -c "kubectl-ai \
  --llm-provider $LLM_PROVIDER \
  --model $OPENAI_MODEL_NAME \
  --ui-type $UI_TYPE \
  --ui-listen-address 0.0.0.0:$UI_PORT \
  --skip-permissions"
