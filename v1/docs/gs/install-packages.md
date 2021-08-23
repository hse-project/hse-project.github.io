# Install from Packages

HSE can be installed from release packages in a few simple steps.

!!! tip
    Follow the [instructions](install-source.md) to install all dependencies
    for your platform, and to build and install the `mpool-kmod` repo from
    source,  **before** installing the `mpool` repo release packages,
    followed by the `hse` repo release packages.

## Download and Install mpool Packages

Download the latest `mpool` and `mpool-devel`
[packages](https://github.com/hse-project/mpool/releases)
for your platform, which contain the user-space API library, CLI, and header
files for the mpool kernel module.
Package names start with `mpool*X.Y.Z` and `mpool-devel*X.Y.Z`,
where `X.Y.Z` is the version.

Install the mpool packages for your platform as follows.

=== "RHEL 8"

    ```
    $ sudo dnf install ./mpool-X.Y.Z*.rpm
    $ sudo dnf install ./mpool-devel-X.Y.Z*.rpm
    ```

=== "Ubuntu 18.04"

    ```
    $ sudo apt-get install ./mpool_X.Y.Z*.deb
    $ sudo apt-get install ./mpool-devel_X.Y.Z*.deb
    ```

=== "RHEL 7"

    ```
    $ sudo yum install ./mpool-X.Y.Z*.rpm
    $ sudo yum install ./mpool-devel-X.Y.Z*.rpm
    ```


## Download and Install hse Packages

Download the latest `hse` and `hse-devel`
[packages](https://github.com/hse-project/hse/releases)
for your platform, which contain the HSE library, CLI, and header files.
Package names start with `hse*X.Y.Z` and `hse-devel*X.Y.Z`,
where `X.Y.Z` is the version.

Install the hse packages for your platform as follows.

=== "RHEL 8"

    ```
    $ sudo dnf install ./hse-X.Y.Z*.rpm
    $ sudo dnf install ./hse-devel-X.Y.Z*.rpm
    ```

=== "Ubuntu 18.04"

    ```
    $ sudo apt-get install ./hse_X.Y.Z*.deb
    $ sudo apt-get install ./hse-devel_X.Y.Z*.deb
    ```

=== "RHEL 7"

    ```
    $ sudo yum install ./hse-X.Y.Z*.rpm
    $ sudo yum install ./hse-devel-X.Y.Z*.rpm
    ```

