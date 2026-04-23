# Migration Risk Analysis: v9.3.2 → v10.2.6

**Rollout branch:** `testnet-rollout-10.2.6`
**Total new migrations:** 17

Risk legend:
- 🔴 **HIGH** — May cause prolonged table lock on large tables; plan a maintenance window or concurrent approach
- 🟡 **MEDIUM** — May cause brief lock or is conditional; review row counts before deploying
- 🟢 **SAFE** — No significant lock risk

---

## Main Repo Migrations (`priv/repo/migrations`)

### 🔴 HIGH — `20250812000000_internal_transactions_drop_not_null_constraints`

```sql
ALTER TABLE internal_transactions
  ALTER COLUMN trace_address DROP NOT NULL,
  ALTER COLUMN value DROP NOT NULL;
```

**Risk:** `internal_transactions` is likely the largest and most actively written table in Blockscout. `ALTER TABLE … DROP NOT NULL` requires an `ACCESS EXCLUSIVE` lock for the full duration of the operation. On a large database this could take minutes and block all reads/writes.

**Recommendation:** Run during low-traffic window. Consider `SET lock_timeout = '5s'` and retry approach. Alternatively, apply with a replica-first strategy.

---

### 🟡 MEDIUM — `20250908062439_add_call_type_enum_to_internal_transactions`

```sql
CREATE TYPE internal_transactions_call_type AS ENUM ('call', 'callcode', 'delegatecall', 'staticcall', 'invalid');
ALTER TABLE internal_transactions ADD COLUMN call_type_enum internal_transactions_call_type;
-- drops and creates constraints with validate: false
```

**Risk:** Adding a nullable column to `internal_transactions` requires a brief `ACCESS EXCLUSIVE` lock but does not rewrite the table in PostgreSQL 11+. The constraint operations use `validate: false` (no table scan). Lock duration should be very short.

---

### 🟡 MEDIUM — `20250915135943_create_transaction_errors`

```sql
CREATE TABLE transaction_errors (...);
ALTER TABLE internal_transactions ADD COLUMN error_id smallint;
-- drops/creates several constraints with validate: false
```

**Risk:** Same as above — adding a nullable column to `internal_transactions` takes a brief lock. `CREATE TABLE` and constraint operations with `validate: false` are safe.

---

### 🟢 SAFE — `20260107090004_alter_contract_verification_status_table`

```sql
ALTER TABLE contract_verification_status RENAME TO smart_contract_verification_statuses;
ALTER INDEX contract_verification_status_pkey RENAME TO smart_contract_verification_statuses_pkey;
ALTER TABLE smart_contract_verification_statuses RENAME COLUMN address_hash TO contract_address_hash;
```

**Risk:** `contract_verification_status` is a small table (status tracking only). RENAME operations take a brief metadata lock only.

---

### 🟢 SAFE — `20260114143222_re_run_sanitize_incorrect_nft_migration`

```sql
UPDATE migrations_status SET status = 'started', meta = '...'
WHERE migration_name = 'sanitize_incorrect_nft' AND ...
```

**Risk:** `migrations_status` is tiny. This UPDATE restarts a background migration; no table lock risk.

---

### 🟡 MEDIUM — `20260121084059_reset_tokens_extended_skip_metadata`

```sql
UPDATE tokens
SET skip_metadata = null
WHERE skip_metadata IS TRUE AND decimals IS NOT NULL AND name IS NOT NULL AND symbol IS NOT NULL
```

**Risk:** `tokens` can be a large table. This UPDATE is filtered (WHERE on indexed-ish columns), but will acquire row-level locks for each matching row. Could cause write contention on `tokens` for the duration. Volume of matching rows is unknown — check before deploying.

**Recommendation:** Run `EXPLAIN ANALYZE` on the WHERE clause first to estimate row count. If large, batch or run during off-peak.

---

### 🟢 SAFE — `20260128120316_drop_internal_transactions_zero_value_delete_queue`

```sql
DROP TABLE internal_transactions_zero_value_delete_queue;
```

**Risk:** This should be a small queue table. DROP TABLE takes a brief lock.

---

### 🟡 MEDIUM — `20260128160608_add_current_token_balance_retry_fields`

```sql
ALTER TABLE address_current_token_balances
  ADD COLUMN refetch_after utc_datetime_usec,
  ADD COLUMN retries_count smallint;
```

**Risk:** `address_current_token_balances` can be large. Adding nullable columns in PostgreSQL 11+ is fast (metadata-only change, no table rewrite), but still requires a brief `ACCESS EXCLUSIVE` lock.

---

### 🟢 SAFE — `20260213092943_add_internal_transactions_pk_not_null_constraint`

