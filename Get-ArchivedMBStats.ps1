###########################################################################
#
# NAME: Get-ArchivedMBStats.ps1
#
# AUTHOR: Peter Schmidt
# EMAIL: peter@msdigest.net
#
# COMMENT: Shows all mailboxes that are enabled for Online Archvie in Exchange 2010. Output shows both Mailbox and Archived Mailbox statistics.
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the creator, owner above has no warranty, obligations,
# or liability for such use.
#
# VERSION HISTORY:
# 1.0 2011.09.29 - Initial release
#
# OUTPUT EXAMPLE:
#	Display Name                 TotalItemSize (MB)               ItemCount Database                RetentionPolicy
#	------------                 ------------------               --------- --------                ---------------
#	Peter Schmidt                               147                    3572 EXDB01                  Default Archive and ...
#	Online Archive - Pet...                     430                    4798 ARDB01
#
# HOW TO RUN:
#	.\Get-ArchivedMBStats.ps1 | ft
#
# INPUTS:
#	None. You cannot pipe objects to this script.
#
###########################################################################

$combCollection = @()

Write-Host "`nPlease wait...`n"

$archiveMailboxes = Get-Mailbox | where {$_.ArchiveDatabase -ne $null} | Select Identity, RetentionPolicy

ForEach ($mbx in $archiveMailboxes)
{
	$mbxStats = Get-MailboxStatistics $mbx.Identity | Select DisplayName, TotalItemSize, ItemCount, Database
	$archiveStats = Get-MailboxStatistics $mbx.Identity -Archive | Select DisplayName, TotalItemSize, ItemCount, Database

	$mbcomb = "" | Select "Display Name", "TotalItemSize (MB)", ItemCount, Database, RetentionPolicy
	$archcomb = "" | Select "Display Name", "TotalItemSize (MB)", ItemCount, Database

	$mbcomb."Display Name" = $mbxStats.DisplayName
	$mbcomb."TotalItemSize (MB)" = [math]::round($mbxStats.TotalItemSize.Value.ToMB(), 2)
	$mbcomb.ItemCount = $mbxStats.ItemCount
	$mbcomb.Database = $mbxStats.Database
	$mbcomb.RetentionPolicy = $mbx.RetentionPolicy
	$archcomb."Display Name" = $archiveStats.DisplayName
	$archcomb."TotalItemSize (MB)" = [math]::round($archiveStats.TotalItemSize.Value.ToMB(), 2)
	$archcomb.ItemCount = $archiveStats.ItemCount
	$archcomb.Database = $archiveStats.Database

	$combCollection += $mbcomb 
	$combCollection += $archcomb
	$combCollection += "`n"
}
write-output $combCollection
Write-Host "`nList of archived mailboxes done...`n" -Foregroundcolor Green