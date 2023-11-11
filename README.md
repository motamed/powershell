# Azure PowerShell Scripts

This repository contains a collection of PowerShell scripts for managing Azure resources, including Machine Learning workspaces, HDInsight clusters, and computer states.

## Prerequisites

- PowerShell
- Azure CLI


## Scripts

### Azure Basics

- [Login](Azure/Basics/Login.ps1): Log in to your Azure account.
- [Create VM](Azure/Basics/Create_VM.ps1): Create a new Azure virtual machine.
- [Create Resource Group](Azure/Basics/Create_Resource_Group.ps1): Create a new Azure resource group.

### Azure Resource Deployment

- [Deploy Template From Your Local Machine](Azure/ResourceDeployment/Deploy_Template_From_Your_Local_Machine.ps1): Deploy an Azure Resource Manager template from your local machine.
- [Deploy Template From External Source](Azure/ResourceDeployment/Deploy_Template_From_External_Source.ps1): Deploy an Azure Resource Manager template from an external source.
- [List Deployed Resources](Azure/Basics/List_Deployed_Resources.ps1): List all deployed resources in your Azure account.

### Azure HDInsight

- [HDInsight Basic](Azure/HDInsight/HDInsight-Basic.ps1): Create a new HDInsight cluster.

### Azure Machine Learning

- [Deploy ML](Azure/ML/deploy_ml.ps1): Deploy an Azure Machine Learning workspace and compute instance.


### Computer State

- [Lock](ComputerState/lock.ps1): Lock the workstation.
- [Shutdown](ComputerState/shutdown.ps1): Shutdown the computer.
- [Restart](ComputerState/restart.ps1): Restart the computer.
- [Logoff](ComputerState/logoff.ps1): Log off the current user.

## Usage

Each script can be run individually, depending on your needs. For example, to deploy an Azure Machine Learning workspace and compute instance, you would run:

```powershell
./Azure/ML/deploy_ml.ps1
