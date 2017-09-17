#v2 adds writing output to the event log 

#eventlog vars
$eventLog = "System"
$eventType = "Information"
$eventID = 212
$eventSource = "SafeRestart"


#declare the day of the month for a reboot
[int]$rebootDay = 22
#set the minimum days before reboot allowed
[int]$rebootAge = 1


#get the current day of the month and hour
[int]$hour = get-date -format HH
[int]$day = get-date -format dd

#get the number of days the server has been running.  Returns "0" if less than 24 hours
$os=Get-WmiObject win32_operatingsystem
$uptime = ((get-date) - ($os.ConvertToDateTime($os.lastbootuptime))).Days

#Create the new event source
if (!(Get-Eventlog -LogName $eventLog -Source $eventSource)){
     New-EventLog -LogName $eventLog  -Source $eventSource
}

If($hour -lt 12 -or $hour -gt 16){ Write-Eventlog -LogName $eventLog -Source $eventSource -EntryType $eventType -EventID $eventID -Message "Will not reboot, outside of maintenance hours" }
ElseIf($day -ne $rebootDay) { Write-Eventlog -LogName $eventLog -Source $eventSource -EntryType $eventType -EventID $eventID -Message "Will not reboot, outside of maintenance day" }
ElseIf($uptime -lt $rebootAge) { Write-Eventlog -LogName $eventLog -Source $eventSource -EntryType $eventType -EventID $eventID -Message "Will not reboot, rebooted within 24 hours" }
Else{
	(Write-Eventlog -LogName $eventLog -Source $eventSource -EntryType $eventType -EventID $eventID -Message "This system will be restarted by the SafeRestart Powershell Script")
   (restart-computer)
}
