# Create Azure resource group
resource "azurerm_resource_group" "rg" {
  name     = "Testing-rg"
  location = "Southeast Asia"
  tags = {
    environment = "Demo"
  }
}

# Create Azure Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "tppry-vnet"
  address_space       = ["10.0.0.0/12"] #allows more subnet instead of /16
  location            = "Southeast Asia"
  resource_group_name = "Testing-rg"

  tags = {
    environment = "Demo"
  }
}

# Define the subnet within the virtual network
resource "azurerm_subnet" "vnet" {
  name                 = "test-subnet"
  resource_group_name  = "Testing-rg"
  virtual_network_name = "tppry-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}


# create Azure storage account
resource "azurerm_storage_account" "st" {
  name                     = "teststorageacc"
  resource_group_name      = "Testing-rg"
  location                 = "Southeast Asia"
  access_tier              = "Hot"
  account_kind             = "FileStorage" #For SMB
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = var.storage_is_hns_enabled
  network_rules {
    default_action             = (length(var.storage_ip_rules) + length(azurerm_subnet.vnet.id)) > 0 ? "Deny" : "True"
    ip_rules                   = var.storage_ip_rules
    virtual_network_subnet_ids = azurerm_subnet.vnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}


# Create  storage account's `files share` using terraform
resource "azurerm_storage_share" "azure_storage" {
  name                 = "fileshareforall"
  storage_account_name = "teststorageacc"
  quota                = 50
  depends_on = [
    azurerm_storage_account.st
  ]
}

# Create private DNS zone for blob storage account
resource "azurerm_private_dns_zone" "prvt_dns" {
  name                = "myblob.privatelink.southeastasia.core.windows.net"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name


  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create private virtual network link to prod vnet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_pdz_vnet_link" {
  name                  = "privatelink_to_${azurerm_virtual_network.vnet.name}"
  resource_group_name   = "Testing-rg"
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = "private_zone"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [

    azurerm_virtual_network.vnet,

  ]
}

# Create private endpoint for blob storage account
resource "azurerm_private_endpoint" "pe_blob" {
  name                = "pv_endpoint"
  location            = azurerm_storage_account.st.location
  resource_group_name = "Testing-rg"
  subnet_id           = azurerm_subnet.vnet.id


  private_service_connection {
    name                           = "private"
    private_connection_resource_id = azurerm_storage_account.st.id
    is_manual_connection           = false
    subresource_names              = var.pe_blob_subresource_names

  }

  private_dns_zone_group {
    name                 = var.pe_blob_private_dns_zone_group_name
    private_dns_zone_ids = [azurerm_private_dns_zone.prvt_dns.id]
  }


  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    azurerm_storage_account.st,

  ]
}