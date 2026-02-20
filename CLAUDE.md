# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Blockscout fork** customized for the **Vana network** (VANA coin, Chain ID 1480). Blockscout is an Elixir/Phoenix blockchain explorer for EVM-compatible chains. The upstream repo is `blockscout/blockscout`.

**Version**: 9.3.2 | **Elixir**: ~> 1.19 | **Erlang**: 27.3 | **Phoenix**: 1.6.16

## Branch Strategy

- `master` — default branch (upstream base)
- `mainnet` — production deployment for Vana mainnet
- `testnet` / `testnet-v*` — testnet deployments
- `upstream/*` — upstream blockscout branches
- CI only builds from `mainnet` or `testnet*` branches

## Build & Development Commands

```bash
# Install dependencies
mix deps.get

# Compile
mix compile

# Run dev server (port defaults to 4000)
mix phx.server

# Interactive shell
iex -S mix

# Run all tests
mix test

# Run tests for a specific app
mix test --only apps/explorer
mix test --only apps/block_scout_web
mix test --only apps/indexer --no-start   # --no-start prevents supervision tree startup

# Run a single test file
mix test apps/explorer/test/explorer/chain_test.exs

# Run a single test by line number
mix test apps/explorer/test/explorer/chain_test.exs:42

# Database operations (default Explorer.Repo)
mix ecto.create
mix ecto.migrate
mix ecto.rollback

# Account database (separate repo)
mix ecto.create -r Explorer.Repo.Account
mix ecto.migrate -r Explorer.Repo.Account

# Code quality
mix credo
mix dialyzer
mix sobelow
mix format --check-formatted

# Production release
MIX_ENV=prod mix release blockscout
```

## Architecture

### Umbrella Apps (`apps/`)

| App | Purpose |
|-----|---------|
| `explorer` | Core data layer — Ecto schemas, DB queries, caching (ConCache + Redis), chain context modules. The `Explorer.Chain` module (~141KB) is the central context. |
| `block_scout_web` | Phoenix web layer — REST API v1/v2, GraphQL (Absinthe), Etherscan-compatible API, WebSocket channels, rate limiting. |
| `indexer` | Blockchain data fetcher — block/tx/receipt/log fetchers using `BufferedTask` for batched processing. Runs in realtime and catch-up modes. |
| `ethereum_jsonrpc` | JSON-RPC client abstraction — supports Geth, Erigon, Nethermind variants via HTTP and WebSocket. |
| `utils` | Shared utilities — HTTP helpers, compile/runtime env helpers. |
| `nft_media_handler` | NFT media processing — S3 storage, image processing with OpenCV/Evision. |

### Runtime Modes

Controlled by `Explorer.mode()` (set via env vars `DISABLE_INDEXER`, `DISABLE_API`, `DISABLE_WEBAPP`):
- `:all` — API + Indexer (default)
- `:api` — API web server only
- `:indexer` — Indexer only

CI builds separate Docker images for `indexer` and `api` modes.

### Key Configuration

- `config/runtime.exs` — Main runtime config, reads hundreds of env vars
- `config/config_helper.exs` — Helper for parsing env vars, manages conditional repos
- `init.sh` — Local dev environment setup (sets env vars and runs `mix phx.server`)
- `docker-compose/envs/` — Docker environment files per service

### Essential Environment Variables

```bash
DATABASE_URL=postgresql://user:pass@host:5432/dbname
ETHEREUM_JSONRPC_HTTP_URL=https://rpc-endpoint
ETHEREUM_JSONRPC_WS_URL=wss://rpc-endpoint
ETHEREUM_JSONRPC_TRACE_URL=https://rpc-endpoint
CHAIN_ID=1480
COIN=VANA
COIN_NAME=VANA
NETWORK=Vana
SECRET_KEY_BASE=<phoenix-secret>
```

### Docker

```bash
# Build and run all services
cd docker-compose && docker-compose up --build

# Production build via Makefile
cd docker && make build

# Dockerfile: docker/Dockerfile (multi-stage: deps → compile → release)
```

The CI workflow (`.github/workflows/build-push.yml`) builds and pushes to an OVH private registry, triggered manually with a version input.

## Coding Conventions (from CONTRIBUTING.md)

### Naming
- Use full names, not abbreviations: `transaction` not `tx`, `block_number` not `block_num`, `address_hash` not `address`
- API v2 response fields: hashes end in `_hash`, aggregations use `_count`/`_sum` suffix, indices are numbers

### Configuration
- **Strongly prefer runtime configuration** over compile-time
- Use `Utils.RuntimeEnvHelper` with pattern matching instead of `Utils.CompileTimeEnvHelper` with `if @chain_type ==`
- Only use `CompileTimeEnvHelper` when modifying existing database schemas (Ecto schemas are compile-time)
- New DB tables: create a new `Ecto.Repo` module and add to `config/config_helper.exs` conditionally
- Feature-specific API endpoints: use `chain_scope` macro or `CheckFeature` plug

### Commits
- Follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `doc:`, `perf:`, `refactor:`
- One logical change per commit
- Bug fixes should include regression tests in a separate commit

### Pre-commit
- gitleaks is configured (`.pre-commit-config.yaml`) to prevent secret commits
