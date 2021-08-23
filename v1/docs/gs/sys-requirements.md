# System Requirements

The following are system requirements for successfully deploying HSE
in your environment.

## Hardware Requirements

Hardware requirements are largely dictated by the application embedding HSE,
and the amount of data stored.
The following guidelines are based on experience with previous
application integrations.

* **CPU**: x86_64; 3.0 GHz or higher; 16 threads or more
* **Memory**: 32 GB or more
* **Storage**: SSD volumes *only*; use NVMe for best performance

For systems with multiple direct-attached SSDs, performance can be
**significantly** improved by configuring the SSDs to be balanced
across NUMA nodes.
Tools like [`lstopo`](https://linux.die.net/man/1/lstopo) can
be helpful in creating and verifying a balanced configuration.


## Operating System Requirements

Linux&reg; 64-bit operating system distribution

* Red Hat&reg; Enterprise Linux&reg; 8.2 (RHEL 8.2)
* Ubuntu&reg; 18.04.4 LTS
* Red Hat&reg; Enterprise Linux&reg; 7.9 (RHEL 7.9), which received only
limited release testing

HSE, and the mpool component it depends on, may build and run on other
Linux 64-bit distributions, but only those listed above have been tested
with the latest release.


## Mpool Requirements

Mpool (object storage media pool) is a loadable kernel module
that implements an object storage device interface on SSD volumes.
HSE stores its data in an mpool, versus a file system or raw volume.
Hence, mpool must be installed and configured on the system as
described in this documentation.


## Version Requirements

You must install a supported combination of HSE and mpool
releases from the `hse`, `mpool`, and `mpool-kmod` repos, along with
any prerequisites.  Please review the
[release notes](../help/relnotes.md) for details.
