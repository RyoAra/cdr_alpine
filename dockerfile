FROM alpine:latest

RUN apk --no-cache --update add alpine-sdk bash libstdc++ libc6-compat npm libx11-dev libxkbfile-dev libsecret-dev && \
    npm config set unsafe-perm true && \
    npm install -g code-server

# ENTRYPOINT ["code-server", "--auth", "password", "--bind-addr", "0.0.0.0:8080"]
# ENTRYPOINT ["code-server", "--auth", "password"]
# ENTRYPOINT ["--auth", "none"]
ENTRYPOINT [""]
CMD [""]