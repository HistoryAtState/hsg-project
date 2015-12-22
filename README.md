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

## Prerequisites

- eXist 3.0RC1
- Current versions of ant, git, and bower executables

## Setup

- Clone this repo
- Run `ant setup` once to pull required repositories (and any time new repositories are added). (If git cannot be found, edit `build.properties` to set the correct path to the executable.)
- Run `ant` to build all packages and deploy them into the database. (Edit `build.properties` to ensure that `instance.uri`, `instance.user`, and `instance.password` are correct for your eXist instance.)

## Other targets

- To pull the latest updates for all repos, call `ant update`
- To only build the packages (and not deploy them), call `ant build`
- To clean the project of all generated packages, call `ant clean`. This also calls each repository's own `clean` targets.
- To build a single repo's package, call `ant -f repos/REPO_NAME/build.xml`
- To deploy a single repo's package, call `ant deploy-one -Drepo-name=REPO_NAME -Dxar=REPO_NAME-X_Y.xar`
- For example, to build and deploy the latest `hsg-shell` code, enter:

```bash
ant update
ant -f repos/hsg-shell/build.xml
ant deploy-one -Drepo-name=hsg-shell -Dxar=hsg-shell-0.1.xar
```

## Notes

- This has been tested with Mac OS X 10.11 and Amazon Linux
- To add a repository, add its info to build.properties
- Pull requests welcome
