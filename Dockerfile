FROM rust:1.66-buster AS builder-common
COPY ./src /app/src
COPY ./Cargo.toml /app/
COPY ./Cargo.lock /app/

FROM builder-common AS builder-debug
RUN cd /app && cargo build

FROM builder-common AS builder-release
RUN cd /app && cargo build -r

FROM debian:buster AS common
ARG VERSION
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y curl && \
    rm -rf /var/lib/apt/lists/*
COPY ./Rocket.toml /app/
RUN echo ${VERSION} > /app/version.txt
WORKDIR /app
CMD ["/app/glyph-api"]
HEALTHCHECK --interval=15s --timeout=15s \
    CMD curl --fail http://localhost:8000/v1/healthcheck || exit 1

FROM common AS debug
COPY --from=builder-debug /app/target/debug/glyph-api /app/

FROM common AS release
COPY --from=builder-release /app/target/release/glyph-api /app/
