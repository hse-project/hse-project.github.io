# Contributing to HSE Project Documentation

We are not able to accept community contributions at this time, but
stay tuned.


## General Information

When we start taking contributions, this first section will
point to general information on contributing to any hse-project repo.


## Workflow

The following are instructions for contributing to this specific repo.
Before proceeding, please review the `README.md` file for this repo which
provides information on the repo branch structure and documentation site
generation tools.

To update a particular version of the documentation, clone the
`hse-project.github.io` repo and checkout the branch of interest.
For example

    $ git clone https://github.com/hse-project/hse-project.github.io.git
    $ cd hse-project.github.io
    $ git checkout v1

Make your updates and then preview your changes as follows.

    $ mkdocs build
    $ mkdocs serve

Point a browser to localhost:8000 to see the changes.  When you are
satisfied, commit your changes and submit a pull request (PR).
Once your PR is accepted your changes will be included in the next
release of the HSE project documentation.
