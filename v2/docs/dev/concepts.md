# Concepts

The following describes HSE concepts that are important to understand for
developing HSE applications and making effective use of the HSE API.


## KVDB and KVS

HSE provides functions to create and access a key-value database (KVDB).
A KVDB comprises one or more named key-value stores (KVS), each of which
is an independent collection of key-value (KV) pairs.  A KVS is analogous to
a table in a relational database.

HSE provides the standard KV operators for managing KV pairs stored in
a KVS: put, get, and delete.  HSE also provides transactions, cursors,
prefix deletes, and other advanced features.

The HSE data model enables each KVS in a KVDB to be optimized for how the
KV pairs it stores will be accessed.


## Data Model

Understanding the HSE data model is fundamental to achieving maximum
application performance.  Adhering to the [best practices](bp.md)
of this data model can result in **significantly** greater performance than
might be achieved otherwise.  While this data model is simple, it has proven
very effective.


### Key Structure

To describe the HSE data model, we define the following terms.

* **key** &mdash; a byte string used to uniquely identify a value for
storage, retrieval, and deletion in a KVS
* **segmented key** &mdash; a key that is logically divided into
`N` segments, `N >= 2`, arranged to group related KV pairs when keys are
sorted lexicographically
* **unsegmented key** &mdash; a key not logically divided into segments

For segmented keys, we further define the following.

* **key prefix** &mdash; the first `K` segments, `1 <= K < N`, that group
related KV pairs when keys are sorted lexicographically
* **key prefix length** &mdash; the length of a key prefix in bytes


### KVS Configuration

In the common case where related sets of KV pairs are accessed together,
best performance is generally achieved by

* defining a segmented key with a key prefix such that KV pairs to
be accessed together are grouped (contiguous) when keys are
sorted lexicographically, **and**

