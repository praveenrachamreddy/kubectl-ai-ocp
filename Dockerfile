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

# Install Python libraries
RUN pip3 install --no-cache-dir flask openai

# Set working directory
WORKDIR /app

# ENV VARS for OpenAI compatibility using internal URL
ENV OPENAI_API_KEY=dummy-key
ENV OPENAI_API_BASE=http://istio-ingressgateway.istio-system.svc.cluster.local:8080/v1
ENV OPENAI_MODEL_NAME=mistral
ENV OPENAI_SKIP_SSL_VERIFICATION=true

# Use OpenShift-friendly user
USER 1001

# Expose port for web UI
EXPOSE 8888

# Command to run
CMD ["kubectl-ai", "--llm-provider", "openai", "--model", "mistral", "--ui-type", "web", "--ui-listen-address", "0.0.0.0:8888", "--skip-permissions"]
