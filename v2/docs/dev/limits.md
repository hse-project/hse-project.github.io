# Limits

The tables below provide guidance on HSE operating limits.  A few are
enforced, but most are based on testing and experience.

The limits appropriate for a specific HSE application are
largely dependent on the performance requirements of that application,
and the hardware it runs on.

Feel free to push these limits in testing and
[let us know](../res/community.md) how far you get and what you observe.


## KVDB Limits

| Entity | Description | Limit | Enforced |
| :-- | :-- | --: | --: |
| KVDB count | Active KVDB per system | 8 | No |
| KVS count| KVSs in a KVDB | 16 | No |
| Key count| Total keys in a KVDB (billions) | 200 | No |
| Capacity | Total storage capacity of a KVDB (TB) | 12 | No |
| Transaction count | Concurrent transactions in a KVDB | 1,000 per CPU | Yes |
| Cursor count | Concurrent cursors in a KVDB | 10,000 | No |


!!! info
    An application can only have a single KVDB open at a time.
    We expect to remove this limitation in a later release.


## KVS Limits

| Entity | Description | Limit | Enforced |
| :-- | :-- | --: | --: |
| Key size | Range of valid key sizes (bytes) | 1 &ndash; 1,334 | Yes |
| Value size | Range of valid value sizes (bytes) | 0 &ndash; 1MiB | Yes |
| Key count| Total keys in a KVS (billions) | 50 | No |
| Capacity | Total storage capacity of a KVS (TB) | 4 | No |
| Cursor count | Concurrent cursors in a KVS | 8,000 | No |
