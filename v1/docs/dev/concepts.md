# Concepts

The following describes HSE concepts that are important to understand for
developing HSE client applications and making effective use of the HSE API.

## KVDB and KVS

HSE implements a key-value database (KVDB).  An application
embedding HSE may have one or more KVDB open for access at a time.

A KVDB comprises one or more *named* key-value stores (KVS), each storing
a collection of key-value (KV) pairs.
A KVS is analogous to a table in a relational database.

The HSE API provides the standard KV operators for managing KV pairs
stored in a KVS: put, get, and delete.
HSE also provides advanced operations, including transactions, cursors,
and prefix deletes.

Finally, HSE supports a data model enabling *each* KVS in a KVDB to be
optimized for how the KV pairs it stores will be accessed.

## Data Model

Understanding the HSE data model is fundamental to achieving maximum
performance from HSE.  Adhering to the
[best practices](best-practices.md) of this data model
can result in **significantly** greater performance than might be
achieved otherwise.  While this data model is simple, it has proven
very effective.

### Key Structure

To describe the HSE data model, we define the following terms.

* **key** &mdash; a byte string used to uniquely identify a value for
storage, retrieval, and deletion in a KVS
* **multi-segment key** &mdash; a key that is logically divided into
`N` segments, `N >= 2`, arranged to group related KV pairs when keys are
sorted lexicographically
* **unsegmented key** &mdash; a key not logically divided into segments; i.e.,
is not a multi-segment key

For multi-segment keys, we further define the following.

* **key prefix** &mdash; the first `K` segments, `1 <= K < N`, that group
related KV pairs when keys are sorted lexicographically
* **key prefix length** &mdash; the length of a key prefix in bytes

### KVS Configuration

In the common case where related sets of KV pairs are accessed together,
best performance is generally achieved by

* defining a multi-segment key with a key prefix such that KV pairs to
be accessed together are grouped (contiguous) when keys are
sorted lexicographically, **and**

