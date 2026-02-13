FROM docker.io/oven/bun:latest

WORKDIR /app
COPY . .

RUN bun install & bun run ./index.ts
