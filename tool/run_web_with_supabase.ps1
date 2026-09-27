[CmdletBinding()]
param(
  [string]$Device = 'chrome'
)

$projectRef = 'rsswzbgqapvrutcqasqv'
$projectUrl = "https://$projectRef.supabase.co"
$apiKeys = supabase projects api-keys --project-ref $projectRef --output json |
  ConvertFrom-Json

$publishableKey = $apiKeys |
  Where-Object { $_.type -eq 'publishable' } |
  Select-Object -First 1 -ExpandProperty api_key

if ([string]::IsNullOrWhiteSpace($publishableKey)) {
  throw 'Không tìm thấy publishable key. Hãy đăng nhập Supabase CLI và thử lại.'
}

flutter run -d $Device `
  --dart-define="SUPABASE_URL=$projectUrl" `
  --dart-define="SUPABASE_PUBLISHABLE_KEY=$publishableKey"