---
hide:
  - toc
---

# API Reference

See the HSE API documentation in the
[`hse.h`](https://github.com/hse-project/hse/blob/master/include/hse/hse.h)
header file.
There are also examples of using the HSE API in the
[`samples`](https://github.com/hse-project/hse/blob/master/samples)
directory.

## Using a Custom Allocator

Some users may wish to substitute custom allocators where we have
used C standard library allocation functions. Below are some of
the functions your custom allocator may override. Be aware that overriding
these or other functions may impact performance, introduce bugs, or have other
unintended consequences.

* `malloc`
* `calloc`
* `realloc`
* `free`
* `posix_memalign`
* `aligned_alloc`
* `strdup`

!!! tip
    HSE has some custom use-case specific allocators within it based on `mmap`.
    These cannot be substituted.
