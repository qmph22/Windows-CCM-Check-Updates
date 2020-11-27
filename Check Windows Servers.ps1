#Define Servers
$Servers = 'server1', 'server2', 'server3','server1', 'server2', 'server3','server1', 'server2', 'server3'

#Define Array (empty)
$Updates = @()

#Define Job List (empty)
$Jobs = @()

#Iterate attempt to connect to servers. Continue foreach loop if server cannot be reached.
Write-Host "Checking servers: $Servers"
Foreach ($Server in $Servers){
#Begin seperate job for each server to reduce time spent running this entire script
$Jobs += Start-Job -ScriptBlock {
    #Check connection to $Using:Server with ICMP. $Using is to be able to send local variables to remote commands
    if (Test-Connection -ComputerName $Using:Server -Quiet -Count 2)
    {
            #If connection was sucessful, attempt to pull updates from the server
            Try {
            $Application = Invoke-Command -cn -$Using:Server {Get-WmiObject -Namespace 'root\ccm\clientdsk' -Class CCM_SoftwareUpdate}

            #If Application is empty, there are no CCM updates available at this time
            if (!$Application){
                New-Object PSObject -Property ([ordered]@{
                n = 'ServerName'
                e = $Using:Server
                ArticleID = ' - '
                Publisher = ' - '
                Software = ' - '
                Description = ' - '
                State = ' - '
                CCMErrorCode = ' - '})
                }
            else {
                #Get evaluation states for each update found.
                Foreach ($App in $Application) {
                    $EvState = Switch ($App.EvaluationState){
                        '0' {}
                        '1' {}
                        '2' {}
                        '3' {}
                        '4' {}
                        '5' {}
                        '6' {}
                        '7' {}
                        '8' {}
                        '9' {}
                        '10' {}
                        '11' {}
                        '12' {}
                        '13' {}
                        '14' {}
                        '15' {}
                        '16' {}
                        '17' {}
                        '18' {}
                        '19' {}
                        '20' {}
                        '21' {}
                        '22' {}
                        '23' {}
                    }
                New-Object PSObject -Property ([ordered]@{
                n = 'ServerName'
                e = $Using:Server
                ArticleID = $App.ArticleID
                Publisher = $App.Publisher
                Software = $App.Name
                Description = $App.Description
                State = $EvState
                CCMErrorCode = $ErrorCode})
                }
            }
        }
        Catch {
            #Write failed server name on a new line with error message
            New-Object PSObject -Property ([ordered]@{
            n = 'ServerName'
            e = $Using:Server
            ArticleID = ' ERROR INVOKING COMMAND '
            Publisher = ' ERROR INVOKING COMMAND '
            Software = ' ERROR INVOKING COMMAND '
            Description = ' ERROR INVOKING COMMAND '
            State = ' ERROR INVOKING COMMAND '
            CCMErrorCode = 'ERROR INVOKING COMMAND'})
            Continue
            }
        }
    #If failed, create a line in the $Updates array that says it errored out
    else
    {
        New-Object PSObject -Property ([ordered]@{
        n = 'ServerName'
        e = $Using:Server
        ArticleID = ' CONNECTION ERROR '
        Publisher = ' CONNECTION ERROR '
        Software = ' CONNECTION ERROR '
        Description = ' CONNECTION ERROR '
        State = ' CONNECTION ERROR '
        CCMErrorCode = 'CONNECTION ERROR'})
        Continue
    }
    }
}
        $Updates += New-Object PSObject -Property ([ordered]@{
        n = 'ServerName'
        e = 'TestServer'
        ArticleID = ' TEST '
        Publisher = ' TEST '
        Software = ' TEST '
        Description = ' TEST '
        State = ' TEST '
        CCMErrorCode = '0x12345678'})

Write-Host 'Waiting for jobs to finish'
#Wait for jobs to complete. Supress output
Get-Job | Wait-Job | Out-Null

#Add results of all jobs to $Updates and display
$Updates += Receive-Job -Job $Jobs
$Updates | Out-GridView -Title "Updates"

Read-Host 'Script has ran sucessfully. Press Enter to exit'
