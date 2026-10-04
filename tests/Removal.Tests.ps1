# Run in Windows PowerShell 5.1; loads functions through the AST without starting setup.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
$source = Join-Path (Split-Path $PSScriptRoot) 'FreshWindowsSetup.UI.ps1'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($source, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
foreach ($name in @('Get-StartupEntries', 'Get-TaskEntries', 'Remove-StartupEntry', 'Remove-TaskEntry')) {
    $node = $ast.Find({ param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name }, $true)
    . ([scriptblock]::Create($node.Extent.Text))
}
function Write-SetupLog { param($Message, $Level) }
function Assert { param($Condition, $Message) if (-not $Condition) { throw $Message } }
function Expect-Failure { param([scriptblock]$Action, [string]$Pattern)
    try { & $Action } catch { if ($_.Exception.Message -match $Pattern) { return }; throw }
    throw 'Expected operation to fail.'
}
$script:testRoot = Join-Path $env:TEMP ('FreshWindowsSetup-tests-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($script:testRoot)
function New-RemovalBackupDirectory {
    if ($script:failBackup) { throw 'Backup failed' }
    return $script:testRoot
}
$script:failBackup = $false
$script:deleted = @()
$script:taskXml = '<Task><Actions /></Task>'
$script:taskState = 3
$script:folder = [pscustomobject]@{}
$script:folder | Add-Member ScriptMethod GetTask { param($name) return [pscustomobject]@{ Xml = $script:taskXml; State = $script:taskState } }
$script:folder | Add-Member ScriptMethod DeleteTask { param($name, $flags) $script:deleted += $name }
$script:folder | Add-Member ScriptMethod GetTasks { param($flags) return @() }
$script:service = [pscustomobject]@{}
$script:service | Add-Member ScriptMethod Connect { }
$script:service | Add-Member ScriptMethod GetFolder { param($path) return $script:folder }
function New-Object { param($ComObject) Assert ($ComObject -eq 'Schedule.Service') 'Unexpected COM object'; return $script:service }
function Get-ScheduledTask { param($ErrorAction)
    [pscustomobject]@{ TaskPath = '\Vendor\'; TaskName = 'Updater[1]*'; State = 'Ready'; Actions = @([pscustomobject]@{ Execute = 'updater.exe'; Arguments = '/check' }) }
}
try {
    $tasks = @(Get-TaskEntries)
    Assert ($tasks.Count -eq 1 -and -not $tasks[0].Default) 'Tasks must be unchecked by default.'
    Assert ($tasks[0].Name -match 'updater.exe /check') 'Task action must be visible.'
    $entry = $tasks[0]
    $script:taskXml = '<Task>changed</Task>'
    Expect-Failure { Remove-TaskEntry $entry } 'pasikeitė'
    Assert ($script:deleted.Count -eq 0) 'Changed task must remain registered.'
    $script:taskXml = $entry.Xml; $script:taskState = 4
    Expect-Failure { Remove-TaskEntry $entry } 'vykdoma'
    Assert ($script:deleted.Count -eq 0) 'Running task must remain registered.'
    $script:taskState = 3; $script:failBackup = $true
    Expect-Failure { Remove-TaskEntry $entry } 'Backup failed'
    Assert ($script:deleted.Count -eq 0) 'Backup failure must prevent deletion.'
    $script:failBackup = $false
    Remove-TaskEntry $entry
    Assert ($script:deleted.Count -eq 1 -and $script:deleted[0] -ceq 'Updater[1]*') 'Deletion must use the exact task name.'
    Assert ([IO.File]::ReadAllText((Join-Path $script:testRoot 'task.xml')) -ceq $entry.Xml) 'Task XML backup must match.'
    $location = Import-Clixml -LiteralPath (Join-Path $script:testRoot 'task-location.xml')
    Assert ($location.TaskPath -ceq '\Vendor\' -and $location.TaskName -ceq 'Updater[1]*') 'Task location backup must match.'
    Expect-Failure { Remove-StartupEntry ([pscustomobject]@{ Kind = 'File'; Path = (Join-Path $script:testRoot 'outside.lnk'); Hash = 'unused' }) } 'paleisties aplanke'
    $startup = @(Get-StartupEntries)
    Assert (@($startup | Where-Object Default).Count -eq 0) 'Startup entries must be unchecked by default.'
    Assert (@($startup | Where-Object { $_.Kind -notin @('Registry', 'File') }).Count -eq 0) 'Unexpected startup source.'
    Write-Output 'PASS: task inventory, exact deletion, backups, changed/running task and backup failure guards, startup scope and defaults.'
} finally {
    $resolved = [IO.Path]::GetFullPath($script:testRoot)
    $tempRoot = [IO.Path]::GetFullPath($env:TEMP).TrimEnd('\') + '\'
    if ($resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and [IO.Path]::GetFileName($resolved).StartsWith('FreshWindowsSetup-tests-')) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
