#
# Get-WebService.ps1 (v2.0 Aug 3, 2007)
#
# Oisin Grehan <oising@gmail.com> (x0n)
#
# Usage: 
#   $proxy = .\get-webservice.ps1 [-Url] http://site/service.asmx?wsdl [-Anonymous] [[-SoapProtocol] <Soap | Soap12>]
#
# to see available webmethods:
# $proxy | gm
#

# $url = "http://services.msdn.microsoft.com/contentservices/contentservice.asmx?wsdl"
 
param($url = $(throw "need `$url"), [switch]$Anonymous, [string]$protocol = "Soap")
 
[void][system.Reflection.Assembly]::LoadWithPartialName("system.web.services")
 
trap {
        "Error:`n`n $error";
        break; 
}
 
#$request = [System.Net.WebRequest]::Create($url);
$dcp = new-object system.web.services.discovery.discoveryclientprotocol
 
if (! $Anonymous) {
    Write-Progress "Network Credentials" "Awaiting input..."
    $dcp.Credentials = (Get-Credential).GetNetworkCredential()
}

Write-Progress "Discovery" "Searching..."
$dcp.AllowAutoRedirect = $true
[void]$dcp.DiscoverAny($url)
$dcp.ResolveAll()

# get service name
foreach ($entry in $dcp.Documents.GetEnumerator()) { # needed for Dictionary
    if ($entry.Value -is [System.Web.Services.Description.ServiceDescription]) {
        $script:serviceName = $entry.Value.Services[0].Name
        Write-Verbose "Service: $serviceName"
    }
}

Write-Progress "WS-I Basic Profile 1.1" "Validating..."
$ns = new-Object System.CodeDom.CodeNamespace # "WebServices"

$wref = new-object System.Web.Services.Description.WebReference $dcp.Documents, $ns
$wrefs = new-object system.web.services.description.webreferencecollection
[void]$wrefs.Add($wref)

$ccUnit = new-object System.CodeDom.CodeCompileUnit
[void]$ccUnit.Namespaces.Add($ns)

$violations = new-object system.web.Services.Description.BasicProfileViolationCollection
$wsi11 = [system.web.services.WsiProfiles]::BasicProfile1_1

if ([system.web.Services.Description.WebServicesInteroperability]::CheckConformance($wsi11, $wref, $violations)) {
    Write-Progress "Proxy Generation" "Compiling..."
    
    $webRefOpts = new-object System.Web.Services.Description.WebReferenceOptions
	$webRefOpts.CodeGenerationOptions = "GenerateNewAsync","GenerateProperties" #,"GenerateOldAsync"

	#StringCollection strings = ServiceDescriptionImporter.GenerateWebReferences(
	#	webReferences, codeProvider, codeCompileUnit, parameters.GetWebReferenceOptions());

    $csprovider = new-object Microsoft.CSharp.CSharpCodeProvider
	$warnings = [System.Web.Services.Description.ServiceDescriptionImporter]::GenerateWebReferences(
		$wrefs, $csprovider, $ccunit, $webRefOpts)
        
    if ($warnings.Count -eq 0) {
        $param = new-object system.CodeDom.Compiler.CompilerParameters
        [void]$param.ReferencedAssemblies.Add("System.Xml.dll")
        [void]$param.ReferencedAssemblies.Add("System.Web.Services.dll")        
        $param.GenerateInMemory = $true;
        #$param.TempFiles = (new-object System.CodeDom.Compiler.TempFileCollection "c:\temp", $true)
        $param.GenerateExecutable = $false;
        #$param.OutputAssembly = "$($ns.Name)_$($sdname).dll"
        $param.TreatWarningsAsErrors = $false;
        $param.WarningLevel = 4;
        
        # do it
        $compileResults = $csprovider.CompileAssemblyFromDom($param, $ccUnit);
 
        if ($compileResults.Errors.Count -gt 0) {
            Write-Progress "Proxy Generation" "Failed."
            foreach ($output in $compileResults.Output) { write-host $output }
            foreach ($err in $compileResults.Errors) { write-warning $err }            
        } else {            
            $assembly = $compileResults.CompiledAssembly

            if ($assembly) {
                $serviceType = $assembly.GetType($serviceName)                
                $assembly.GetTypes() | % { Write-Verbose $_.FullName }
            } else {
                Write-Warning "Failed: `$assembly is null"
				return
            }
            
            # return proxy instance
            $proxy = new-object $serviceType.FullName
            if (! $Anonymous) {
                $proxy.Credentials = $dcp.Credentials
            }
            $proxy # dump instance to pipeline
        }
    } else {
        Write-Progress "Proxy Generation" "Failed."        
        Write-Warning $warnings
    }
    #Write-Progress -Completed
}

