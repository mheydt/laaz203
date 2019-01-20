$rgName = "batchRG"
$stgAcctName = "laaz200batchsa"
$location = "southcentralus"
$batchAcctName = "laaz200batchacct"
$poolName = "myPool"

az group create `
 -l $location `
 -n $rgName

az storage account create `
 -g $rgName `
 -n $stgAcctName `
 -l $location `
 --sku Standard_LRS

az batch account create `
 -n $batchAcctName `
 --storage-account $stgAcctName `
 -g $rgName `
 -l $location

az batch account login `
 -n $batchAcctName `
 -g $rgName `
 --shared-key-auth

az storage account keys list `
 -g $rgName -n $stgAcctName `
 --query "[0].value" | tr -d '"'

az batch account keys list `
 -g $rgName -n $batchAcctName `
 --query primary 
 
az batch account keys list `
 -g $rgName -n $batchAcctName 

az batch pool create `
 --id mypool `
 --vm-size Standard_A1_v2 `
 --target-dedicated-nodes 2 `
 --image `
   canonical:ubuntuserver:16.04-LTS `
 --node-agent-sku-id `
   "batch.node.ubuntu 16.04"

az batch pool show `
 --pool-id $poolName `
 --query "allocationState"

az batch job create `
 --id myjob `
 --pool-id mypool

for ($i=0; $i -lt 4; $i++) {
    az batch task create `
     --task-id mytask$i `
     --job-id myjob `
     --command-line "/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'" 
}

az batch task show `
 --job-id myjob `
 --task-id mytask1

az batch task file list `
 --job-id myjob `
 --task-id mytask1 `
 --output table

az batch task file download `
 --job-id myjob `
 --task-id mytask1 `
 --file-path stdout.txt `
 --destination ./stdout.txt

az batch pool delete -n $poolName
az group delete -n $rgName