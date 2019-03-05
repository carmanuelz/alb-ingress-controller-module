# alb-ingress-controller terraform module

Terraform module for creating alb-ingress-controller in kubernetes with an IAM user

Creates both the IAM user with permissions for alb-ingress-controller and the k8 deployment with necessary roles.

The latest version of the alb-ingress-controller image can be found at https://github.com/kubernetes-sigs/aws-alb-ingress-controller

## Important install steps

All Subnets to be used with k8 need to be tagged with `kubernetes.io/cluster/CLUSTER_NAME` = `shared`. Public subnets should also be tagged with `kubernetes.io/role/elb` = `1`, and private subnets with `kubernetes.io/role/internal-elb` = `1`.

## Legal stuff

This terraform module is released under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Copyright 2019 Measures for Justice Institute.
