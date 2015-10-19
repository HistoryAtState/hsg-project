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

## Setup (via ant)

You need the ant, git and bower executables installed. If git cannot be found, edit build.properties to set the correct path to the executable. To deploy everything to a running eXist instance, you also need to set `instance.uri`, `instance.user` and `instance.password` properly.

- Clone the repo
- Run `ant setup` once to pull required repositories
- Run `ant` to build all xars and deploy them into the database
- To only build the xars, call `ant build`

## Setup (via shell scripts)

- Clone the repo
- Open hsg-project.xpr in oXygen
- From the External Tools menu, run "Update dependent repos" (or, from the command line, run `sh scripts/pull.sh`). This checks out all dependent repos into a "repos" subdirectory.
- From the same menu, run "Build packages" (or, from the command line, run `sh scripts/build.sh`). This runs each package's ant build file and copies the contents of its build file into a "xars" subdirectory.
- Then upload the packages via Dashboard > Package Manager.
- To fetch new updates from repositories, repeat these steps again ("Update dependent repos", "Build packages", and upload)
- In sum, this simplifies the process of checking out and previewing the latest files

## Notes

- This has been tested with Mac OS X 10.11, oXygen XML Editor 17.0, and eXist 3.0RC1.
- To add a repository, add its info to scripts/pull.sh and scripts/build.sh
- Pull requests welcome
