# Use the base image from the devcontainer.json file
FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bullseye

# watchman latest release version. Could be done auto, but that needs a script. See https://github.com/facebook/watchman/issues/982
ARG WM_VERSION=v2024.04.15.00

# install watchman
RUN wget https://github.com/facebook/watchman/releases/download/$WM_VERSION/watchman-$WM_VERSION-linux.zip && \
  unzip watchman-$WM_VERSION-linux.zip && \
  cd watchman-$WM_VERSION-linux && \
  mkdir -p /usr/local/{bin,lib} /usr/local/var/run/watchman && \
  cp bin/* /usr/local/bin && \
  cp lib/* /usr/local/lib && \
  chmod 755 /usr/local/bin/watchman && \
  chmod 2777 /usr/local/var/run/watchman && \
  cd .. && \
  rm -fr watchman-$WM_VERSION-linux.zip watchman-$WM_VERSION-linux
