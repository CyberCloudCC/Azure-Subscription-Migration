# Title: Azure-Subscription-Migration-Backup
# Author: Arno Franken
# Date: 12-10-2020
# Company: Cyber Cloud
# URL: https://www.cybercloud.cc

echo Check for AZ CLI Resource Graph extension:
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name resource-graph
echo Login check.
az login
echo Your subscriptions are as follows:
az account list | jq -r '.[] | .name'
read -p "Type subscription name you want to transfer (nothing will happen yet) " subscription_name
az account set --subscription "$subscription_name"
echo AZ CLI has been set to subscription: "$subscription_name"
SUBSCRIPTION_ID=$(az account show --subscription "$subscription_name" | jq -r '.id')
echo Subscription GUID is: "$SUBSCRIPTION_ID"
echo
echo \#\# SAVING ALL STANDARD ROLE ASSIGNMENTS \#\#
az role assignment list --all --include-inherited --output json > azure-roleassignments.json
echo azure-roleassignments.json ... Done.
az role assignment list --all --include-inherited --output tsv > azure-roleassignments.tsv
echo azure-roleassignments.tsv ... Done.
az role assignment list --all --include-inherited --output table > azure-roleassignments.txt
echo azure-roleassignments.txt ... Done.
echo \#\# CURRENT CUSTOM ROLES \#\#
az role definition list --custom-role-only true --output json --query '[].{roleName:roleName, roleType:roleType}'
echo 
echo "Please note that you have to save each custom role above manually with the following command:"
echo "az role definition list --name <custom_role_name> > customrolename.json"
echo "As during development of this script, we had no actual test subscription that showed custom roles, we could not automate this yet."
echo \#\# ROLE ASSIGNMENTS FOR MANAGED IDENTITIES \#\#
az ad sp list --all --filter "servicePrincipalType eq 'ManagedIdentity'" > azure-managedidentities.json
echo azure-managedidentities.json ... Done.
echo 
echo \#\# KEYVAULTS \#\#
echo .. 
for kv in $(az keyvault list | jq -r '.[].name'); do
   echo $kv ... saving to azure-kv-$kv.json
   az keyvault show --name $kv >> azure-kv-$kv.json
done
echo Done.
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
echo
echo \#\# AZURE AD OBJECTS \#\#
echo ... saving azure-ad-user-list.json
az ad user list > azure-ad-user-list.json
echo Done.
echo
echo \#\# OTHER KNOWN RESOURCES \#\#
az graph query -q 'resources | where type != "microsoft.azureactivedirectory/b2cdirectories" | where  identity <> "" or properties.tenantId <> "" or properties.encryptionSettingsCollection.enabled == true | project name, type, kind, identity, tenantId, properties.tenantId' --subscriptions $SUBSCRIPTION_ID --output table > azure-other-known-resources.json
echo azure-other-known-resources.json ... Done.

echo \#\# WARNING \#\#
echo Check the following Azure resources manually and verify any attached ACLs:
echo 1. Azure Data Lake Storage Gen1, 
echo 2. Azure Data Lake Storage Gen2
echo 3. Azure Files
echo
echo Thank you for using this script.