```sql
-- Creates check constraints with validate: false
ALTER TABLE internal_transactions
  ADD CONSTRAINT internal_transactions_block_number_not_null CHECK (block_number IS NOT NULL) NOT VALID,
  ADD CONSTRAINT internal_transactions_transaction_index_not_null CHECK (transaction_index IS NOT NULL) NOT VALID;
```

**Risk:** `NOT VALID` (validate: false) means PostgreSQL does not scan existing rows. Lock is very brief. Safe.

---

### 🟢 SAFE — `20260217131711_reset_token_transfer_block_consensus_migration`

```sql
DELETE FROM migrations_status WHERE migration_name = 'token_transfers_block_consensus';
```

**Risk:** `migrations_status` is tiny. Safe.

---

### 🟡 MEDIUM — `20260220073231_vacuum_full_multichain_search_db_main_export_queue`

```sql
-- Only runs if estimated row count < 10,000
VACUUM FULL public.multichain_search_db_main_export_queue;
```

**Risk:** `VACUUM FULL` acquires an `ACCESS EXCLUSIVE` lock for its duration, blocking all access to the table. However, the migration guards it with a row count check (< 10k rows). If the table has < 10k rows, the lock duration should be short. Verify row count before deploying to production.

---

### 🟡 MEDIUM — `20260220073239_alter_multichain_search_db_export_balances_queue_id_to_bigint`

```sql
-- Only runs if estimated row count < 10,000
ALTER TABLE multichain_search_db_export_balances_queue ALTER COLUMN id TYPE bigint;
ALTER SEQUENCE multichain_search_db_export_balances_queue_id_seq AS bigint;
VACUUM FULL public.multichain_search_db_export_balances_queue;
```

**Risk:** `ALTER COLUMN TYPE` from integer to bigint requires a full table rewrite (locks table for duration). Combined with `VACUUM FULL`. Guarded by < 10k row count check. If your multichain queue table has grown large (≥ 10k rows), this migration safely skips — but the `id` column will not be upgraded. Verify queue size.

---

### 🟡 MEDIUM — `20260220073248_vacuum_full_multichain_search_db_export_counters_queue`

Same pattern as `073231` above — conditional `VACUUM FULL` on counters queue if < 10k rows.

---

### 🟡 MEDIUM — `20260220073250_vacuum_full_multichain_search_db_export_token_info_queue`

Same pattern as `073231` above — conditional `VACUUM FULL` on token info queue if < 10k rows.

---

## Optimism Migrations (`priv/optimism/migrations`)

### 🟢 SAFE — `20251205112616_op_eigen_da_blobs`

```sql
ALTER TYPE op_frame_sequence_blob_type ADD VALUE IF NOT EXISTS 'eigenda';
```

**Risk:** Adding a value to an existing ENUM type. In PostgreSQL 12+, this is a catalog-only change and does not require a table rewrite. The `IF NOT EXISTS` guard makes it safe to re-run. Only relevant if the `op_frame_sequence_blob_type` type exists (Optimism deployments only).

---

## Shrunk Internal Transactions Migrations (`priv/shrunk_internal_transactions/migrations`)

### 🟢 SAFE — `20250919150023_drop_call_has_error_id_or_result_constraint`

```sql
ALTER TABLE internal_transactions DROP CONSTRAINT IF EXISTS call_has_error_id_or_result;
```

**Risk:** `drop_if_exists` with `validate: false`. Brief metadata lock only.

---

### 🟢 SAFE — `20260407115103_remove_call_has_error_id_or_result_constraint`

Same as above — `drop_if_exists` constraint on internal_transactions.

---

## Summary

| Risk Level | Count | Migrations |
|---|---|---|
| 🔴 HIGH | 1 | `20250812000000` (internal_transactions NOT NULL drop) |
| 🟡 MEDIUM | 7 | `20250908`, `20250915`, `20260121`, `20260128_160608`, `20260220_073231`, `20260220_073239`, `20260220_073248`, `20260220_073250` |
| 🟢 SAFE | 9 | All others |

## Pre-deployment Checklist

- [ ] Check row count of `internal_transactions` table — plan maintenance window for `20250812000000`
- [ ] Check row count of `tokens` table — estimate impact of `20260121084059` UPDATE
- [ ] Check row counts of multichain queue tables before deploying (should be < 10k for migrations to run)
- [ ] Verify `op_frame_sequence_blob_type` type exists only if this is an Optimism deployment
- [ ] Run migrations in a staging/testnet environment before production
- [ ] Have a rollback plan for `20250812000000` — the `down` migration re-adds NOT NULL which will fail if any rows have NULL values
