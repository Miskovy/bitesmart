# Stage 1: Build the application
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies) needed for the build
RUN npm install

# Copy source code and config files
COPY tsconfig.json ./
COPY src/ ./src/
COPY drizzle/ ./drizzle/

# Build the TypeScript code
RUN npm run build

# Prune devDependencies to keep only production dependencies
# This creates a lean node_modules folder for the next stage
RUN npm prune --omit=dev

# Stage 2: Create the production image
FROM node:20-alpine AS production

# Set Node environment to production
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Switch to the less privileged "node" user automatically created in the node image
# This is a best practice for security
USER node

# Copy package.json
COPY --chown=node:node package*.json ./

# Copy the pruned node_modules from the builder stage
COPY --chown=node:node --from=builder /app/node_modules ./node_modules

# Copy the compiled output from the builder stage
COPY --chown=node:node --from=builder /app/dist ./dist

# Copy the drizzle database migrations (in case you need to run them on startup)
COPY --chown=node:node --from=builder /app/drizzle ./drizzle

# Expose the port your app runs on
EXPOSE 3000

# Start the application
# Using standard node execution here based on your tsconfig (src/server.ts -> dist/server.js)
CMD ["node", "dist/server.js"]
