[CmdletBinding()]
param(
  [string]$Device = 'chrome',
  [string]$MapTilerApiKey = $env:MAPTILER_API_KEY,
  [switch]$LocalNamsanNativeSpeech
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

$nativeSpeechDefine = if ($LocalNamsanNativeSpeech) {
  '--dart-define=LOCAL_NAMSAN_NATIVE_SPEECH=true'
} else {
  $null
}

flutter run -d $Device --dart-define=MAPTILER_API_KEY=$MapTilerApiKey `
  --dart-define="SUPABASE_URL=$projectUrl" `
  --dart-define="SUPABASE_PUBLISHABLE_KEY=$publishableKey" `
  $nativeSpeechDefine
