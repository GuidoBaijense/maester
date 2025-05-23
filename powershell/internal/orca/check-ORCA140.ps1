# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA140 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA140()
    {
        $this.Control=140
        $this.Area="Anti-Spam Policies"
        $this.Name="High Confidence Spam Action"
        $this.PassText="High Confidence Spam action set to Quarantine message"
        $this.FailRecommendation="Change High Confidence Spam action to Quarantine message"
        $this.Importance="It is recommended to configure High Confidence Spam detection action to Quarantine message."
        $this.ExpandResults=$True
        $this.ItemName="Anti-Spam Policy"
        $this.DataType="Action"
        $this.ChiValue=[ORCACHI]::Medium
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-spam settings"="https://security.microsoft.com/antispam"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-6"
        }  
    }

    <#
    
        RESULTS
    
    #>
    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"]).Count  
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
       
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $HighConfidenceSpamAction = $($Policy.HighConfidenceSpamAction)

            $IsBuiltIn = $false
            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem=$policyname
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
            
            # Fail if HighConfidenceSpamAction is not set to Quarantine
    
            If($HighConfidenceSpamAction -eq "Quarantine") 
            {
                $ConfigObject.ConfigData=$HighConfidenceSpamAction
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            else 
            {
                $ConfigObject.ConfigData=$HighConfidenceSpamAction
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # For either Delete or Quarantine we should raise an informational
            If($HighConfidenceSpamAction -eq "Delete" -or $HighConfidenceSpamAction -eq "Redirect")
            {
                $ConfigObject.ConfigData=$HighConfidenceSpamAction
    
                $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                $ConfigObject.InfoText = "The $(HighConfidenceSpamAction) option may impact the users ability to release emails and may impact user experience."
            }

            # Add config to check
            $this.AddConfig($ConfigObject)
            
        }        

    }

}