* creating a KVS to store these KV pairs with a key prefix length
parameter ([`pfx_len`](../gs/params.md#kvs-create-time-parameters))
equal to the key prefix length of the segmented key.

In the case where there is no relationship between KV pairs,
best performance is generally achieved by

* defining an unsegmented key, **and**

* creating a KVS to store these KV pairs with a key prefix length parameter
([`pfx_len`](../gs/params.md#kvs-create-time-parameters)) of zero (0).

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
The primary use for cursors is with KVS storing segmented keys,
where the length of the specified filter is *equal to or greater than* the
key prefix length.  Used this way, cursors provide efficient iteration
over sets of related KV pairs.

Prefix deletes are used to atomically remove all KV pairs in a KVS
with keys whose initial bytes match a specified filter.
The length of the filter must be *equal to* the `pfx_len` parameter
of the KVS.
The primary use for prefix deletes is with KVS storing segmented keys.
This is a powerful capability that enables sets of related KV pairs to
be deleted in a single operation without cursor iteration.

Transactions are used to execute a sequence of KV operations atomically.
Transactions support operating on KV pairs in one or more KVS in a KVDB.
This allows storing multiple collections of KV pairs in different KVS
to optimize access, without giving up the ability to operate on any of
those KV pairs within the context of a single transaction.


### Modeling Examples

Below we present examples of applying the HSE data model to the real-world
problem of storing and analyzing machine-generated data.
Specifically, log data captured from datacenter servers.

System logs are commonly retrieved from datacenter servers on a periodic
basis and stored for both real-time and historical analysis.
We examine several ways this data might be modeled, depending on
how it will be accessed and managed.


#### Simple Log Storage

We start with a simple data model for storing log data in a KVDB.  This
model uses a single KVS with segmented keys as defined below,
and values which are individual log records.

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
of 8 bytes.  Hence, we would create a KVS for storing these KV pairs
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

We extend the simple data model from above to include an *epoch identifier*
representing a well-defined time interval.
For example, an epoch might be four hours in length, with 6 epochs per day,
42 epochs per week, and so forth.  We assume that a log record's timestamp
can be mapped to a specific epoch through simple computation.

We again use a single KVS but with segmented keys as defined below,
and values which are individual log records.

| Key offset | Segment Length (bytes) | Segment Name | Description |
| :-- | :-- | :-- | :-- |
| 0 | 8 | sysID | System identifier |
| 8 | 8 | epochID | Epoch identifier |
| 16 | 8 | ts | Timestamp |
| 24 | 2 | typeID | Log type identifier |

We define the key prefix to be `(sysID, epochID)`, yielding a key prefix
length of 16 bytes.  Hence, we would create a KVS for storing these KV pairs
with a key prefix length parameter (`pfx_len`) of 16 bytes.

With this data model and KVS configuration, a cursor with the filter
`(sysID, epochID)` can be used to efficiently iterate over the log records
associated with the system `sysID` within the epoch `epochID`.
Furthermore, the cursor can be used to efficiently seek to the first
key (in the cursor's view) that is lexicographically equal to or greater
than `(sysID, epochID, ts)`, and then iterate from there within the epoch.

With this revised data model, it is still easy and efficient to search
the log records associated with system `sysID` over an arbitrary time span,
though it is necessary to configure a cursor to iterate over each
epoch of interest (e.g., to cross epoch boundaries).
However, we can now prune log records very efficiently by using a single prefix
delete to remove all KV pairs with a specified key prefix of `(sysID, epochID)`.

Next we examine a variation on this per-system epoch-based data model.


#### All-Systems Epoch-based Log Storage

The previous data model makes it easy and efficient to iterate over the
log records associated with a given `sysID` for a specified `epochID`.
However, to view records from multiple systems for a specified `epochID`
requires a cursor iteration per `sysID` of interest.

We can instead group the log records for all systems within an epoch
by using a KVS with segmented keys as defined below,
and values which are individual log records.

| Key offset | Segment Length (bytes) | Segment Name | Description |
| :-- | :-- | :-- | :-- |
| 0 | 8 | epochID | Epoch identifier |
| 8 | 8 | ts | Timestamp |
| 16 | 8 | sysID | System identifier |
| 24 | 2 | typeID | Log type identifier |

We define the key prefix to be `(epochID)`, yielding a key prefix
length of 8 bytes.  Hence we would create a KVS for storing these KV pairs
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
criteria that the length of the cursor filter be *equal to or greater than* the
key prefix length to achieve maximum performance.

With this revised data model, pruning log records remains efficient because
we can still use a single prefix delete to remove all KV pairs with a
specified key prefix of `(epochID)`.  In this case, the records for all
systems in the epoch are pruned together.

!!! tip
    This particular data model provides the opportunity to point out another
    [best practice](bp.md) that can result in **significantly**
    greater performance.
    For a KVS storing segmented keys, it is important that the key
    prefix specified in put operations takes on a modest number of
    different values over a consecutive sequence of puts.  For this example,
    that means choosing an epoch that is relatively short versus what
    one might select with the prior data model.

Finally, we will examine an index-based data model for log storage.


#### Index-based Log Storage

The prior data models for log storage have the benefit of simplicity
in that the KVDB has only a single KVS.
However, they may provide less flexibility than required by the application.
In this next example, we demonstrate how to use multiple KVS to effectively
index log records.

For brevity, we define the key structure for each KVS using the tuple
syntax, segment names, and segment lengths adopted in prior examples.

| KVS Name | Key Type | Key | Key Prefix | KVS pfx_len | Value |
| :-- | :-- | :-- | :-- | :-- | :-- |
| logRec | segmented | (epochID, ts, sysID, typeID) | (epochID) | 8 | Log record content |
| sysIdx | segmented | (sysID, epochID, ts, typeID) | (sysID, epochID) | 16 | |

The KVS `logRec` stores the content of all log records, with each log record
uniquely identified by the segmented key `(epochID, ts, sysID, typeID)` with
key prefix `(epochID)`.
Hence we would create KVS `logRec` with a key prefix length parameter
(`pfx_len`) of 8 bytes.

The KVS `sysIdx` is an index for the log records stored in KVS `logRec`,
with a key pefix of `(sysID, epochID)`.
Hence we would create KVS `sysIdx` with a key prefix length parameter
(`pfx_len`) of 16 bytes.

Using KVS `logRec`, a cursor with the filter `(epochID)` can be used to
efficiently iterate over the log records for all systems within the
epoch `epochID` in timestamp order.
Furthermore, the cursor can be used to efficiently seek to the first
key (in the cursor's view) that is lexicographically equal to or greater
than `(epochID, ts)`, and then iterate from there within the epoch.

Using KVS `sysIdx`, a cursor with the filter `(sysID, epochID)` can be used to
efficiently iterate over the log records associated with the system `sysID`
within the epoch `epochID`.
Furthermore, the cursor can be used to efficiently seek to the first
key (in the cursor's view) that is lexicographically equal to or greater
than `(sysID, epochID, ts)`, and then iterate from there within the epoch.

Note that KVS `sysIdx` does not contain any log record contents, and in fact
stores no values at all (i.e., all value lengths are zero).
To obtain the contents of a specific log record, there is the added step of
a get operation in KVS `logRec` with key `(epochID, ts, sysID, typeID)`.

The above schema accomplishes the following.

* Efficient iteration over the log records from all systems in a specified
epoch using a cursor with KVS `logRec`.
* Efficient iteration over the log records from a specific system in a
specified epoch using a cursor with KVS `sysIdx`.
* No duplication of log record content.

A transaction can be used to atomically put (insert) KV pairs for a given log
record in KVS `logRec` and KVS `sysIdx`. This guarantees integrity
of the `sysIdx` index.

Pruning log records is a bit more complex than the prior data models,
bit still relatively straight-forward.  To delete all log records for a
given `epochID`, where the epoch is assumed to have passed, you would

* use a cursor with filter `(epochID)` to iterate over KVS `logRec` to
build a list of all `sysID` in the epoch, and then
* in a single transaction, prefix delete each key prefix `(sysID, epochID)`
from KVS `sysIdx`, and prefix delete the key prefix `(epochID)` from
KVS `logRec`.


## Snapshots

HSE implements industry-standard
[snapshot isolation](https://en.wikipedia.org/wiki/Snapshot_isolation)
semantics.
The implication is that transactions and cursors operate on KVS snapshots.

Conceptually, a KVS snapshot contains KV pairs from all transactions
committed, or non-transaction operations completed, at the time the snapshot
is taken.  A KVS snapshot is ephemeral and ceases to exist when all associated
operations complete.


## Transactions

Transactions may be used to execute a sequence of KV operations
as a unit of work that is atomic, consistent, isolated, and durable (ACID).
A transaction may operate on KV pairs in one or more KVS in a KVDB.

When a KVS is opened, the
[`transactions_enable`](../gs/params.md#kvs-runtime-parameters)
parameter specifies whether or not that KVS
supports transactions.  This is not a persistent setting in that
the KVS may be closed and later reopened in a different mode.
The following table specifies the operations that may be performed
on a KVS opened with transactions enabled or disabled, where

* **Read** is a query operation, such as get or cursor iteration
* **Update** is a mutation operation, such as put, delete, or prefix delete

| | KVS Transactions Enabled | KVS Transactions Disabled |
| :-- | :-: | :-: |
| Transaction Read | :material-check: | :material-close: |
| Transaction Update | :material-check: | :material-close: |
| Non-transaction Read | :material-check: | :material-check: |
| Non-transaction Update | :material-close: | :material-check: |

Conceptually, when a transaction is initiated an instantaneous snapshot is
taken of all KVS in the specified KVDB for which transactions are enabled.
The transaction may then be used to read or update KV pairs in these KVS
snapshots.

Snapshot isolation is enforced by failing updates that collide with updates
in concurrent transactions, after which the transaction may be aborted and
retried.
In rare cases, the collision detection mechanism may produce false positives.

HSE implements asynchronous (non-durable) transaction commits.
Committed transactions are made durable either via explicit HSE API calls,
or automatically within the durability
interval ([`dur_intvl_ms`](../gs/params.md#kvdb-runtime-parameters))
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
    with KVS storing segmented keys, **and** where a filter is specified
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

There are two types of cursors: non-transaction and transaction.

A non-transaction cursor iterates over a KVS snapshot that is taken at the
time the cursor is created. However, the cursor's view may be explicitly
updated to the latest snapshot of the KVS at any time.
A non-transaction cursor can be created for a KVS independent of whether
the KVS was opened with transactions enabled or disabled.

A transaction cursor iterates over the KVS snapshot associated with
an active transaction, *including* any updates made in that transaction.
If the transaction commits or aborts before the cursor is destroyed,
the cursor's view reverts to the KVS snapshot taken at the time the
transaction first became active.  I.e., updates made in the transaction
are no longer in the cursor's view.
By definition a transaction cursor can only be created for a KVS that was
opened with transactions enabled.  A transaction cursor's view cannot be
explicitly updated.


## Durability Controls

HSE provides the `hse_kvdb_sync()` API call to flush cached KVDB updates
to stable storage, either synchronously or asynchronously.
All cached updates are flushed, whether from non-transaction operations
or committed transactions.
In the normal case where journaling is enabled
([`dur_enable`](../gs/params.md#kvdb-runtime-parameters)), cached updates are
written to the journal on stable storage.  Otherwise, cached updates are
written directly to a KVDB [media class](../gs/storage.md#media-classes)
on stable storage.

HSE also supports automatically flushing cached KVDB updates to the
journal on stable storage.  The frequency for automatically flushing
cached updates is controlled by the durability interval
([`dur_intvl_ms`](../gs/params.md#kvdb-runtime-parameters)) configured
for a KVDB.


## Multithreading

HSE supports highly-concurrent multithreaded applications, and most functions
in the HSE API are thread-safe.  However, there are a few exceptions, as
documented in the [API reference](apis.md).


## Delete Semantics

Delete operations logically remove KV pairs from a KVS.
However, HSE implements physical removal as a background operation, and hence
capacity is not freed immediately.
