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

| Requirement | Notes |
|---|---|
| Java 11 | Zulu 11 is what we run. eXist 6.2.0 client jars are vendored in `lib/`. CI also builds against 21. |
| Maven | `ant setup` runs `mvn dependency:copy-dependencies` to populate `lib/` from `pom.xml`. |
| Git | `build/local.build.properties` points at an absolute path, set by `ant upgrade-local-build-properties`. |
| Ant | Only needed for the command-line workflow; oXygen users get it bundled with oXygen. |
| Node.js ≥ 22 | Only needed to build `hsg-shell`, which runs `npm start` (gulp) during its `xar` target. |
| Docker | The fastest way to get a running eXist with all of HSG already installed. |

On macOS with Homebrew:

```bash
brew install --cask docker-desktop zulu@11
brew install ant git maven node
```

## Quick start

Get a running eXist with the complete history.state.gov already deployed — no build required:

```bash
mkdir -p ~/Downloads/hsg-project-downloads
docker run -d --name hsg-project \
  -p 8080:8080 -p 8443:8443 \
  -v ~/Downloads/hsg-project-downloads:/tmp/hsg-project-downloads \
  joewiz/hsg-project:latest
```

The image is multi-arch (`linux/amd64`, `linux/arm64`) and is roughly 6 GB compressed. Watch `docker logs -f hsg-project` until `Server has started, listening on:` appears, then open <http://localhost:8080/exist/apps/hsg-shell/>.

Give Docker at least 8 GB of memory — the container sets `-XX:MaxRAMPercentage=75.0`, so eXist's heap is derived from whatever Docker is allowed to use.

Then clone the data repositories so you can edit and redeploy them:

```bash
git clone https://github.com/HistoryAtState/hsg-project.git
cd hsg-project
ant setup
```

`ant setup` runs `upgrade-local-build-properties` (which writes absolute tool paths into `build/local.build.properties`), copies Maven dependencies into `lib/`, and clones every repo listed under `git.public.repo-names`.

To push a single repository's changes into the running container:

```bash
ant deploy-one -Drepo-name=rdcr -Dxar=rdcr-0.0.0-development.xar
```

Or, from oXygen, open a file from that repo and select `Deploy current file's repository to localhost`.

> **Note:** `ant` (the default `all` target) and `ant deploy` depend on `ping-public-repo`, which requires access to the internal `public-repo.hsg` host. Outside the office network, use `deploy-one` / `deploy-repo-to-localhost`, which do not.

## Setup

For Office of the Historian staff, see the [hsg-project wiki](https://github.com/HistoryAtState/hsg-project/wiki), especially [Setting up a history.state.gov development environment](https://github.com/HistoryAtState/hsg-project/wiki/setup) and [Using version control with history.state.gov publications and datasets](https://github.com/HistoryAtState/hsg-project/wiki/version-control).

For the general developer community:

- Clone this repo
- For oXygen users:
    - Open the `hsg-project.xpr` file in oXygen
    - From the External Tools toolbar menu (or Tools > External Tools):
    - Select `2. Clone all repositories & resources` once to pull required repositories (and any time new repositories are added).
    - Select `Deploy current file's repository to localhost` to build and deploy a single repository into the database.
- For command line users:
    - Run `ant setup` once to pull required repositories (and any time new repositories are added).
    - Run `ant` to build all packages and deploy them into the database (requires internal network access; see the note above).

### Building hsg-shell

`hsg-shell` is the only repository with a Node toolchain. With Node ≥ 22 installed:

```bash
ant update-one -Drepo-name=hsg-shell
ant -f repos/hsg-shell/build.xml
ant deploy-one -Drepo-name=hsg-shell -Dxar=hsg-shell-0.0.0-development.xar
```

Without Node, you are limited to the `hsg-shell` build baked into the Docker image.

## Publishing

Data repositories are published by [Tuttle](https://github.com/eeditiones/tuttle), which syncs each repository's default branch from GitHub into the corresponding collection on the deployment servers. Changes reach history.state.gov by being merged to the repository's default branch, not by uploading files to production.

Repositories run `commitlint` with `@commitlint/config-conventional` in CI, and releases are cut by `semantic-release`. Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/) (`fix:`, `feat:`, `docs:`, `chore:`, …) or the lint job fails.

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

### Ant target for building DEV and PROD xars (for development and production server)

The default `ant` target will build xar files without any triggers and will internally call targets `build` > `build-xar`. 
An additional variable in target `build-xar` lets you to build 2 xar files containing triggers for 2 different environments: prod and dev.  
By running the `ant build` command plus the environment variable like described below, you call a specific `subant` target `xar-dev` or `xar-prod` - both are found in each repo's build.xml.

1. Command for DEV:
    * will create `*-consumer-dev.xar` without replication triggers and *-producer-dev.xar` containing replication triggers
    * calls target `xar-dev` 
    ```bash
    ant -Dbuild-env=-dev build
    ```

2. Command for PROD: 
    * will create `*-consumer-prod.xar` without replication triggers and `*-producer-prod.xar` containing replication triggers
    * calls target `xar-prod` 
    ```bash
    ant -Dbuild-env=-prod build
    ```

## Notes

- Developed and used on macOS (Apple Silicon and Intel); the Ant build also runs on Linux, where `homebrew-prefix` resolves to an empty string and tools are taken from `PATH`
- To add a repository, add its info to `build/build.properties`
- Pull requests welcome
