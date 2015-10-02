# hsg-project

The new hsg3 spans many git repositories, which together form the applications and data published at history.state.gov. This project simplifies the tasks of getting these repositories, building the and creating application and data packages to load into eXist. 

## Goals

To automate the following steps:

- check out latest files √
- commit local edits
- build packages √
- deploy packages locally for preview
- deploy packages to remote test or production servers

(No check mark means this hasn't been automated and must still be done manually.)

## Setup

- Clone the repo
- Open hsg-project.xpr in oXygen
- From the External Tools menu, run "Update dependent repos". This checks out all dependent repos into a "repos" subdirectory.
- Then run "Build packages". This runs each package's ant build file and copies the contents of its build file into a "xars" subdirectory.
- Then upload the packages via Dashboard > Package Manager.
- To fetch new updates from repositories, repeat these steps again ("Update dependent repos", "Build packages", and upload)
- In sum, this simplifies the process of checking out and previewing the latest files

## Notes

- This has been tested with Mac OS X 10.11, oXygen XML Editor 17.0, and eXist 3.0RC1.
- To add a repository, add its info to scripts/pull.sh and scripts/build.sh
- Pull requests welcome
