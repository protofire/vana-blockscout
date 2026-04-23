# Release Changes: v9.3.2 → v10.2.6

**Rollout branch:** `testnet-rollout-10.2.6`
**Base branch:** `testnet`
**Upstream tag:** `v10.2.6`
**Previous base:** `v9.3.2`
**Upstream commits merged:** 185

---

## New ENV Variables

| Variable | Default | Description | App | Since |
|---|---|---|---|---|
| `MIGRATION_DELETE_ZERO_VALUE_INTERNAL_TRANSACTIONS_STORAGE_PERIOD` | `30d` | Storage period for recent zero-value calls (time format, replaces `_DAYS` var) | Indexer | v9.3.3 |
| `BLOCK_MINER_GETS_BURNT_FEES` | `false` | If true, burnt fees are added to block miner profit and displayed as zero | API | v10.0.0 |
| `UNIVERSAL_PROXY_CONFIG` | (empty) | JSON-encoded universal proxy config. Cannot be set together with `UNIVERSAL_PROXY_CONFIG_URL` | API | v10.0.0 |
| `MIGRATION_EMPTY_INTERNAL_TRANSACTIONS_DATA_BATCH_SIZE` | `1000` | Batch size for clearing internal transactions data in migration | Indexer | v10.0.0 |
| `MIGRATION_EMPTY_INTERNAL_TRANSACTIONS_DATA_CONCURRENCY` | `1` | Concurrency for clearing internal transactions data in migration | Indexer | v10.0.0 |
| `MIGRATION_EMPTY_INTERNAL_TRANSACTIONS_DATA_TIMEOUT` | `0` | Timeout between clearing internal transaction data batches | Indexer | v10.0.0 |
| `CACHE_PENDING_OPERATIONS_COUNT_PERIOD` | `5m` | Interval for pending operations count task. **Replaces `CACHE_PBO_COUNT_PERIOD`** (default was `20m`) | API, Indexer | v10.0.0 |
| `ACCOUNT_DYNAMIC_ENV_ID` | (empty) | Dynamic Environment ID for Dynamic auth provider | API | v10.0.0 |
| `INDEXER_OPTIMISM_L1_BATCH_EIGENDA_BLOBS_API_URL` | (empty) | URL for DA indexer supporting EigenDA layer | Indexer | v10.0.0 |
| `INDEXER_OPTIMISM_L1_BATCH_EIGENDA_PROXY_BASE_URL` | (empty) | URL for EigenDA proxy node | Indexer | v10.0.0 |
| `INDEXER_ARBITRUM_MESSAGES_TRACKING_FAILURE_THRESHOLD` | `10m` | Threshold before L1 message tracking task is marked failed | Indexer | v10.0.0 |
| `INDEXER_ARBITRUM_MISSED_MESSAGE_IDS_RANGE` | `10000` | Size of message ID range when discovering missed L1→L2 messages | Indexer | v10.0.0 |
| `INDEXER_CURRENT_TOKEN_BALANCES_BATCH_SIZE` | `100` | Batch size for current token balances fetcher | Indexer | v10.0.0 |
| `INDEXER_CURRENT_TOKEN_BALANCES_CONCURRENCY` | `10` | Concurrency for current token balances fetcher | Indexer | v10.0.0 |
| `ACCOUNT_SENDGRID_OTP_TEMPLATE` | (empty) | Sendgrid email OTP template for login with email | API | v10.1.0 |
| `ACCOUNT_KEYCLOAK_DOMAIN` | (empty) | Domain for Keycloak auth provider | API | v10.1.0 |
| `ACCOUNT_KEYCLOAK_REALM` | (empty) | Realm for Keycloak | API | v10.1.0 |
| `ACCOUNT_KEYCLOAK_CLIENT_ID` | (empty) | Keycloak client ID | API | v10.1.0 |
| `ACCOUNT_KEYCLOAK_CLIENT_SECRET` | (empty) | Keycloak client secret | API | v10.1.0 |
| `ACCOUNT_KEYCLOAK_EMAIL_WEBHOOK_URL` | (empty) | URL where new email users are reported (Keycloak) | API | v10.1.0 |
| `ETHEREUM_JSONRPC_RECEIPTS_BY_BLOCK` | `false` | If true, fetch tx receipts by block instead of per-transaction | API, Indexer | v10.2.0 |
| `ETHEREUM_JSONRPC_MAX_RECEIPTS_BY_BLOCK` | `1000` | Max transactions per block before falling back to per-transaction receipts | API, Indexer | v10.2.0 |
| `INDEXER_TOKEN_TRANSFER_BLOCK_CONSENSUS_SANITIZER_INTERVAL` | `20m` | Interval for token transfer block consensus sanitizer | Indexer | v10.2.2 |

### New ENV Variables (from config diff, not in CHANGELOG)

