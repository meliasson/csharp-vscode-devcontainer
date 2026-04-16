#!/bin/bash

# Embrace fail fast. Abort immediately on failure.
set -e

# Make sure that VS Code is Git editor so we don't get trapped in GNU
# nano or similar.
if [ "$(git config core.editor)" != 'code --wait' ]; then
    git config core.editor 'code --wait'
fi

# Register the Git hooks globally so all repos in the container
# (including those under projects/) use the same hooks.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git config --global core.hooksPath "$REPO_ROOT/.githooks"

# Install tools listed in the manifest file.
dotnet tool restore

# Add private NuGet repository.
if [ -n "$NUGET_SOURCE_PATH" ] \
  && [ -n "$NUGET_USERNAME" ] \
  && [ -n "$NUGET_ACCESS_TOKEN" ]; then
  dotnet nuget add source $NUGET_SOURCE_PATH \
    --name sdc-nuget-packages \
    --username $NUGET_USERNAME \
    --password $NUGET_ACCESS_TOKEN \
    --store-password-in-clear-text
fi
