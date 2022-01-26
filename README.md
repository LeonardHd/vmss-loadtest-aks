# Jmeter Loadtesting for AKS-based Applications

```bash
RAND="$RANDOM"
prefix="applt$RAND"
rg="$prefix-sut"
aksName="$prefix-sutaks"
agwname="$prefix-sutagw"
agwipname="$prefix-sutagw-ip"
vnetname="$prefix-sut-vnet"
location='westeurope'
nodeSize="Standard_B2ms"

az group create -n $rg -l $location

az network vnet create -g $rg -n $vnetname --address-prefix 10.0.0.0/12

az network vnet subnet create --address-prefixes 10.1.0.0/16 \
                              --name aks-subnet \
                              --resource-group $rg \
                              --vnet-name $vnetname 

az network vnet subnet create --address-prefixes 10.3.0.0/16 \
                              --name apim-subnet \
                              --resource-group $rg \
                              --vnet-name $vnetname
 
aksSubnetId=$(az network vnet subnet show -n aks-subnet --vnet-name $vnetname -g $rg --query id -o tsv)

az aks create \
    --resource-group $rg \
    --name $aksName \
    --node-count 3 \
    --enable-cluster-autoscaler \
    --enable-managed-identity \
    --min-count 1 \
    --max-count 50 \
    --generate-ssh-keys \
    --node-vm-size $nodeSize \
    --location $location \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id $aksSubnetId \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.0.0.10 \
    --service-cidr 10.0.0.0/16 -y

# App Gateway Setup
az network vnet subnet create --address-prefixes 10.2.0.0/16 --name "$agwname-subnet" --resource-group $rg --vnet-name $vnetname              
az network public-ip create -n $agwipname -g $rg --allocation-method Static --sku Standard
az network application-gateway create -n $agwname -l $location -g $rg --sku Standard_v2 --public-ip-address $agwipname --private-ip-address 10.2.0.100  --vnet-name $vnetname --subnet "$agwname-subnet"

appgwId=$(az network application-gateway show -n $agwname -g $rg -o tsv --query "id") 
az aks enable-addons -n $aksName -g $rg -a ingress-appgw --appgw-id $appgwId

az aks get-credentials -n $aksName -g $rg
az aks command invoke \
  --resource-group $rg \
  --name $aksName \
  --command "kubectl apply -f deployment.yaml" \
  --file deployment.yaml

az aks command invoke \
  --resource-group $rg \
  --name $aksName \
  --command "kubectl get service"

# Setup Loadtesting Suite
rgLoadTest="$prefix-loadtest"
vnetnameLoadTest="$prefix-loadtest-vnet"

az group create -n $rgLoadTest -l $location
az network vnet create -g $rgLoadTest -n $vnetnameLoadTest --address-prefix 10.16.0.0/12
az network vnet subnet create --address-prefixes 10.17.0.0/16 \
                              --name default \
                              --resource-group $rgLoadTest \
                              --vnet-name $vnetnameLoadTest 

aksVNetId=$(az network vnet show --name $vnetname -g $rg --query id -o tsv)
loadtestVNetId=$(az network vnet show --name $vnetnameLoadTest -g $rgLoadTest --query id -o tsv)

az network vnet peering create -g $rgLoadTest --name loadtestpeering --vnet-name $vnetnameLoadTest --remote-vnet $aksVNetId --allow-vnet-access
az network vnet peering create -g $rg --name akspeering --vnet-name $vnetname --remote-vnet $loadtestVNetId --allow-vnet-access

az vm create -n masterwindows -g $rgLoadTest --image MicrosoftWindowsDesktop:Windows-10:win10-21h2-pro:latest --vnet-name $vnetnameLoadTest --subnet default --public-ip-sku Standard --admin-username loadtest

az vm run-command invoke  --command-id RunPowerShellScript --name masterwindows -g $rgLoadTest --scripts @win-extension/setup.ps1

az vmss create \
  --resource-group $rgLoadTest \
  --name workerVms \
  --image UbuntuLTS \
  --upgrade-policy-mode automatic \
  --admin-username loadtest \
  --vnet-name $vnetnameLoadTest \
  --subnet default

az vmss extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --resource-group $rgLoadTest \
  --vmss-name workerVms \
  --settings '{"fileUris":["https://raw.githubusercontent.com/LeonardHd/vmss-loadtest-aks/main/vmss-extension/jmeter.service", "https://raw.githubusercontent.com/LeonardHd/vmss-loadtest-aks/main/vmss-extension/run.sh", "https://raw.githubusercontent.com/LeonardHd/vmss-loadtest-aks/main/vmss-extension/setup.sh"],"commandToExecute":"/bin/bash setup.sh"}'
```

## APIM Integration

```bash

# TODO

```
