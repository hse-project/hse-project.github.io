# Best Practices

The following are best practices for developing HSE applications.
Many of these are covered in greater detail in the discussion of
HSE [concepts](concepts.md).


## Keys and KVS

Use a segmented key in the common case where related sets of KV pairs
are accessed together.  Choose a key prefix that groups related KV pairs
when keys are sorted lexicographically, and always create the KVS
storing these KV pairs with a
[`pfx_len`](../gs/params.md#kvs-create-time-parameters)
equal to the key prefix length.

Choose a key prefix for segmented keys that will take on a modest
number of different values over a consecutive sequence of puts.
For example, in a sequence of one million put operations, ideally
no more than 5% of the keys will have the same key prefix value.

Use a different KVS for each collection of KV pairs requiring its own
segmented key structure.

Create index KVS to efficiently implement multiple query patterns that
cannot be supported with a single segmented key prefix.

Use an unsegmented key in the case where there is no relationship between
KV pairs, and always create the KVS storing these KV pairs with a
[`pfx_len`](../gs/params.md#kvs-create-time-parameters) of zero (0).


## Cursors and Gets

Always use get operations when iteration is not required.  Gets are
**significantly** faster than cursor seeks.

Where iteration is required, use cursors with KVS storing segmented keys,
and with a filter whose length is *equal to or greater than* the key prefix
length.  Otherwise, cursor performance can be greatly reduced.

Use non-transaction cursors for most applications.  Transaction cursors
exist to support some specialized use cases.


## Transactions

Use transactions when required for application correctness.
Otherwise, for best performance open KVS with transactions *disabled*
(per [`transactions_enable`](../gs/params.md#kvs-runtime-parameters))
and use non-transaction operations.


## Application Lifecycle

At application startup call `hse_init()`.  This function should be called
only once.  From there you can create or open a KVDB and its associated KVS
and perform KV operations.

At application shutdown you should close all KVS for a KVDB before closing
that KVDB.  After all KVDB are closed, a single call to `hse_fini()` will
completely shutdown the HSE subsystem within your application.
Using a signal handler to close resources can also be helpful when
trying to handle unexpected application shutdown.

