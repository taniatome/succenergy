# Succenergy AI Coach API — Cloud Run image.
#
# Multi-stage so the toolchain that compiles TypeScript never ships: the
# final image carries the built JavaScript, production dependencies and
# nothing else.

# --- Stage 1: dependencies ---------------------------------------------------
#
# Installed in its own stage so a source-only change reuses this layer
# instead of reinstalling the tree on every build.

FROM node:22-alpine AS deps

WORKDIR /app

# Only the manifests, so the layer is invalidated by a dependency change and
# not by a change to src/.
COPY package.json package-lock.json ./

# `npm ci` rather than `npm install`: it installs exactly the lockfile and
# fails if the two disagree, so a build cannot silently pick up a different
# version than was tested.
RUN npm ci --ignore-scripts

# --- Stage 2: build ----------------------------------------------------------

FROM node:22-alpine AS build

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY package.json package-lock.json tsconfig.json ./
COPY src ./src

RUN npm run build

# Drops devDependencies from the tree that gets copied forward. Re-resolving
# from the lockfile rather than pruning in place, so the result is exactly
# what a production install would give.
RUN npm ci --omit=dev --ignore-scripts

# --- Stage 3: runtime --------------------------------------------------------

FROM node:22-alpine AS runtime

# dumb-init reaps zombies and forwards signals, so the SIGTERM Cloud Run
# sends on shutdown actually reaches Node and the graceful shutdown in
# index.ts runs. Without an init as PID 1, the signal is delivered to a
# process that does not handle it by default.
RUN apk add --no-cache dumb-init

ENV NODE_ENV=production

WORKDIR /app

# The node image ships an unprivileged `node` user. Ownership is set on copy
# rather than with a later chown, which would duplicate the whole tree in an
# extra layer.
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --chown=node:node package.json ./

# Nothing in the container needs to write to it. The container filesystem is
# ephemeral on Cloud Run regardless, but a non-writable app directory means a
# compromised process cannot drop anything next to the code and run it.
USER node

# Documentation only — Cloud Run injects PORT and the app reads it. The value
# here matches Cloud Run's default so `docker run -p 8080:8080` works without
# passing PORT by hand.
ENV PORT=8080
EXPOSE 8080

# Exec form, so Node is the process that receives signals rather than a shell
# sitting between it and the runtime.
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