| Variable | Default | Description | App |
|---|---|---|---|
| `API_DISABLE_CONTRACT_CREATION_INTERNAL_TRANSACTION_ASSOCIATION` | (unset/false) | Disables association of contract creation with internal transactions | API, Indexer |
| `INDEXER_FETCHER_INIT_DELAY` | `10m` | Delay before indexer fetchers begin initial stream | Indexer |
| `INDEXER_ARCHIVAL_TOKEN_BALANCES_BATCH_SIZE` | `100` | **Renames** `INDEXER_TOKEN_BALANCES_BATCH_SIZE` — historical token balance fetcher batch size | Indexer |
| `INDEXER_ARCHIVAL_TOKEN_BALANCES_CONCURRENCY` | `10` | **Renames** `INDEXER_TOKEN_BALANCES_CONCURRENCY` | Indexer |
| `INDEXER_ARCHIVAL_TOKEN_BALANCES_MAX_REFETCH_INTERVAL` | `168h` | **Renames** `INDEXER_TOKEN_BALANCES_MAX_REFETCH_INTERVAL` | Indexer |
| `INDEXER_ARCHIVAL_TOKEN_BALANCES_EXPONENTIAL_TIMEOUT_COEFF` | `100` | **Renames** `INDEXER_TOKEN_BALANCES_EXPONENTIAL_TIMEOUT_COEFF` | Indexer |
| `INDEXER_DISABLE_ARCHIVAL_TOKEN_BALANCES_FETCHER` | (unset) | Disables the historical (archival) token balances fetcher supervisor | Indexer |
| `MICROSERVICE_BENS_PROTOCOLS` | (empty) | Comma-separated list of BENS protocols to use | API |

---

## Deprecated ENV Variables

| Variable | Replacement | Default | Deprecated in |
|---|---|---|---|
| `CACHE_PBO_COUNT_PERIOD` | `CACHE_PENDING_OPERATIONS_COUNT_PERIOD` | `20m` (old) → `5m` (new default) | v10.0.0 |
| `MIGRATION_DELETE_ZERO_VALUE_INTERNAL_TRANSACTIONS_STORAGE_PERIOD_DAYS` | `MIGRATION_DELETE_ZERO_VALUE_INTERNAL_TRANSACTIONS_STORAGE_PERIOD` | `30` days → `30d` time string | v9.3.3 |
| `INDEXER_TOKEN_BALANCES_BATCH_SIZE` | `INDEXER_ARCHIVAL_TOKEN_BALANCES_BATCH_SIZE` | `100` | v10.0.0 |
| `INDEXER_TOKEN_BALANCES_CONCURRENCY` | `INDEXER_ARCHIVAL_TOKEN_BALANCES_CONCURRENCY` | `10` | v10.0.0 |
| `INDEXER_TOKEN_BALANCES_MAX_REFETCH_INTERVAL` | `INDEXER_ARCHIVAL_TOKEN_BALANCES_MAX_REFETCH_INTERVAL` | `168h` | v10.0.0 |
| `INDEXER_TOKEN_BALANCES_EXPONENTIAL_TIMEOUT_COEFF` | `INDEXER_ARCHIVAL_TOKEN_BALANCES_EXPONENTIAL_TIMEOUT_COEFF` | `100` | v10.0.0 |

---

## Breaking Changes

### 1. Internal Transactions — Major Re-architecture (v10.0.0)
- Internal transactions now use a `call_type_enum` (Postgres ENUM) instead of the `call_type` string. New `transaction_errors` table stores error messages by ID via a new `error_id` FK.
- `internal_transaction` fields `trace_address` and `value` are now nullable.
- The `index` field now represents position within the transaction (was block-level `block_index`). This changes API behavior for callers of internal transaction endpoints.
- `selfdestruct` internal transactions return `NaN` for `gas_limit` in REST API (fixed in v10.0.0).
- 0-index internal transactions are excluded from `/api/v2/internal-transactions` endpoint.

### 2. Token Balances Fetcher Split (v10.0.0)
- `Indexer.Fetcher.TokenBalance` is split into `Indexer.Fetcher.TokenBalance.Historical` and `Indexer.Fetcher.TokenBalance.Current`.
- All `INDEXER_TOKEN_BALANCES_*` env vars are **renamed** to `INDEXER_ARCHIVAL_TOKEN_BALANCES_*`.
- If you have these set in Helm/K8s configs, they **must** be renamed or balances won't respect your limits.

### 3. `CACHE_PBO_COUNT_PERIOD` renamed + default change (v10.0.0)
- The old `CACHE_PBO_COUNT_PERIOD` (default `20m`) is replaced by `CACHE_PENDING_OPERATIONS_COUNT_PERIOD` (default `5m`). If you relied on the 20m interval, set the new var explicitly to `20m`.

