# Create a KVDB

After [configuring an mpool](config-storage.md) for HSE storage, you
can create (store) a KVDB in the mpool using the `hse` CLI.

Continuing with the prior
[example](config-storage.md#storage-configuration-example),
we create a KVDB in the mpool `mydb`.

    $ hse kvdb create mydb
    $ hse kvdb list
    kvdbs:
    - name: mydb
      label: raw

The name and label of the KVDB are simply the name and label of the mpool
that stores it.  In a later example, we will update the label to
something more descriptive.

At this point, the KVDB is ready to use with one of the applications that
has already been integrated with HSE, or with your own application.

The remainder of this section defines HSE configuration parameters,
and provides further `hse` CLI usage examples.
For applications we have integrated with HSE, detailed configuration
information is provided in their individual sections of this documentation.


## Configuration Parameters

HSE configuration parameters can be specified in several ways.

* Directly in `hse` CLI commands as `<param>=<value>` pairs
* From a configuration file passed to the `hse` CLI with the `-c` option
* In HSE API calls using functions for specifying parameters directly
or reading them from a configuration file

The most common (and preferred) method is for an application to use
HSE API calls to read parameter values from a configuration file, and then
to augment or override those values as appropriate for that application.

HSE parameters apply to either a KVDB, or to a key-value store (KVS) within
a KVDB.  A KVS in a KVDB is analogous to a table in a relational database
in that each KVS stores an independent collection of key-value (KV) pairs.
These and other [HSE concepts](../dev/concepts.md) are described in
the section on developing HSE applications.

When using the `hse` CLI, only persistent parameters need to be specified.
Specifying non-persistent parameters has no effect.

The KVDB and KVS parameter tables below specify the HSE version at which
a parameter was introduced.  If the version column is blank, the
parameter has been available since the initial release.

!!! note
    The configuration parameters listed below are part of the stable HSE API.
    Configuration files installed for applications that have been
    integrated with HSE may use experimental parameters.


## KVDB Parameters

| Parameter | Description | Default | Persistent | Version |
| :-- | :-- | --: | --: | --: |
| `dur_intvl_ms` | Max time data is cached before flushing to media (ms) | 500 | No | |
| `log_lvl` | Syslog severity level (0=emergency; 7=debug) | 7 | No | |
| `read_only` | Read-only mode enabled (0=disabled; 1=enabled) | 0 | No | |
| `throttle_init_policy` | Ingest throttle at startup (light; medium; default) | default | No | 1.8.0 |

Below are additional details on setting several of these KVDB parameters.

### Durability Interval (dur_intvl_ms)

The durability interval for a KVDB is the frequency at which cached
updates from committed transactions and stand-alone KV operations
are flushed to stable storage.  This interval is specified by the
`dur_intvl_ms` parameter in units of milliseconds.

The concepts section provides additional discussion on
HSE [durability controls](../dev/concepts.md#durability-controls).

### Initial Throttle (throttle_init_policy)

On startup, a KVDB throttles the rate at which it processes puts
and deletes of KV pairs, referred to as the ingest rate.
KVDB increases the ingest rate until it reaches the maximum
sustainable value for the underlying mpool storage.
This ramp-up process can take on the order of **50 to 200 seconds**.

For benchmarks, this initial throttling can *greatly* distort results.
In production environments, this initial throttling may impact the time
before a service is fully operational.

The `throttle_init_policy` parameter can be used to achieve the maximum
ingest rate in far less time.  It specifies a relative initial throttling
value of `light`, `medium`, or `default` (maximum) throttling.

Setting the `throttle_init_policy` parameter improperly for the underlying
mpool storage can cause the durability interval (`dur_intvl_ms`) to be violated,
or internal indexing structures to become unbalanced until KVDB determines
the maximum sustainable ingest rate for the mpool.

The `mpool_profile` tool is provided to determine an appropriate
`throttle_init_policy` setting for an mpool as follows

    $ /opt/hse/bin/mpool_profile -v mydb

Use the output of `mpool_profile` to specify the `throttle_init_policy` value
for a KVDB.  If the mpool configuration changes, for example a staging media
class is added, rerun `mpool_profile` as the `throttle_init_policy` value
may change.

!!! tip
    mpool_profile may run for **several minutes** before producing output.


## KVS Parameters

| Parameter | Description | Default | Persistent | Version |
| :-- | :-- | --: | --: | --: |
| `pfx_len` | Key prefix length (bytes) | 0 | Yes | |
| `value_compression` | Value compression method (lz4; none) | none | No | 1.8.0 |
| `mclass_policy` | Media class usage policy (see discussion for values) | capacity_only | No | 1.8.0 |

Below are additional details on setting several of these KVS parameters.

### Key Prefix Length (pfx_len)

The HSE [data model](../dev/concepts.md#data-model) requires that a
KVS store either

* multi-segment keys, with the KVS `pfx_len` parameter set to the key prefix
length, or
* unsegmented keys, with the KVS `pfx_len` parameter set to zero (0).

Applications must adhere to this data model, and its associated
[best practices](../dev/best-practices.md), to achieve maximum performance
with HSE.

### Media Class Usage (mclass_policy)

The mpool storage for a KVDB can be configured with both the required
capacity media class and an optional staging media class.  For example,
an mpool might be created with a capacity media class on a volume backed
by value-oriented SATA QLC SSDs, and a staging media class on a volume
backed by high-end NVMe TLC SSDs.
See the [mpool Wiki](https://github.com/hse-project/mpool/wiki)
for complete information on configuring and managing mpool storage.

The media class usage policy for a KVS defines how the KVS is stored when
a staging media class is present.
The KVS, or more precisely the KV data in that KVS, can be either *pinned* to
a particular media class, or *tiered* from the staging media class to the
capacity media class as it ages, as specified by its `mclass_policy`
parameter.

| mclass_policy Value | Description | Staging Storage for Tiering |
| :-- | :-- | --: |
| `capacity_only` | KVS pinned to capacity media class | |
| `staging_only` | KVS pinned to staging media class | |
| `staging_min_capacity` | KVS keys and values tiered | Up to 100GB |
| `staging_max_capacity` | KVS keys pinned to staging media class with values tiered | Up to 100GB + key data + 20% of value data |

Of the two tiering options, `staging_max_capacity` will in general yield the
highest throughput, lowest latency, and least write-amplification in the
capacity media class.  The amount of staging storage consumed when
tiering depends on many factors, but the estimates above provide
reasonable guidelines for planning.

Regardless of the media class usage policies selected for the KVS in a KVDB,
always apply the [best practices](config-storage.md#best-practices) for
configuring mpool storage.  Also be aware that when the staging
media class is present, a KVDB will consume up to approximately 50GB of
space in it **independent** of the media class usage policies selected for
its KVS.

!!! note
    If no staging media class is present, and an `mclass_policy` value other
    than `capacity_only` is specified, a warning is logged and `capacity_only`
    is applied.


## Configuration Files

The parameters for a KVDB, and any KVS within that KVDB, can be specified
in a configuration file using [YAML](https://yaml.org) format.
The syntax is mostly easily defined by example.

    api_version: 1
    kvdb:
        dur_intvl_ms: 200
        log_lvl: 6
        throttle_init_policy: light
    kvs:
        pfx_len: 8
        value_compression: lz4
        mclass_policy: capacity_only
    kvs.kvs1:
        pfx_len: 0
        mclass_policy: staging_max_capacity
        
This file specifies a `dur_intvl_ms` of 200, a `log_lvl` of 6, and
a `throttle_init_policy` of `light` for the KVDB.
Every KVS created in the KVDB will have a `pfx_len` of 8 bytes,
a `value_compression` of `lz4`, and an `mclass_policy` of `capacity_only`.
The single exception is the KVS named `kvs1`, which will have a
`pfx_len` of 0 bytes, and an `mclass_policy` of `staging_max_capacity`.

Unspecified parameters get their default values.  Values for parameters which
are persistent, and which have already been applied, are ignored.
The only required key is `api_version` specifying the schema, which
is currently 1.

When a configuration file is passed to the `hse` CLI, any parameters
specified directly on the command line will override those in the
configuration file.
