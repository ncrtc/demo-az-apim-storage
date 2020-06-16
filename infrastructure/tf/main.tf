# Configure the Azure provider
provider "azurerm" {
  version = "= 2.14.0"
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

  sku_name = "Consumption_1"

  security {
      enable_backend_ssl30 = false
      enable_backend_tls10 = false
      enable_backend_tls11 = false
      enable_frontend_ssl30 = false
      enable_frontend_tls10 = false
      enable_frontend_tls11 = false
      enable_triple_des_ciphers = false
  }

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML
  }
}