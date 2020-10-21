# Introduction 

Although it seems to be an easy job, there are many caveats to account (and prepare) for while migrating an Azure subscription to another tenants, such as: 
- Users lose their Azure RBAC assigned roles
- Classic administrators lose access
- Keyvaults are inaccessible after the transfer and need to be fixed
- All managed identities (system- and user-managed identities) will be lost and need to be re-enabled or re-created after the transfer
- Etc. 

Unfortunately, there is no automated, scripted solution for this yet and it will always require some manual intervention as nothing goes as planned. This script will create a back-up of all important information that you will need during and after the migration. We are humble but happy to share it and feel free to create a pull request.

# Azure Subscription to another tenant

Transferring an Azure subscription to a different Azure AD directory is a complex process that must be carefully planned and executed. Many Azure services require security principals (identities) to operate normally or even manage other Azure resources. This script tries to cover most of the Azure services that depend heavily on security principals. 

Please always refer to the official Azure documentation before using this script: https://docs.microsoft.com/nl-nl/azure/role-based-access-control/transfer-subscription?WT.mc_id=Portal-Microsoft_Azure_Billing#save-all-role-assignments

## Requirements

### Unix based
1. Azure Command Line Interface (AZ CLI): https://docs.microsoft.com/nl-nl/cli/azure/install-azure-cli
2. JQ: https://stedolan.github.io/jq/download/ 

### Windows 
1. Azure Command Line Interface (AZ CLI): https://docs.microsoft.com/nl-nl/cli/azure/install-azure-cli
2. JQ: https://stedolan.github.io/jq/download/ 
3. Add the jq binary to your PATH variables.
4. Install Bash to be able to execute .sh, e.g. https://gitforwindows.org/ 

## Usage ##
```
sudo chmod +x ./main.sh
./main.sh
```
