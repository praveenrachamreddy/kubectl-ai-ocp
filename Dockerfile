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


# Set ENV for OpenAI compatibility (using your mistral endpoint)
ENV OPENAI_API_KEY=dummy_key
ENV OPENAI_API_BASE=http://mistral-7b-praveen-datascience.apps.ocp4.imss.work
ENV OPENAI_MODEL_NAME=mistral



# Use OpenShift-friendly user
USER 1001

# Expose both the web UI port and, optionally, the agent’s TUI port
EXPOSE 8888

# Start kubectl-ai in web mode
# CMD ["kubectl-ai", "--ui-type", "web", "--ui-listen-address", "0.0.0.0:8888", "--llm-provider", "openai", "--model", "gpt-4.1", "--skip-permissions"]
# Start kubectl-ai using OpenAI provider with custom endpoint
CMD ["kubectl-ai", "--llm-provider", "openai", "--model", "mistral", "--ui-type", "web", "--ui-listen-address", "0.0.0.0:8888", "--skip-permissions"]




