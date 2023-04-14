#!/usr/bin/pwsh

$backuptime = Get-Date -format "yyyyMMddHHmm"
$Username = 'administrator@vsphere.local'
$cred = New-Object System.Management.Automation.PsCredential $Username,(Get-Content /opt/script/secrect/vc.txt| ConvertTo-SecureString)
$url="https://hooks.slack.com/services/123456"

Connect-VIServer 10.1.1.15 -Credential $cred
New-Snapshot -VM "10.1.7.189_jms (2.0)" -Name $backuptime -Memory
Get-VM -Name "10.1.7.189_jms (2.0)"|Get-Snapshot | Where-Object{$_.Created -lt(Get-Date).AddDays(- 30)}| Remove-Snapshot -Confirm:$false

if ( $? -eq 1 )
{
$payload=ConvertTo-Json @{
	"pretext"="Jumpserver Backup Result : Success"
	"color"="#10F509"
} 
Invoke-RestMethod -uri $url -Method Post -body $payload -ContentType 'application/json' | Out-Null
}

else
{
$payload=ConvertTo-Json @{
        "pretext"="Jumpserver Backup Result : Failed"
        "color"="#F50958"
}
Invoke-RestMethod -uri $url -Method Post -body $payload -ContentType 'application/json' | Out-Null
}
