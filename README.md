# Genpact AKS Infrastructure (Terraform)

This project provisions Azure infrastructure for a Kubernetes platform: a resource group, virtual network, dedicated subnets for AKS and managed database workloads, an AKS cluster, and an Azure Container Registry (ACR) with pull access for AKS.

### How many IP addresses does the Kubernetes subnet need?

This project uses the classic Azure CNI model because `network_plugin = "azure"` is set in the AKS `network_profile`. In this mode, both node IPs and pod IPs are allocated from the AKS subnet.
The chosen `10.1.0.0/16` can generate up to 2^16 unique ips. that is the limit set by the subnet.
node pod limits, default maxPods is 30(up to 250), and we didnt change it.

With the current node limits (autoscaler min 1, max 2, max surge 10%), A practical estimate is:

- 1 IP per node
- up to the node's configured pod capacity per node
- a little extra for upgrade/surge headroom

so we are limited more by the node maxPods limit, the subnet we chose has more than enough IPs to allocate.

### How does the cluster authenticate to the registry?

- AKS uses managed identity.
- Terraform assigns the AcrPull role to the AKS kubelet identity on the ACR scope.
- no registry username/password stored in cluster secrets. azure manages the role creation and rotation.

### What should and should not be publicly accessible?

Publicly accessible:

- Only the ingress entry point (typically a single Service of type LoadBalancer managed by the ingress controller).

Not publicly accessible:

- Internal application services should be Service type ClusterIP.
- Database endpoints should stay private in their delegated subnet.

Target model: one controlled public ingress, all backend services private.