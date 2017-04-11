# ---------------------------------------------------------------------------
# Author: Keith Hill, jachymko
# Desc:   Configures a Windows PowerShell prompt to use Visual Studio
#         and .NET compilers, libs, header files, etc.
# Date:   Dec 23, 2006
# Site:   http://pscx.codeplex.com
#
# Dependencies: Add-PathVariable cmdlet in PSCX
#
# Preference Variables:
#     VisualStudioSKU, VisualStudioVersion and MSBuildToolsVersion.
#
# Usage:  $Pscx:ScriptsDir\Import-VisualStudioVars.ps1
# ---------------------------------------------------------------------------
param ($SkuPreference     = $Pscx:Preferences['VisualStudioSKU'],
       $VersionPreference = $Pscx:Preferences['VisualStudioVersion'],
       $MSBuildPreference = $Pscx:Preferences['MSBuildToolsVersion'])

# Execute in nested scope so all function definitions go away when script completes
& {
	function Main 
	{
		$VCPath = $VSPath = $null
		
		$VisualStudioKey = Get-VisualStudioKey $SkuPreference $VersionPreference
		if (!$VisualStudioKey -or !(Test-Path $VisualStudioKey.PSPath)) 
		{
			# If Visual Studio is not installed then bail
			return
		}
		
		# Set the paths for Visual Studio C/C++ compiler directories
		$VSPath = GetExistingPath $(Split-Path ($VisualStudioKey.InstallDir) -Parent | Split-Path -Parent)
		$VCPath = GetExistingPath $(Join-Path $VSPath 'VC')
		if ($VSPath) 
		{
			# Set up the base directory environment variables
			Set-PathVariable -Name VSInstallDir -Value $VSPath
			Set-PathVariable -Name VCInstallDir -Value $VCPath	
			Set-PathVariable -Name DevEnvDir    -Value ($VisualStudioKey.InstallDir)
		}
		
		# Set the paths for the Framework and SDK directories
		$FrameworkKey = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\.NETFramework
		Set-PathVariable -Name FrameworkVersion -Value 'v2.0.50727'
		Set-PathVariable -Name FrameworkDir     -Value (GetExistingPath $FrameworkKey.InstallRoot)
		if (@($FrameworkKey.psobject.properties | %{$_.Name}) -contains 'sdkInstallRootv2.0') {
			$sdkInstallDir = GetExistingPath $FrameworkKey.'sdkInstallRootv2.0'
			if ($sdkInstallDir) {
				Set-PathVariable -Name FrameworkSDKDir  -Value $sdkInstallDir
			}
		}
		
		# Get the location of the current Windows SDK dir, if installed
		$WinSdkDir = Get-WindowsSdkDir

		Add-PathVariable -Name 'Path'    -Value (Get-Paths)    -Prepend
		Add-PathVariable -Name 'Include' -Value (Get-Includes) -Prepend
		Add-PathVariable -Name 'Lib'     -Value (Get-Libs)     -Prepend
		Add-PathVariable -Name 'LibPath' -Value (Get-LibPaths) -Prepend
	}
	
	function Get-VSSkuPath
	{
		foreach ($sku in $SkuPreference)
		{
			$SkuPath = (Join-Path $Software32 $sku)
			
			if (Test-Path $SkuPath)
			{
				return $SkuPath
			}
		}
	}
	
	function Get-VSVersionPath($SkuPath)
	{
		foreach ($ver in $VersionPreference)
		{
			$VersionPath = (Join-Path $SkuPath $ver)
			if (Test-Path $VersionPath)
			{
				return $VersionPath
			}
		}
	}

	function Get-VisualStudioKey
	{
		# Determine the base registry path
		$Software32 = 'HKLM:\SOFTWARE\Microsoft'
		
		if ([IntPtr]::Size -eq 8)
		{
			$Software32 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft'
		}
		
		$SkuPath = Get-VSSkuPath $SkuPreference
		if (!$SkuPath)
		{
			Write-Debug "None of the Visual Studio SKUs $($OFS=', '; $SkuPreference) is installed."
			return
		}
		
		$VersionPath = Get-VSVersionPath $SkuPath $VersionPreference
		if (!$VersionPath)
		{
			Write-Debug "None of the Visual Studio versions $($OFS=', '; $VersionPreference) is installed."
			return
		}
		
		Get-ItemProperty $VersionPath
	}
	
	function Get-WindowsSdkDir
	{
		$sdkRegPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows'
		if (Test-Path $sdkRegPath)
		{
			$regval = Get-ItemProperty $sdkRegPath
			if ($regval)
			{
				if ($regval.CurrentInstallFolder) 
				{
					return $regval.CurrentInstallFolder
				}
			}
		}
	
		$sdkRegPath = 'HKCU:\SOFTWARE\Microsoft\Microsoft SDKs\Windows'
		if (Test-Path $sdkRegPath)
		{
			$regval = Get-ItemProperty $sdkRegPath
			if ($regval)
			{
				if ($regval.CurrentInstallFolder) 
				{
					return $regval.CurrentInstallFolder
				}
			}
		}
		
		$defaultPath = join-path $VCPath PlatformSDK
		if (Test-Path $defaultPath)
		{
			return $defaultPath
		}
	}
	
	function Get-MSBuildPath
	{
		foreach ($ver in $MSBuildPreference)
		{
			$VersionPath = Join-Path 'HKLM:\Software\Microsoft\MSBuild\ToolsVersions' $ver

			if (Test-Path $VersionPath)
			{
				return (Get-ItemProperty $VersionPath).MSBuildToolsPath
			}
		}
	}
	
	function GetExistingPath($path)
	{
		if ($path -and (Test-Path $path))
		{
			$path
		}
	}

	function Get-Paths 
	{
		if ($VSPath)
		{
			$Env:DevEnvDir

			join-path $VSPath 'Common7\Tools'
			join-path $VSPath 'Common7\Tools\bin'
		}
		
		if ($VCPath)
		{
			join-path $VCPath 'BIN'
			join-path $VCPath 'VCPackages'
		}			
		
		if ($WinSdkDir)
		{
			join-path $WinSdkDir 'Bin'
		}
		
		if ($Env:FrameworkSDKDir)
		{
			join-path $Env:FrameworkSDKDir 'bin'
		}
		
		# !! This one must be before FrameworkDir to ensure that 
		# !! the 3.5 tools get called instead of 2.0, if preferred.
		GetExistingPath $(Get-MSBuildPath)		
		              
		join-path $Env:FrameworkDir $Env:FrameworkVersion
	}
	
	function Get-Includes
	{
		if ($VCPath)
		{
			join-path $VCPath 'Include'
			join-path $VCPath 'AtlMfc\Include'
		}
		
		if ($WinSdkDir)
		{
			join-path $WinSdkDir 'Include'
		}
		
		if ($Env:FrameworkSDKDir)
		{
			join-path $Env:FrameworkSDKDir 'Include'
		}
	}
	
	function Get-Libs
	{
		if ($VCPath)
		{
			join-path $VCPath 'Lib'
			join-path $VCPath 'AtlMfc\Lib'
		}
		
		if ($WinSdkDir)
		{
			join-path $WinSdkDir 'Lib'
		}
		
		if ($Env:FrameworkSDKDir)
		{		
			join-path $Env:FrameworkSDKDir 'Lib'
		}
	}
	
	function Get-LibPaths
	{
		if ($VCPath)
		{
			join-path $VCPath 'AtlMfc\Lib'
		}
		
		join-path $Env:FrameworkDir $Env:FrameworkVersion
	}

	. Main
}