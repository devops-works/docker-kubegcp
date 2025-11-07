FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg2 \
    python3 && \
    curl -LO "https://dl.k8s.io/release/v1.33.5/bin/linux/amd64/kubectl" && \
    curl -LO "https://dl.k8s.io/release/v1.33.5/bin/linux/amd64/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl kubectl.sha256 && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
      | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      google-cloud-cli \
      google-cloud-cli-gke-gcloud-auth-plugin && \
    apt-get remove -y gnupg2 curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /usr/lib/google-cloud-sdk/platform/bundled-python* && \
    rm -rf /usr/lib/google-cloud-sdk/lib/surface/alpha \
           /usr/lib/google-cloud-sdk/lib/surface/beta \
           /usr/lib/google-cloud-sdk/platform/gsutil* && \
    rm -rf /var/lib/apt/lists/* \
           /var/cache/apt/archives/* \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/locale/* \
           /usr/share/info/* \
           /root/.cache/* \
           /tmp/*

ENV CLOUDSDK_PYTHON=python3
ENV KUBECONFIG=/.kube/config
ENV CLOUDSDK_CONFIG=/.config/gcloud
WORKDIR /

ENTRYPOINT ["kubectl"]
