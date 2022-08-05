locals {
    prefix-hub         = "hub"
    hub-resource-group = "hub-vnet-rg"
    shared-key         = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

# Creating resource group
resource "azurerm_resource_group" "hub-vnet-rg" {
    name     = local.hub-resource-group
    location = var.location
}

# Creating hub net, subnets and components inside subnets.
# Creating hub vnet
resource "azurerm_virtual_network" "hub-vnet" {
    name                = "${local.prefix-hub}-vnet"
    location            = azurerm_resource_group.hub-vnet-rg.location
    resource_group_name = azurerm_resource_group.hub-vnet-rg.name
    address_space       = ["10.0.0.0/16"]

    tags = {
    environment = "hub-spoke"
    }
}

# Creating hub subnet where Azure Firewall will live
resource "azurerm_subnet" "hub-subnetfw" {
    name                 = "${local.prefix-hub}-subnetfw"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["10.0.1.0/27"]
}

# Creating the hub subnet to azure bastion (ab)
resource "azurerm_subnet" "hub-subnetab" {
    name                 = "${local.prefix-hub}-subnetab"
    resource_group_name  = azurerm_resource_group.hub-vnet-rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefixes       = ["10.0.2.0/27"]
}

# Creating public ip for azure bastion
resource "azurerm_public_ip" "pipab" {
  name                = "abhubpip"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Creating azure bastion
resource "azurerm_bastion_host" "hubab" {
  name                = "hubazurebastion"
  location            = azurerm_resource_group.hub-vnet-rg.location
  resource_group_name = azurerm_resource_group.hub-vnet-rg.name

    ip_configuration {
      name                 = "hubabconfig"
      subnet_id            = azurerm_subnet.hub-subnetab.id
      public_ip_address_id = azurerm_public_ip.pipab.ip_address
    }
}