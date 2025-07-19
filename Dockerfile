FROM registry.access.redhat.com/ubi9/ubi

# Add user
RUN useradd -r -u 1001 -g root default

# Install dependencies
RUN yum -y update && \
    yum -y install --allowerasing python3 python3-pip git curl unzip && \
    yum clean all

# Install kubectl (using specific version v1.33.3)
RUN curl -LO "https://dl.k8s.io/release/v1.33.3/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install oc (OpenShift CLI)
RUN curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz && \
    tar -xzf oc.tar.gz && \
    mv oc /usr/local/bin/ && \
    chmod +x /usr/local/bin/oc && \
    rm oc.tar.gz

# Install kubectl-ai (manual installation to avoid sudo)
RUN curl -LO https://github.com/GoogleCloudPlatform/kubectl-ai/releases/download/v0.0.17/kubectl-ai_Linux_x86_64.tar.gz && \
    tar -xzf kubectl-ai_Linux_x86_64.tar.gz && \
    mv kubectl-ai /usr/local/bin/ && \
    chmod +x /usr/local/bin/kubectl-ai && \
    rm kubectl-ai_Linux_x86_64.tar.gz

# Install Flask and OpenAI
RUN pip3 install --no-cache-dir flask openai

# Create workdir
WORKDIR /app


# Set environment variable for OpenAI Key (to be overridden)
ENV OPENAI_API_KEY=""

# Copy custom LLM config
COPY custom-llm.yaml /etc/kubectl-ai/custom-llm.yaml

# Use OpenShift-friendly user
USER 1001

# Expose both the web UI port and, optionally, the agent’s TUI port
EXPOSE 8888

# Start kubectl-ai in web mode
# CMD ["kubectl-ai", "--ui-type", "web", "--ui-listen-address", "0.0.0.0:8888", "--llm-provider", "openai", "--model", "gpt-4.1", "--skip-permissions"]

CMD ["kubectl-ai", "--llm-provider", "mistral", "--model", "mistral-7b-instruct", "--custom-llm-config", "/etc/kubectl-ai/custom-llm.yaml", "--ui-type", "web", "--ui-listen-address", "0.0.0.0:8888", "--skip-permissions"]



