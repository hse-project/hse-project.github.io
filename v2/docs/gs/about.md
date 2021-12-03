# About

HSE is a fast embeddable key-value store designed for SSDs and persistent
memory.  It is implemented as a C library that links with your
application, directly or via alternate language bindings.


## Overview

HSE provides functions to create and access a key-value database (KVDB).
A KVDB comprises one or more named key-value stores (KVSs), each of which
is an independent collection of key-value pairs.  A KVS is analogous to
a table in a relational database.
The HSE data model enables each KVS in a KVDB to be optimized for how the
key-value pairs it stores will be accessed.

HSE provides the standard operators for managing key-value pairs in
a KVS: put, get, and delete.  HSE also provides transactions, cursors,
prefix deletes, and other advanced features.

Details on the HSE programming and data models can be found
[here](../dev/concepts.md).
Details on how KVDB data is stored in file systems can be found
[here](storage.md).


## Project Repos

The HSE project includes the following repos:

* [`hse`](https://github.com/hse-project/hse)
contains the HSE library source
* [`hse-python`](https://github.com/hse-project/hse-python)
contains HSE Python bindings
* [`hse-mongo`](https://github.com/hse-project/hse-mongo)
is a fork that integrates HSE with MongoDB
* [`hse-ycsb`](https://github.com/hse-project/hse-ycsb)
is a fork that integrates HSE with the YCSB benchmark
* [`rfcs`](https://github.com/hse-project/rfcs)
contains RFCs for major enhancements to the HSE library or other project
components
* [`hse-project.github.io`](https://github.com/hse-project/hse-project.github.io)
contains the source for this documentation

Instructions for building, installing, and contributing to repo contents are
in their local `README.md` and `CONTRIBUTING.md` files.
Forked repos, such as `hse-mongo` and `hse-ycsb`, contain this information
in `README.md` and `CONTRIBUTING.md` files in the `hse` directory within
those repos.  To make these easy to locate, there are symlinks to them named
`README_HSE.md` and `CONTRIBUTING_HSE.md` in the repo root directory.


## Using HSE

After building and installing the `hse` repo, you can develop HSE
applications in C/C++ by including the
[`hse.h`](https://github.com/hse-project/hse/blob/master/include/hse/hse.h)
header file and linking with `libhse-2`.
Information on using an alternate HSE language binding is included
in its associated repo.


## Releases

See the release section of each HSE project repo for specific
releases and associated release notes.
For example, `hse` releases can be found
[here](https://github.com/hse-project/hse/releases).

Releases of the HSE library and associated language bindings use
[semantic versioning](https://semver.org).
Releases of forked repos use a versioning scheme that is documented
in their associated `README.md`.
