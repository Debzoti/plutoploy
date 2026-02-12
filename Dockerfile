FROM docker.io/oven/bun:latest

WORKDIR /app

# Install deps first for better layer caching
COPY package.json bun.lock .
RUN bun install

# Copy the rest of the source
COPY . .

CMD ["bun", "run", "./index.ts"]
