function Unzip {
    param (
        [Parameter(Mandatory=$true)]
        [string] $myPath
    )

    #Get the list of zip files from the specified path
    $zipFiles = Get-ChildItem -Path $myPath -Filter *.zip

    foreach ($item in $zipFiles)
    {
        # Unzip the file
        $destinationPath = ($item.FullName -replace '.zip', '')
        Expand-Archive -Path $item.FullName -DestinationPath $destinationPath -Force

        # Remove the zip file after extraction
        if (Test-Path -Path $destinationPath) {
            Remove-Item -Path $item.FullName -Recurse -Force
        }
    }
}

# util to print a queue, if needed
function Print-Queue {
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Queue[System.IO.DirectoryInfo]] $queue
    )

    foreach ($item in $queue) {
        Write-Host $item.FullName
    }
}

function Unzip-All-Nested-Files-And-Move (
    param (
        [Parameter(Mandatory=$true)]
        [string] $myRootPath,
        [string] $myDestinationPath
    )

    #Initialize a queue with the root path
    $queue = [System.Collections.Generic.Queue[System.IO.DirectoryInfo]]::new()
    $queue.Enqueue((Get-Item -Path $myRootPath))
    #Print-Queue -queue $queue

    # Process the queue
    while ($queue.Count -gt 0) {
        $currentFolder = $queue.Dequeue()
        $currentFolderPath = $currentFolder.FullName
        Write-Host "Current Folder Path: $currentFolderPath"

        Unzip -myPath %currentFolderPath

        # Get all subfolders of the current folder and enqueue them
        $subfolders = Get-ChildItem -Path $currentFolderPath -Directory
        foreach ($subfolder in $subfolders) {
            $subfolderPath = $subFolder.FullName
            Write-Host "Current SubFolder Path: $currentFolderPath"

            $queue.Enqueue($subfolder)
        }

        # Get all files in the current folder except .ps1 and .whatever files
        # and move them to destination
        $files = Get-ChildItem -Path $currentFolderPath -File | Where-Object {
            # $_ represents the current object in the pipeline
            $_.Extension -ne ".ps1" -and $_.Extension -ne ".whatever"
        }
        foreach ($file in $files) {
            $filePath = $file.FullName
            Write-Host "Current File: $filePath"
            # Move file to the parent folder
            Move-Item -Path $filePath -Destination $myDestinationPath -Force
        }
    }
)