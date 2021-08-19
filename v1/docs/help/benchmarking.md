# Benchmarking

The following are tips for benchmarking an HSE client application,
whether one of your own, or one we have already integrated
such as [YCSB](../apps/ycsb.md) or [MongoDB](../apps/mongodb.md).
If developing your own application, review the section on
HSE [concepts](../dev/concepts.md) and
follow HSE client [best practices](../dev/best-practices.md).


## Mpool Storage

Configure mpool storage for the client application on a volume with performance
characteristics similar to what will be observed in production.

Follow mpool configuration
[best practices](../gs/config-storage.md#best-practices) for HSE storage.

Use the
[`mpool_profile`](../gs/create-kvdb.md#initial-throttle-throttle_init_policy)
tool to determine the appropriate KVDB `throttle_init_policy` value to use
with the mpool.


## Configuration Parameters

Create an HSE
[configuration file](../gs/create-kvdb.md#configuration-files) for the
client application with at least the following parameter settings:

* `kvdb.throttle_init_policy` with a value determined by `mpool_profile`
* `kvdb.dur_intvl_ms` with a value appropriate for the application
* `kvs.value_compression` with a value of `lz4`, **unless** the application
performs its own value compression
