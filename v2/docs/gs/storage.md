# KVDB Storage

The following provides an overview of important KVDB storage
concepts.

## Media Classes

The KVDB storage model is based on the concept of media classes,
where each media class represents a tier of storage.
HSE currently defines two media classes for a KVDB:

* **Capacity**, which is required and represents the bulk (bottom)
tier of storage
* **Staging**, which is optional and represents a faster (higher) tier of
storage

Each media class for a KVDB is simply a directory in a file system.
For example, a KVDB could be configured with a capacity directory
in a file system on cost-optimized SATA QLC SSDs, and a staging
directory in a file system on performance-optimized NVMe TLC SSDs.

The data for a KVDB is stored as a set of files in each of its capacity
and (optional) staging directories.

## KVDB and Runtime Homes

Every KVDB has a home directory with files storing its metadata.
A KVDB home directory may also contain an optional
[`kvdb.conf`](params.md#kvdbconf-json-file) file with
user-defined KVDB and KVS parameter settings.

HSE also defines a runtime home directory for an application embedding HSE.
This runtime home may contain an optional
[`hse.conf`](params.md#hseconf-json-file) file with user-defined global
parameter settings.

!!! info
    Most applications will use a single KVDB with only the capacity media
    class configured.  In this common case, the KVDB and runtime homes
    can be the same directory, and this directory can contain the capacity
    media class.

