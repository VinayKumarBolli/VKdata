provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "databricks" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "databricks_vnet" {
  name                = "${var.databricks_workspace_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.databricks.location
  resource_group_name = azurerm_resource_group.databricks.name

  subnet {
    name           = "databricks-subnet"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "worker-subnet"
    address_prefix = "10.0.2.0/24"
  }
}

resource "azurerm_databricks_workspace" "databricks" {
  name                = var.databricks_workspace_name
  resource_group_name = azurerm_resource_group.databricks.name
  location            = azurerm_resource_group.databricks.location
  sku                 = "standard"
  parameters = {
    vnet_id              = azurerm_virtual_network.databricks_vnet.id
    vnet_address_space   = [azurerm_virtual_network.databricks_vnet.address_space[0]]
    subnet_id            = azurerm_virtual_network.databricks_vnet.subnet[0].id
    public_subnet_id     = azurerm_virtual_network.databricks_vnet.subnet[1].id
    private_static_ip    = "10.0.1.4"
    public_static_ip     = "10.0.2.4"
  }
}
