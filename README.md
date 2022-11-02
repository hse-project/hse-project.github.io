# HSE Project Documentation

This repo contains the HSE project documentation which is served
via GitHub Pages.  We use a single documentation set (site) for all
repos under [hse-project](https://github.com/hse-project) to make it easy
to navigate and search for information.

## Per-repo Documentation

The HSE project documentation is complemented by information provided in
standard per-repo files including:

* `README.md`: Overview of the repo contents, information on how to
build and install it, and references to other relevant information.
* `CONTRIBUTING.md`: Information on how to contribute to the repo contents.
* `LICENSE`: The full license text for the repo.
* `LICENSE.3rdparty.md`: License information for 3rd-party source
included in the repo or built as a sub-repo and statically linked.

Forked repos, such as `hse-mongo` and `hse-ycsb`, contain information on
building and contributing in `README.md` and `CONTRIBUTING.md` in the
`hse` directories within those repos.  To make these files easy to locate
when cloning a forked repo, there are symlinks to them named `README_HSE.md`
and `CONTRIBUTING_HSE.md` in the repo root directory.

## Version Directories

Different versions of the HSE project documentation are stored in separate
directories in this repo.

* `v3` contains the HSE `3.x` project documentation
* `v2` contains the HSE `2.x` project documentation
* `v1` contains the HSE `1.x` project documentation which is deprecated and no longer built

## Site Generation Tools

The HSE project documentation is based on
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/), which is a
theme for the [MkDocs](https://www.mkdocs.org/) static site generator. For
versioning we use [Mike](https://github.com/jimporter/mike) which is natively
integrated with Material for MkDocs. These tools are Python packages. If you
need to get `mkdocs` and `mike` to build the site, use the `requirements.txt`
file:

Note that you will need Python `>= 3.7` to build the website.

```shell
python3 -m pip install -r requirements.txt
```

The HSE documentation includes an API reference that is built from
header files in the `hse` repo.  This process uses
[doxygen](https://www.doxygen.nl/index.html) to generate XML that is converted
to markdown using [doxybook2](https://github.com/matusnovak/doxybook2).

## Building

The website is built using [Meson](https://mesonbuild.com/).

In order to build the documentation, run the following commands:

```shell
meson build
ninja -C build
```

If you don't want to build any of the API documentation, make sure to use the
`-Dapis=none` option.

## Viewing

You can view the generated site with hot reloading using the following command:

```shell
ninja -C build serve-vX # where X is the major version you want to view
# OR
ninja -C build serve # will serve the site with the version selector
```

Point a web browser at the URL output from the above command.

You can change the `--dev-addr` passed to `mkdocs` or `mike` using the
environment variable: `HSE_SERVE_DEV_ADDR`. Defaults to `localhost:8000`.

Editing the markdown files, while the site is being served, should reload the
website.

## Deploying

In order to deploy the website to the a branch, run the following:

```shell
ninja -C build deploy-vX # where X is the major version you want to deploy
# OR
ninja -C build deploy # will deploy all major versions
```

The default branch for deployment is `gh-pages`, but this can be changed by
setting the environment variable: `HSE_DEPLOY_BRANCH`.

The default remote for deployment is `origin`, but this can be changed by
setting the envrionment variable: `HSE_DEPLOY_REMOTE`.

Only users with write permission to the `hse-project.github.io` repo can deploy
the HSE project documentation to GitHub. Before deploying any documentation
updates, all changes since the last update will be reviewed by the maintainers,
editorial PRs will be submitted if needed, and the commit to be deployed will be
tagged.
