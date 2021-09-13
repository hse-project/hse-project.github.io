# Command Line Interface

Applications will normally use the HSE API to create and manage a KVDB.
However, the HSE command line interface (CLI) can also be used for these
tasks.  The CLI is itself an HSE application.

Below are several usage examples which assume the following.

* `/var/bulk` is a file system on storage suitable for a capacity media class
* `/var/fast` is a file system on storage suitable for a staging media class

See the discussion on [KVDB storage](storage.md) for more details on
media classes.


## Create a KVDB

Create a KVDB taking all the defaults.

```shell
mkdir /var/bulk/kvdb1
hse kvdb create /var/bulk/kvdb1
```

The KVDB home directory is `/var/bulk/kvdb1`, and the required
capacity media class directory defaults to `/var/bulk/kvdb1/capacity`.

Next, create a KVDB specifying
[parameters](params.md#kvdb-parameters)
for both the required capacity and optional staging media class directories.

```shell
mkdir /var/bulk/kvdb2 && mkdir /var/bulk/capacity2 && mkdir /var/fast/staging2
hse kvdb create /var/bulk/kvdb2 storage.capacity.path=/var/bulk/capacity2 storage.staging.path=/var/fast/staging2
```

The KVDB home directory is `/var/bulk/kvdb2`, the capacity media class
directory is `/var/bulk/capacity2`, and the staging media class directory
is `/var/fast/staging2`.


## Create a KVS

Create a KVS in a KVDB taking all the defaults.

```shell
hse kvs create /var/bulk/kvdb1 kvs1
```

The KVS named `kvs1` is created in KVDB home directory `/var/bulk/kvdb1`.
KVS `kvs1` is created with the default key prefix
length ([`prefix.length`](params.md#kvs-create-time-parameters)) of zero (0).

Next, create a KVS specifying the key prefix length.

```shell
hse kvs create /var/bulk/kvdb2 kvs1 prefix.length=8
```

The KVS named `kvs1` is created in KVDB home directory `/var/bulk/kvdb2`.
KVS `kvs1` is created with the specified key prefix length of 8 bytes.


## Get KVDB Info

Get general information about a KVDB.

```shell
hse kvdb info /var/bulk/kvdb1
```

This command displays general information for the KVDB
home directory `/var/bulk/kvdb1`, including its KVS list.


## Get KVDB Storage Info

Get information about the media classes configured for a KVDB.

```shell
hse storage info /var/bulk/kvdb1
```

This command displays media class information for the KVDB
home directory `/var/bulk/kvdb1`, including storage space metrics.

These storage space metrics include:

* **Total** space in the file systems hosting the KVDB media classes
* **Available** space in the file systems hosting the KVDB media classes
* Space **allocated** for the KVDB
* Space **used** by the KVDB, which is always less than or equal to the
allocated space


## Add a KVDB Media Class

Add a staging media class to an existing KVDB.

```shell
mkdir /var/fast/staging1
hse storage add /var/bulk/kvdb1 storage.staging.path=/var/fast/staging1
```

The staging media class directory `/var/fast/staging1` is configured for
the KVDB home directory `/var/bulk/kvdb1`.

This command can only be used to add a staging media class to a KVDB.
The command will fail if either the KVDB already has a staging media class
or if an application has the KVDB open.

The next time an application opens the KVDB, the newly added
staging media class will be used for KVS storage as determined by the
[`mclass.policy`](params.md#kvs-runtime-parameters)
parameter for each KVS.


## Compact a KVDB

HSE implements the physical removal of logically deleted data via a background
operation called compaction.  Though generally not required, compaction can
be initiated manually.
Be aware that compaction can take **several minutes** or longer depending on
the amount of data stored in the KVDB, among many other factors, so a
timeout can be specified in seconds.

```shell
hse kvdb compact --timeout 120 /var/bulk/kvdb1
```

The KVDB home directory is `/var/bulk/kvdb1`,
and compaction is started with a timeout of 120 seconds.
If an application has the KVDB open, the compaction may continue past the
timeout value.  In this case, the status of the compaction can be queried.

```shell
hse kvdb compact --status /var/bulk/kvdb1
```

A compaction operation can also be canceled.

```shell
hse kvdb compact --cancel /var/bulk/kvdb1
```


## Drop a KVS

Drop (delete) a KVS in a KVDB.

```shell
hse kvs drop /var/bulk/kvdb2 kvs1
```

The KVS named `kvs1` is dropped from the KVDB home directory
`/var/bulk/kvdb2`.


## Drop a KVDB

Drop (delete) a KVDB and all of its KVSs.

```shell
hse kvdb drop /var/bulk/kvdb1
hse kvdb drop /var/bulk/kvdb2
```

The KVDBs with home directories `/var/bulk/kvdb1` and `/var/bulk/kvdb2`
are dropped.
