FROM ipfs/kubo:latest AS kubo_binary
FROM golang:latest AS go_builder

WORKDIR /app

COPY ./go.mod ./go.sum ./main.go /app/

RUN go build -o proxy_app

FROM busybox:glibc

ENV PORT="3031"
ENV ENV="production"
ENV IPFS_GATEWAY_HOST="http://127.0.0.1:8080"

WORKDIR /app

COPY --from=kubo_binary /usr/local/bin/ipfs /usr/local/bin/ipfs
COPY --from=go_builder /app/proxy_app /app/proxy_app

COPY ./scripts/entrypoint.sh /app/

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
