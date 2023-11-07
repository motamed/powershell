# PowerShell Azure ML Deployment

This PowerShell script is used to deploy Azure Machine Learning resources.

## Prerequisites

- Azure CLI
- Azure Machine Learning extension for Azure CLI

## Variables File

Before running the script, you need to set your specific values in the `variables.ps1` file. This file contains variables such as the resource group name, location, workspace name, and compute name. Make sure to replace the placeholders with your actual values.

## Usage

```powershell
./deploy_ml.ps1