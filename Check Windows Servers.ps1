﻿#Define Servers
$Servers = 'server1', 'server2', 'server3'

#Define Array (empty)
$Updates = @()

#Iterate attempt to connect to servers. Continue foreach loop if server cannot be reached.
Foreach ($Server in $Servers){

#Check connection to $Server with ICMP
if (Test-Connection -ComputerName $Server -Quiet -Count 2)
{
#If connection was sucessful, attempt to pull updates from the server
Try {
$Application = Invoke-Command -cn -$Server {Get-WmiObject -Namespace 'root\ccm\clientdsk' -Class CCM_SoftwareUpdate}

#If Application is empty, there are no CCM updates available at this time

}
Catch {
Write-Host "Error pulling updates for $Server"
Write-Host $_.ErrorDetails.Message

#Write failed server name on a new line with error message
$Updates += New-Object PSObject -Property ([ordered]@{
n = 'ServerName'
e = $Server
ArticleID = ' ERROR '
Publisher = ' ERROR '
Software = ' ERROR '
Description = ' ERROR '
State = ' ERROR '})
Continue
}
}
#If failed, create a line in the $Updates array that says it errored out
else
{
Write-Host "Error connecting to $Server"
Write-Host $_.ErrorDetails.Message
$Updates += New-Object PSObject -Property ([ordered]@{
n = 'ServerName'
e = $Server
ArticleID = ' ERROR '
Publisher = ' ERROR '
Software = ' ERROR '
Description = ' ERROR '
State = ' ERROR '})
Continue
}




}

$Updates