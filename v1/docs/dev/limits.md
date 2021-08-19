# Limits

The tables below provide guidance on HSE operating limits.  A few are
enforced, but most are based on testing and experience.

The limits appropriate for a specific HSE client application are
largely dependent on the performance requirements of that application,
and the hardware it runs on.

Feel free to push these limits in a *test* environment, and
[let us know](../help/resources.md) how far you get
and what you observe.


## KVDB Limits

| Entity | Description | Limit | Enforced |
| :-- | :-- | --: | --: |
| KVDB count | Active KVDB per system | 8 | No |
| KVS count| KVS in a KVDB | 16 | No |
| Key count| Total keys in a KVDB (billions) | 200 | No |
| Capacity | Total storage capacity of a KVDB (TB) | 12 | No |
| Transaction count | Concurrent transactions in a KVDB | 1,000 per CPU | Yes |
| Cursor count | Concurrent cursors in a KVDB | 10,000 | No |

!!! tip
    An active cursor can consume up to 2MB of memory.


## KVS Limits

| Entity | Description | Limit | Enforced |
| :-- | :-- | --: | --: |
| Key size | Range of valid key sizes (bytes) | 1 &ndash; 1,334 | Yes |
| Value size | Range of valid value sizes (bytes) | 0 &ndash; 1MiB | Yes |
| Key count| Total keys in a KVS (billions) | 50 | No |
| Capacity | Total storage capacity of a KVS (TB) | 4 | No |
| Cursor count | Concurrent cursors in a KVS | 8,000 | No |


## Mpool Limits

These mpool limits apply only to HSE as an mpool client application.
Other mpool client applications may have vastly different mpool limits.

| Entity | Description | Limit | Enforced |
| :-- | :-- | --: | --: |
| Media class capacity | Volume size storing a media class (TB) | 8 | No |
| Mpool capacity | Combined capacity of all media classes (TB) | 16 | No |

