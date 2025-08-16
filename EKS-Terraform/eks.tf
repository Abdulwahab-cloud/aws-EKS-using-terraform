resource "aws_iam_role" "eks-role" {
    name = "EKSClusterRole"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-role.name
}

resource "aws_eks_cluster" "eks" {
  name = local.eks_name
  role_arn = aws_iam_role.eks-role.arn
  version  = local.eks_version

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

 
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true
    subnet_ids = [
      aws_subnet.private1.id,
      aws_subnet.private2.id,
      aws_subnet.public1.id,
      aws_subnet.public2.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.attachment,
  ]
}

resource "aws_iam_role" "fargate-role" {
    name = "fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
/* resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "vpc-cni"
  depends_on = [aws_eks_cluster.eks]
} */

resource "aws_iam_role_policy_attachment" "fargate_execution" {
  role       = aws_iam_role.fargate-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

/* resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
} */

/* resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "EC2_ecr" {
  role = aws_iam_role.node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
} */

resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "Abdulwahab-cluster"
  pod_execution_role_arn = aws_iam_role.fargate-role.arn
  subnet_ids             = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  /* selector {
    namespace = "default"
  } */

  selector {
    namespace = "kube-system"
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_execution
  ]
}

resource "aws_eks_fargate_profile" "node_profile" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "fg-NodeApp"
  pod_execution_role_arn = aws_iam_role.fargate-role.arn
  subnet_ids             = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  selector {
    namespace = "node-app"
  }

 

  depends_on = [
    aws_iam_role_policy_attachment.fargate_execution
  ]
}