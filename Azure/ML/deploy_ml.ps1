#--------------------------------------------------------------------------------------------
# Description: This script will deploy the Azure ML workspace and compute instance
# Usage: ./deploy_ml.ps1
# --------------------------------------------------------------------------------------------


# Load variables from variables.ps1
. ./variables.ps1

# Check if Azure CLI is installed
if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Output "Azure CLI could not be found"
    Write-Output "Install Azure CLI from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest"
    exit
}

# Check if user is logged in to Azure
$currentSubscriptionCheck = az account show 2>$null
if ($null -eq $currentSubscriptionCheck) {
    Write-Output "User is not logged in or token has expired. Logging in now..."
    az login --use-device-code | Out-Null
    $currentSubscription = az account show | ConvertFrom-Json
}
else {
    # logged in
    $currentSubscription = az account show | ConvertFrom-Json
    Write-Output "Logged in as $($currentSubscription.user.name)"    
}


$currentSubscription = az account show | ConvertFrom-Json
# Check if the current subscription is the correct one
if ($currentSubscription.id -eq $SubscriptionId) {
    Write-Host "Logged into the Proper subscription."$($currentSubscription.id)
}
else {
    Write-Host "Not logged into the correct subscription."
    Write-Host "Logging into the correct subscription now..."
    az account set --subscription $SubscriptionId | Out-Null
}

# Check if Azure ML extension is installed
$azExtensions = az extension list --output json | ConvertFrom-Json
if ($azExtensions.name -notcontains "azure-cli-ml") {
    Write-Host "Azure ML extension is not installed. Installing now..."

    # Start a background job for installing the Azure ML extension
    $job = Start-Job -ScriptBlock {
        az extension add --name azure-cli-ml
    }

    # Show a spinner while the job is running
    $spinner = '|/-\'
    $i = 0
    while ($job.State -eq 'Running') {
        $i = $i % 4
        Write-Host "`rInstalling Azure ML extension $($spinner[$i])" -NoNewline
        Start-Sleep -Seconds 1
        $i++
    }
    Write-Host "" # Move to the next line after the spinner

    # Get the result of the job
    $installResult = Receive-Job -Job $job

    if ($null -eq $installResult) {
        Write-Host "Failed to install Azure ML extension"
        exit
    }
    else {
        Write-Host "Azure ML extension installed !"
    }
}
else {
    Write-Host "Azure ML extension is installed"
}

# Check if resource group exists
$groupExists = az group exists --name $resourceGroup --output tsv
if ($groupExists -eq 'false') {

    Write-Host "Resource group does not exist. Creating now..."
    az group create --name $resourceGroup --location $location | Out-Null    
}
else {
    Write-Host "Using existing resource group $resourceGroup"
}

# Check if ML workspace exists
$workspace = az ml workspace show --workspace-name $workspaceName --resource-group $resourceGroup 2>$null
if ($null -eq $workspace) {
    Write-Host "Workspace does not exist. Creating now..."

    # Start a background job for creating the workspace
    $job = Start-Job -ScriptBlock {
        az ml workspace create --workspace-name $using:workspaceName --resource-group $using:resourceGroup 2>$null
    }

    # Show a spinner while the job is running
    $spinner = '|/-\'
    $i = 0
    while ($job.State -eq 'Running') {
        $i = $i % 4
        Write-Host "`rCreating workspace $($spinner[$i])" -NoNewline
        Start-Sleep -Seconds 1
        $i++
    }
    Write-Host "" # Move to the next line after the spinner
    Write-Host "Workspace created !"
    

    # Get the result of the job
    $workspace = Receive-Job -Job $job

    if ($null -eq $workspace) {
        Write-Host "Failed to create workspace"
        Write-Host "Please check if the workspace name is available and try again"
        exit
    }
}

# Check if compute instance exists
$computeInstance = az ml computetarget show --name $computeName --workspace-name $workspaceName --resource-group $resourceGroup 2>$null
if ($null -eq $computeInstance) {
    Write-Host "Compute instance does not exist. Creating now..."

    # Start a background job for creating the compute instance
    $job = Start-Job -ScriptBlock {
        az ml computetarget create computeinstance --name $using:computeName --vm-size Standard_DS3_v2 --workspace-name $using:workspaceName --resource-group $using:resourceGroup 2>$null
    }

    # Show a spinner while the job is running
    $spinner = '|/-\'
    $i = 0
    while ($job.State -eq 'Running') {
        $i = $i % 4
        Write-Host "`rCreating compute instance $($spinner[$i])" -NoNewline
        Start-Sleep -Seconds 1
        $i++
    }
    Write-Host "" # Move to the next line after the spinner

    # Get the result of the job
    $computeInstance = Receive-Job -Job $job

    if ($null -eq $computeInstance) {
        Write-Host "Failed to create compute instance"
        exit
    }
    else {
        Write-Host "Compute instance created !"
    }
}

# Check if compute instance is running
$computeStatus = az ml computetarget show --name $computeName --workspace-name $workspaceName --resource-group $resourceGroup --query provisioningState --output tsv
if ($computeStatus -ne "Succeeded") {
    Write-Host "Compute instance is not running. Starting now..."

    # Start a background job for starting the compute instance
    $job = Start-Job -ScriptBlock {
        az ml computetarget start --name $using:computeName --workspace-name $using:workspaceName --resource-group $using:resourceGroup 2>$null
    }

    # Show a spinner while the job is running
    $spinner = '|/-\'
    $i = 0
    while ($job.State -eq 'Running') {
        $i = $i % 4
        Write-Host "`rStarting compute instance $($spinner[$i])" -NoNewline
        Start-Sleep -Seconds 1
        $i++
    }
    Write-Host "" # Move to the next line after the spinner

    # Get the result of the job
    $startResult = Receive-Job -Job $job

    if ($null -eq $startResult) {
        Write-Host "Failed to start compute instance"
        exit
    }
    else {
        Write-Host "Compute instance started !"
    }
}
else {
    Write-Host "Compute instance is running !"
}

# Check if compute instance is ready
$computeStatus = az ml computetarget show --name $computeName --workspace-name $workspaceName --resource-group $resourceGroup --query provisioningState --output tsv
if ($computeStatus -ne "Succeeded") {
    Write-Output "Compute instance is not ready"
    exit
}
else {
    Write-Output "Compute instance is ready !"
}

# Output details of the workspace
$workspaceDetails = az ml workspace show --workspace-name $workspaceName --resource-group $resourceGroup --output json | ConvertFrom-Json
Write-Output "Workspace details:"
Write-Output ("- ID: " + $workspaceDetails.id) | Format-Table
Write-Output ("- Name: " + $workspaceDetails.name) | Format-Table
Write-Output ("- Location: " + $workspaceDetails.location) | Format-Table
Write-Output ("- Creation time: " + $workspaceDetails.creationTime) | Format-Table
Write-Output ("- Provisioning state: " + $workspaceDetails.provisioningState) | Format-Table
Write-Output ("- Key vault: " + $workspaceDetails.keyVault) | Format-Table
Write-Output ("- Application insights: " + $workspaceDetails.applicationInsights) | Format-Table

# Output details of the compute instance
$computeDetails = az ml computetarget show --name $computeName --workspace-name $workspaceName --resource-group $resourceGroup --output json | ConvertFrom-Json
Write-Output "Compute instance details:"
Write-Output ("Name: " + $computeDetails.name)


