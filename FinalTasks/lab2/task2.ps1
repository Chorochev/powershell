<#
    .SYNOPSIS
    task2.ps1

    .DESCRIPTION
    Creatings accounts_new.csv and updates columns name and email.

    .PARAMETER path
    The path to employee’s accounts.

    .OUTPUTS
    Creates a new filein current directory ("accounts_new.csv").

    .EXAMPLE
    PS> .\task2.ps1 .\accounts.csv    
#>

[CmdletBinding()]
Param
(
    [parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path -Path $_ }, ErrorMessage = "Wrong path.")]
    [String]    
    $path
) 

begin {
    
}

process {    
    $EmailHashTable = New-Object 'HashTable'
    $TextInfo = (Get-Culture).TextInfo   

    # Reading all the file.   
    $accounts = Import-Csv $path    
    $accounts | Foreach-Object { 
        # Formatting the name
        $_.name = $TextInfo.ToTitleCase($_.name)
        # Creating the email
        $name_array = -split $_.name
        $_.email = -join ($name_array[0][0], $name_array[1])
        $_.email = $TextInfo.ToLower($_.email)
        if ($EmailHashTable.ContainsKey($_.email)) {
            $EmailHashTable[$_.email]++
        }
        else {
            $EmailHashTable[$_.email] = 1
        }       
    }    
    # Updates emails 
    $accounts | Foreach-Object { 
        if ($EmailHashTable[$_.email] -gt 1) {
            $_.email = -join ($_.email, $_.location_id, "@abc.com")
        }
        else {
            $_.email = -join ($_.email, "@abc.com")
        }
    }
    # Creating new file
    $accounts | Export-Csv -UseQuotes AsNeeded -Path .\accounts_new.csv    
}

end {
    
}

