param
(
[String]$SourceFile
)

$pass = ''
$pair = "somekey:x"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$filename = Split-Path $SourceFile -leaf
$headers = @{'Authorization'=$basicAuthValue;'Accept'='application/json';'Content-Type'='application/json'}
$page = Invoke-WebRequest -Uri "https://rdl-share.ucsd.edu/attachments/binary_upload?filename=$filename" -Headers $headers -InFile $SourceFile -Method Post -UseBasicParsing
return $page
