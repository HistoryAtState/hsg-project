# hsg-project

The application and data published at history.state.gov (HSG) come from numerous HistoryAtState repositories and are powered by eXist-db. This project simplifies the task of getting these repositories onto your computer and running a full local instance of history.state.gov for research or development purposes.

## Goals

To simplify:

- cloning the many history.state.gov source git repositories
- pulling the latest changes from the repositories
- uploading edits to a local eXist-db instance for preview

## Quick start via Docker

Get a running eXist with a complete history.state.gov already deployed — no dependencies, git cloning, or building required:

```bash
docker run -d --name hsg-project \
  -p 8080:8080 -p 8443:8443 \
  joewiz/hsg-project:latest
```

The image is multi-arch (`linux/amd64`, `linux/arm64`) and is roughly 6 GB compressed. Watch `docker logs -f hsg-project` until `Server has started, listening on:` appears, then open <http://localhost:8080/exist/apps/hsg-shell/>.

Give Docker at least 8 GB of memory — the container sets `-XX:MaxRAMPercentage=75.0`, so eXist's heap is derived from whatever Docker is allowed to use.

## Full development setup

For Office of the Historian staff, see the [hsg-project wiki](https://github.com/HistoryAtState/hsg-project/wiki), especially [Setting up a history.state.gov development environment](https://github.com/HistoryAtState/hsg-project/wiki/setup) and [Using version control with history.state.gov publications and datasets](https://github.com/HistoryAtState/hsg-project/wiki/version-control).

For the general developer community:

### Prerequisites

| Requirement | Notes |
|---|---|
| Java 11 or later | Zulu 11 is what we run; the build is also tested on 21. |
| eXist-db 6.x | Open source native XML database, powers history.state.gov |
| Maven | `ant setup` runs `mvn dependency:copy-dependencies` to populate `lib/` from `pom.xml`. |
| Git | `build/local.build.properties` points at an absolute path, set by `ant upgrade-local-build-properties`. |
| Ant | Only needed for the command-line workflow; Oxygen users get it bundled. |
| Node.js ≥ 22 | Only needed to build `hsg-shell`, which runs `npm start` (gulp) during its `xar` target. |
| OR: just Docker! | The fastest way to get a running eXist with all of HSG already installed. (See "Quick start" above.) |

On macOS with Homebrew:

```bash
brew install zulu@11 exist-db ant git maven node
```

- Install eXist-db
- Clone this repo
- For Oxygen users:
    - Open the `hsg-project.xpr` file in Oxygen
    - From the External Tools toolbar menu (or Tools > External Tools):
    - Select `2. Clone all repositories & resources` once to pull required repositories (and any time new repositories are added).
    - Select `Deploy current file's repository to localhost` to build and deploy a single repository into the database.
- For command line users:
    - Run `ant setup` once to pull required repositories (and any time new repositories are added).
    - Run `ant` to build all packages and deploy them into the database.

### Building hsg-shell

`hsg-shell` is the only repository with a Node toolchain. With Node ≥ 22 installed:

```bash
ant update-one -Drepo-name=hsg-shell
ant -f repos/hsg-shell/build.xml
ant deploy-one -Drepo-name=hsg-shell
```

Without Node, you are limited to the `hsg-shell` build baked into the Docker image.

## Commit conventions

Repositories run `commitlint` with `@commitlint/config-conventional` in CI, and releases are cut by `semantic-release`. Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/) (`fix:`, `feat:`, `docs:`, `chore:`, …) or the lint job fails.

## Troubleshooting

- In the case of authentication errors, check `build/local.build.properties` to ensure that `local.instance.uri`, `local.instance.user`, and `local.instance.password` are correct for your eXist instance.
- In the case of errors that git cannot be found, edit `build/local.build.properties` to set the correct path to the executable.

## Other External Tools entries for Oxygen users

- To pull the latest updates for all repos, select `Pull updates from all repositories`
- To pull the latest updates for a single repo, open a file from that repo and select `Pull updates from current file's repository`
- To deploy a single repo's package, open a file from that repo and select `Deploy current file's repository to localhost`

## Other Ant targets for command line users

- To pull the latest updates for all repos, call `ant update`
- To only build the packages (and not deploy them), call `ant build`
- To clean the project of all generated packages, call `ant clean`. This also calls each repository's own `clean` targets.
- To pull the latest updates for a single repo, call `ant update-one -Drepo-name=REPO_NAME`
- To build a single repo's package, call `ant -f repos/REPO_NAME/build.xml`
- To deploy a single repo's package, call `ant deploy-one -Drepo-name=REPO_NAME` (the `.xar` in `repos/REPO_NAME/build/` is found automatically; pass `-Dxar=FILENAME.xar` only to disambiguate)

### Production builds of hsg-shell

`hsg-shell` is the only repository with a development/production build distinction. Set `HSG_ENV=production` to have gulp fully minify the JavaScript bundle; otherwise uglify runs with `compress` and `mangle` disabled.

```bash
HSG_ENV=production ant -f repos/hsg-shell/build.xml
```

## Notes

- Developed and used on macOS (Apple Silicon and Intel); the Ant build also runs on Linux, where `homebrew-prefix` resolves to an empty string and tools are taken from `PATH`
- To add a repository, add its info to `build/build.properties`
- Pull requests welcome
