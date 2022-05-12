function My-Function {
    param(
    )

}

Invoke-Expression (show-command My-Function -passthru) -ErrorAction Ignore
