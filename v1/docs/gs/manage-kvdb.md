# Manage a KVDB

HSE requires minimal management beyond configuring mpool storage,
creating a KVDB, and optionally defining an associated configuration file
as previously described.
The following examples illustrate the few other aspects of KVS and
KVDB management.

## Managing KVS

Most often a client application will use the HSE API to create and manage
the one or more KVS it needs for storing collections of KV pairs
in accordance with the HSE [data model](../dev/concepts.md#data-model).
However, KVS can also be managed from the `hse` CLI.

### Create a KVS

Continuing with our example KVDB, we create three KVS.

    $ hse kvs create mydb/docData docData.pfx_len=0
    $ hse kvs create mydb/docIdx docIdx.pfx_len=16
    $ hse kvs create mydb/docIdxAlt docIdxAlt.pfx_len=12

    $ hse kvdb list -v
    kvdbs:
    - name: mydb
      label: raw
      kvslist:
        - mydb/docData
        - mydb/docIdx
        - mydb/docIdxAlt

### Destroy a KVS

Similarly, we can remove a KVS from the KVDB, along with any KV data it stores.

    $ hse kvs destroy mydb/docIdxAlt
    $ hse kvdb list -v
    kvdbs:
    - name: mydb
      label: raw
      kvslist:
        - mydb/docData
        - mydb/docIdx


## Managing KVDB

Most KVDB management is related to its lifecycle or storage.

### View Parameters for a KVDB

The parameters for a KVDB can be specified via multiple sources, as previously
discussed.  You can view the parameters in effect for an *active* KVDB,
including all of its KVS, as follows.

    $ hse kvdb params mydb

!!! tip
    For this command to work, the KVDB must be open by a client application.


### Rename or Label a KVDB

As previously noted, the name and label of a KVDB are simply the name
and label of the mpool that stores it.  Hence, the `mpool` CLI is
used to change the name or label of a KVDB.  Note that an mpool (and
hence KVDB) must be deactivated to rename it.

    $ sudo mpool deactivate mydb
    $ sudo mpool rename mydb docDB
    $ sudo mpool activate docDB
    $ sudo mpool set docDB label=Weather_Docs

    $ hse kvdb list -v
    kvdbs:
    - name: docDB
      label: Weather_Docs
      kvslist:
        - docDB/docData
        - docDB/docIdx

### Compact a KVDB

HSE implements the physical removal of logically deleted data
as a background operation.  Physical removal can also be forced
from the `hse` CLI.  This operation can take **several minutes**
depending on the amount of data stored in the KVDB, among
other factors, and so a timeout can be specified.

    $ hse kvdb compact --timeout 120 docDB

If a KVDB is in use by an application, the compaction operation may
continue past the timeout value (specified or default).  In this case,
the status of the compaction can be queried.

    $ hse kvdb compact --status docDB

The compaction can also be canceled.

    $ hse kvdb compact --cancel docDB


### Destroy a KVDB

Finally, a KVDB is deleted by destroying the mpool that stores it.

    $ sudo mpool destroy docDB
    $ hse kvdb list
    No KVDBs found
