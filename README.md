# Azure_DevOps

I will be using this repository to test Azure DevOps processes and functionality.  


Setup Azure CLI  
[Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)  
```bash
# If using the Government cloud you need to set it first 
az cloud list --output table
az cloud set --name $Cloud_Name

# Log in to Azure
az login --use-device-code
```

