#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Packages project artifacts into 7z archives with checksums.
.DESCRIPTION
    This script scans the dev_build directory, creates 7z archives for each project,
    and generates checksum files for both the archive and its contents.
.PARAMETER SourceDir
    The root directory containing project artifacts (default: ./dev_build)
.PARAMETER OutputDir
    The directory where archives will be saved (default: ./artifacts)
#>
param(
    [string]$SourceDir = "../dev_build",
    [string]$OutputDir = "./artifacts"
)
$7zip = if ($IsWindows) { "C:\Program Files\7-Zip\7z.exe" } else { "7z" }
$tempBase = if ($IsWindows) { $env:TEMP } else { "/tmp" }


function AddCheckSumsToArchive {
    param (
        [string]$tempDir,
        [string]$archivePath
    )
    $md5File = Join-Path -Path $tempDir -ChildPath "md5sums.txt"
    $sha1File = Join-Path -Path $tempDir -ChildPath "sha1sums.txt"
    $sha256File = Join-Path -Path $tempDir -ChildPath "sha256sums.txt"

    Get-ChildItem -Path $project -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName        
        "$((Get-FileHash -Path $_.FullName -Algorithm MD5).Hash)  ${relativePath}" | Out-File -FilePath $md5File -Append -Encoding utf8
        "$((Get-FileHash -Path $_.FullName -Algorithm SHA1).Hash)  ${relativePath}" | Out-File -FilePath $sha1File -Append -Encoding utf8
        "$((Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash)  ${relativePath}" | Out-File -FilePath $sha256File -Append -Encoding utf8
    }
    
    & $7zip u $archivePath $md5File $sha1File $sha256File | Out-Null
}
function CheckRequirements {
    if (-not (Get-Command $7zip -ErrorAction SilentlyContinue)) {
        Write-Error "7z is required but not found. Please install it first."
        exit 1
    }

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }
}

function PrepareTempDir {
    $tempBase = if ($IsWindows) { $env:TEMP } else { "/tmp" }
    $tempDir = Join-Path -Path $tempBase -ChildPath "artifact_packager_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir | Out-Null

    return $tempDir
}

function GetDirsToArchive {
    param (
        [string]$sourceDir
    )
    $projects = Get-ChildItem -Path $sourceDir -Directory

    if ($projects.Count -eq 0) {
        Write-Warning "No projects found in $sourceDir"
        exit 0
    }

    return $projects
}
function CreateArchive {
    param (
        [string]$archivePath,
        [System.Object]$project
    )
    & $7zip a -t7z -mx9 $archivePath "$($project.FullName)/*" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create archive for $($project.Name)"
        continue
    }
}

function CreateArchiveCheckSumFiles {
    param (
        [string]$archivePath
    )
    (Get-FileHash -Path $archivePath -Algorithm MD5).Hash | Out-File -Path "${archivePath}.md5" -Encoding utf8
    (Get-FileHash -Path $archivePath -Algorithm SHA1).Hash | Out-File -Path "${archivePath}.sha1" -Encoding utf8
    (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash | Out-File -Path "${archivePath}.sha256" -Encoding utf8
}
function Main {
    CheckRequirements
    $projects = GetDirsToArchive -sourceDir $SourceDir

    foreach ($project in $projects) {
        $projectName = $project.Name

        $archivePath = Join-Path -Path $OutputDir -ChildPath "${projectName}_artifacts" -AdditionalChildPath "${projectName}_artifacts.7z"
        
        Write-Host "Processing project: $projectName"
        
        CreateArchive -archivePath $archivePath -project $project

        $tempDir = PrepareTempDir
        
        try {
            AddCheckSumsToArchive -tempDir $tempDir -archivePath $archivePath
        }
        finally {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        (Get-FileHash -Path $archivePath -Algorithm MD5).Hash | Out-File -Path "${archivePath}.md5" -Encoding utf8
        (Get-FileHash -Path $archivePath -Algorithm SHA1).Hash | Out-File -Path "${archivePath}.sha1" -Encoding utf8
        (Get-FileHash -Path $archivePath -Algorithm SHA256).Hash | Out-File -Path "${archivePath}.sha256" -Encoding utf8
        
        
        Write-Host "Successfully created archive and checksums for $projectName"
    }

    Write-Host "All projects processed successfully"

}

Main



