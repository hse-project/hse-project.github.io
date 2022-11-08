# System Requirements

The following are system requirements for running HSE applications.


## Hardware

Hardware requirements are largely dictated by the application embedding HSE
and the amount of data stored.  The following are general guidelines.

* **Architecture**: 64-bit Intel&reg;/AMD (x86_64) or IBM Z&reg; (s390x)
* **Memory**: 32 GB or more
* **Block Storage**: SSD volumes *only*; use NVMe for best performance
* **Persistent Memory** (optional): must support a DAX-enabled file system

If a file system storing a KVDB [media class](storage.md#media-classes) is configured on a
logical block device comprising multiple physical block devices, such as when using XFS with LVM,
performance can be **significantly** improved by balancing these physical devices across NUMA nodes.
Tools like [`lstopo(1)`](https://linux.die.net/man/1/lstopo) can be helpful in creating and
verifying a balanced configuration.

For the single logical or physical block device configured with a file system for use with HSE,
performance can also be **significantly** improved by setting the read-ahead to the greater
of the device default or 128 KiB.  For example:

```shell
cat /sys/block/nvme0n1/queue/read_ahead_kb
128
```

## Operating System

HSE should work with most modern Linux&reg; 64-bit operating system
distributions.  We have run HSE on the following:

* Red Hat&reg; Enterprise Linux&reg; (RHEL) 8 and 9
* Ubuntu&reg; 18.04, 20.04, and 22.04
* Fedora&reg; 35 and 36


## File System

HSE requires the following file system features.

* `fallocate(2)` with modes zero (0), `FALLOC_FL_PUNCH_HOLE`,
`FALLOC_FL_KEEP_SIZE`
* `openat(2)` with flag `O_DIRECT`
* DAX if the file system will host a [pmem media class](storage.md#media-classes)

Several common file systems support these features, including XFS and ext4.
For most HSE applications we recommend using XFS.

!!! info
    File systems hosting pmem media classes should be mounted with the
    option `-o dax=always`.


## Virtual Memory

HSE performance and quality of service (QoS) can be **significantly**
improved by configuring
[huge pages](https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt)
and other virtual memory
[tuning parameters](https://www.kernel.org/doc/Documentation/sysctl/vm.txt).
For most HSE applications we recommend the following settings.

```shell
sudo sysctl -w vm.nr_hugepages=256
sudo sysctl -w vm.swappiness=1
sudo sysctl -w vm.dirty_background_ratio=5
sudo sysctl -w vm.dirty_ratio=15
```
