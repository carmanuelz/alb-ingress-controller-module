/*
Copyright 2019 Measures for Justice Institute.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

variable "aws_region" {
  default = "us-east-1"
  description = "aws region to use"
}

variable "version" {
  default = "1.1.1"
  description = "Version of alb-ingress-controller to use"
}

variable "config_context" {
  description = "kubectl config context to use"
}

variable "cluster_role" {
  default = "alb-ingress-controller"
  description = "name of the cluster role created with clutser-role.yaml"
}

variable "cluster_name" {
  description = "Name of your k8 cluster"
}

variable "vpc_id" {
  description = "Name of the vpc your k8 cluster is in"
}