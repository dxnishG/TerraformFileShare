# Terraform Deployment Guide for Azure Storage Account

From this chapter, the guide enlists a number of steps that you will need to crack Azure Storage Account deployment with Terraform. It consists of the configuration and operations of the file share for officemates, which are required to perform the tasks.

## Prerequisites

Starting off, ensure below prerequisites are met/done:

1. **Azure Subscription**: You must have an active Azure subscription.
2. **Azure CLI**: Install the Azure CLI to authenticate Terraform with your Azure account.
3. **Terraform**: Install Terraform on your local machine. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
4. **Visual Studio Code (VS Code)**: This deployment was done by using VS Code with the Azure extension.

## Deployment Steps

Follow these steps to deploy the Azure Storage Account using Terraform:

1. **Clone the Repository**: Clone the repository containing the files to your local machine.

2. **Initialize Terraform**: Open VS Code, navigate to the cloned repository folder, and open a terminal. Run the following command to initialize Terraform:

    ```bash
    terraform init
    ```
    ```bash
    terraform validate
    ```

3. **Review Terraform Configuration**: Review the `main.tf` file in the repository to understand the resources being provisioned and customize any variables if needed.

4. **Deploy Resources**: Run the following command to apply the Terraform configuration and deploy the Azure Storage Account to your subscription:

    ```bash
    terraform plan
    ```
    ```bash
    terraform apply
    ```

5. **Access Setup for Office Workers**: Once deployed, officemates can access the link by following these steps:

    - **Generate Shared Access Signature (SAS)**:
      - Navigate to the Azure portal and locate the deployed Azure Storage Account.
      - Go to the "Shared access signature" section or use Azure CLI to generate a SAS token for the file share.
      ```bash
      az storage share generate-sas --account-name teststorageacc --name fileshareforall --expiry <expiry_time> --permissions <permissions>
      ```
      - Specify the desired permissions (e.g., read, write, list) and expiration duration for the SAS token.

    - **Get SAS URL**:
      - Copy the generated SAS URL after generating the SAS token.
      - This URL will be used for accessing the file share.

    - **Share SAS URL with Office Workers**:
      - Provide the SAS URL to the office workers who need access to the file share.
      - Office workers can use this URL to access the file share using various methods, such as:
        - Mounting the file share as a network drive,
        - Accessing it programmatically,
        - Using compatible tools like Azure Storage Explorer.

## Code Snippets

Moving on, below are the code snippets acquired from main.tf, are for the analysis of the resources which were created in the terraform configuration file as well as the inclusion of reasoning for why certain options were preferred over the other available options.

1. **Resource Group**:

    ```hcl
    resource "azurerm_resource_group" "rg" {
      name     = "Testing-rg"
      location = "Southeast Asia"
      tags = {
        environment = "Demo"
      }
    }
    ```

    **Explanation**: The resource group is named "Testing-rg" and located in "Southeast Asia" to prevent connection issues as the best practice for region selection is to always choose the one closest to you. Tags are applied to categorize resources based on the environment, in this instance, "Demo".

2. **Azure Storage Account**:

    ```hcl
    resource "azurerm_storage_account" "st" {
      name                     = "teststorageacc"
      resource_group_name      = azurerm_resource_group.rg.name
      location                 = "Southeast Asia"
      access_tier              = "Hot"
      account_kind             = "FileStorage"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      is_hns_enabled           = var.storage_is_hns_enabled
      ...
    }
    ```

    **Explanation**: 
    - **Name**: The storage account is named "teststorageacc".
    - **Resource Group**: It's associated with the previously defined resource group "Testing-rg".
    - **Location**: Located in "Southeast Asia" to reduce latency for users.
    - **Access Tier**: Chosen as "Hot" as I assume the data will be frequently accessed.
    - **Account Kind**: "FileStorage" is selected for SMB access to the file share based on requirement.
    - **Account Tier**: "Standard" tier was chosen as we do not need top-tier selections. This provides standard performance and redundancy which to me is enough.
    - **Replication Type**: "LRS" (Locally Redundant Storage) is chosen for redundancy within the same region.
    - **Hierarchical Namespace (HNS) Enabled**: The option is set based on the value of the variable `var.storage_is_hns_enabled`.

3. **Storage Share**:

    ```hcl
    resource "azurerm_storage_share" "azure_storage" {
      name                 = "fileshareforall"
      storage_account_name = azurerm_storage_account.st.name
      quota                = 50
      ...
    }
    ```

    **Explanation**: 
    - **Name**: The file share is named "fileshareforall" assuming all staffs will be using it.
    - **Storage Account Name**: It's associated with the previously defined storage account "teststorageacc" for creating the share within the account.
    - **Quota**: A quota of 50 GB is set based on the requirement given.
