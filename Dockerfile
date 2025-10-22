# ===========================
# BUILD STAGE
# ===========================
FROM node:22-bookworm-slim AS build
WORKDIR /app

# ✅ Install git (required by pnpm to fetch some packages)
RUN apt-get update && apt-get install -y git \
  && rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate

# Copy lockfile and package.json first for better caching
COPY package.json pnpm-lock.yaml* ./

# Fetch packages offline
RUN pnpm fetch

# Copy rest of the code
COPY . .

# Install all dependencies including devDependencies
RUN pnpm install --offline --frozen-lockfile

# Build the app
RUN NODE_OPTIONS=--max-old-space-size=4096 pnpm run build

# ===========================
# PRODUCTION STAGE
# ===========================
FROM node:22-bookworm-slim AS production
WORKDIR /app

# Install only git (needed for some scripts)
RUN apt-get update && apt-get install -y git \
  && rm -rf /var/lib/apt/lists/*

# Copy build and prod dependencies from build stage
COPY --from=build /app/build /app/build
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/package.json /app/package.json

# Remove devDependencies for production
RUN pnpm prune --prod --ignore-scripts

# ===========================
# DEVELOPMENT STAGE
# ===========================
FROM build AS development
WORKDIR /app

# ✅ Keep devDependencies in development to run remix dev server
RUN mkdir -p /app/run

# Expose port for Vite
EXPOSE 5173

# Default command for dev stage
CMD ["pnpm", "run", "dev", "--host", "0.0.0.0"]
