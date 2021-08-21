# Benchmarking Tips

The following are tips for benchmarking HSE applications.


## System Requirements

The system running the HSE application should meet the specified
[requirements](../gs/sysreqs.md).  In particular:

* Configure huge pages as documented
* Balance storage devices across NUMA nodes when applicable


## Configuration Parameters

In the HSE application or [`kvdb.conf`](../gs/params.md#kvdbconf-json-file)
file, provide appropriate values for at least the
following parameters.

KVDB [parameters](../gs/params.md#kvdb-parameters):

* `throttle_init_policy` with a value determined by `kvdb_profile`
* `dur_intvl_ms` with a value appropriate for the application
* `dur_mclass=staging` if a
[staging media class](../gs/storage.md#media-classes) is configured for the KVDB

KVS [parameters](../gs/params.md#kvs-parameters):

* `value_compression=lz4` for all KVSs, *unless* the application performs
its own value compression
