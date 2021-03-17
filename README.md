# k8s-cluster

The scope of this project is to provision and manage the underlying infrastructure for a demo K8s cluster on GCP using Terraform.

This includes the provisioning of a custom VPC network with a regional subnet and a permissive ingress firewall rule.

The K8s cluster will consist of 3 master and 3 worker nodes.
