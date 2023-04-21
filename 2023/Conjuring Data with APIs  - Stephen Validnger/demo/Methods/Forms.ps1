#region understanding the method
$formData = @{
    comments  = 'somefwmoff eoiwef'
    custemail = 'woeifj@of.oef'
    custtel   = '353-353-3535'
    delivery  = '12:00'
    size      = 'medium'
    topping   = @('bacon', 'cheese')
}

curl someurl -f 'some dataform blob'

Invoke-RestMethod -uri https://httpbin.org/post -Method Post -Form $formData
#endregion

#region Make it a Tool
function Submit-PizzaOrder {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $EmailAddress,

        [Parameter(Mandatory)]
        [String]
        [ValidatePattern('\d{3}-\d{3}-\d{4}',ErrorMessage = 'That is not a valid US phone number, sonny!')]
        $TelephoneNumber,

        [Parameter(Mandatory)]
        [String]
        $DeliveryTime,

        [Parameter(Mandatory)]
        [ValidateSet('Small','Medium','Large')]
        [String]
        $Size,

        [Parameter(Mandatory)]
        [ValidateSet('Bacon','Extra Cheese','Onion','Mushroom')]
        [String[]]
        $Toppings,

        [Parameter()]
        [String]
        $Comments
    )

    process {

        $formData = @{
            comments  = $Comments
            custemail = $EmailAddress
            custtel   = $TelephoneNumber
            delivery  = $DeliveryTime
            size      = $Size
            topping   = $Toppings
        }
        
        $response = Invoke-RestMethod -uri https://httpbin.org/post -Method Post -Form $formData

       [pscustomobject]@{
            Status = 'Confirmed! Your pie is on the way!'
            Email = $response.form.custemail
            Telephone = $response.form.custtel
            Delivery = $response.form.delivery
            Size = $response.form.size
            Toppings = $response.form.topping
            Comments = $response.form.comments
        }
    }
}
#endregion