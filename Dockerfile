# Stage 1: Build compilation workspace layer
FROM node:20-alpine AS build-env
WORKDIR /app

# Copy dependency graphs and install frozen lockfile frames
COPY package*.json ./
RUN npm ci

# Evaporate compilation sources down to distribution structures
COPY tsconfig.json ./
COPY src/ ./src
RUN npm run build

# Stage 2: Hardened lean target production runtime layer
FROM node:20-alpine AS production-runtime
WORKDIR /app
ENV NODE_ENV=production

# Install only active execution dependencies to minimize surface risk boundaries
COPY package*.json ./
RUN npm ci --only=production

# Pull forward frozen compiled production assets from the builder layer
COPY --from=build-env /app/dist ./dist

# Restrict authorization context permissions to a non-privileged root safe user account
USER node

# Execute the application engine matrix loop
CMD ["node", "dist/index.js"]
