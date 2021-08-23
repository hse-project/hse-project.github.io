# Configure Storage

HSE uses the mpool kernel module to store data.
Mpool implements an object storage device interface on SSD volumes.

The term *volume* is used generically here to refer to a

* Physical drive or drive partition
* Logical drive, such as a Linux LVM volume, a SAN array volume, or a
cloud storage volume

We recommend using logical volumes when configuring mpools for HSE
storage.  Logical volumes provide greater flexibility in managing capacity
and performance, among other benefits.

## Storage Configuration Example

The following example demonstrates configuring an mpool to store an
HSE key-value database (KVDB).  The mpool is configured with a
single *media class* (class of solid-state storage), which is the common case.

In this example, Linux LVM is used to create a logical volume striped on
two physical SSDs.  This volume is then used to configure the
required *capacity* media class for the mpool.


### Configure a logical volume

Configure a striped logical volume from a volume group comprising
two physical SSDs.

    $ sudo vgcreate vg_nvmeSSD /dev/nvme1n1 /dev/nvme2n1
    $ sudo lvcreate -L 1TB -i 2 -I 64 -n mydb_capacity vg_nvmeSSD


### Configure an mpool

Configure an mpool using the `mpool` CLI.  This creates an mpool
device file `/dev/mpool/<mpool name>`.  Mpool uses the standard Linux
security model whereby each mpool (device file) has an owner (UID),
group owner (GID), and mode bits controlling access.
In this example, `jdoe` is used for the UID and GID.

We also specify a *media block* (mblock) size for the capacity media
class of 32MB, which is recommended for all HSE media class devices.

    $ sudo mpool create mydb /dev/vg_nvmeSSD/mydb_capacity uid=jdoe gid=jdoe mode=0600 capsz=32


### View the mpool

You can now view information about the mpool using the `mpool` CLI, and see
it in the device file namespace.

    $ sudo mpool list
    MPOOL    TOTAL    USED   AVAIL  CAPACITY  LABEL    HEALTH
    mydb     1.00t   1.16g    972g     0.12%    raw   optimal

    $ ls -l /dev/mpool
    crw------- 1 jdoe jdoe 238, 1 Mar 18 18:44 mydb
    


### Summary

The mpool `mydb` can now be used to [create a KVDB](create-kvdb.md).


## Best Practices

See the [mpool Wiki](https://github.com/hse-project/mpool/wiki)
for complete information on configuring
and managing mpool storage, including increasing mpool capacity, and
configuring multiple media classes.
The `mpool` CLI also contains embedded help.

Best practices for configuring an mpool for HSE storage include
the following.

* Use SSD-backed volumes.  HSE is designed and optimized for SSD
performance characteristics.
* Configure volumes with a 4KB logical block size whenever possible.
* When using Linux LVM to configure logical volumes, specify a `stripesize`
of 64KB for striped volumes.
* Configure mpools with a 32MB *media block* (mblock) size, which is the
default.
* Configure mpools with 5% spare capacity in each media class, which is the
default.
* Configure mpools with 40% more capacity than required to store
key-value data to accommodate space amplification from HSE metadata
and deferred deletes.  Keep in mind that mpool capacity can be increased,
though not while the stored KVDB is active (in use).
