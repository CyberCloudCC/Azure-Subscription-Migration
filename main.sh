# Title: Azure Subscription Mover
# Author: Arno Franken
# Date: 12-10-2020
# Company: Cyber Cloud
# URL: https://www.cybercloud.cc

read -p "Hoe heet je? " varname
echo Hallo "$varname" ! Wat fijn om je weer te zien..! 
echo Eerst moeten we even checken of je de AZ CLI Resource Graph extensie hebt geïnstalleerd:
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name resource-graph
echo Laten we eerst even kijken of je ingelogd bent.
az login
echo Nu kunnen we verder, jouw Azure Subscriptions zijn de volgende:
az account list | jq -r '.[] | .name'
read -p "Typ nu de naam van de subscription die je wilt verplaatsen (er gebeurt nog niks hoor): " subscription_name
az account set --subscription "$subscription_name"
echo AZ CLI is nu ingesteld op subscription: "$subscription_name"
SUBSCRIPTION_ID=$(az account show --subscription "$subscription_name" | jq -r '.id')
echo Subscription GUID ingesteld op: "$SUBSCRIPTION_ID"
echo
echo \#\# SAVING ALL ROLE ASSIGNMENTS \#\#
az role assignment list --all --include-inherited --output json > azure-roleassignments.json
echo azure-roleassignments.json ... Done.
az role assignment list --all --include-inherited --output tsv > azure-roleassignments.tsv
echo azure-roleassignments.tsv ... Done.
az role assignment list --all --include-inherited --output table > azure-roleassignments.txt
echo azure-roleassignments.txt ... Done.
echo \#\# CURRENT CUSTOM ROLES \#\#
az role definition list --custom-role-only true --output json --query '[].{roleName:roleName, roleType:roleType}'
echo \#\# ROLE ASSIGNMENTS FOR MANAGED IDENTITIES \#\#
az ad sp list --all --filter "servicePrincipalType eq 'ManagedIdentity'" > azure-managedidentities.json
echo azure-managedidentities.json ... Done.
echo 
echo \#\# KEYVAULTS \#\#
az keyvault show
az keyvault show > azure-keyvaults.json 
echo azure-keyvaults.json ... Done.
echo
echo \#\# Azure SQL databases with Azure AD authentication \#\#
IDS=$(az graph query -q 'resources | where type == "microsoft.sql/servers" | project id' -o tsv | cut -f1)
if [ -z "$IDS" ]
then
      echo "There are no SQL databases with Azure AD authentication"
else
      echo "There are SQL databases with Azure AD authentication"
      az sql server ad-admin list --ids $IDS > azure-sql-databases-with-ad-authentication.json
      echo "azure-sql-databases-with-ad-authentication.json ... Done."
fi

echo \#\# OTHER KNOWN RESOURCES \#\#
az graph query -q 'resources | where type != "microsoft.azureactivedirectory/b2cdirectories" | where  identity <> "" or properties.tenantId <> "" or properties.encryptionSettingsCollection.enabled == true | project name, type, kind, identity, tenantId, properties.tenantId' --subscriptions $SUBSCRIPTION_ID --output table > azure-other-known-resources.json
echo azure-other-known-resources.json ... Done.

echo \#\# WARNING \#\#
echo Controleer de volgende Azure resources handmatig en verifieer op aanwezigheid van ACLs:
echo 1. Azure Data Lake Storage Gen1, 
echo 2. Azure Data Lake Storage Gen2
echo 3. Azure Files
echo
echo Bedankt voor het gebruik van dit script!

