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

    $tier = Get-StorageTier -FriendlyName $FriendlyName -ErrorAction SilentlyContinue
    $poolName = ($SSD | Get-StoragePool).FriendlyName

	$returnValue = @{
		Ensure = [System.String] $Ensure
		FriendlyName = [System.String] $FriendlyName
		PoolName = [System.String] $PoolName
		MediaType = [System.String] $tier.MediaType
	}

	$returnValue
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

		[ValidateSet("SSD","HDD")]
		[System.String]
		$MediaType
	)

    Switch ($Ensure) {
        'Present' { 
            Write-Verbose "Creating Storage Tier FriendlyName : $FriendlyName"
            Write-Verbose "Creating Storage Tier's MediaType  : $MediaType"
            Get-StoragePool $PoolName | New-StorageTier –FriendlyName $FriendlyName –MediaType $MediaType }

        'Absent'  { 
            Write-Verbose "Removing Storage Tier FriendlyName : $FriendlyName"
            Write-Verbose "Removing Storage Tier's MediaType  : $MediaType"
            Remove-StorageTier –FriendlyName $FriendlyName -Confirm:$false }
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

		[ValidateSet("SSD","HDD")]
		[System.String]
		$MediaType
	)

    $tier = Get-StorageTier -FriendlyName $FriendlyName -ErrorAction SilentlyContinue
    
    Switch ($Ensure) {
        'Present' { 
            If (!($tier)) { $result = $false }
            Else { $result = $true } }

        'Absent'  { 
            If (!($tier)) { $result = $true }
            Else { $result = $false } }
    }

	$result
}


Export-ModuleMember -Function *-TargetResource

