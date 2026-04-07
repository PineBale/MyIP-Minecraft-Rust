FROM ghcr.io/rust-lang/rust:1-alpine3.22 AS builder

RUN apk add musl-dev
RUN apk add make
RUN apk add build-base
RUN apk add openssl-dev
RUN apk add perl
RUN rustup component add rustfmt
RUN rustup component add clippy
RUN cargo install cargo-tarpaulin --features vendored-openssl

WORKDIR /usr/src/app

COPY . .

RUN make all


FROM alpine:3.22

RUN apk add --no-cache tini

COPY --from=builder /usr/src/app/target/release/minecraft_myip /usr/local/bin/minecraft_myip

EXPOSE 25565

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["minecraft_myip", "0.0.0.0:25565"]