### 4. Cache TTL disabled for Blocks/Transactions/Uncles caches (v10.0.0)
- `Explorer.Chain.Cache.Blocks`, `Explorer.Chain.Cache.Transactions`, `Explorer.Chain.Cache.Uncles` now have `ttl_check_interval: false` and `global_ttl: nil` — these caches no longer expire on a timer. Data is instead updated via distributed cache mechanism.

### 5. `TransactionsApiV2` cache removed (v10.0.0)
- `Explorer.Chain.Cache.TransactionsApiV2` module is gone. The `Transactions` cache now covers both API paths.

### 6. `UNIVERSAL_PROXY_CONFIG` mutual exclusion (v10.0.0)
- Setting both `UNIVERSAL_PROXY_CONFIG_URL` and `UNIVERSAL_PROXY_CONFIG` at the same time now raises a startup error.

### 7. Delete queue threshold default changed (v10.0.0)
- `INDEXER_INTERNAL_TRANSACTIONS_DELETE_QUEUE_THRESHOLD` default changed from `10m` → `0s` (effectively disables the wait before deletion).

### 8. Contract verification status table renamed (v10.0.0+)
- DB table `contract_verification_status` renamed to `smart_contract_verification_statuses`. Column `address_hash` renamed to `contract_address_hash`. Handled by migration `20260107090004`.

### 9. `MICROSERVICE_MULTICHAIN_SEARCH_URL` now parsed via `parse_url_env_var` (v10.0.0)
- Trailing slashes are stripped. If the URL had a trailing slash and dependent code relies on it, it may break.

### 10. Zero-value internal transactions queue dropped (v10.0.0)
- `internal_transactions_zero_value_delete_queue` table is dropped. The delete queue approach replaced by filtering on import.

### 11. `MissingRangesManipulator` disabled (v10.0.0)
- The `MissingRangesManipulator` is disabled by default. If your setup depended on it to backfill gaps, verify separately.

---

## Build Changes

| Component | Old | New |
|---|---|---|
| App version (`mix.exs`) | `9.3.2` | `10.2.6` |
| `prometheus_ex` | `~> 5.0.0` | `~> 5.1.0` |
| `tesla` | `~> 1.15.3` | `~> 1.16.0` |
| `ex_doc` | `~> 0.39.1` | `~> 0.40.1` |
| Dockerfile ARG | — | `MUD_INDEXER_ENABLED` added to build args |

---

## New Services / External Dependencies

- **Dynamic auth provider** — New optional SSO provider (`ACCOUNT_DYNAMIC_ENV_ID`). No new service required, uses Dynamic's hosted JWKS endpoint.
- **Keycloak** — New optional auth provider (`ACCOUNT_KEYCLOAK_*` vars). No new service in docker-compose; requires external Keycloak instance if used.
- **EigenDA** — New optional indexer for Optimism EigenDA blobs (`INDEXER_OPTIMISM_L1_BATCH_EIGENDA_*`). No new docker-compose service.

---

## Action Items

- [ ] **Rename token balance env vars** — Replace all `INDEXER_TOKEN_BALANCES_*` with `INDEXER_ARCHIVAL_TOKEN_BALANCES_*` in Helm/K8s/docker-compose configs
- [ ] **Rename pending ops cache var** — Replace `CACHE_PBO_COUNT_PERIOD` with `CACHE_PENDING_OPERATIONS_COUNT_PERIOD` (decide if you want the old `20m` default or the new `5m`)
- [ ] **Rename delete migration var** — Replace `MIGRATION_DELETE_ZERO_VALUE_INTERNAL_TRANSACTIONS_STORAGE_PERIOD_DAYS=30` with `MIGRATION_DELETE_ZERO_VALUE_INTERNAL_TRANSACTIONS_STORAGE_PERIOD=30d`
- [ ] **Verify `UNIVERSAL_PROXY_CONFIG_URL` and `UNIVERSAL_PROXY_CONFIG` are not both set** — will panic at startup
- [ ] **Review `API_DISABLE_CONTRACT_CREATION_INTERNAL_TRANSACTION_ASSOCIATION`** — new opt-in to skip internal tx association for contract creation; useful for performance
- [ ] **Review `ETHEREUM_JSONRPC_RECEIPTS_BY_BLOCK`** — opt-in performance improvement; test against your RPC provider first
- [ ] **Review `INDEXER_FETCHER_INIT_DELAY=10m`** — new 10m delay before fetchers start; may affect startup behavior expectations
- [ ] **Review Dockerfile ARG** — if using custom Dockerfile, ensure `MUD_INDEXER_ENABLED` build arg is present
- [ ] **Test internal transactions endpoints** — significant refactor of internal tx format; 0-index ITs excluded from API, `block_index` → `transaction_index`/`index` rename
- [ ] **Verify Vana-specific customizations survive merge** — particularly: `fix: set host in header`, `chore: disabling captcha verification`, custom logging
