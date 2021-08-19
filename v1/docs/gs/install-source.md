# Install from Source

HSE can be built and installed from source in a few simple steps.

!!! tip
    Build and install from repo `mpool-kmod`, then `mpool`, and then `hse`.

## Install Dependencies

Install dependencies for your platform.

=== "RHEL 8"

    Install the following tools, libraries, and headers.

    ```
    $ sudo dnf install "@Development Tools" cmake kernel-headers-$(uname -r) kernel-devel-$(uname -r) elfutils-libelf-devel sos rsync libuuid-devel openssl-devel java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel libmicrohttpd libmicrohttpd-devel userspace-rcu userspace-rcu-devel lz4 lz4-devel
    ```

=== "Ubuntu 18.04"

    Download CMake [3.13.2](https://github.com/Kitware/CMake/releases/tag/v3.13.2)
    or later and [install](https://cmake.org/install/) on your system.

    Install the following tools, libraries, and headers.

    ```
    $ sudo apt-get install build-essential libblkid-dev gettext autopoint autoconf bison libtool pkg-config openjdk-8-jdk libmicrohttpd-dev liburcu-dev libyaml-dev liblz4-1 liblz4-dev curl
    ```

=== "RHEL 7"

    Download CMake [3.11.4](https://github.com/Kitware/CMake/releases/tag/v3.11.4)
    or later and [install](https://cmake.org/install/) on your system.

    Install the following tools, libraries, and headers.

    ```
    $ sudo yum install "@Development Tools" kernel-headers-$(uname -r) kernel-devel-$(uname -r) elfutils-libelf-devel sos rsync libuuid-devel openssl-devel java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel libmicrohttpd libmicrohttpd-devel userspace-rcu userspace-rcu-devel lz4 lz4-devel
    ```


## Build mpool-kmod Repo

Clone the latest release tag from the `mpool-kmod`
[repo](https://github.com/hse-project/mpool-kmod/releases),
which contains the mpool kernel module source.
Releases are named `rX.Y.Z`, where `X.Y.Z` is the version.

For example

    $ git clone https://github.com/hse-project/mpool-kmod.git
    $ cd mpool-kmod
    $ git checkout rX.Y.Z

Build and install for your platform as follows.

=== "RHEL 8"

    ```
    $ make package
    $ sudo dnf install ./builds/$(uname -n)/$(uname -r)/rpm/release/kmod-mpool-$(uname -r)-X.Y.Z*.rpm
    ```

    !!! note
        For release `r1.7.1` use package path `./builds/release/`.

=== "Ubuntu 18.04"

    ```
    $ make package
    $ sudo apt-get install ./builds/$(uname -n)/$(uname -r)/deb/release/kmod-mpool-$(uname -r)_X.Y.Z*.deb
    ```

    !!! note
        Ubuntu requires release `r1.8.0` or later.

=== "RHEL 7"

    ```
    $ make package
    $ sudo yum install ./builds/$(uname -n)/$(uname -r)/rpm/release/kmod-mpool-$(uname -r)-X.Y.Z*.rpm
    ```

    !!! note
        For release `r1.7.1` use package path `./builds/release/`.


## Validate mpool Loaded

Validate that the kernel module loaded correctly by confirming that `mpool`
appears in the output of the `lsmod` command.  If it does not appear,
try manually loading the kernel module using `sudo modprobe mpool`.

If you update your kernel, you will need to re-build and install the
mpool kernel module.


## Build mpool Repo

Clone the latest release tag from the `mpool`
[repo](https://github.com/hse-project/mpool/releases),
which contains the mpool user-space API and CLI source.
Releases are named `rX.Y.Z`, where `X.Y.Z` is the version.

For example

    $ git clone https://github.com/hse-project/mpool.git
    $ cd mpool
    $ git checkout rX.Y.Z

Build and install for your platform as follows.

=== "RHEL 8"

    ```
    $ make package
    $ sudo dnf install ./builds/$(uname -n)/rpm/release/mpool-X.Y.Z*.rpm
    $ sudo dnf install ./builds/$(uname -n)/rpm/release/mpool-devel-X.Y.Z*.rpm
    ```

    !!! note
        For release `r1.7.1` use package path `./builds/release*/`.

=== "Ubuntu 18.04"

    ```
    $ make package
    $ sudo apt-get install ./builds/$(uname -n)/deb/release/mpool_X.Y.Z*.deb
    $ sudo apt-get install ./builds/$(uname -n)/deb/release/mpool-devel_X.Y.Z*.deb
    ```

    !!! note
        Ubuntu requires release `r1.8.0` or later.

=== "RHEL 7"

    ```
    $ make package
    $ sudo yum install ./builds/$(uname -n)/rpm/release/mpool-X.Y.Z*.rpm
    $ sudo yum install ./builds/$(uname -n)/rpm/release/mpool-devel-X.Y.Z*.rpm
    ```

    !!! note
        For release `r1.7.1` use package path `./builds/release*/`.


## Build hse Repo

Clone the latest release tag from the `hse`
[repo](https://github.com/hse-project/hse/releases),
which contains the HSE source.
Releases are named `rX.Y.Z`, where `X.Y.Z` is the version.

For example

    $ git clone https://github.com/hse-project/hse.git
    $ cd hse
    $ git checkout rX.Y.Z

Build and install for your platform as follows.

=== "RHEL 8"

    ```
    $ make package
    $ sudo dnf install ./builds/$(uname -n)/rpm/release/hse-X.Y.Z*.rpm
    $ sudo dnf install ./builds/$(uname -n)/rpm/release/hse-devel-X.Y.Z*.rpm
    ```

    !!! note
        For release `r1.7.1` use package path `./builds/release/`.

=== "Ubuntu 18.04"

    ```
    $ make package
    $ sudo apt-get install ./builds/$(uname -n)/deb/release/hse_X.Y.Z*.deb
    $ sudo apt-get install ./builds/$(uname -n)/deb/release/hse-devel_X.Y.Z*.deb
    ```

    !!! note
        Ubuntu requires release `r1.8.0` or later.

=== "RHEL 7"

    ```
    $ make package
    $ sudo yum install ./builds/$(uname -n)/rpm/release/hse-X.Y.Z*.rpm
    $ sudo yum install ./builds/$(uname -n)/rpm/release/hse-devel-X.Y.Z*.rpm
    ```

    !!! note
        For release `r1.7.1` use package path `./builds/release/`.

