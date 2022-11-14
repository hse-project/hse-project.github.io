# Benchmarking Tips

The following are tips for benchmarking HSE applications.


## System Requirements

The system running the HSE application should meet the specified
[requirements](../gs/sysreqs.md).  Be certain to:

* Configure huge pages and other virtual memory tuning parameters
* Balance block storage devices across NUMA nodes, when applicable, and configure read-ahead


## Configuration Parameters

In the HSE application or [`kvdb.conf`](../gs/params.md#kvdbconf-json-file)
file, provide appropriate values for at least the
following parameters.

KVDB [parameters](../gs/params.md#kvdb-parameters):

* `throttling.init_policy` as determined by
[`hse storage profile`](../gs/cli.md#profile-kvdb-storage)
in the common case where the KVDB is configured with a capacity media class
* `durability.interval_ms` as appropriate for the application
* `durability.mclass` representing the fastest tier of storage configured
for the KVDB

KVS [parameters](../gs/params.md#kvs-parameters):

* `mclass.policy` maximizing the use of faster tiers of storage for all
KVSs when multiple media classes are configured for a KVDB
* `value.compression.default=on` for all KVSs, *unless* the application
performs its own value compression or values are known to not compress
