# System Requirements

The following are system requirements for running HSE applications.


## Hardware

Hardware requirements are largely dictated by the application embedding HSE
and the amount of data stored.  The following are general guidelines.

* **CPU**: x86_64; 3.0 GHz or higher; 16 threads or more
* **Memory**: 32 GB or more
* **Storage**: SSD volumes *only*; use NVMe for best performance

If [KVDB storage](storage.md) is configured on multiple devices, such
as when using XFS with LVM, performance can be **significantly** improved by
balancing these devices across NUMA nodes.
Tools like [`lstopo`](https://linux.die.net/man/1/lstopo) can
be helpful in creating and verifying a balanced configuration.


## Operating System

HSE should work with most modern Linux&reg; 64-bit operating system
distributions.  We have run HSE on the following.

* Red Hat&reg; Enterprise Linux&reg; 8 (RHEL 8)
* Ubuntu&reg; 18.04


## File System

HSE requires the following file system features.

* `fallocate(2)` with modes zero (0), `FALLOC_FL_PUNCH_HOLE`,
`FALLOC_FL_KEEP_SIZE`
* `openat(2)` with flag O_DIRECT

Several common file systems support these features, including XFS and ext4.
For most HSE applications we recommend using XFS.


## Virtual Memory

HSE performance and quality of service (QoS) can be **significantly**
improved by configuring
[huge pages](https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt).
We recommend setting `vm.nr_hugepages=256` on your system.
