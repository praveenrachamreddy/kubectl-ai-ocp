FROM registry.access.redhat.com/ubi9/ubi

# Install prerequisites
RUN yum -y update && \
    yum -y install --allowerasing curl tar gzip python3 && \
    yum clean all

# Install kubectl (optional, if needed)
RUN curl -LO "https://dl.k8s.io/release/v1.33.3/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Download and install kubectl-ai latest binary
RUN KAI_VER=$(curl -s https://api.github.com/repos/GoogleCloudPlatform/kubectl-ai/releases/latest | \
                 grep tag_name | cut -d '"' -f 4) && \
    curl -Lo kubectl-ai.tar.gz \
      https://github.com/GoogleCloudPlatform/kubectl-ai/releases/download/${KAI_VER}/kubectl-ai_Linux_x86_64.tar.gz && \
    tar -xzf kubectl-ai.tar.gz && \
    chmod +x kubectl-ai && mv kubectl-ai /usr/local/bin/ && \
    rm kubectl-ai.tar.gz

# Add non-root user
RUN useradd -u 1001 -r -m appuser
USER appuser

WORKDIR /home/appuser

ENV LLM_PROVIDER=gemini \
    OPENAI_MODEL_NAME=gemini-2.5-pro \
    UI_TYPE=web \
    UI_PORT=8888

ENTRYPOINT ["kubectl-ai"]
CMD ["--llm-provider", "gemini", \
     "--model", "gemini-2.5-pro", \
     "--ui-type", "web", \
     "--ui-listen-address", "0.0.0.0:8888"]
