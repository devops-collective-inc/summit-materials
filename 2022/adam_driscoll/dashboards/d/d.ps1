New-UDDashboard -Title 'Life Counter' -Pages (New-UDPage -Name 'Home' -Content {
        if (-not $Cache:Players) {
            $Cache:Players = [System.Collections.ArrayList]::new()
        }
    
        New-UDDynamic -Id 'lifecounter' -Content {
            if (-not $Session:PlayerName) {
                New-UDForm -Content {
                    New-UDTextbox -Label 'Name' -Id 'name'
                } -OnSubmit {
                    $Session:PlayerName = $EventData.Name 
                    Sync-UDElement -Id 'lifecounter' -Broadcast
                    $Cache:Players.Add([PSCustomObject]@{
                            name = $EventData.name 
                            life = 20
                        })
                }
                return
            }

            New-UDButton -Text 'New Game' -OnClick {
                $Cache:Players = [System.Collections.ArrayList]::new()
                $Session:PlayerName = $null
                Sync-UDElement -Id 'lifecounter' -Broadcast
            } -Icon (New-UDIcon -Icon 'File')

            New-UDTable -Columns @(
                New-UDTableColumn -Title 'Player' -Property 'Name'
                New-UDTableColumn -Title 'Life' -Property 'Life' -Render {
                    New-UDStack -Direction row -Children {
                        New-UDButton -OnClick {
                            $Player = $Cache:Players | Where-Object Name -EQ $EventData.Name
                            $Player.Life--
                            Sync-UDElement -Id 'lifecounter' -Broadcast
                        } -Icon (New-UDIcon -Icon 'Minus')  

                        New-UDTypography -Text $EventData.Life -Variant h3 -Style @{
                            margin = '5px'
                        }

                        New-UDButton -OnClick {
                            $Player = $Cache:Players | Where-Object Name -EQ $EventData.Name
                            $Player.Life++
                            Sync-UDElement -Id 'lifecounter' -Broadcast
                        } -Icon (New-UDIcon -Icon 'Plus')  
                    }


                }
            ) -Data $Cache:Players
        }
    } -Blank)