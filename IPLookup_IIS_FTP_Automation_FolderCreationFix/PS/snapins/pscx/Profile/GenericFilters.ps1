# ---------------------------------------------------------------------------
# Desc:   PowerShell Community Extensions miscellaneous filter definitions.
# Site:   http://pscx.codeplex.com
# Usage:  In your profile place the following command:
#  
#         . "$Pscx:ProfileDir\GenericFilters.ps1"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
### <Filter name='Get-PropertyValue'>
### <Author>Keith Hill</Author>
### <Description>
###	This filter is different from the Select-Object cmdlet in that it
### doesn't create a wrapper object (PSCustomObject) around the property.
### If you just want to get the property's value to assign it to another
### variable this filter will come in handy.  If you assigned the result
### of the Select-Object operation you wouldn't get the property's value.
### You would get an object that wraps that property and its value.
### </Description>
### <Usage>
### $start = Get-History -Id 143 | Get-PropertyValue StartExecutionTime
### </Usage>
### </Filter>
# ---------------------------------------------------------------------------
set-alias gpv Get-PropertyValue -Option AllScope -Description "PSCX filter alias"
filter Get-PropertyValue([string] $propertyName) {
    $_.$propertyName
}

# ---------------------------------------------------------------------------
### <Filter name='Remove-Accessors'>
### <Author>Keith Hill</Author>
### <Description>
###	This filter is intended to be used to filter the Get-Member output
### to eliminate display of compiler generated accessor methods.
### </Description>
### <Usage>
### Get-Process | Get-Member | Remove-Accessors
### </Usage>
### </Filter>
# ---------------------------------------------------------------------------
set-alias ra Remove-Accessors -Option AllScope -Description "PSCX filter alias"
filter Remove-Accessors {
    if ($_.Name -notmatch "(get_*)|(set_*)|(op_*)") { 
        $_ 
    }
}

# ---------------------------------------------------------------------------
### <Filter name='New-HashObject'>
### <Author>Adrian Milliner, added here by jachymko</Author>
### <Description>
###	Use when you need to create a PSObject from a dictionary. The
### keys-value pairs are turned into NoteProperties.
### </Description>
### <Usage>
### $ht = @{fname='John';lname='Doe';age=42}
### $ht | New-HashObject
### </Usage>
### </Filter>
# ---------------------------------------------------------------------------
Set-Alias nho New-HashObject -Option AllScope -Description "PSCX function alias"
filter New-HashObject {
    if ($_ -isnot [Collections.IDictionary]) { 
		return $_ 
	}

    $result = new-object PSObject
    $hash = $_

    $hash.Keys | %{ $result | add-member NoteProperty "$_" $hash[$_] -force }

    $result
}

# ---------------------------------------------------------------------------
### <Filter name='Invoke-Ternary'>
### <Author>Karl Prosser</Author>
### <Description>
###	Similar to the C# ? : operator e.g. name = (value != null) ? String.Empty : value;
### </Description>
### <Usage>
### 1..10 | ?: {$_ -gt 5} {"Greater than 5";$_} {"Not greater than 5";$_}
### </Usage>
### </Filter>
# ---------------------------------------------------------------------------
set-alias ?: Invoke-Ternary -Option AllScope -Description "PSCX filter alias"
filter Invoke-Ternary {
	param([scriptblock]$condition  = $(throw "Parameter '-condition' (position 1) is required"), 
	      [scriptblock]$trueBlock  = $(throw "Parameter '-trueBlock' (position 2) is required"), 
	      [scriptblock]$falseBlock = $(throw "Parameter '-falseBlock' (position 3) is required"))
	
	if (&$condition) { 
		&$trueBlock
	} 
	else { 
		&$falseBlock 
	}
}

# ---------------------------------------------------------------------------
### <Filter name='Invoke-NullCoalescing'>
### <Author>Keith Hill but heavily influenced by Karl Prosser's Invoke-Ternary</Author>
### <Description>
###	Similar to the C# ?? operator e.g. name = value ?? String.Empty;
### where value would be a Nullable&lt;T&gt; in C#.  Even though PowerShell
### doesn't support nullables yet we can approximate this behavior.
### In the example below, $LogDir will be assigned the value of $env:LogDir
### if it exists and it's not null, otherwise it get's assigned the
### result of the second script block (C:\Windows\System32\LogFiles).
### This behavior is also analogous to Korn shell assignments of this form:
### LogDir = ${$LogDir:-$WinDir/System32/LogFiles}
### </Description>
### <Usage>
### $LogDir = ?? {$env:LogDir} {"$env:windir\System32\LogFiles"}
### </Usage>
### </Filter>
# ---------------------------------------------------------------------------
set-alias ?? Invoke-NullCoalescing -Option AllScope -Description "PSCX filter alias"
filter Invoke-NullCoalescing {
	param([scriptblock]$primaryExpr   = $(throw "Parameter '-primaryExpr' (position 1) required"), 
	      [scriptblock]$alternateExpr = $(throw "Parameter '-alternateExpr' (position 2) required"))
	      
	if ($primaryExpr -ne $null) {
		$result = &$primaryExpr
		if ($result -ne $null -and "$result" -ne '') {
			$result
		}
		else {
			&$alternateExpr
		}
	}
	else {
		&$alternateExpr
	}
}