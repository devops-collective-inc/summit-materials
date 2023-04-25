Describe 'Bucket check' {
    It 'powershell2023summit should exist' {
        $bucket = Get-S3Bucket -BucketName 'powershell2023summit'
        $bucket | Should -Not -BeNullOrEmpty
    }
    It 'doesnotexistpowershell2023summit should not exist' {
        $bucket = Get-S3Bucket -BucketName 'doesnotexistpowershell2023summit'
        $bucket | Should -BeNullOrEmpty
    }
}