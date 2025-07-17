FROM registry.access.redhat.com/ubi9/ubi

# Add user
RUN useradd -r -u 1001 -g root default

# Install dependencies
RUN yum -y update && \
    yum -y install --allowerasing python3 python3-pip git curl unzip && \
    yum clean all

# Install kubectl
RUN KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt || echo "v1.31.0") && \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install oc (OpenShift CLI)
RUN curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz && \
    tar -xzf oc.tar.gz && \
    mv oc /usr/local/bin/ && \
    chmod +x /usr/local/bin/oc && \
    rm oc.tar.gz

# Install kubectl-ai
RUN curl -sSL https://raw.githubusercontent.com/GoogleCloudPlatform/kubectl-ai/main/install.sh | bash && \
    mv ~/.kubectl-ai/bin/kubectl-ai /usr/local/bin/ && \
    rm -rf ~/.kubectl-ai

# Install Flask and OpenAI
RUN pip3 install --no-cache-dir flask openai

# Create workdir
WORKDIR /app

# Copy Flask API file
COPY app.py .

# Set environment variable for OpenAI Key (to be overridden)
ENV OPENAI_API_KEY=""

# Use OpenShift-friendly user
USER 1001

# Expose Flask port
EXPOSE 5000

# Command to run the Flask app
CMD ["python3", "app.py"]
