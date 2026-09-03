```powershell
# ============================================================
# CAREFLOW DAY 13 RUN SCRIPT
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "       CAREFLOW - DAY 13"
Write-Host "   PROCESS BOTTLENECK ANALYSIS"
Write-Host "========================================"
Write-Host ""

# Find dbt_project.yml
$dbtProjectFile = Get-ChildItem `
    -Path $PSScriptRoot `
    -Filter "dbt_project.yml" `
    -Recurse `
    -File `
    | Select-Object -First 1

if (-not $dbtProjectFile) {

    Write-Host "ERROR: dbt_project.yml was not found."
    Write-Host ""
    Write-Host "Run this command manually:"
    Write-Host "Get-ChildItem -Path . -Filter dbt_project.yml -Recurse"

    exit 1
}

$dbtProjectPath = $dbtProjectFile.Directory.FullName

Write-Host "dbt project found:"
Write-Host $dbtProjectPath
Write-Host ""

Set-Location $dbtProjectPath

Write-Host "Running dbt debug..."
dbt debug

Write-Host ""
Write-Host "Running intermediate model..."
dbt run --select int_process_bottlenecks

Write-Host ""
Write-Host "Running MART model..."
dbt run --select fct_process_bottlenecks

Write-Host ""
Write-Host "Running tests..."
dbt test

Write-Host ""
Write-Host "========================================"
Write-Host "       DAY 13 COMPLETED"
Write-Host "========================================"
```
