data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

module "iam_assumable_role_mpc_party" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.48.0"
  provider_url                  = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  create_role                   = true
  role_name                     = "mpc-${var.cluster_name}-${var.party_name}-${var.name}"
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}"]
  role_policy_arns              = [aws_iam_policy.mpc_aws.arn]
}

resource "aws_iam_policy" "mpc_aws" {
  name   = "mpc-${var.cluster_name}-${var.party_name}"
  policy = var.policy
}
