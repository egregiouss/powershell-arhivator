BeforeAll {    
    $testRoot = Join-Path -Path $TestDrive -ChildPath "dev_build"
    $outputDir = Join-Path -Path $TestDrive -ChildPath "artifacts"
    
    $project1 = Join-Path -Path $testRoot -ChildPath "project1"
    New-Item -ItemType Directory -Path $project1 -Force | Out-Null
    $file1Content = "test content for hash verification"
    $file1Path = Join-Path -Path $project1 -ChildPath "file1.txt"
    $file1Content | Out-File -FilePath $file1Path -Encoding utf8
    
    $script:expectedMD5 = (Get-FileHash -Path $file1Path -Algorithm MD5).Hash
    $script:expectedSHA1 = (Get-FileHash -Path $file1Path -Algorithm SHA1).Hash
    $script:expectedSHA256 = (Get-FileHash -Path $file1Path -Algorithm SHA256).Hash
    
    $project2 = Join-Path -Path $testRoot -ChildPath "project2"
    New-Item -ItemType Directory -Path $project2 -Force | Out-Null
    "another content" | Out-File -FilePath (Join-Path -Path $project2 -ChildPath "file2.txt") -Encoding utf8
    $subDir = Join-Path -Path $project2 -ChildPath "subdir"
    New-Item -ItemType Directory -Path $subDir -Force | Out-Null
    "sub content" | Out-File -FilePath (Join-Path -Path $subDir -ChildPath "file3.txt") -Encoding utf8
    
    .\archivate_script.ps1 -SourceDir $testRoot -OutputDir $outputDir
}

Describe "Artifact Archivator Tests" {
    It "Creates archives for each project" {
        $archive1 = Join-Path -Path $outputDir -ChildPath "project1_artifacts" -AdditionalChildPath "project1_artifacts.7z"
        $archive2 = Join-Path -Path $outputDir -ChildPath "project2_artifacts" -AdditionalChildPath "project2_artifacts.7z"
        
        $archive1 | Should -Exist
        $archive2 | Should -Exist
    }
    
    Context "Checksum verification" {
        BeforeAll {
            $tempDir = Join-Path -Path $TestDrive -ChildPath "extracted"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            
            $archive1 = Join-Path -Path $outputDir -ChildPath "project1_artifacts" -AdditionalChildPath "project1_artifacts.7z"
            & 7z x -o"$tempDir" $archive1 | Out-Null
            
            $script:md5sums = Get-Content -Path (Join-Path -Path $tempDir -ChildPath "md5sums.txt")
            $script:sha1sums = Get-Content -Path (Join-Path -Path $tempDir -ChildPath "sha1sums.txt")
            $script:sha256sums = Get-Content -Path (Join-Path -Path $tempDir -ChildPath "sha256sums.txt")
        }
        
        AfterAll {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        It "Includes correct checksum files in archives" {
            (Join-Path -Path $tempDir -ChildPath "md5sums.txt") | Should -Exist
            (Join-Path -Path $tempDir -ChildPath "sha1sums.txt") | Should -Exist
            (Join-Path -Path $tempDir -ChildPath "sha256sums.txt") | Should -Exist
        }
        
        It "MD5 checksums are correct" {
            $md5sums | Should -Contain "$expectedMD5  $file1Path"
        }
        
        It "SHA1 checksums are correct" {
            $sha1sums | Should -Contain "$expectedSHA1  $file1Path"
        }
        
        It "SHA256 checksums are correct" {
            $sha256sums | Should -Contain "$expectedSHA256  $file1Path"
        }
    }
    
    Context "Archive checksum files" {
        It "Creates checksum files for archives" {
            $archive1 = Join-Path -Path $outputDir -ChildPath "project1_artifacts" -AdditionalChildPath "project1_artifacts.7z"
            "${archive1}.md5" | Should -Exist
            "${archive1}.sha1" | Should -Exist
            "${archive1}.sha256" | Should -Exist
        }
        
        It "Archive checksum files contain valid hashes" {
            $archive1 = Join-Path -Path $outputDir -ChildPath "project1_artifacts" -AdditionalChildPath "project1_artifacts.7z"
            
            (Get-Content -Path "${archive1}.md5").Trim() | Should -Match '^[a-f0-9]{32}$'
            (Get-Content -Path "${archive1}.sha1").Trim() | Should -Match '^[a-f0-9]{40}$'
            (Get-Content -Path "${archive1}.sha256").Trim() | Should -Match '^[a-f0-9]{64}$'
            
            $actualMD5 = (Get-FileHash -Path $archive1 -Algorithm MD5).Hash
            (Get-Content -Path "${archive1}.md5").Trim() | Should -Be $actualMD5
        }
    }
    
    It "Handles empty source directory" {
        $emptyDir = Join-Path -Path $TestDrive -ChildPath "empty"
        New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
        
        { .\archivate_script.ps1 -SourceDir $emptyDir -OutputDir $outputDir } | Should -Not -Throw
    }
}