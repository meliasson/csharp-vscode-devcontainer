# C# VS Code Devcontainer

A devcontainer setup for C# development in VS Code. The goal is a zero-install
workflow — open the repo, start the container, and get a fully configured
development environment without touching your local machine.

## Prerequisites

To develop locally:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)
- [VS Code](https://code.visualstudio.com/) with the
  [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
  extension

## Getting started

1. Clone the repo and open it in VS Code.
2. When prompted, click **Reopen in Container** (or run
   `Dev Containers: Reopen in Container` from the command palette).
3. Wait for the container to build and the post-create setup to finish.
4. Clone your C# project(s) into the `projects/` directory — it is ignored by
   git, so your work stays separate from this repo.

The container is based on **Ubuntu 24.04** and automatically provisions
everything listed below.

## What's inside

### .NET SDKs

| Version | Notes |
|---------|-------|
| 10.0 | Default |
| 8.0 | LTS |
| 6.0 | Legacy support |

### VS Code extensions

| Extension | Purpose |
|-----------|---------|
| **C# Dev Kit** | Full C# IDE experience (IntelliSense, test runner, solution explorer) — no Visual Studio required |
| **CSharpier** | Opinionated C# formatter; formats the file on every save |
| **EditorConfig** | Enforces the `.editorconfig` rules for file types CSharpier doesn't cover |

### CLI tools

| Tool | Command | Purpose |
|------|---------|---------|
| [CSharpier](https://csharpier.com/) | `dotnet csharpier` | Format code / check formatting in CI |
| [dotnet-outdated](https://github.com/dotnet-outdated/dotnet-outdated) | `dotnet outdated` | List NuGet packages with available updates |
| [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) | `copilot` | AI assistance in the terminal |

Tools are defined in `.config/dotnet-tools.json` and restored automatically
during container startup via `dotnet tool restore`.

### Shell

[zsh](https://www.zsh.sh/) is the default shell, configured with the `dotnet`
and `git` plugins for tab completion and prompt integration.

## Code formatting

CSharpier is the single source of truth for C# formatting. It runs
automatically on save. To check or fix formatting manually:

```sh
# Check (exit code 1 if any file would be changed)
dotnet csharpier --check .

# Fix
dotnet csharpier .
```

The `.editorconfig` at the repo root covers everything else (JSON, XML, plain
text) — line endings, indentation, trailing whitespace, and final newlines.

## Pre-push hook

A Git pre-push hook (`.githooks/pre-push`) runs before every `git push`. The
hook is registered **globally** in the container, so it applies to all repos —
including those cloned into `projects/`.

If the repo has no `.sln` file the hook skips silently. Otherwise it runs:

1. `dotnet build` — ensures the project compiles.
2. `dotnet csharpier --check .` — ensures all code is formatted.
3. `dotnet outdated --version-lock Minor --fail-on-updates` — ensures no patch-level NuGet updates are pending.

The push is aborted if any step fails, keeping the remote history clean.

## Private NuGet feed (optional)

If the project depends on a private NuGet source, set the following environment
variables on your **host machine** before opening the container (e.g. in
`~/.bashrc` or `~/.zshrc`):

```sh
export NUGET_SOURCE_PATH="https://your-feed-url"
export NUGET_USERNAME="your-username"
export NUGET_ACCESS_TOKEN="your-token"
```

The container forwards these at build time and registers the feed automatically.
If the variables are absent the public NuGet feed is still available and setup
continues without errors.
