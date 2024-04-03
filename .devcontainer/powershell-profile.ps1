
# A convenience function that we can use to pack and publish the project
# to our "local NuGet repository".
function Deploy-LibToLocalFeed {
    param(
        $PathToProject
    )

    dotnet pack --no-cache -c Release -o . $PathToProject
    sudo mv *.nupkg ~/local-nuget-feed
}

# Initialize Oh My Posh with a custom theme that doesn't require special
# fonts to be installed on the host machine.
oh-my-posh init pwsh --config ~/.oh-my-posh/themes/minimal.json | Invoke-Expression

# Let Oh My Posh use posh-git for Git status and autocompletion.
$env:POSH_GIT_ENABLED = $true

# Enable tab completion for .NET CLI.
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
