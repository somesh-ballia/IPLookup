# ---------------------------------------------------------------------------
### <Script>
### <Author>jachymko</Author>
### <Description>Invokes URL to Virtual Server's VSWebApp.exe.
### </Description>
### </Script>
# ---------------------------------------------------------------------------
param($address = 'localhost')

Start-Process "http://$($address):1024/VirtualServer/VSWebApp.exe"