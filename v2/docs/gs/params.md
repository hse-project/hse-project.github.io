# Configuration Parameters

HSE defines global, KVDB, and KVS configuration parameters as described
below.  These are classified as either *create-time* parameters,
which apply when an application creates a KVDB or KVS,
or *runtime* parameters, which apply each time an application
initializes the HSE library or opens a KVDB or KVS.

## Global Parameters

Global parameters are runtime parameters that apply at the application level.
These parameters may be specified in the `hse_init()` API call or in the
optional [`hse.conf`](#hseconf-json-file) JSON file
in the [runtime home](storage.md#kvdb-and-runtime-homes) directory,
which is also specified in `hse_init()`.

For `hse_init()` API calls, specify global parameters in the form
`<param>=<value>`.  For example, `socket.enabled=false`.

The following global parameters are part of the stable API.


| Parameter | Default | Description |
| :-- | :-- | :-- |
| `logging.enabled` | `true` | Logging mode (false==disabled, true==enabled) |
| `logging.structured` | `false` | Logging style (false==basic, true==structured) |
| `logging.destination` | `syslog` | Log destination (stdout, stderr, file, syslog) |
| `logging.path` | `<runtime home>/hse.log` | Log file when logging.destination==file |
| `logging.level` | `7` | Logging severity level (0==emergency; 7==debug) |
| `socket.enabled` | `true` | REST interface mode (false==disabled, true==enabled) |
| `socket.path` | `/tmp/hse-<pid>.sock` | UNIX domain socket file when socket.enabled==true |


## KVDB Parameters

KVDB parameters apply when a KVDB is created or opened.

### KVDB Create-time Parameters

KVDB create-time parameters may be specified in the `hse_kvdb_create()` API
call or when using the CLI to create a KVDB.  In either case, specify
KVDB create-time parameters in the form `<param>=<value>`.
For example, `storage.capacity.path=/path/to/capacity/dir`.

The following KVDB create-time parameters are part of the stable API.

| Parameter | Default | Description |
| :-- | :-- | :-- |
| `storage.capacity.path` | `<KVDB home>/capacity` | Capacity media class directory |
| `storage.staging.path` | <none> | Staging media class directory |


### KVDB Runtime Parameters

KVDB runtime parameters may be specified in the `hse_kvdb_open()` API call
or in the optional [`kvdb.conf`](#kvdbconf-json-file) JSON file in the
[KVDB home](storage.md#kvdb-and-runtime-homes) directory,
which is also specified in `hse_kvdb_open()`.

For `hse_kvdb_open()` API calls, specify KVDB runtime parameters in the form
`<param>=<value>`.  For example, `durability.interval_ms=1000`.

The following KVDB runtime parameters are part of the stable API.

| Parameter | Default | Description |
| :-- | :-- | :-- |
| `read_only` | `false` | Access mode (false==read/write, true==read-only) |
| `durability.enabled` | `true` | Journaling mode (false==disabled, true==enabled) |
| `durability.interval_ms` | `100` | Max time data is cached (in milliseconds) when durability.enabled==true |
| `durability.mclass` | `capacity` | Media class for journal (capacity, staging) |
| `throttling.init_policy` | `default` | Ingest throttle at startup (light, medium, default) |


#### Durability Settings

The KVDB durability parameters control how HSE journals updates for that
KVDB to provide for recovery in the event of a failure.

The parameter `durability.enabled` determines whether or not journaling
is enabled.
In general, you should always set this to `true`.  As a rare exception,
applications that implement their own form of durability may want to
disable HSE journaling to increase performance.

The parameter `durability.interval_ms` specifies the frequency (in milliseconds)
for automatically flushing cached updates to the journal on stable storage.
Increasing this value may improve performance but also increases the amount
of data that may be lost in the event of a failure.

The parameter `durability.mclass` specifies the media class for storing journal
files.  In general, best performance is achieved by storing the journal files
on the fastest media class configured for a KVDB.

See the discussion on HSE
[durability controls](../dev/concepts.md#durability-controls)
for additional details.


#### Initial Throttle Setting

On startup, HSE throttles the rate at which it processes updates in a
KVDB, referred to as the *ingest rate*.  HSE increases the ingest rate for
the KVDB until it reaches the maximum sustainable value for the underlying
storage.  This ramp-up process can take up to **200 seconds**.

For benchmarks, this initial throttling can *greatly* distort results.
In general operation, this initial throttling may impact the time
before a service is fully operational.

The `throttling.init_policy` parameter can be used to achieve the maximum
ingest rate in far less time.  It specifies a relative initial throttling
value of `light` (minimum), `medium`, or `default` (maximum) throttling.

Setting the `throttling.init_policy` parameter improperly for the underlying
storage can cause the durability interval (`durability.interval_ms`) to be violated
or internal indexing structures to become unbalanced for a period of time.
For example, this may occur if `throttling.init_policy` is set to `light`
with relatively slow KVDB storage.

The `kvdb_profile` tool is provided to determine an appropriate
`throttling.init_policy` setting for your KVDB storage.
You can run it as follows.

```shell
kvdb_profile /path/to/capacity/storage/for/the/kvdb
```

The path specified in `kvdb_profile` should be a directory in the file
system hosting the capacity media class for the KVDB of interest.
Use the output of `kvdb_profile` to specify the `throttling.init_policy` value
for that KVDB.


## KVS Parameters

KVS parameters apply when a KVS is created or opened.

### KVS Create-time Parameters

KVS create-time parameters may be specified in the `hse_kvdb_kvs_create()` API
call or when using the CLI to create a KVS.  In either case, specify
KVS create-time parameters in the form `<param>=<value>`.
For example, `prefix.length=8`.

The following KVS create-time parameters are part of the stable API.

| Parameter | Default | Description |
| :-- | :-- | :-- |
| `prefix.length` | `0` | Key prefix length (bytes) |


!!! tip
    The KVS name `default` is reserved and may not be used in
    `hse_kvdb_kvs_create()` API calls or with the CLI.


### KVS Runtime Parameters

KVS runtime parameters may be specified in the `hse_kvdb_kvs_open()` API call
or in the optional [`kvdb.conf`](#kvdbconf-json-file) JSON file in the
[KVDB home](storage.md#kvdb-and-runtime-homes) directory,
which is also specified in `hse_kvdb_open()`.

For `hse_kvdb_kvs_open()` API calls, specify KVS runtime parameters in the
form `<param>=<value>`.  For example, `compression.value.algorithm=lz4`.

The following KVS runtime parameters are part of the stable API.

| Parameter | Default | Description |
| :-- | :-- | :-- |
| `transactions.enabled` | `false` | Transaction mode (false==disabled, true==enabled) |
| `mclass.policy` | `capacity_only` | See discussion below for values |
| `compression.value.algorithm` | `none` | Value compression method (none, lz4) |
| `compression.value.min_length` | `12` | Value length above which compression is attempted (bytes) |


#### Transaction Mode

When a KVS is opened, the `transactions.enabled` value determines whether
or not transactions are enabled for the KVS.  This mode may be changed by
closing and reopening the KVS.

See the discussion on HSE [transactions](../dev/concepts.md#transactions)
for additional details.

#### Media Class Usage

The media class usage policy for a KVS defines how the key-value data in
that KVS is stored and managed in a KVDB configured with a staging media class.

Key-value data in a KVS can either be *pinned* to a particular media class,
or *tiered* from the staging media class to the capacity media class as it
ages, as determined by the `mclass.policy` value for the KVS:

* `capacity_only` pins all key-value data to the capacity media class
* `staging_only` pins all key-value data to the staging media class
* `staging_min_capacity` tiers all key-value data
* `staging_max_capacity` pins all key data to the staging media class and
tiers all value data

Of the two tiering options, `staging_max_capacity` will generally yield the
highest throughput, lowest latency, and least write-amplification in the
capacity media class.  The trade-off is more storage required in the
staging media class.

!!! info
    If no staging media class is present, and an `mclass.policy` value other
    than `capacity_only` is specified, a warning is logged and `capacity_only`
    is applied.


## Configuration Files

The following are the JSON file formats for the optional HSE configuration
files.

### hse.conf JSON File

See the discussion on [global parameters](#global-parameters) for definitions,
legal values, and defaults.

```
{
  "logging": {
    "enabled": boolean,
    "structured": boolean,
    "destination": "stdout | stderr | file | syslog",
    "path": "/log/file/path",
    "level": integer
  },
  "socket": {
    "enabled": boolean,
    "path": "/UNIX/socket/file/path"
  }
}
```

### kvdb.conf JSON File

See the discussions on [KVDB runtime parameters](#kvdb-runtime-parameters) and
[KVS runtime parameters](#kvs-runtime-parameters) for definitions,
legal values, and defaults.

```
{
  "read_only": boolean,
  "durability": {
    "enabled": boolean,
    "interval": integer,
    "mclass": "capacity | staging"
  },
  "throttling": {
    "init_policy": "light | medium | default"
  },
  "kvs": {
    "<kvs name>": {
      "transactions": {
        "enabled": boolean
      },
      "mclass": {
        "policy": "see KVS runtime parameter discussion for value strings"
      },
      "compression": {
        "value": {
          "algorithm": "lz4 | none",
          "min_length": integer
        }
      }
    }
  }
}
```

The KVS name `default` is reserved and its parameters apply to all the KVS
in a KVDB.  Parameters specified for a named KVS override those specified via
`default`.


## Precedence of Parameters

The final value for a specific configuration parameter is determined of
follows:

* The built-in default value is applied first
* The value is then overridden by an API (or CLI) setting, if any
* The value is then overridden by an `hse.conf` or `kvdb.conf` setting, if any

This ordering allows the effective value of a configuration parameter
to be modified without recompiling an HSE application.
