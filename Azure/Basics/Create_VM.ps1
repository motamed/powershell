$vmParams = @{
    ResourceGroupName = 'TutorialResources'
    Name = 'TutorialVM1'
    Location = 'eastus'
    ImageName = 'Win2016Datacenter'
    PublicIpAddressName = 'tutorialPublicIp'
    Credential = $cred
    OpenPorts = 3389
  }
  $newVM1 = New-AzureRmVM @vmParams