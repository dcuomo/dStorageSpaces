function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$FriendlyName
	)

	<#
	$returnValue = @{
		FriendlyName = [System.String]
		Ensure = [System.String]
		PoolName = [System.String]
		ResiliencySettingName = [System.String]
		Size = [System.UInt64]
		NumberofColumns = [System.UInt16]
		NumberofDataCopies = [System.UInt16]
	}

	$returnValue
	#>
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$FriendlyName,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[System.String]
		$PoolName,

		[ValidateSet("Simple","Mirror","Parity")]
		[System.String]
		$ResiliencySettingName,

		[System.UInt64]
		$Size,

		[System.UInt16]
		$NumberofColumns,

		[System.UInt16]
		$NumberofDataCopies
	)


    $vhd = Get-VirtualDisk -FriendlyName $FriendlyName -ErrorAction SilentlyContinue

    Switch ($Ensure) {
        Absent { Remove-VirtualDisk -FriendlyName $FriendlyName -Confirm:$false }
        Present { 
            If ($vhd -eq $null) { 
                New-VirtualDisk -StoragePoolFriendlyName $PoolName -FriendlyName $FriendlyName -ResiliencySettingName $ResiliencySettingName -Size $Size -NumberOfDataCopies $NumberofDataCopies -NumberOfColumns $NumberofColumns
            } ElseIf ($Size -ne $vhd.Size) {
                Resize-VirtualDisk -FriendlyName $FriendlyName -Size $Size
            }
        }
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$FriendlyName,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[System.String]
		$PoolName,

		[ValidateSet("Simple","Mirror","Parity")]
		[System.String]
		$ResiliencySettingName,

		[System.UInt64]
		$Size,

		[System.UInt16]
		$NumberofColumns,

		[System.UInt16]
		$NumberofDataCopies
	)

    $vhd = Get-VirtualDisk -FriendlyName $FriendlyName -ErrorAction SilentlyContinue

    Switch ($Ensure) {
        Absent  { if ( $vhd -eq $null ) { $Result = $true } Else { $Result = $false } }
        Present { if ( $vhd -eq $null ) { $Result = $false }
            Elseif ($Size -ne $vhd.Size) { $Result = $false }
            Else { $Result = $true } } 
    }

	$result
}


Export-ModuleMember -Function *-TargetResource

