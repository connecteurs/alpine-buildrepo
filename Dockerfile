FROM ghcr.io/connecteurs/alpine

RUN apk add --no-cache \
  alpine-conf \
  alpine-sdk \
  aports-build \
  sudo

COPY --from=registry.gitlab.com/les-connecteurs/docker/directory-index \
  /bin/directory_index \
  /bin/directory_index

RUN adduser -D builder \
  && addgroup builder abuild \
  && echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN install -d -o builder -g builder /home/builder/.abuild/

COPY sudo.conf /etc/
RUN chmod 440 /etc/sudo.conf

USER builder
WORKDIR /home/builder
COPY entrypoint.sh .
RUN sudo chmod +x entrypoint.sh
RUN mkdir keys packages

VOLUME /home/builder/keys
VOLUME /home/builder/packages

ENTRYPOINT ["./entrypoint.sh"]
