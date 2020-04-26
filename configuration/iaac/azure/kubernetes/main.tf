provider "azurerm" {
  version = "~>2.0.0"
  features {}
}


resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group}_${var.environment}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "terraform-k8s" {
  name                = "${var.cluster_name}_${var.environment}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name            = "agentpool"
    node_count      = "1"
    vm_size         = "Standard_D16a_v4"
  }

  service_principal {
    client_id     = "968ad5d6-4507-4dc6-a939-e888af013faa"
    client_secret = "1e2bc0be-833a-4ec6-90cd-312342e5a64f"
  }

  tags = {
    Environment = var.environment
  }
}

terraform {
  backend "azurerm" {
    # storage_account_name="<<storage_account_name>>" #OVERRIDE in TERRAFORM init
    # access_key="<<storage_account_key>>" #OVERRIDE in TERRAFORM init
    # key="<<env_name.k8s.tfstate>>" #OVERRIDE in TERRAFORM init
    # container_name="<<storage_account_container_name>>" #OVERRIDE in TERRAFORM init
  }
}
