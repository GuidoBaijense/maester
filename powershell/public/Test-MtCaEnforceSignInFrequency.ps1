<#
 .Synopsis
  Checks if the tenant has at least one conditional access policy enforcing sign-in frequency for non-corporate devices

 .Description
    Sign-in frequency conditional access policy can be helpful to minimize the risk of data leakage from a shared device.

  Learn more:
  https://aka.ms/CATemplatesBrowserSession

 .Example
  Test-MtCaEnforceSignInFrequency
#>

Function Test-MtCaEnforceSignInFrequency {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter()]
        [switch]$AllDevices
    )

    if ( ( Get-MtLicenseInformation EntraID ) -eq "Free" ) {
        Add-MtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return $null
    }

    $policies = Get-MtConditionalAccessPolicy | Where-Object { $_.state -eq "enabled" }

    $testDescription = "
Microsoft recommends disabling browser persistence for users accessing the tenant from a unmanaged device.

See [Require reauthentication and disable browser persistence - Microsoft Learn](https://aka.ms/CATemplatesBrowserSession)"
    $testResult = "These conditional access policies enforce the use of a compliant device :`n`n"

    $result = $false
    foreach ($policy in $policies) {
        # Check if device filter for compliant or hybrid Azure AD joined devices is present
        if (-not $AllDevices.IsPresent) {
            if ( $policy.conditions.devices.deviceFilter.mode -eq "include" `
                    -and $policy.conditions.devices.deviceFilter.rule -match 'device.trustType -ne \"ServerAD\"' `
                    -and $policy.conditions.devices.deviceFilter.rule -match 'device.isCompliant -ne True' `
            ) {
                $IsDeviceFilterPresent = $true
            } elseif ( $policy.conditions.devices.deviceFilter.mode -eq "exclude" `
                    -and $policy.conditions.devices.deviceFilter.rule -match 'device.trustType -eq \"ServerAD\"' `
                    -and $policy.conditions.devices.deviceFilter.rule -match 'device.isCompliant -eq True' `
            ) {
                $IsDeviceFilterPresent = $true
            } else {
                $IsDeviceFilterPresent = $false
            }
        } else {
            # We don't care about device filter if we are checking for all devices
            $IsDeviceFilterPresent = $true
        }
        if ( $policy.sessionControls.signInFrequency.isEnabled -eq $true `
                -and $policy.sessionControls.signInFrequency.frequencyInterval -eq "timeBased" `
                -and $IsDeviceFilterPresent `
                -and $policy.conditions.users.includeUsers -eq "All" `
                -and $policy.conditions.applications.includeApplications -eq "All" `
        ) {
            $result = $true
            $currentresult = $true
            $testResult += "  - [$($policy.displayname)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($($policy.id))?%23view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies?=)`n"
        } else {
            $currentresult = $false
        }
        Write-Verbose "$($policy.displayName) - $currentresult"
    }

    if ($result -eq $false) {
        $testResult = "There was no conditional access policy enforcing sign-in frequency for non-corporate devices."
    }
    Add-MtTestResultDetail -Description $testDescription -Result $testResult

    return $result
}