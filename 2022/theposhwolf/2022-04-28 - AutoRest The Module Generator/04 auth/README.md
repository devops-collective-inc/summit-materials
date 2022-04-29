# Customize

```powershell
autorest README.md
```

## Results

```powershell
$session = Invoke-RwLoginAuthentication -Email '<email>' -Password '<password>'
$env:RunwaySessionToken = $session.Session
```