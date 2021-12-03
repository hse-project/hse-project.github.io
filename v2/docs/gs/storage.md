# KVDB Storage

The following provides an overview of important KVDB storage
concepts.

## Media Classes

The KVDB storage model is based on the concept of media classes,
where each media class represents a tier of storage.
HSE defines the following media classes for a KVDB:

* **capacity**, representing the bottom (bulk) tier of storage
* **staging**, representing a higher (faster) tier of storage than capacity
* **pmem**, representing byte-addressable persistent memory as the
top (fastest) tier of storage

Each media class for a KVDB is a directory in a file system.
The capacity and staging media classes must reside in a file system
created on block storage.
The pmem media class must reside in a
[DAX-enabled](https://www.kernel.org/doc/Documentation/filesystems/dax.txt)
file system created on persistent memory.
Data for a KVDB is stored as a set of files in each of its configured
media class directories.

See the section on [system requirements](sysreqs.md#file-system) for additional
details on creating file systems for media classes.

!!! info
    HSE does not validate the performance of the media classes configured
    for a KVDB to confirm alignment with this tiered storage model.
    Also, KVDB data in the capacity or staging media classes may be
    cached in DRAM (specifically the OS page cache), and so those media
    classes may outperform pmem for working sets that fit in the DRAM cache.


## Valid Configurations

The following are valid storage configurations for a KVDB:

* A capacity media class only
* A capacity media class plus one or both of a staging or pmem media class
* A pmem media class only

A KVDB can be created with any valid storage configuration.  Later, a media
class can be added to the KVDB provided the result is also a valid
storage configuration.

## Usage Example

A KVDB can be configured with multiple media classes to increase overall
performance and to reduce wear for the capacity media class in terms of
total bytes written (TBW).
For example, a KVDB might be configured with:

* a capacity directory in a file system created on cost-optimized QLC SSDs
* a staging directory in a file system created on performance-optimized TLC SSDs

In this example, the [media class usage policy](params.md#media-class-usage)
(`mclass.policy`) for KVSs in the KVDB could be set to `staging_max_capacity`
to pin all key data to the staging media class and tier all value data from
the staging to the capacity media class.
In addition, the [durability setting](params.md#durability-settings)
for the KVDB controlling journal placement (`durability.mclass`) would be set
to store the journal in the staging media class.

This KVDB configuration would increase overall performance, versus using
the capacity media class only, while also greatly reducing the TBW to the
lower endurance QLC SSDs.

## Home Directory

Every KVDB has a home directory with files storing its metadata.
A KVDB home directory may also contain an optional
[`kvdb.conf`](params.md#kvdbconf-json-file) file with
user-defined KVDB and KVS parameter settings.

When a KVDB is created with a home directory in a file system
on block storage, by default a capacity media class directory is
created within the home directory.
Similarly, when a KVDB is created with a home directory in a DAX-enabled
file system on persistent memory, by default a pmem media class is created
within the home directory.
In the common case where a KVDB is configured with only a single media
class, these defaults result in all data, metadata, and parameter settings
for the KVDB residing within its home directory.
