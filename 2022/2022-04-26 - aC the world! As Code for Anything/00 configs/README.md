# Example Configurations (no code)

These configs are designed to use resources (AD and Exchange) that I hope most folks are familiar with.

## AD Privileged Group Memberships

Managing AD groups can be a pain, using a config we could lessen the load.

### Simple JSON

```json
{
    "groups": {
        "Domain Admins": [
            "admin.theposhwolf",
            "admin.jsnover",
            "admin.dabreakglass",
        ],
        "Schema Admins": [
            "admin.djones",
            "admin.sabreakglass"
        ]
    }
}
```

### More complex JSON

```json
{
    "groups": {
        "Domain Admins": {
            "members": [
                "admin.theposhwolf",
                "admin.jsnover",
                "admin.dabreakglass",
            ],
            "location": "DC=com,DC=domain,OU=Privileged Groups",
            "restrictMembership": true,
            "monitor": true
        },
        "Schema Admins": {
            "members": [
                "admin.djones",
                "admin.sabreakglass"
            ],
            "location": "DC=com,DC=domain,ou=Privileged Groups",
            "restrictMembership": true,
            "monitor": true
        }
    }
}
```

### Array instead of object

```json
{
    "groups": [
        {
            "name": "Domain Admins",
            "members": [
                "admin.theposhwolf",
                "admin.jsnover",
                "admin.dabreakglass",
            ],
            "location": "DC=com,DC=domain,OU=Privileged Groups",
            "restrictMembership": true,
            "monitor": true
        },
        {
            "name": "Schema Admins",
            "members": [
                "admin.djones",
                "admin.sabreakglass"
            ],
            "location": "DC=com,DC=domain,ou=Privileged Groups",
            "restrictMembership": true,
            "monitor": true
        }
    ]
}
```

### PowerShell notation

```powershell
@{
    groups = @{
        "Domain Admins" = @{
            members = @(
                "admin.theposhwolf",
                "admin.jsnover",
                "admin.dabreakglass",
            )
            location = "DC=com,DC=domain,OU=Privileged Groups"
            restrictMembership = $true
            monitor = $true
        }
        "Schema Admins" = @{
            members = @(
                "admin.djones",
                "admin.sabreakglass"
            )
            location = "DC=com,DC=domain,ou=Privileged Groups"
            restrictMembership = $true
            monitor = $true
        }
    }
}
```

## Exchange Resource Mailboxes

```json
{
    "Resources": {
        "ConferenceRoom1": {
            "email": "conferenceroom1@domain.com",
            "capacity": 20,
            "location": "Bldg3-Fl2",
            "booking": {
                "allowRepeating": true,
                "autoAccept": true,
            }
        }
    }
}
```

