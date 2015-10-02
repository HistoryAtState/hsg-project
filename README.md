# hsg-project

Making the new hsg3 structure comprehensible for our oXygen users

## Goals

To make the following easy:

- check out latest files √
- commit local edits
- build local packages √
- deploy local packages
- publish packages to production

## Setup

- Clone the repo
- Open hsg-project.xpr in oXygen
- From the External Tools menu, run "Update dependent repos". This checks out all dependent repos into a "repos" subdirectory.
- Then run "Build packages". This runs each package's ant build file and copies the contents of its build file into a "xars" subdirectory.
- Then upload the packages via Dashboard Package Manager
- In sum, this simplifies the process of checking out and previewing the latest files