# ---------------------------------------------------------------------------
# Author: jachymko
# Desc:   Common appearance settings
# Date:   Dec 23, 2006
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following commands:
#  
#         . "$Pscx:ProfileDir\EyeCandy.ps1"
# ---------------------------------------------------------------------------

function Start-EyeCandy 
{	
	. $Pscx:Preferences['EyeCandyScript']

	if ($Host.Name -eq 'ConsoleHost')
	{
		if ($Pscx:Session['EyeCandy/ConsoleForeColor']) 
		{
			$Host.UI.RawUI.ForegroundColor = $Pscx:Session['EyeCandy/ConsoleForeColor']
		}
		
		if ($Pscx:Session['EyeCandy/ConsoleBackColor']) 
		{
			$Host.UI.RawUI.BackgroundColor = $Pscx:Session['EyeCandy/ConsoleBackColor']
			$Host.PrivateData.ErrorBackgroundColor   = $Pscx:Session['EyeCandy/ConsoleBackColor']
			$Host.PrivateData.WarningBackgroundColor = $Pscx:Session['EyeCandy/ConsoleBackColor']
			$Host.PrivateData.DebugBackgroundColor   = $Pscx:Session['EyeCandy/ConsoleBackColor']
			$Host.PrivateData.VerboseBackgroundColor = $Pscx:Session['EyeCandy/ConsoleBackColor']
		}
		
		Update-HostTitle
	}
	
	if ($Pscx:Session['EyeCandy/MotDayPreference'] -is [ScriptBlock]) 
	{
		$Banner = & $Pscx:Session['EyeCandy/MotDayPreference']
		if ($Banner) 
		{
			if ($Host.Name -eq 'ConsoleHost')
			{
				$foreColor = $Host.UI.RawUI.ForegroundColor
				if ($Pscx:Session['EyeCandy/PromptForeColor'] -and ($Host.Name -eq 'ConsoleHost'))
				{
					$foreColor = $Pscx:Session['EyeCandy/PromptForeColor']
				}
				$Banner | Write-Host -ForegroundColor $foreColor
			}
			else
			{
				# For any other host besides powershell.exe, just output banner
				$Banner			
			}
		}
	}
}

#
# Prompt function
# 
# To modify, create $PscxPromptPreference variable.
# For an example, see the EyeCandy.*.ps1 scripts.
#
function Write-Prompt 
{
	param($Id, 
	      $ForeColor = $Pscx:Session['EyeCandy/PromptForeColor'], 
	      $BackColor = $Pscx:Session['EyeCandy/PromptBackColor'])
	      
	# Default prompt
	$prompt = "PS $(get-location)>"
	if ($Pscx:Session['EyeCandy/PromptPreference'] -is [ScriptBlock]) 
	{
		$OFS = ''
		$prompt = "$(& $Pscx:Session['EyeCandy/PromptPreference'] $Id)"
	}
	
	if ($Host.Name -eq 'ConsoleHost')
	{
		if ($Host.UI.RawUI.CursorPosition.X -ne 0)
		{
			write-host
		}	
	
		if (!$ForeColor)
		{
			$ForeColor = $Host.UI.RawUI.ForegroundColor
		}
		
		if (!$BackColor)
		{
			$BackColor = $Host.UI.RawUI.BackgroundColor	
		}
	
		($prompt) | write-host -NoNewLine -ForegroundColor $ForeColor -BackgroundColor $BackColor
	}
	else
	{
		# For any other host besides powershell.exe, just return the prompt string
		$prompt
	}
}

# ---------------------------------------------------------------------------
### <Function name='Prompt'>
### <Author>jachymko</Author>
### <Description>
### Replacement prompt function.  See EyeCandy.Vista.ps1 and EyeCandy.WinXP.ps1
### for examples on how to configure the prompt
### function.
### </Description>
### </Function>
# ---------------------------------------------------------------------------
function Prompt
{
	$id = 0
	$histItem  = Get-History -Count 1
	if ($histItem -ne $null) {
		$id = $histItem.Id
	}
	Write-Prompt ($id + 1)
	Update-HostTitle
	return ' '
}

#
# Host Title function
#
# Uses the $PscxHostTitlePreference variable.
# For an example, see the EyeCandy.*.ps1 scripts.
#
function Update-HostTitle
{
	if ($Host.Name -eq 'ConsoleHost')
	{
		if ($Pscx:Session['EyeCandy/HostTitlePreference'] -is [ScriptBlock])
		{
			$title = & $Pscx:Session['EyeCandy/HostTitlePreference']
			
			if ($title)
			{
				$OFS = ' '
				$Host.UI.RawUI.WindowTitle = "$title"
				return
			}
		}
		
		if ($Pscx:Session['EyeCandy/HostTitlePreference'])
		{
			$Host.UI.RawUI.WindowTitle = "$($Pscx:Session['EyeCandy/HostTitlePreference'])"
		}
	}
}

Start-EyeCandy