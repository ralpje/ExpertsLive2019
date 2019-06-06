#get all users
$uri = "https://graph.microsoft.com/beta/users"
$users = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$users.value
$users.value | Select-Object DisplayName, ID, UserPrincipalName

#get specific user
$uri = "https://graph.microsoft.com/beta/users/MeganB@M365x096169.OnMicrosoft.com"
$megan = invoke-restmethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$megan.displayName
$megan | Select-Object DisplayName, MobilePhone, City

#update user info
$PatchJSON = @{
    "mobilephone" = "+31640409642"
    "city"        = "Heemskerk"
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri -Method PATCH -Headers @{Authorization = "Bearer $token" } -Body $PatchJSON -ContentType 'Application/JSON'

#create new user
$uri = "https://graph.microsoft.com/beta/users"
$NewUserJSON = @{
    "accountEnabled"    = $true
    "displayName"       = "EL Demo User"
    "mailNickname"      = "eldemouser"
    "userPrincipalName" = "eldemouser@M365x096169.OnMicrosoft.com"
    "passwordProfile"   = @{
        "forceChangePasswordNextSignIn" = $true 
        "password"                      = "Welkom2019"
    }
} | convertto-Json

$response = Invoke-RestMethod -Uri $uri -Method POST -Headers @{Authorization = "Bearer $token" } -Body $NewUserJSON -ContentType 'application/json'
$response
$response.displayname
$response.passwordprofile
$response.passwordProfile.forceChangePasswordNextSignIn
$response.id

#get and delete created user
$uri = $uri + '/' + $response.id
invoke-restmethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
Invoke-RestMethod -Method DELETE -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop

#get all groups
$uri = "https://graph.microsoft.com/beta/groups"
Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$groups = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$groups.value
$groups.value | select DisplayName

#get member of first group
$groups.value[0]
$groupid = $groups.value[0].id
$uri = $uri + '/' + $groupid
Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$uri = $uri + '/' + 'members'
$members = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$members.value | select DisplayName, UserPrincipalName

#get groups user is member of
$uri = "https://graph.microsoft.com/beta/users" + '/' + "CameronW@M365x096169.onmicrosoft.com" + '/' + 'MemberOf'
$membership = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop

#OneDrive
$uri = "https://graph.microsoft.com/beta/drives"
$drives = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$drives.value
$drives.value | select-object Name, WebURL

$uri = "https://graph.microsoft.com/beta/users" + '/' + "MeganB@M365x096169.OnMicrosoft.com" + '/' + 'drive'
Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop

##PowerShell device management scripts
$uri = "https://graph.microsoft.com/beta/deviceManagement/devicemanagementscripts"
$scripts = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$scripts.value
$uri = $uri + '/' + $scripts.value.id
$script = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop
$script
$script.scriptContent
$scriptcontent = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($script.scriptcontent))
$scriptcontent | out-file C:\temp\EL2019\script.ps1

###Device configuration profiles
$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceconfigurations"
$configs = Invoke-RestMethod -Method GET -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop

foreach ($config in $configs.value) {
    $configname = $config.displayName
    $configfile = "C:\temp\EL2019\$configname" + '.json'
    $config | ConvertTo-Json | out-file $configfile
}


$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceconfigurations"
$ConfigJSON = get-content "C:\temp\EL2019\Template\Win10-DeviceConfig-new.json"

Invoke-RestMethod -Method POST -Uri $uri -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop -Body $ConfigJSON -ContentType 'application/json'