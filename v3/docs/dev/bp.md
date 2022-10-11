# Best Practices

The following are best practices for developing HSE applications.
Many of these are covered in greater detail in the discussion of
HSE [concepts](concepts.md).


## Keys and KVSs

Use a segmented key in the common case where related sets of KV pairs in a
KVS are accessed together.  Choose a key prefix that groups related KV pairs
when keys are sorted lexicographically, and always create the KVS
storing these KV pairs with a
[`prefix.length`](../gs/params.md#kvs-create-time-parameters)
equal to the key prefix length.

Use a different KVS for each collection of KV pairs requiring its own
segmented key structure.

Create index KVSs to efficiently implement query patterns that
cannot be supported with a single segmented key prefix.

Use an unsegmented key in the case where there is no relationship between
KV pairs in a KVS, and always create the KVS storing these KV pairs with a
[`prefix.length`](../gs/params.md#kvs-create-time-parameters) of zero (0).


## Cursors and Gets

Always use get operations when iteration is not required.  Gets are
**significantly** faster than cursor seeks.

Use non-transaction cursors for most applications.  Transaction cursors
exist to support some specialized use cases and incur additional overhead.


## Transactions

Use transactions when required for application correctness.
Otherwise, for best performance open a KVS with transactions *disabled*
([`transactions.enabled=false`](../gs/params.md#kvs-runtime-parameters))
and use non-transaction operations.


## Application Lifecycle

At application startup, call `hse_init()` to initialize the HSE subsystem
within your application.  This function should be called only once.
From there you can create or open a KVDB and its associated KVSs
and perform KV operations.

At application shutdown, close all KVSs for a KVDB before closing
that KVDB.  After all KVDBs are closed, call `hse_fini()` to
completely shutdown the HSE subsystem within your application.
Using a signal handler to close resources can also be helpful when
trying to handle unexpected application shutdown.
