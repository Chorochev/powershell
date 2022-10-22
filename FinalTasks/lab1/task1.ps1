<#
    .SYNOPSIS
    task1.ps1

    .DESCRIPTION
    This script check if ip_address_1 and ip_address_2 belong to the same network or not.

    .PARAMETER ip_address_1
    The first IP-address in the format x.x.x.x .

    .PARAMETER ip_address_2
    The second IP-address in the format x.x.x.x .

    .PARAMETER network_mask
    The network mask in the format x.x.x.x or xx (255.0.0.0 or 8). 

    .OUTPUTS
    Text output yes or no.

    .EXAMPLE
    PS> .\task1.ps1 -ip_address_1 192.168.0.10 -ip_address_2 192.168.0.20 -network_mask 255.255.255.0
    yes

    .EXAMPLE
    PS> .\task1.ps1 -ip_address_1 192.168.0.10 -ip_address_2 192.168.0.20 -network_mask 24
    yes 
    
    .EXAMPLE
    PS> .\task1.ps1 -ip_address_1 192.168.1.10 -ip_address_2 192.168.0.20 -network_mask 24
    no 
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, mandatory = $true)]  
    [string]$ip_address_1,

    [Parameter(Position = 1, mandatory = $true)]   
    [string]$ip_address_2,

    [Parameter(Position = 2, mandatory = $true)]   
    [string]$network_mask
)

begin {    
    [int]$count_error = 0
    # The temples for regular
    [string]$temlpe_ip = "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"     
    [string]$temlpe_network_mask = "\b([1-9]|1[1-9]|2[1-9]|3[1-2])\b"

    # chech 1
    $result1 = $ip_address_1 -match $temlpe_ip        
    if ($result1 -eq $false) {
        Write-Host "ERROR: The ip_address_1 $ip_address_1 is invalid. Use this format x.x.x.x." -ForegroundColor Red
        $count_error++
    }   

    # chech 2
    $result2 = $ip_address_2 -match $temlpe_ip        
    if ($result2 -eq $false) { 
        Write-Host "ERROR: The ip_address_2 $ip_address_2 is invalid. Use this format x.x.x.x." -ForegroundColor Red        
        $count_error++       
    }  
    
    function Convert_IP_to_bits {      
        param (
            [string]$ip
        )
        $separator = '.'
        $arr = $ip.Split($separator)
        [string]$binarstr = ""
        for ($i = 0; $i -lt $arr.Count; $i++) {   
            $item = [Convert]::ToString($arr[$i], 2)
            [int]$num = [System.Convert]::ToString($item)    
            $binarstr += "{0:d8}" -f $num
        }     
        Write-Output $binarstr
    }

    $result3 = $network_mask -match $temlpe_ip        
    if ($result3 -eq $true) {   
        $binarstr = Convert_IP_to_bits $network_mask  
        if ( $binarstr -like "*01*") {           
            Write-Host "ERROR: The network_mask $network_mask is invalid. Use this format x.x.x.x." -ForegroundColor Red        
            $count_error++ 
        }    
    }  
    
    $result4 = $network_mask -match $temlpe_network_mask   
    if ($result3 -eq $false -And $result4 -eq $false ) { 
        Write-Host "ERROR: This $network_mask isn't a subnet mask." -ForegroundColor Red        
        $count_error++
    }   
    
    if ($count_error -gt 0) {
        break
    }
}

process {       
    # Convert all to bit arrays
    [string]$binar_ip1 = Convert_IP_to_bits $ip_address_1
    [string]$binar_ip2 = Convert_IP_to_bits $ip_address_2    
    [string]$binar_mask = ""
    if ($network_mask -match $temlpe_ip) {
        $binar_mask = Convert_IP_to_bits $network_mask
    }
    if ($network_mask -match $temlpe_network_mask) {       
        [int]$ones = [System.Convert]::ToString($network_mask)  
        for ($i = 0; $i -lt $ones; $i++) {  
            $binar_mask = $binar_mask + "1"
        }
        $zeros = 32 - $ones
        for ($i = 0; $i -lt $zeros; $i++) {  
            $binar_mask = $binar_mask + "0"
        }
    }

    [string]$subnet_address1 = ""
    [string]$subnet_address2 = ""
    # Getting networks addresses
    for ($i = 0; $i -lt 32; $i++) {
        $newbit1 = "0"
        $newbit2 = "0"
        if ($binar_mask[$i] -eq "1") {
            $newbit1 = $binar_ip1[$i]
            $newbit2 = $binar_ip2[$i]
        }
        $subnet_address1 = $subnet_address1 + $newbit1
        $subnet_address2 = $subnet_address2 + $newbit2
    }

    # Write-Host "ip1  => $binar_ip1" -ForegroundColor Yellow
    # Write-Host "ip2  => $binar_ip2" -ForegroundColor Yellow
    # Write-Host "mask => $binar_mask" -ForegroundColor Yellow
    # Write-Host "adr1 => $subnet_address1" -ForegroundColor Yellow
    # Write-Host "adr2 => $subnet_address2" -ForegroundColor Yellow
    
    if ($subnet_address1 -eq $subnet_address2) {
        Write-Host "yes" -ForegroundColor Green
    }
    else {
        Write-Host "no" -ForegroundColor Red
    }
}

end {
    
}

