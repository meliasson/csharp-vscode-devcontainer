#!/bin/bash

# Setup PowerShell profile.
mkdir -p /home/vscode/.config/powershell
cp ./.devcontainer/powershell-profile.ps1 /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1

# Make sure that VS Code is Git editor so we don't get trapped in GNU
# nano or similar.
if [ "$(git config core.editor)" != 'code --wait' ]; then
    git config core.editor 'code --wait'
fi

# Enable sharing of Git hooks.
git config core.hooksPath .githooks

# Let's take a walk on the wild side and trust PSGallery.
pwsh -NoProfile -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"

# Install posh-git so we get Git tab completion.
pwsh -NoProfile -Command "Install-Module -Name posh-git -Repository PSGallery"

# Install Oh My Posh so we, like Scott Hanselman, may one day learn to
# love our PowerShell prompts. Since we don't like to be administators
# on our machines, we pick a theme that doesn't require installation of
# additional fonts.
curl -s https://ohmyposh.dev/install.sh | sudo bash -s
mkdir -p /home/vscode/.oh-my-posh/themes
cp ./.devcontainer/oh-my-posh-theme.json /home/vscode/.oh-my-posh/themes/minimal.json

# Install CSharpier to save brainpower. (By reducing decision fatigue,
# kind of like Steve Jobs did with clothing, right?) And who knows,
# maybe we'll end up with a codebase that's uniform and easy to read.
dotnet tool install csharpier -g

# Add private NuGet repository.
if [ -n "$NUGET_SOURCE_PATH" ] \
  && [ -n "$NUGET_USERNAME" ] \
  && [ -n "$NUGET_ACCESS_TOKEN" ]; then
  dotnet nuget add source $NUGET_SOURCE_PATH \
    --name private-nuget-feed \
    --username $NUGET_USERNAME \
    --password $NUGET_ACCESS_TOKEN \
    --store-password-in-clear-text
fi

# Configure a local NuGet respository so we can get test versions of
# dependencies like Biometria's service bus extension.
dotnet nuget add source /home/vscode/local-nuget-feed \
  --name local-nuget-feed
