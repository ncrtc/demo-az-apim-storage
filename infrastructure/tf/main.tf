# Configure the Azure provider
provider "azurerm" {
  version = "= 2.13.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-apim-tf-01"
  location = "East US"
}

resource "azurerm_api_management" "example" {
  name                = "tjs-tf-apim"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "tjs"
  publisher_email     = "tim@tjs.com"

  sku_name = "Consumption_0"

  policy {
    xml_link = "https://raw.githubusercontent.com/ncrtc/demo-az-apim-storage/master/policy-standard.xml"
  }
}