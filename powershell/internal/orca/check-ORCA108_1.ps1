# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA108_1 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA108_1()
    {
        $this.Control="108-1"
        $this.Area="DKIM"
        $this.Name="DNS Records"
        $this.PassText="DNS Records have been set up to support DKIM"
        $this.FailRecommendation="Set up the required selector DNS records in order to support DKIM"
        $this.Importance="DKIM signing can help protect the authenticity of your messages in transit and can assist with deliverability of your email messages."
        $this.ExpandResults=$True
        $this.ItemName="Domain"
        $this.DataType="DNS Record"
        $this.ChiValue=[ORCACHI]::Low
        $this.Links= @{
            "Use DKIM to validate outbound email sent from your custom domain in Office 365"="https://aka.ms/orca-dkim-docs-1"
        }
    
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        $Check = "DKIM"

        # Check pre-requisites for DNS resolution
        If(!(Get-Command "Resolve-DnsName" -ErrorAction:SilentlyContinue))
        {
            # No Resolve-DnsName command
            ForEach($AcceptedDomain in $Config["AcceptedDomains"])
            {
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object = $($AcceptedDomain.Name)
                $ConfigObject.SetResult([ORCAConfigLevel]::All,[ORCAResult]::Informational)
                $ConfigObject.ConfigItem = "Pre-requisites not installed"
                $ConfigObject.ConfigData = "Resolve-DnsName is not found on ORCA computer. Required for DNS checks."
                $this.AddConfig($ConfigObject)
            }

            $this.CheckFailed = $true
            $this.CheckFailureReason = "Resolve-DnsName is not found on ORCA computer and is required for DNS checks."
        } 
        else 
        {
            # Check DKIM is enabled
    
            ForEach($AcceptedDomain in $Config["AcceptedDomains"]) 
            {
                $HasMailbox = $false
                
                try
                {
                    
                    If($AcceptedDomain.Name -notlike "*.onmicrosoft.com") 
                { 
                        $mailbox = Resolve-DnsName -Name $($AcceptedDomain.Name) -Type MX -ErrorAction:Stop
                        if($null -ne $mailbox -and $mailbox.Count -gt 0)
                        {
                            $HasMailbox = $true
                        }
                    }
                }
                Catch{}
                If($HasMailbox) 
                {
        
                    # Get matching DKIM signing configuration
                    $DkimSigningConfig = $Config["DkimSigningConfig"] | Where-Object {$_.Name -eq $AcceptedDomain.Name}
        
                    If($DkimSigningConfig)
                    {  
                        if($DkimSigningConfig.Enabled -eq $true)
                        {

                            <#
                            
                            SELECTOR1
                            
                            #>
                                $ConfigObject = [ORCACheckConfig]::new()
                                $ConfigObject.ConfigItem=$($DkimSigningConfig.Domain)

                                # Check DKIM Selector Records
                                $Selector1 = $Null
                                if($null -ne $this.ORCAParams.AlternateDNS)
                                {
                                    Try { $Selector1 = Resolve-DnsName -Type CNAME -Name "selector1._domainkey.$($DkimSigningConfig.Domain)" -Server $this.ORCAParams.AlternateDNS -ErrorAction:stop } Catch {}
                                }
                                else 
                                {
                                    Try { $Selector1 = Resolve-DnsName -Type CNAME -Name "selector1._domainkey.$($DkimSigningConfig.Domain)" -ErrorAction:stop } Catch {}
                                }
                                
                                If($Selector1.Type -eq "CNAME" -and $Selector1.NameHost -eq $DkimSigningConfig.Selector1CNAME)
                                {
                                    # DKIM Selector1 Correctly Configured
                                    $ConfigObject.ConfigData="Selector1 CNAME $($DkimSigningConfig.Selector1CNAME)"
                                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                                } 
                                else
                                {
                                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")   
                                }

                                # Add selector 1 result
                                $this.AddConfig($ConfigObject)
                            
                            <#
                            
                            SELECTOR2
                            
                            #>
                                # Selector 2 Config Object
                                $ConfigObject = [ORCACheckConfig]::new()
                                $ConfigObject.ConfigItem=$($DkimSigningConfig.Domain)
                            
                                # Check DKIM Selector Records
                                $Selector2 = $Null
                                if($null -ne $this.ORCAParams.AlternateDNS)
                                {
                                    Try { $Selector2 = Resolve-DnsName -Type CNAME -Name "selector2._domainkey.$($DkimSigningConfig.Domain)" -Server $this.ORCAParams.AlternateDNS -ErrorAction:stop } Catch {}
                                }
                                else 
                                {
                                    Try { $Selector2 = Resolve-DnsName -Type CNAME -Name "selector2._domainkey.$($DkimSigningConfig.Domain)" -ErrorAction:stop } Catch {}
                                }

                                If($Selector2.Type -eq "CNAME" -and $Selector2.NameHost -eq $DkimSigningConfig.Selector2CNAME)
                                {
                                    # DKIM Selector1 Correctly Configured
                                    $ConfigObject.ConfigData="Selector2 CNAME $($DkimSigningConfig.Selector2CNAME)"
                                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                                }
                                else
                                {
                                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")  
                                }    
                                
                                # Add selector 2 result
                                $this.AddConfig($ConfigObject)
                        }
                    }
        
                }
        
            }     
        }
    }

}