* creating a KVS to store these KV pairs with a key prefix length
parameter ([`pfx_len`](../gs/create-kvdb.md#kvs-parameters)) equal to the
key prefix length of the multi-segment key.

In the case where there is no relationship between KV pairs,
best performance is generally achieved by

* defining an unsegmented key, **and**

* creating a KVS to store these KV pairs with a key prefix length
parameter ([`pfx_len`](../gs/create-kvdb.md#kvs-parameters)) of zero (0).

Keep in mind that a KVDB may contain multiple named KVS.  So in the case
where there are multiple collections of KV pairs, each collection
can be stored in a different KVS with a key structure, and corresponding
KVS `pfx_len` parameter, that is appropriate for that collection.
This is a powerful capability that enables HSE to optimize storage and
access for all KV pairs in a KVDB without compromise.


### Operation Support

HSE provides several advanced operations with features that directly
support the HSE data model.  These operations are described in detail
later, but we briefly discuss how they support the data model here.

Cursors are used to iterate over keys in a KVS in forward or reverse
lexicographic order.  Cursors support an optional *filter*, which is a byte
string limiting a cursor's view to only those keys whose initial bytes match
the filter.
The primary use for cursors is with KVS storing multi-segment keys,
where the length of the specified filter is *equal to or greater than* the
key prefix length.  Used this way, cursors provide efficient iteration
over sets of related KV pairs.

Prefix deletes are used to atomically remove all KV pairs in a KVS
with keys whose initial bytes match a specified filter.
The length of the filter must be *equal to* the `pfx_len` parameter
of the KVS.
The primary use for prefix deletes is with KVS storing multi-segment keys.
This is a powerful capability that enables sets of related KV pairs to
be deleted in a single operation without cursor iteration.

Transactions are used to execute a sequence of KV operations atomically.
Transactions support operating on KV pairs in one or more KVS in a KVDB.
This allows storing multiple collections of KV pairs in different KVS
to optimize access, without giving up the ability to operate on any of
those KV pairs within the context of a single transaction.



### Modeling Examples

Below we present examples of applying the HSE data model to a real-world
problem &mdash; storing and analyzing machine-generated data.
Specifically, log data captured from datacenter servers.

System logs are commonly retrieved from datacenter servers on a periodic
basis and stored for both real-time and historical analysis.
We examine several ways this data might be modeled, depending on
how it will be accessed and managed.

#### Simple Log Storage

We start with a simple HSE data model for log storage using the multi-segment
key defined below, with values being individual log records.

| Key offset | Segment Length (bytes) | Segment Name | Description |
| :-- | :-- | :-- | :-- |
| 0 | 8 | sysID | System identifier |
| 8 | 8 | ts | Timestamp |
| 16 | 2 | typeID | Log type identifier |

In this and later examples, segment names are for convenience of
presentation (they do not exist in the HSE API), and segment lengths
are representative.  Also, partial or
complete keys may be represented as tuples using segment names.
For example, `(sysId)`, `(sysID, ts)`, or `(sysID, ts, typeID)`.

We define the key prefix to be `(sysID)`, yielding a key prefix length
of 8 bytes.  Hence, we would create a KVS to store these KV pairs
with a key prefix length parameter (`pfx_len`) of 8 bytes.

With this data model and KVS configuration, a cursor with the filter
`(sysID)` can be used to efficiently iterate over the log records
associated with the system `sysID`.  Furthermore, the cursor can be
used to efficiently seek to the first key (in the cursor's view) that
is lexicographically equal to or greater than a `(sysID, ts)`, and then
iterate from there.

This data model makes it easy and efficient to search the log records
associated with system `sysID` over an arbitrary time span.
However, pruning those log records, for example to retain only those from
the past 30 days, requires iterating over all older records and deleting them
individually.

Next we will look at enhancing this data model to make log record maintenance
more efficient.


#### Per-System Epoch-based Log Storage

We extend the simple HSE data model for log storage to include
an *epoch identifier* representing a well-defined time interval.
For example, an epoch might be four hours in length, with 6 epochs per day,
42 epochs per week, and so forth.  We assume that a log record's timestamp
can be mapped to a specific epoch through simple computation.

| Key offset | Segment Length (bytes) | Segment Name | Description |
| :-- | :-- | :-- | :-- |
| 0 | 8 | sysID | System identifier |
| 8 | 8 | epochID | Epoch identifier |
| 16 | 8 | ts | Timestamp |
| 24 | 2 | typeID | Log type identifier |

We define the key prefix to be `(sysID, epochID)`, yielding a key prefix
length of 16 bytes.  Hence, we would create a KVS to store these KV pairs
with a key prefix length parameter (`pfx_len`) of 16 bytes.

With this data model and KVS configuration, a cursor with the filter
`(sysID, epochID)` can be used to efficiently iterate over the log records
associated with the system `sysID` within the epoch `epochID`.
Furthermore, the cursor can be used to efficiently seek to the first
key (in the cursor's view) that is lexicographically equal to or greater
than `(sysID, epochID, ts)`, and then iterate from there within the epoch.

With this revised data model, it is still easy and efficient to search
the log records associated with system `sysID` over an arbitrary time span,
albeit with the minor inconvenience that a new cursor must be created to cross
an epoch boundary.
The benefit is more efficient pruning of log records, because we can now
use a single prefix delete to remove all KV pairs with a specified key
prefix of `(sysID, epochID)`.

Next we will examine a variation on this per-system epoch-based data model.


#### All-Systems Epoch-based Log Storage

The multi-segment key and key prefix defined in the previous HSE data model
make it easy and efficient to iterate over the log records associated
with a given `sysID` for a specified `epochID`.  However, to view records
from multiple systems for a specified `epochID` requires a cursor iteration
per system.

We can instead group the log records for all systems within an epoch using
the following multi-segment key.

| Key offset | Segment Length (bytes) | Segment Name | Description |
| :-- | :-- | :-- | :-- |
| 0 | 8 | epochID | Epoch identifier |
| 8 | 8 | ts | Timestamp |
| 16 | 8 | sysID | System identifier |
| 24 | 2 | typeID | Log type identifier |

We define the key prefix to be `(epochID)`, yielding a key prefix
length of 8 bytes.  Hence we would create a KVS to store these KV pairs
with a key prefix length parameter (`pfx_len`) of 8 bytes.

With this data model and KVS configuration, a cursor with the filter
`(epochID)` can be used to efficiently iterate over the log records for
all systems within the epoch `epochID` in timestamp order.
Furthermore, the cursor can be used to efficiently seek to the first
key (in the cursor's view) that is lexicographically equal to or greater
than `(epochID, ts)`, and then iterate from there within the epoch.

It should be clear that there is some loss of efficiency, versus the
prior data model, to obtain all the log records associated with a specified
`sysID` over an arbitrary time span, because records associated with systems
other than `sysID` will be in the cursor's view and must be skipped.
However, this is still a reasonably efficient query because it meets the
critical criteria that the length of the cursor filter be
*equal to or greater than* the key prefix length to achieve
maximum performance.

With this revised data model, pruning log records remains efficient because
we can still use a single prefix delete to remove all KV pairs with a
specified key prefix of `(epochID)`.  In this case, the records for all
systems in the epoch are pruned together.

!!! tip
    This particular data model provides the opportunity to point out another
    [best practice](best-practices.md) that can result in **significantly**
    greater performance.
    For a KVS storing multi-segment keys, it is important that the key
    prefix specified in put operations takes on a modest number of
    different values over a consecutive sequence of puts.  For this example,
    that means choosing an epoch that is relatively short versus what
    one might select with the prior data model.

Finally, we will examine an index-based data model for log storage.


#### Index-based Log Storage

The prior HSE data models for log storage have the benefit of simplicity.
However, they may provide less flexibility than required by the client
application.
In this example, we demonstrate how to use multiple KVS to effectively
index log records.

For brevity, we define the key structure for each KVS using the tuple
syntax, segment names, and segment lengths adopted in prior examples.
The only new element is `logID`, which uniquely identifies a log record.


| KVS Name | Key Type | Key | Key Prefix | KVS pfx_len | Value |
| :-- | :-- | :-- | :-- | :-- | :-- |
| logRec | unsegmented | (logID) | | 0 | Log record content |
| sysIdx | multi-segment | (sysID, epochID, ts, typeID, logID) | (sysID, epochID) | 16 | |
| epochIdx | multi-segment | (epochID, ts, sysID, typeID, logID) | (epochID) | 8 | |


The KVS `logRec` stores the content of all log records, with each log
record identified by a unique unsegmented key `logID`.  Because
KVS `logRec` stores KV pairs with an unsegmented key, it is configured
with a key prefix length parameter (`pfx_len`) of 0 bytes.

The two KVS `sysIdx` and `epochIdx` are indexes for the log records stored
in KVS `logRec`.
These KVS are nearly identical to those created in the prior data model
examples for per-system epoch-based log storage and all-systems epoch-based
log storage, respectively.
The only differences are that `logID` is added to the multi-segment keys
as the final segment, and their are no associated values (i.e., the values
are zero length).

The same cursor queries apply to `sysIdx` and `epochIdx` as in those prior
data models, with the added step that to view the log content requires a
get operation with key `logID` from the KVS `logRec`.
The benefit is that we can use `sysIdx` to efficiently search the log records
for a given `sysID` within any time span, or we can use `epochIdx` to
efficiently search the log records for all systems within that time span.

A transaction can be used to atomically put (insert) the KV pairs for a given
log record in all of `logRec`, `sysIdx`, and `epochIdx`.  This ensures
integrity of the indexes.

Pruning log records is more complex than the prior data models.
One approach to deleting all log records for a given `epochID`, where
the epoch is assumed to have passed, is to

* use a cursor with filter `(epochID)` to iterate over KVS `epochIdx` to
build lists of all `sysID` and `logID` in the epoch; and then
* in a transaction delete all `logID` from `logRec`; prefix delete each
key prefix `(sysID, epochID)` from `sysIdx`; and prefix delete
the key prefix `(epochID)` from `epochIdx`.


## Snapshots

HSE implements industry-standard
[snapshot isolation](https://en.wikipedia.org/wiki/Snapshot_isolation)
semantics.
The implication is that transactions and cursors operate on KVS snapshots.

Conceptually, a KVS snapshot contains KV pairs from all transactions
committed, and stand-alone operations completed, at the time the snapshot
is taken.  In this context, a stand-alone KV operation is one performed
outside of a transaction.

A KVS snapshot is ephemeral and ceases to exist when all associated
operations complete.


## Transactions

Transactions may be used to execute a sequence of KV operations
as a unit of work that is atomic, consistent, isolated, and durable (ACID).
A transaction may operate on KV pairs in one or more KVS in a KVDB.

Conceptually, when a transaction is initiated an instantaneous snapshot is
taken of all KVS in the specified KVDB.  The transaction may then be used
to read or update KV pairs in these KVS snapshots.

Snapshot isolation is enforced by failing updates (puts or deletes) that
collide with updates in concurrent transactions, after which the transaction
may be aborted and retried.
In rare cases, the collision detection mechanism may produce false positives.

Stand-alone KV operations are not visible to, and do not impact,
concurrent transactions.
For example, a stand-alone put operation is not visible to, and will not
collide with, any concurrent transaction.

HSE implements asynchronous (non-durable) transaction commits.
Committed transactions are made durable either via explicit HSE API calls,
or automatically within the durability
interval ([`dur_intvl_ms`](../gs/create-kvdb.md#kvdb-parameters))
configured for a KVDB.

HSE implements transactions using multiversion concurrency control (MVCC)
techniques supporting a high-degree of transaction concurrency.


## Cursors

Cursors are used to iterate over keys in a KVS snapshot.  A cursor
can iterate over keys in forward or reverse lexicographic order.

Cursors support an optional *filter*, which is a byte
string limiting a cursor's view to only those keys in a KVS snapshot
whose initial bytes match the filter.

!!! tip
    Cursors deliver **significantly** greater performance when used
    with KVS storing multi-segment keys, **and** where a filter is specified
    with a length *equal to or greater than* the key prefix length.
    To the degree practical, you should structure applications to avoid
    using cursors outside of this use case.  Furthermore, you should always use
    get operations instead of cursor seeks when iteration is not required.

A cursor can be used to seek to the first key in the cursor's view that
is lexicographically *equal to or greater than* a specified key.
The interaction of cursor filters and seek is best described by example.

Consider a KVS storing the following keys, which are listed in lexicographic
order: "ab001", "af001", "af002", "ap001".

If a cursor is created for the KVS with a filter of "af", then the
cursor's view is limited to the keys: "af001", "af002".

If that cursor is then used to seek to the key "ab", it will be positioned
at the first key in its view equal to or greater than "ab", which is "af001".
Iterating (reading) with the cursor will return the key "af001", then "af002",
and then the `EOF` condition indicating there are no more keys in view.

If instead the cursor is used to seek to the key "ap", it will be
positioned past the last key in its view, such that an
attempt to iterate (read) with the cursor will indicate an `EOF` condition.

There are several different types of cursors.

A *free* cursor iterates over a KVS snapshot that is taken at the time the
cursor is created.  The view of a free cursor can be explicitly updated to
the latest snapshot of the KVS.  Most applications will use a free
cursor for iteration.

A *transaction snapshot* cursor iterates over a KVS snapshot associated with
an active transaction.  The cursor *does not* have in its view any
updates made in that transaction, and its view *does not* change
when the transaction commits or aborts.

A *transaction bound* cursor iterates over a KVS snapshot associated with
an active transaction, *including* any updates made in that transaction.
A transaction bound cursor becomes a free cursor when that transaction
commits or aborts.  The view of the (now free) cursor depends on if
the *static view* flag was specified when the transaction bound cursor was
created.

* **With** static view flag: the cursor continues with the same KVS snapshot,
meaning any updates made in the transaction are no longer in its view.
* **Without** static view flag and transaction **commits**: the cursor's
view is updated to the KVS snapshot immediately following the transaction
commit, which will include updates made in that transaction, and potentially
in other committed transactions or completed stand-alone operations.
* **Without** static view flag and transaction **aborts**: the cursor's
view is updated to the latest snapshot of the KVS.


## Durability Controls

HSE provides APIs for flushing cached KVDB updates to stable storage,
either synchronously or asynchronously.
Flushing applies to all cached updates, from both stand-alone
KV operations and committed transactions.

Cached updates are automatically flushed to stable storage within
the durability interval ([`dur_intvl_ms`](../gs/create-kvdb.md#kvdb-parameters))
configured for a KVDB.


## Multithreading

HSE supports highly-concurrent multithreaded applications, and most functions
in the HSE API are thread-safe.  However, there are a few exceptions, as
documented in the HSE [API reference](api-reference.md).


## Delete Semantics

Delete operations logically remove KV pairs from a KVS.
However, HSE implements physical removal as a background operation, and hence
capacity is not freed immediately.
