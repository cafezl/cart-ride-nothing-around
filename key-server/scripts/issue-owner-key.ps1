[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^\d{1,20}$')]
  [string]$UserId,

  [Parameter(Mandatory = $true)]
  [ValidatePattern('^https://[^/]+(?:/)?$')]
  [string]$WorkerUrl
)

$endpoint = $WorkerUrl.TrimEnd('/') + '/v1/nothrilo/key/admin/issue'
$secureSecret = Read-Host 'ADMIN_ISSUE_SECRET (entrada oculta)' -AsSecureString
$secretPointer = [IntPtr]::Zero
$plainSecret = $null

try {
  $secretPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSecret)
  $plainSecret = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($secretPointer)
  if ([string]::IsNullOrWhiteSpace($plainSecret) -or $plainSecret.Length -lt 32) {
    throw 'O segredo precisa ter pelo menos 32 caracteres.'
  }

  $response = Invoke-RestMethod `
    -Method Post `
    -Uri $endpoint `
    -Headers @{ Authorization = "Bearer $plainSecret" } `
    -ContentType 'application/json' `
    -Body (@{ userId = $UserId } | ConvertTo-Json -Compress)

  $expiry = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$response.expiresAt).ToLocalTime()
  [pscustomobject]@{
    Key       = $response.key
    UserId    = $response.userId
    ExpiraEm  = $expiry.ToString('yyyy-MM-dd HH:mm:ss zzz')
    Validade  = '24 horas'
  }
}
finally {
  if ($secretPointer -ne [IntPtr]::Zero) {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($secretPointer)
  }
  $plainSecret = $null
  $secureSecret = $null
  Remove-Variable plainSecret, secureSecret -ErrorAction SilentlyContinue
}
