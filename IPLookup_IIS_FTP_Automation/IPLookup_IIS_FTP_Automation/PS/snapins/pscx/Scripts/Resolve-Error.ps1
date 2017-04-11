# ---------------------------------------------------------------------------
### <Script>
### <Author>Jeffrey Snover</Author>
### <Description>
### Use when reporting an error or ask a question about a exception you
### are seeing.  This function provides all the information we have 
### about the error message making it easier to diagnose what is 
### actually going on.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
param($ErrorRecord=$Error[0])

if ($args -eq '-?') {
    ""
    "Usage: Resolve-Error [-ErrorRecord] <object>"
    ""
    "Parameters:"
    "    -ErrorRecord : The error record to resolve (default is `$Error[0]"
    "    -?           : Display this usage information"
    ""
    return
}

$ErrorRecord | Format-List * -Force
$ErrorRecord.InvocationInfo |Format-List *
$Exception = $ErrorRecord.Exception
for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
{   "$i" * 80
   $Exception |Format-List * -Force
}