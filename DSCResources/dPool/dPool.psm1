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

    $StoragePool = Get-StoragePool -FriendlyName $FriendlyName -ErrorAction SilentlyContinue

	$returnValue = @{
		Ensure       = $Ensure
		FriendlyName = $FriendlyName
		SubSystemFriendlyName = ($StoragePool | Get-StorageSubSystem).FriendlyName
		PhysicalDisks         = ($StoragePool | Get-PhysicalDisk).UniqueID
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
        $SubSystemFriendlyName,

        [System.String[]]
        $PhysicalDisksUniqueID
    )

    Switch ($Ensure) {
        Absent { 
            Get-VirtualDisk -StoragePool (Get-StoragePool -FriendlyName $FriendlyName) | Remove-VirtualDisk -Confirm:$false
            Write-Verbose "Removing Storage Pool - $FriendlyName"
            Remove-StoragePool -FriendlyName $FriendlyName -Confirm:$false
        }

        Present { 
            If ($PhysicalDisksUniqueID) {
                Write-Verbose "Creating Storage Pool: $FriendlyName"
                Write-Debug   "--Using specified disks $PhysicalDisksUniqueID"
                New-StoragePool -FriendlyName $FriendlyName -StorageSubSystemFriendlyName $SubSystemFriendlyName -PhysicalDisks (Get-PhysicalDisk -CanPool $true -UniqueId $PhysicalDisksUniqueID)

            } ElseIf (!($PhysicalDisksUniqueID)) {
                Write-Verbose "Creating Storage Pool: $FriendlyName"
                Write-Debug   "--Using all poolable disks"
                New-StoragePool -FriendlyName $FriendlyName -StorageSubSystemFriendlyName $SubSystemFriendlyName -PhysicalDisks (Get-PhysicalDisk -CanPool $true)

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
        $SubSystemFriendlyName,

        [System.String[]]
        $PhysicalDisksUniqueID
    )

    $StoragePool = Get-StoragePool -FriendlyName $FriendlyName -ErrorAction SilentlyContinue

    Switch ($Ensure) {
        Absent  { 
            if ( $StoragePool ) { 
                write-verbose 'Pool Exists - Fails'
                $Result = $false  
            } 
            Else { $Result = $true }
        }
        
        Present { 
            if ( $StoragePool ) { $Result = $true } 
            Else { 
                write-verbose 'Pool does not exist - fails test'
                $Result = $false 
            }
        }
    }

    Write-Debug 'This module validates only that a storage pool of the appropriate name is created.  It does not validate the appropriate disks'
	
	$result
}


Export-ModuleMember -Function *-TargetResource

