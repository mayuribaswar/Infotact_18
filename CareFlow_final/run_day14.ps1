# ============================================================
# CAREFLOW DAY 14
# PATIENT JOURNEY PERFORMANCE ANALYSIS
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "       CAREFLOW - DAY 14"
Write-Host " PATIENT JOURNEY PERFORMANCE ANALYSIS"
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
    Write-Host "Find it using:"
    Write-Host "Get-ChildItem -Path . -Filter dbt_project.yml -Recurse"

    exit 1
}

$dbtProjectPath = $dbtProjectFile.Directory.FullName

Write-Host "dbt project found:"
Write-Host $dbtProjectPath
Write-Host ""

Set-Location $dbtProjectPath

Write-Host "========================================"
Write-Host "STEP 1 - DBT DEBUG"
Write-Host "========================================"

dbt debug

Write-Host ""
Write-Host "========================================"
Write-Host "STEP 2 - PATIENT JOURNEY MODEL"
Write-Host "========================================"

dbt run --select int_patient_journey

Write-Host ""
Write-Host "========================================"
Write-Host "STEP 3 - PATIENT JOURNEY MART"
Write-Host "========================================"

dbt run --select fct_patient_journey

Write-Host ""
Write-Host "========================================"
Write-Host "STEP 4 - RUN DAY 14 TESTS"
Write-Host "========================================"

dbt test --select int_patient_journey fct_patient_journey

Write-Host ""
Write-Host "========================================"
Write-Host "DAY 14 COMPLETED SUCCESSFULLY"
Write-Host "========================================"