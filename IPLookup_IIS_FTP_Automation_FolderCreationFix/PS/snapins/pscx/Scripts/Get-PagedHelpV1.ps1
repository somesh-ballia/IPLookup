# ---------------------------------------------------------------------------
### <Script>
### <Author>jachymko</Author>
### <Description>
### Pages help using LESS.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
param(
	[string] $Name,
	[string[]] $Category=@('All'),
	[string[]] $Component,
    [string[]] $Functionality,
    [string[]] $Role,
    [switch] $Full,
    [switch] $Detailed,
    [switch] $Examples,
    [string] $Parameter=$null
)

function pager {
	$OutputEncoding = [Console]::OutputEncoding
	
	$input | & "$pscx:Home\Applications\Less-394\less.exe"
}

# Full,Examples,Detailed,Parameter are in different parameter sets
if ($Full)
{
	if ($Detailed)
	{
		#Detailed and #Full are in different sets..let get-help cmdlet handle the error
		get-help $Name -Full -Detailed | pager
		return;
	}

	if ($Examples)
	{
		#Examples and #Full are in different sets..let get-help cmdlet handle the error
		get-help $Name -Full -Examples | pager
		return;
	}

	if ($Parameter)
	{
		#Parameter and #Full are in different sets..let get-help cmdlet handle the error
		get-help $Name -Full -Parameter $Parameter | pager
		return;
	}

	if ( ($Component) -or ($Functionality) -or ($Role) )
	{
		get-help $Name -Full -Category $Category -Component $Component -Functionality $Functionality -Role $Role | pager
		return;
	}

	get-help -Full $Name -Category $Category | pager      
}
elseif ($Detailed)
{
	if ($Examples)
	{
		#Examples and #Detailed are in different sets..let get-help cmdlet handle the error
		get-help $Name -Detailed -Examples | pager  
		return;
	}

	if ($Parameter)
	{
		#Parameter and #Detailed are in different sets..let get-help cmdlet handle the error
		get-help $Name -Detailed -Parameter $Parameter | pager   
		return;
	}

	if ( ($Component) -or ($Functionality) -or ($Role) )
	{
		get-help $Name -Detailed -Category $Category -Component $Component -Functionality $Functionality -Role $Role | pager  
		return;
	}
	get-help $Name -Detailed -Category $Category | pager  
}
elseif ($Examples)
{     
	if ($Parameter)
	{
		#Parameter and #Examples are in different sets..let get-help cmdlet handle the error
		get-help $Name -Examples -Parameter $Parameter | pager  
		return;
	}

	if ( ($Component) -or ($Functionality) -or ($Role) )
	{
		get-help $Name -Examples -Category $Category -Component $Component -Functionality $Functionality -Role $Role | pager  
		return;
	}
	get-help $Name -Examples -Category $Category | pager  
}
elseif ($Parameter)
{
	if ( ($Component) -or ($Functionality) -or ($Role) )
	{
		get-help $Name -Parameter $Parameter -Category $Category -Component $Component -Functionality $Functionality -Role $Role | pager  
		return;
	}
	get-help $Name -Parameter $Parameter -Category $Category | pager  
}
elseif ( ($Component) -or ($Functionality) -or ($Role) )
{
	get-help $Name -Category $Category -Component $Component -Functionality $Functionality -Role $Role | pager  
	return;
}
else
{
	get-help $Name -Category $Category | pager  
}