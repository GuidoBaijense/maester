# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()


<#

Checks MDO Anti-phishing policy Advanced phishing thresholds 

#>



class ORCA220 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA220()
    {
        $this.Control=220
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Advanced Phishing Threshold Level"
        $this.PassText="Advanced Phish filter Threshold level is adequate."
        $this.FailRecommendation="Set Advanced Phish filter Threshold to 3 or 4"
        $this.Importance="The higher the Advanced Phishing Threshold Level, the stricter the mechanisms are that detect phishing attempts against your users."
        $this.ExpandResults=$True
        $this.ItemName="Antiphishing Policy"
        $this.DataType="Advanced Phishing Threshold Level"
        $this.ChiValue=[ORCACHI]::Medium
        $this.ObjectType="Policy"
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-phishing"="https://security.microsoft.com/antiphishing"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {


        ForEach($Policy in $Config["AntiPhishPolicy"]) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $PhishThresholdLevel = $($Policy.PhishThresholdLevel)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$policyname
            $ConfigObject.ConfigData=$PhishThresholdLevel
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $ConfigObject.ConfigReadonly = $Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            # Standard

            If($PhishThresholdLevel -eq 3)  
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # Strict

            If($PhishThresholdLevel -eq 4)
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,"Pass")
            } 
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,"Fail")
            }

            $this.AddConfig($ConfigObject)


        }
        
        If($Config["AnyPolicyState"][[PolicyType]::Antiphish] -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem="No Enabled Policies"
            $ConfigObject.ConfigData=""
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            $this.AddConfig($ConfigObject)
        }       

    }

}
