$repo = $PSScriptRoot
$claudeDir = "$env:USERPROFILE\.claude"

$links = @{
    "$claudeDir\CLAUDE.md" = "$repo\CLAUDE.md"
    "$claudeDir\skills"    = "$repo\skills"
}

if (!(Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir | Out-Null
}

foreach ($link in $links.GetEnumerator()) {
    if (Test-Path $link.Key) {
        Remove-Item $link.Key -Force -Recurse
    }
    New-Item -ItemType SymbolicLink -Path $link.Key -Target $link.Value | Out-Null
    Write-Host "$($link.Key) -> $($link.Value)"
}

Write-Host "`nDone."
