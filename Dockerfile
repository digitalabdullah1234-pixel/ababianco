# Bianco: one container serves the website and the API on port 3000.

# ---- Build ----
FROM node:24-bookworm-slim AS build
WORKDIR /app
RUN npm install -g pnpm@10.26.1

COPY . .
RUN pnpm install --frozen-lockfile

# The Stripe publishable key is built into the website, so it is a build argument.
ARG VITE_STRIPE_PUBLISHABLE_KEY=""
ENV VITE_STRIPE_PUBLISHABLE_KEY=${VITE_STRIPE_PUBLISHABLE_KEY}

RUN pnpm run build

# ---- Run ----
FROM node:24-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3000

# The server is bundled into one file, so node_modules are not needed here.
# Keep the same paths as the build stage: the server finds files relative to itself.
COPY --from=build --chown=node:node /app/apps/api-server/dist ./apps/api-server/dist
COPY --from=build --chown=node:node /app/apps/bianco-restaurant/dist/public ./apps/bianco-restaurant/dist/public
COPY --from=build --chown=node:node /app/lib/db/migrations ./lib/db/migrations

USER node
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/api/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "--enable-source-maps", "apps/api-server/dist/index.mjs"]
