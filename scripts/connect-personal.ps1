# Azure AD OAuth User Token for Graph API
# Get OAuth token for a AAD User (returned as $token)

# Add required assemblies
Add-Type -AssemblyName System.Web, PresentationFramework, PresentationCore

# Application (client) ID, tenant ID and redirect URI
$clientId = "64de9488-2619-4e9c-ba21-e90ccdaad391"
$tenantId = "1383070c-7016-4457-8133-e8be22a3d8d5"
$redirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"

# Scope - Needs to include all permisions required separated with a space
$scope = "User.Read.All Group.Read.All" # This is just an example set of permissions

# Random State - state is included in response, if you want to verify response is valid
$state = Get-Random

# Encode scope to fit inside query string 
$scopeEncoded = [System.Web.HttpUtility]::UrlEncode($scope)

# Redirect URI (encode it to fit inside query string)
$redirectUriEncoded = [System.Web.HttpUtility]::UrlEncode($redirectUri)

# Construct URI
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUriEncoded&response_mode=query&scope=$scopeEncoded&state=$state"

# Create Window for User Sign-In
$windowProperty = @{
    Width  = 500
    Height = 700
}

$signInWindow = New-Object System.Windows.Window -Property $windowProperty
    
# Create WebBrowser for Window
$browserProperty = @{
    Width  = 480
    Height = 680
}

$signInBrowser = New-Object System.Windows.Controls.WebBrowser -Property $browserProperty

# Navigate Browser to sign-in page
$signInBrowser.navigate($uri)
    
# Create a condition to check after each page load
$pageLoaded = {

    # Once a URL contains "code=*", close the Window
    if ($signInBrowser.Source -match "code=[^&]*") {

        # With the form closed and complete with the code, parse the query string

        $urlQueryString = [System.Uri]($signInBrowser.Source).Query
        $script:urlQueryValues = [System.Web.HttpUtility]::ParseQueryString($urlQueryString)

        $signInWindow.Close()

    }
}

# Add condition to document completed
$signInBrowser.Add_LoadCompleted($pageLoaded)

# Show Window
$signInWindow.AddChild($signInBrowser)
$signInWindow.ShowDialog()

# Extract code from query string
$authCode = $script:urlQueryValues.GetValues(($script:urlQueryValues.keys | Where-Object { $_ -eq "code" }))

if ($authCode) {

    # With Auth Code, start getting token

    # Construct URI
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

    # Construct Body
    $body = @{
        client_id    = $clientId
        scope        = $scope
        code         = $authCode[0]
        redirect_uri = $redirectUri
        grant_type   = "authorization_code"
    }

    # Get OAuth 2.0 Token
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body

    # Access Token
    $token = ($tokenRequest.Content | ConvertFrom-Json).access_token

}
else {

    Write-Error "Unable to obtain Auth Code!"

}