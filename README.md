# hsg-project

The new hsg3 spans many git repositories, which together form the applications and data published at history.state.gov. This project simplifies the tasks of getting these repositories and building and creating packages to install into eXist.

## Goals

To automate the following steps:

- check out latest files √
- commit local edits
- build packages √
- deploy packages locally for preview
- run unit tests (jenkins?)
- deploy packages to remote test (travis?) and production servers

(No check mark means this hasn't been automated and must still be done manually.)

## Setup

You need the ant, git, and bower executables installed. If git cannot be found, edit `build.properties` to set the correct path to the executable. To deploy everything to a running eXist instance, you also need to set `instance.uri`, `instance.user` and `instance.password` properly.

- Clone the repo
- Run `ant setup` once to pull required repositories (and any time new repositories are added)
- Run `ant` to build all xars and deploy them into the database
- To only build the xars, call `ant build`

## Notes

- This has been tested with Mac OS X 10.11, oXygen XML Editor 17.1, and eXist 3.0 develop.
- To add a repository, add its info to build.properties
- Pull requests welcome
