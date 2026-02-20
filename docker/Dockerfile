# syntax=docker/dockerfile:1

# Build stage compiles/bundles application assets.
FROM alpine:3.19 AS builder
WORKDIR /workspace

# TODO: Replace with real build commands for your language/runtime.
RUN echo "placeholder build step" > artifact.txt

# Runtime stage keeps image slim and non-root.
FROM alpine:3.19
RUN adduser -D -u 10001 appuser
WORKDIR /app
COPY --from=builder /workspace/artifact.txt ./artifact.txt

USER appuser
EXPOSE 8080

# TODO: Replace with real startup command (binary, java -jar, etc.).
CMD ["/bin/sh", "-c", "echo TODO: start application && tail -f /dev/null"]
