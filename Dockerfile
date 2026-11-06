
# Monolith: Vite frontend + Express API

# --- Stage 1: Build the frontend ---
FROM node:22-bookworm-slim AS frontend-build

WORKDIR /app/frontend

COPY frontend/package.json frontend/package-lock.json ./
RUN npm install --no-audit --no-fund --legacy-peer-deps

COPY frontend/ ./

ENV VITE_API_URL=""

ARG VITE_CLERK_PUBLISHABLE_KEY
ENV VITE_CLERK_PUBLISHABLE_KEY=$VITE_CLERK_PUBLISHABLE_KEY

RUN npm run build


# --- Stage 2: Build the backend ---
FROM node:22-bookworm-slim AS backend-build

WORKDIR /app

COPY backend/package.json backend/package-lock.json ./
RUN npm install --no-audit --no-fund

# Copy backend source into /app
COPY backend/ ./

# Generate dist/ from src/
RUN npm run build


# --- Stage 3: Production ---
FROM node:22-bookworm-slim AS production

WORKDIR /app

ENV NODE_ENV=production

# Backend compiled/copied files
COPY --from=backend-build /app/dist ./dist

# Backend dependencies
COPY --from=backend-build /app/node_modules ./node_modules

# Backend package.json
COPY --from=backend-build /app/package.json ./package.json

# Frontend static files
COPY --from=frontend-build /app/frontend/dist ./frontend/dist

EXPOSE 5000

CMD ["node", "dist/index.js"]
