# HSE Project Documentation

This repo contains the HSE project documentation which is served
via GitHub Pages.  We use a single documentation set (site) for all
repos under [hse-project](https://github.com/hse-project) to make it easy
to navigate and search for information.

This documentation is complemented by information provided in standard
per-repo top-level files including:

* README.md &mdash; Overview of the repo contents, information on how to
build and install it, and references to other relevant information.
* CONTRIBUTING.md &mdash; Information on how to contribute to the repo
contents.
* LICENSE &mdash; The full license text for the repo.

> For HSE 1.x releases, and for forked repos such as hse-mongo, information
> on building and installing is in this documentation rather than
> the corresponding README.md.


## Site Generation Tools

The HSE project documentation is based on
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/),
which is a theme for the [MkDocs](https://www.mkdocs.org/)
static site generator.
For versioning we use [Mike](https://github.com/jimporter/mike) which
is natively integrated with Material for MkDocs.

All of these tools are Python packages and can be installed, along with all
dependencies, as follows.

    $ pip install mkdocs-material
    $ pip install mike


## Repo Branches

This repo comprises the following independent (orphan) branches:

* main  &mdash; Contains only the standard top-level repo
files (README.md, etc.).
* vN &mdash; Contains the HSE N.x documentation source and standard
top-level repo files copied from main.  For example, branch v1 contains
the HSE 1.x documentation source.
* gh-pages &mdash; Contains the *generated* static site files served
via GitHub Pages from the URL https://hse-project.github.io.


## Building and Deploying

> The details below are for building and deploying the HSE project
> documentation when there is only a single version, specifically for HSE 1.x.
> These instructions will be updated when versioning support is required
> starting with the release of HSE 2.x.

Build the latest version of the v1 documentation as follows.

    $ git clone https://github.com/hse-project/hse-project.github.io.git
    $ cd hse-project.github.io
    $ git checkout v1
    $ mkdocs build

Deploy the documentation to the gh-pages branch as follows.

    $ mkdocs gh-deploy --clean --force

After a few minutes the latest version of the documentation will be
available from the URL https://hse-project.github.io.

> WARNING: Only users with write permission to the hse-project.github.io
> repo can deploy the HSE project documentation.  These users are a subset
> of the hse-project maintainers.  Before deploying the documentation,
> all changes since the last update must be reviewed, an editorial PR must
> be submitted if needed, and the commit to be deployed must be tagged.

