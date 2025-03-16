FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /nquake

# Install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
  && apt-get install -y curl unzip wget dos2unix gettext dnsutils qstat \
  && rm -rf /var/lib/apt/lists/*

# Copy files
COPY files .

RUN wget https://github.com/QW-Group/ktx/releases/download/1.45/qwprogs-linux-aarch64.zip && unzip qwprogs-linux-aarch64.zip
RUN wget https://github.com/QW-Group/mvdsv/releases/download/1.11/mvdsv_linux_arm64

RUN mv mvdsv_linux_arm64 /nquake/mvdsv
RUN mv qwprogs.so /nquake/ktx/qwprogs.so

COPY scripts/healthcheck.sh /healthcheck.sh
COPY scripts/entrypoint.sh /entrypoint.sh

# Cleanup
RUN find . -type f -print0 | xargs -0 dos2unix -q \
  && find . -type f -exec chmod -f 644 "{}" \; \
  && find . -type d -exec chmod -f 755 "{}" \; \
  && chmod +x mvdsv ktx/mvdfinish.qws ktx/qwprogs.so

VOLUME /nquake/logs
VOLUME /nquake/media
VOLUME /nquake/demos

ENTRYPOINT ["/entrypoint.sh"]
