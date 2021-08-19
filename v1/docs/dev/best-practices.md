# Best Practices

The following are best practices for developing HSE client applications.
Many of these are discussed in detail in the section on
HSE [concepts](concepts.md).


## Keys and KVS

Use a multi-segment key in the common case where related sets of KV pairs
are accessed together.  Choose a key prefix that groups related KV pairs
when keys are sorted lexicographically, and always create the KVS
storing these KV pairs with a
[`pfx_len`](../gs/create-kvdb.md#kvs-parameters) equal to the key prefix length.

Choose a key prefix for multi-segment keys that will take on a modest
number of different values over a consecutive sequence of puts.
For example, in a sequence of one million put operations, ideally
no more than 5% of the keys will have the same key prefix value.

Use a different KVS for each collection of KV pairs requiring its own
multi-segment key structure.

Create index KVS to efficiently implement multiple query patterns that
cannot be supported with a single multi-segment key prefix.

Use an unsegmented key in the case where there is no relationship between
KV pairs, and always create the KVS storing these  KV pairs with a
[`pfx_len`](../gs/create-kvdb.md#kvs-parameters) of zero (0).


## Cursors and Gets

Always use get operations when iteration is not required.  Gets are
**significantly** faster than cursor seeks.

Where iteration is required, use cursors with KVS storing multi-segment keys,
and with a filter whose length is *equal to or greater than* the key prefix
length.  Otherwise, cursor performance can be greatly reduced.

Use free cursors for most applications.  Transaction snapshot cursors
and transaction bound cursors exist to support some specialized use cases.


## Transactions

Use transactions when required for application correctness.
Otherwise, use stand-alone operations for best performance.
Transactions incur overhead to enforce snapshot isolation semantics.


## Application Lifecycle

An HSE application's lifecycle always starts with a call to `hse_kvdb_init()`.
This function should be called only once at the very beginning of your program.
From there you can create and open KVDBs, and their associated KVSs.

When your application starts to shutdown, all KVSs for every KVDB must be
closed before closing the KVDB. Once all KVDBs have been closed, a single call
to `hse_kvdb_fini()` will completely shutdown the HSE subsystem within your
application. Using a signal handler to close resources can also be helpful when
trying to handle unexpected shutdowns of an application.
