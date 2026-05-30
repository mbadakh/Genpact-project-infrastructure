# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# Virtual Network & Subnets
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aks_subnet_prefix]
}

resource "azurerm_subnet" "db" {
  name                 = var.db_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.db_subnet_prefix]

  # Required delegation for Azure managed database services (e.g. Flexible Server)
  delegation {
    name = "db-delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ---------------------------------------------------------------------------
# Azure Container Registry
# ---------------------------------------------------------------------------
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku
  admin_enabled       = false # Use managed identity / RBAC instead
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# AKS Cluster
# ---------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.aks_cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    vm_size             = var.node_pool_vm_size
    node_count          = var.node_count
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
    vnet_subnet_id      = azurerm_subnet.aks.id
    os_disk_size_gb     = 128

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Use system-assigned managed identity — no service principal credentials to rotate
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"        # Azure CNI — pods get VNet IPs
    network_policy    = "calico"       # Pod-level network policy enforcement
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  # Restrict access to the API server (set to your CI/CD or management CIDR in production)
  api_server_access_profile {
    authorized_ip_ranges = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Grant AKS kubelet identity the AcrPull role on the registry
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
