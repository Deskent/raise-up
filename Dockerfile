# syntax=docker/dockerfile:1

FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack enable && corepack prepare pnpm@11.20.0 --activate


# ─────────────────────────────────────────────
# Dependencies
# ─────────────────────────────────────────────
FROM base AS deps

WORKDIR /src

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile


# ─────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────
FROM base AS builder

WORKDIR /src

COPY --from=deps /src/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

RUN pnpm build


# ─────────────────────────────────────────────
# Production
# ─────────────────────────────────────────────
FROM node:22-alpine AS runner

WORKDIR /src

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

# Next.js standalone output
COPY --from=builder --chown=nextjs:nodejs /src/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /src/.next/static ./.next/static

# Если используется public/
# COPY --from=builder --chown=nextjs:nodejs /src/public ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME=0.0.0.0

CMD ["node", "server.js"]
