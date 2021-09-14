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

> For HSE 1.x releases, information on building and installing for all
> repos is in the HSE project documentation rather than per-repo
> `README.md` or `README_HSE.md` files.
> HSE 1.x and its project documentation are no longer actively maintained.


## Site Generation Tools

The HSE project documentation is based on
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/),
which is a theme for the [MkDocs](https://www.mkdocs.org/)
static site generator.
For versioning we use [Mike](https://github.com/jimporter/mike) which
is natively integrated with Material for MkDocs.

All of these tools are Python packages and can be installed, along with all
dependencies, as follows. This also installs any dependency required to build
hse to capture api doxygen files.

```shell
poetry install
poetry shell
```


## Version Directories

Different versions of the HSE project documentation are stored in separate
directories in this repo.

* `v2` contains the HSE 2.x project documentation
* `v1` contains the HSE 1.x project documentation


## Building HSE API doxygen documents

Building the Api documentaion from the header files of hse is enabled using doxygen.
Doxygen xml is converted using [doxybook2](https://github.com/matusnovak/doxybook2),
into markdown files. Generate the Api docs as follows.

```shell
./generate-api.sh
```

## Building and Viewing

Build the latest version of the complete documentation as follows.

```shell
git clone https://github.com/hse-project/hse-project.github.io.git
cd hse-project.github.io
poetry install
poetry shell
./generate-api.sh
mike deploy -F v1/mkdocs.yml 1.x
mike deploy -F v2/mkdocs.yml 2.x
mike set-default -F v2/mkdocs.yml 2.x
```

This build process creates a local branch named `gh-pages` with the
generated static site files.  You can view these as follows.

```shell
mike serve -F v2/mkdocs.yml
```

Point a web browser at the URL output from the above command.

> Note: To build the released (tagged) version of the project documentation,
> execute `git checkout v2deploy` before building with `mike` in the
> steps above.


## Editing

You must use `mike` to build and view the documentation with versioning.
However, the live reload does not work well, if at all.

For editing the project documentation, it is better to use the `mkdocs`
development server which automatically rebuilds Markdown files as they are
updated and causes a connected web browser to reload them.
This provides for a convenient interactive editing session.

```shell
mkdocs serve -f v2/mkdocs.yml
```

Point a web browser at the URL output from the above command.

Keep in mind that only the version of the documentation you are editing
will appear in the browser and that there will not be a version selector.


## Deploying to GitHub

Only users with write permission to the `hse-project.github.io` repo
can deploy the HSE project documentation.
Before deploying any documentation updates,
all changes since the last update will be reviewed by the maintainers,
editorial PRs will
be submitted if needed, and the commit to be deployed will be tagged.
