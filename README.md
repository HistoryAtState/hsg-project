# hsg-project

The new hsg3 spans many git repositories, which together form the applications and data published at history.state.gov. This project simplifies the tasks of getting these repositories and building and creating packages to install into eXist.

## Goals

To automate the following steps:

- check out latest files √
- build packages √
- publish local edits to local (development) & remote (production) servers √
- deploy packages to local (development) server for preview √
- deploy packages to remote (production) servers
- commit local edits to git
- run unit tests (jenkins?)

(No check mark means this hasn't been automated and must still be done manually.)

## Prerequisites

- eXist 3.0RC1
- Current versions of ant, git, and bower executables

## Setup

For Office of the Historian staff, see the [hsg-project wiki](https://github.com/HistoryAtState/hsg-project/wiki), especially the article [Setting up a history.state.gov development environment on your computer](https://github.com/HistoryAtState/hsg-project/wiki/setup) and [Using version control with history.state.gov publications and datasets](https://github.com/HistoryAtState/hsg-project/wiki/version-control].

For the general developer community:

- Clone this repo
- For oXygen users:
    - Open the `hsg-project.xpr` file in oXygen
    - From the External Tools toolbar menu (or Tools > External Tools): 
    - Select `Clone all repositories` once to pull required repositories (and any time new repositories are added). 
    - Select `Deploy all repositories to localhost` to build all packages and deploy them into the database.
- For command line users:
    - Run `ant setup` once to pull required repositories (and any time new repositories are added). 
    - Run `ant` to build all packages and deploy them into the database. 

## Troubleshooting

- In the case of authentication errors, check `build/build.properties` to ensure that `local.instance.uri`, `local.instance.user`, and `local.instance.password` are correct for your eXist instance.
- In the case of errors that git cannot be found, edit `build/build.properties` to set the correct path to the executable.

## Other External Tools entries for oXygen users

- To pull the latest updates for all repos, select `Fetch updates to all repositories`
- To pull the latest updates for a single repo, open a file from that repo and select `Fetch updates to current repository`
- To deploy a single repo's package, open a file from that repo and select `Deploy current repository to localhost`
- To clean the project of all generated packages, select `Delete generated packages` (This also calls each repository's `clean` targets.)

## Other Ant targets for command line users

- To pull the latest updates for all repos, call `ant update`
- To only build the packages (and not deploy them), call `ant build`
- To clean the project of all generated packages, call `ant clean`. This also calls each repository's own `clean` targets.
- To pull the latest updates for a single repo, call `ant update-one -Drepo-name=REPO_NAME`
- To build a single repo's package, call `ant -f repos/REPO_NAME/build.xml`
- To deploy a single repo's package, call `ant deploy-one -Drepo-name=REPO_NAME -Dxar=REPO_NAME-X_Y.xar`
- For example, to build and deploy the latest `hsg-shell` code, enter:

```bash
ant update-one -Drepo-name=hsg-shell
ant -f repos/hsg-shell
ant deploy-one -Drepo-name=hsg-shell -Dxar=hsg-shell-0.2.xar
```

- To start the day and ensure you have the latest version of all files (takes ~10 min; to shorten the time more, first run eXist's `clean-default-data-dir` [build target](http://exist-db.org/exist/apps/doc/building.xml) - which wipes your database of all files and thus avoids the time required to *uninstall* old packages before installing the new ones):

```bash
git pull
ant clean
ant setup
ant
```

## Notes

- This has been tested with Mac OS X 10.11, Amazon Linux, and oXygen 17.1
- To add a repository, add its info to `build/build.properties`
- Pull requests welcome
