. (Join-Path $PSScriptRoot '../Import-LocalModule.ps1')

$isVerbose=($VerbosePreference -eq 'Continue')

Describe "Test_Uri helper function" {
    # Function to test
    . (Join-Path $script:FunctionPath 'PSUri/Test_Uri.ps1')

    Context "Testing multiple URIs and StatusCodes" {
        $uriTests = Import-Csv -LiteralPath (Join-Path $script:FixturePath 'webrequests.csv') -Delimiter ','

        foreach ($uriTest in $uriTests) {
            $verb = 'fail'
            if ($uriTest.shouldpass -eq 1) { $verb = 'pass'}

            It "'$($uriTest.uri)' should $verb if statuscode matches '$($uriTest.statuscodes)'" {
                $result = $null
                if ($uriTest.statuscodes) {
                    $result = Test_Uri -Uri $uriTest.uri -AllowedStatusCodeRegexp $uriTest.statuscodes -ErrorAction SilentlyContinue -Verbose:$isVerbose
                } else {
                    $result = Test_Uri -Uri $uriTest.uri -ErrorAction SilentlyContinue -Verbose:$isVerbose
                }

                $result | Should Not BeNullOrEmpty
                $result.ComputerName | Should Be ([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName)
                $result.TestType | Should Be 'UriTest'
                $result.Test | Should Be $UriTest.uri
                $result.Uri | Should Be $UriTest.uri
                $result.Passed | Should Be ($uriTest.shouldpass -eq 1)
                $result.Result | Should Not BeNullOrEmpty
                $result.Status | Should Not BeNullOrEmpty
            }
        }
    }
}
