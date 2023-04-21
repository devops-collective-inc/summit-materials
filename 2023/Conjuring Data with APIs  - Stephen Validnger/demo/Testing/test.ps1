#requires -Modules NexuShell

Describe "Update-NexusFileBlobStore" {
    BeforeAll {
        $InModule = @{
            ModuleName = "NexuShell"
        }

        #Invoke-Nexus expects a header so we provide a fake one here
        InModuleScope @InModule {
            $script:header = @{
                Authentication = "fake auth"
            }
        }

        # This creates a dumby function for Invoke-Nexus which will contain our fake header
        Mock Invoke-Nexus @InModule

        # We use a real function, in this case Get-NexusBlobStore, and provide the Invoke-Nexus function with fake data to return
        Mock Get-NexusBlobStore @InModule -MockWith {
            if ($script:BlobStoreObject) {
                $script:BlobStoreObject
            } else {
                [PSCustomObject]@{
                    path = "default"
                    softQuota = @{
                        type  = ""
                        limit = ""
                    }
                }
            }
        }
    }

    # Use a real function, but the Invoke-Nexus call it makes will be faked by the mocks we setup
    Context "Updating a BlobStore Path from 'default'" {

        BeforeAll {
            Update-NexusFileBlobStore -Name "Test" -Path "D:\Repository\" -Confirm:$false
        }

        It "Sets the specified path for the specified BlobStore" {
            Assert-MockCalled Invoke-Nexus @InModule -ParameterFilter {
                $UriSlug -eq "/service/rest/v1/blobstores/file/Test" -and
                $Method -eq "Put" -and
                $Body.path -eq "D:\Repository\"
            } -Scope Context
        }
    }

    Context "Updating a BlobStore Path that is already correct" {
        BeforeAll {
            Update-NexusFileBlobStore -Name "Test" -Path "default" -Confirm:$false
        }

        It "Does not attempt to modify the BlobStore" {
            Assert-MockCalled Invoke-Nexus @InModule -Times 0 -Scope Context
        }
    }

    Context "Updating a BlobStore Quota" {
        BeforeAll {
            Update-NexusFileBlobStore -Name "QuotaTest" -SoftQuotaType Remaining -SoftQuotaLimit 203 -Confirm:$false
        }

        It "Sets the specified quota limit for the specified BlobStore" {
            Assert-MockCalled Invoke-Nexus @InModule -ParameterFilter {
                $UriSlug -eq "/service/rest/v1/blobstores/file/QuotaTest" -and
                $Method -eq "Put" -and
                $Body.softQuota.type -eq "spaceRemainingQuota" -and
                $Body.softQuota.limit -eq 203MB
            } -Scope Context
        }
    }
}