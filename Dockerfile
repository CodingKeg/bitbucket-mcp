FROM node:22-alpine as builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files and install dependencies
COPY package*.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN pnpm run build

# Production stage
FROM node:22-alpine as production

WORKDIR /app

# Copy package files and install production dependencies only
COPY package*.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

# Copy build artifacts from builder stage
COPY --from=builder /app/dist ./dist

# Create logs directory
RUN mkdir -p logs

# Set execution permissions
RUN chmod +x ./dist/index.js

# Environment variables
ENV NODE_ENV=production

ENV PORT=3000

# Expose port
EXPOSE 3000

# Run the application
CMD ["node", "dist/index.js"] 