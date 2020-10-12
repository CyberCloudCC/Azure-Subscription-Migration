# Azure Subscription to another tenant

Transferring an Azure subscription to a different Azure AD directory is a complex process that must be carefully planned and executed. Many Azure services require security principals (identities) to operate normally or even manage other Azure resources. This script tries to cover most of the Azure services that depend heavily on security principals. 

Please always refer to the official Azure documentation before using this script: https://docs.microsoft.com/nl-nl/azure/role-based-access-control/transfer-subscription?WT.mc_id=Portal-Microsoft_Azure_Billing#save-all-role-assignments
