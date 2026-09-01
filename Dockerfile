FROM registry.k8s.io/kubectl:v1.37.0 AS kubectl

FROM debian:trixie-slim

COPY --from=kubectl /bin/kubectl /usr/local/bin/kubectl

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg2 \
    python3 && \
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
    rm -rf /usr/lib/google-cloud-sdk/platform/bundled*python* \
           /usr/lib/google-cloud-sdk/platform/bq \
           /usr/lib/google-cloud-sdk/platform/gsutil* \
           /usr/lib/google-cloud-sdk/bin/bq \
           /usr/lib/google-cloud-sdk/lib/surface/alpha \
           /usr/lib/google-cloud-sdk/lib/surface/beta \
           /usr/lib/google-cloud-sdk/lib/third_party/botocore \
           /usr/lib/google-cloud-sdk/lib/third_party/kubernetes && \
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
