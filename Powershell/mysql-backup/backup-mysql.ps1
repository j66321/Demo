#!/usr/bin/pwsh


$backuptime = Get-Date -format "yyyyMMddHHmm"
$Username = 'administrator@vsphere.local'
$cred = New-Object System.Management.Automation.PsCredential $Username,(Get-Content ./secret/vc.txt| ConvertTo-SecureString)

Write-Host "`n########## 選擇 MYSQL Server ##########"
Write-Host "`t1.bingo-rel-mysql-db01 - 10.1.7.84"
Write-Host "`t2.bingo-stg-mysql-db01 - 10.1.7.83"
$mysql_server = Read-Host "Choose MYSQL Server(1 or 2) "

function choose_action {
    Write-Host "`n########## Choose function ##########"
    Write-Host "1. List Restore Point"
    Write-Host "2. Backup MYSQL"
    Write-Host "3. Restore MYSQL"
    $global:mysql_choice = Read-Host "Choose(1 or 2 or 3) "
    Write-Host "You chose $global:mysql_choice`n"
}

function list_restore_point { Write-Host "List Restore Point(Latest 10 item)" ; Connect-VIServer 10.1.1.15 -Credential $cred | Out-Null ; Get-Snapshot -VM $vmname | Sort-Object -Descending -Property Name | Format-Table -AutoSize -Property Name | select -first 10}

function take_snapshot { $global:snapshot_description = Read-Host "Type description" ; Write-Host $backuptime-$global:snapshot_description ; Connect-VIServer 10.1.1.15 -Credential $cred | Out-Null ; New-Snapshot -VM $vmname -Name "$backuptime-$snapshot_description" -Memory}

function recover_vm { Write-Host "List Restore Point(Latest 10 item)" ; Connect-VIServer 10.1.1.15 -Credential $cred | Out-Null ; Get-Snapshot -VM $vmname | Sort-Object -Descending -Property Name | Format-Table -AutoSize -Property Name | select -first 10 ; $global:snapshot_name = Read-Host "List Restore point name(Ex:202209261600_demo)" ; Connect-VIServer 10.1.1.15 -Credential $cred | Out-Null ; Set-VM -VM $vmname -Snapshot $global:snapshot_name | Out-Null ; Write-Host "Restore finished，Wait 5 mins then try the mysql"}

choose_action
switch ( $mysql_server ){
    1 { $vmname = "10.1.7.084_bingo-rel-mysql-db01 (2.0)"
        switch ( $mysql_choice ){
            1 { list_restore_point }
            2 { take_snapshot }
            3 { recover_vm }
                                }
      }
    2 { $vmname = "10.1.7.083_bingo-stg-mysql-db01 (2.0)"
        switch ( $mysql_choice ){
            1 { list_restore_point }
            2 { take_snapshot }
            3 { recover_vm }
                                }
      }
}

