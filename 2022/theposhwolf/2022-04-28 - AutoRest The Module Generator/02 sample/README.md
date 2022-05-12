# Basic REST call

## Parameters in Body

Raw:

```plaintext
POST https://portal.runway.host/api/v2/auth/login HTTP/1.1
Host: portal.runway.host
Authorization: Session <token>
Content-Type: application/json
Content-Length: X

{
  "email": "anthony@runway.host",
  "password": "<password>",
  "remember": true
}
```

PowerShell:

```powershell
$splat = @{
  Uri = 'https://portal.runway.host/api/v2/auth/login'
  Headers = @{
    Authorization = 'Session <token>'
    'Content-Type' = 'application/json'
  }
  Body = @{
    email = "anthony@runway.host"
    password = "<password>"
    remember = $true
  } | ConvertTo-Json
}
Invoke-RestMethod @splat
```

## Parameters in Query

Raw:

```plaintext
POST https://portal.runway.host/api/v2/auth/login?email=anthony@runway.host&password=<password>&remember=true HTTP/1.1
Host: portal.runway.host
Authorization: Session <token>
Content-Type: application/json
Content-Length: X
```

PowerShell

```powershell
$qParams = @(
  "email=anthony@runway.host"
  "password=<password>"
  "remember=true"
) -join '&'
$splat = @{
  Uri = "https://portal.runway.host/api/v2/auth/login?$qParams"
  Headers = @{
    Authorization = 'Session <token>'
    'Content-Type' = 'application/json'
  }
}
Invoke-RestMethod @splat
```

## Parameters in Path

Raw:

```plaintext
GET https://portal.runway.host/api/v2/accounts/{accountId} HTTP/1.1
Host: portal.runway.host
Authorization: Session <token>
Content-Type: application/json
Content-Length: X
```

PowerShell:

```powershell
$accountId = '<accountId>'
$splat = @{
  Uri = "https://portal.runway.host/api/v2/accounts/$accountId"
  Headers = @{
    Authorization = 'Session <token>'
    'Content-Type' = 'application/json'
  }
}
Invoke-RestMethod @splat
```