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

resource "aws_iam_user" "alb-ingress-controler-user" {
  name = "alb-ingress-controler"
}

resource "aws_iam_policy" "alb-ingress-controler-s3-policy" {
  name = "alb-ingress-controler-s3"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveListenerCertificates",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "alb-ingress-controler-attach" {
  user = aws_iam_user.alb-ingress-controler-user.name
  policy_arn = aws_iam_policy.alb-ingress-controler-s3-policy.arn
}

resource "aws_iam_access_key" "alb-ingress-controler-key" {
  user = aws_iam_user.alb-ingress-controler-user.name
}

resource "kubernetes_secret" "aws_key" {
  metadata {
    name = "alb-ingress-controler-aws"
    namespace = "kube-system"
  }

  data = {
    "key_id" = aws_iam_access_key.alb-ingress-controler-key.id
    "key" = aws_iam_access_key.alb-ingress-controler-key.secret
  }
}

resource "kubernetes_service_account" "alb-ingress-controller-sa" {
  metadata {
    name = "alb-ingress-controller"
    namespace = "kube-system"
  }

  secret {
    name = kubernetes_secret.aws_key.metadata[0].name
  }

  automount_service_account_token = "true"
}

resource "kubernetes_cluster_role" "cluter_role" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app" = "alb-ingress-controller"
    }
  }

  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "configmaps",
      "endpoints",
      "events",
      "ingresses",
      "ingresses/status",
      "services",
    ]

    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "",
      "extensions",
    ]

    resources = [
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces",
    ]

    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_bind" {
  metadata {
    name = "alb-ingress-controller"

    labels = {
      app = "alb-ingress-controller"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    name = kubernetes_cluster_role.cluter_role.metadata[0].name
    kind = "ClusterRole"
  }

  subject {
    api_group = ""
    kind = "ServiceAccount"
    name = kubernetes_service_account.alb-ingress-controller-sa.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "alb-ingress-controller"
    namespace = "kube-system"

    labels = {
      app = "alb-ingress-controller"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          app = "alb-ingress-controller"
        }
      }

      spec {
        automount_service_account_token = true
        service_account_name = kubernetes_service_account.alb-ingress-controller-sa.metadata[0].name

        container {
          name = "alb-ingress-controller"
          image = "docker.io/amazon/aws-alb-ingress-controller:v${var.controller_version}"
          image_pull_policy = "Always"

          # Limit the namespace where this ALB Ingress Controller deployment will
          # resolve ingress resources. If left commented, all namespaces are used.
          # - --watch-namespace=your-k8s-namespace

          # Setting the ingress-class flag below ensures that only ingress resources with the
          # annotation kubernetes.io/ingress.class: "alb" are respected by the controller. You may
          # choose any class you'd like for this controller to respect.
          # - --ingress-class=alb

          # Name of your cluster. Used when naming resources created
          # by the ALB Ingress Controller, providing distinction between
          # clusters.
          # - --cluster-name=your-cluster-name

          # AWS VPC ID this ingress controller will use to create AWS resources.
          # If unspecified, it will be discovered from ec2metadata.
          # - --aws-vpc-id=vpc-xxxxxx

          # AWS region this ingress controller will operate in.
          # If unspecified, it will be discovered from ec2metadata.
          # List of regions: http://docs.aws.amazon.com/general/latest/gr/rande.html#vpc_region
          # - --aws-region=us-west-1

          # Enables logging on all outbound requests sent to the AWS API.
          # If logging is desired, set to true.
          # - ---aws-api-debug
          # Maximum number of times to retry the aws calls.
          # defaults to 10.
          # - --aws-max-retries=10
          args = [
            "--ingress-class=alb",
            "--cluster-name=${var.cluster_name}",
            "--aws-vpc-id=${var.vpc_id}",
            "--aws-region=${var.aws_region}",
          ]
          security_context {
            allow_privilege_escalation = "false"
            privileged = "false"
            run_as_user = "999"
            run_as_non_root = "true"
          }
          env {
            name = "AWS_ACCESS_KEY_ID"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.aws_key.metadata[0].name
                key = "key_id"
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.aws_key.metadata[0].name
                key = "key"
              }
            }
          }
          env {
            name = "AWS_DEFAULT_REGION"
            value = var.aws_region
          }
        }
      }
    }
  }
}
