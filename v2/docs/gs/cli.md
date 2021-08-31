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
mkdir /var/bulk/kvdb1 && cd /var/bulk/kvdb1
hse kvdb create
```

The KVDB home defaults to the current working directory `/var/bulk/kvdb1`,
and the required capacity media class directory defaults
to `/var/bulk/kvdb1/capacity`.

Next create a KVDB specifying the home directory.

```shell
mkdir /var/bulk/kvdb2
hse -C /var/bulk/kvdb2 kvdb create
```

The specified KVDB home directory is `/var/bulk/kvdb2`, and the required
capacity media class directory defaults to `/var/bulk/kvdb2/capacity`.

Finally, create a KVDB specifying the home directory and
[KVDB parameters](params.md#kvdb-parameters)
for both the required capacity and optional staging media class directories.

```shell
mkdir /var/bulk/kvdb3 && mkdir /var/bulk/capacity3 && mkdir /var/fast/staging3
hse -C /var/bulk/kvdb3 kvdb create storage.capacity.path=/var/bulk/capacity3 storage.staging.path=/var/fast/staging3
```

The specified KVDB home directory is `/var/bulk/kvdb3`, the capacity media class
directory is `/var/bulk/capacity3`, and the staging media class directory
is `/var/fast/staging3`.


## Create a KVS

Create a KVS in a KVDB taking all the defaults.

```shell
cd /var/bulk/kvdb1
hse kvs create kvs1
```

The KVDB home defaults to the current working directory `/var/bulk/kvdb1`,
and the KVS named `kvs1` is created there with the default key prefix
length ([`pfx_len`](params.md#kvs-create-time-parameters)) of zero (0).

Next create a KVS specifying the KVDB home directory and KVS key
prefix length.

```shell
hse -C /var/bulk/kvdb2 kvs create kvs1 pfx_len=8
```

The specified KVDB home directory is `/var/bulk/kvdb2`, and the KVS named
`kvs1` is created there with a key prefix length of 8 bytes.


## Get KVDB Information

Get information about a KVDB.

```shell
hse -C /var/bulk/kvdb1 kvdb info
```

This command will print out information about a KVDB, including its home
directory, KVS list, and storage space metrics.

These storage space metrics include:

* **Total** space in the file systems hosting the KVDB media classes
* **Available** space in the file systems hosting the KVDB media classes
* Space **allocated** for the KVDB
* Space **used** by the KVDB, which is always less than or equal to the
allocated space


## Compact a KVDB

HSE implements the physical removal of logically deleted data via a background
operation called compaction.  Though generally not required, compaction can
be initiated manually.
Be aware that compaction can take **several minutes** or longer depending on
the amount of data stored in the KVDB, among many other factors, so a
timeout can be specified in seconds.

```shell
cd /var/bulk/kvdb1
hse kvdb compact --timeout 120
```

If an application has the KVDB open, the compaction may continue past the
timeout value.  In this case, the status of the compaction can be queried.

```shell
hse kvdb compact --status
```

A compaction operation can also be canceled.

```shell
hse kvdb compact --cancel
```


## Drop a KVS

Drop (delete) a KVS in a KVDB.

```shell
hse -C /var/bulk/kvdb2 kvs drop kvs1
```

The specified KVDB home directory is `/var/bulk/kvdb2`, and the KVS named
`kvs1` is dropped from there.


## Drop a KVDB

Drop (delete) a KVDB and all of its KVSs.

```shell
cd /var/bulk/kvdb3
hse kvdb drop
```

The KVDB home defaults to the current working directory `/var/bulk/kvdb3`,
and that KVDB is dropped.

Next drop the remaining KVDBs from these examples specifying their
home directories.

```shell
hse -C /var/bulk/kvdb2 kvdb drop
hse -C /var/bulk/kvdb1 kvdb drop
```