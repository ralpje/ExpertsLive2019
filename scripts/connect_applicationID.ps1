# Azure AD OAuth Application Token for Graph API
# Get OAuth token for a AAD Application (returned as $token)

# Application (client) ID, tenant ID and secret
$clientId = "64de9488-2619-4e9c-ba21-e90ccdaad391"
$tenantId = "1383070c-7016-4457-8133-e8be22a3d8d5"
$clientSecret = 'e_6gR5QS0*JKKvjDTliMFrreYJ.Ncr/6'

# Construct URI
$tokenuri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Construct Body
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

# Get OAuth 2.0 Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $tokenuri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token
