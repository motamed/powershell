Get-AzureRmResource |
  Where-Object ResourceGroupName -eq myResourceGroup |
    Select-Object Name,Location,ResourceType