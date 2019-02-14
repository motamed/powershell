# Primary storage account info
$storageAccountResourceGroupName = "StorageRGName-RG"
$storageAccountName = "StorageAccountName"
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $storageAccountResourceGroupName -Name $storageAccountName)[0].value
 
$storageContainer = "StorageContainer"
 
# Cluster configuration info
$location = "westeurope"
$clusterResourceGroupName = "Cluster-RG"
$clusterName = "Cluster-Name"
$clusterCreds = Get-Credential
$sshCreds = Get-Credential
 
# If the cluster's resource group doesn't exist yet, run:
# New-AzureRmResourceGroup -Name $clusterResourceGroupName -Location $location
 
# Hive metastore info
$hiveSqlServer = "ClusterMetaStore"
$hiveDb = "ClusterMetaStoreDB"
$hiveCreds = Get-Credential
 
$clusterType = "Spark"
$clusterOS = "Linux" 
  
# Create the cluster
New-AzureRmHDInsightClusterConfig -ClusterType $clusterType `
            | Add-AzureRmHDInsightMetastore `
                -SqlAzureServerName "$hiveSqlServer.database.windows.net" `
                -DatabaseName $hiveDb `
                -Credential $hiveCreds `
                -MetastoreType HiveMetastore `
            | New-AzureRmHDInsightCluster `
                -OSType $clusterOS `
                -ClusterSizeInNodes 2 `
                -ResourceGroupName $clusterResourceGroupName `
                -ClusterName $clusterName `
                -HttpCredential $clusterCreds `
                -SshCredential $sshCreds `
                -Location $location `
                -DefaultStorageAccountName "$storageAccountName.blob.core.windows.net" `
                -DefaultStorageAccountKey $storageAccountKey `
                -DefaultStorageContainer $storageContainer  
