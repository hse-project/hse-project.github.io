# Benchmarking Tips

The following are tips for benchmarking HSE applications.


## System Requirements

The system running the HSE application should meet the specified
[requirements](../gs/sysreqs.md).  In particular:

* Configure huge pages and other virtual memory tuning parameters as documented
* Balance storage devices across NUMA nodes when applicable


## Configuration Parameters

In the HSE application or [`kvdb.conf`](../gs/params.md#kvdbconf-json-file)
file, provide appropriate values for at least the
following parameters.

KVDB [parameters](../gs/params.md#kvdb-parameters):

* `throttling.init_policy` with a value determined by `kvdb_profile`
* `durability.interval_ms` with a value appropriate for the application
* `durability.mclass=staging` if a
[staging media class](../gs/storage.md#media-classes) is configured for the KVDB

KVS [parameters](../gs/params.md#kvs-parameters):

* `compression.value.algorithm=lz4` for all KVSs, *unless* the application
performs its own value compression or values are known to not compress
