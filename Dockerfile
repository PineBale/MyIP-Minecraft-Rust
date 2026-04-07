FROM ghcr.io/rust-lang/rust:1-alpine3.22 AS builder

RUN apk add musl-dev
RUN apk add make

WORKDIR /usr/src/app

COPY . .

RUN make build


FROM alpine:3.22

RUN apk add --no-cache tini

COPY --from=builder /usr/src/app/target/release/minecraft_myip /usr/local/bin/minecraft_myip

EXPOSE 25565

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["minecraft_myip", "0.0.0.0:25565"]
