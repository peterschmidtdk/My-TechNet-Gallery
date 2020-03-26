#Change-MailboxType.ps1 Script
#Provided by www.msdigest.net / Peter Schmidt (Exchange MVP, MCM: Exchange)
#Blog: www.msdigest.net
#version: 1.1 (Last update: 2014-03-13)
#How to run the script: powershell.exe -executionpolicy unrestricted -command c:\scripts\Change-MailboxType.ps1
#Display a menu with 7 options, where you can select what you what to change

$error.clear()
Clear-Host
Pushd
[string] $menu = @'

	*******************************
	Change Exchange Recipient Type 
	*******************************
	
	Please select an option from the list below.
	
	1) Show Recipient Type of a Mailbox
	2) Change Mailbox Type to a Room
	3) Change Mailbox Type to Equipment
	4) Change Mailbox Type to a Regular Mailbox
	5) Change Mailbox to a Shared Mailbox
	6) Change Booking Window In Days for all Rooms (set number of days)
	7) Change Booking Window In Days for all Equipment (set number of days)
	
	99) Exit

Select an option.. [1-99]?
'@

function Invoke-Pause	{
	$error.clear()
    Write-Host "Press any key to continue..."
	$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    $Host.UI.RawUI.FlushInputBuffer()
} # end function Invoke-Pause

Do { 	
	if ($opt -ne "None") {Write-Host "Last command: "$opt -foregroundcolor Yellow}	
	$opt = Read-Host $menu

	switch ($opt)    {
		1 { # Show recipient type of a Mailbox
			$MBX = Read-Host "Enter alias of Mailbox"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Invoke-Pause
            cls
        }
		2 { # Change Recipient Type to Room
            $MBX = Read-Host "Enter alias of Mailbox"
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Sleep 1
            Write-Host "Changing Recipient Type..."			
            Get-Mailbox $MBX | Set-Mailbox -Type Room | Set-CalendarProcessing -AutomateProcessing AutoAccept -BookingWindowInDays 360
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Invoke-Pause
            cls
		}
		3 { # Change Recipient Type to Equipment
            $MBX = Read-Host "Enter alias of Mailbox"
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Sleep 1
            Write-Host "Changing Recipient Type..."			
            Get-Mailbox $MBX | Set-Mailbox -Type Equipment | Set-CalendarProcessing -AutomateProcessing AutoAccept -BookingWindowInDays 360
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Invoke-Pause
            cls
		}
		4 { # Change Recipient type to Regular Mailbox
            $MBX = Read-Host "Enter alias of Mailbox"
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Sleep 1
            Write-Host "Changing Recipient Type..."			
            Get-Mailbox $MBX | Set-Mailbox -Type Regular
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Invoke-Pause
            cls
		}
		5 { # Change Recipient type to Shared Mailbox
            $MBX = Read-Host "Enter alias of Mailbox"
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Sleep 1
            Write-Host "Changing Recipient Type..."			
            Get-Mailbox $MBX | Set-Mailbox -Type Shared
            Write-Host "Current settings:"
            Get-Mailbox $MBX | fl Name, ResourceType, RecipientTypeDetails
            Invoke-Pause
            cls
		}
		6 { # Change BookingWindowsInDays for all Rooms
            $BWIDRooms = Read-Host "Enter Booking Windows in Days for all Rooms"
            Write-Host "Changing BookingWindowInDays to"$BWIDRooms			
            Get-Mailbox | Where {$_.RecipientTypeDetails -eq "RoomMailbox"} | Set-CalendarProcessing -BookingWindowInDays $BWIDRooms
            Invoke-Pause
            cls
		}
		7 { # Change BookingWindowsInDays for all Rooms
            $BWIDRooms = Read-Host "Enter Booking Windows in Days for all Rooms"
            Write-Host "Changing BookingWindowInDays to"$BWIDRooms			
            Get-Mailbox | Where {$_.RecipientTypeDetails -eq "EquipmentMailbox"} | Set-CalendarProcessing -BookingWindowInDays $BWIDRooms
            Invoke-Pause
            cls
		}
		99 { # Exit
			popd
			Write-Host "Exiting..."
		}
		default {Write-Host "You haven't selected any of the available options. "}
	}
} while ($opt -ne 99)