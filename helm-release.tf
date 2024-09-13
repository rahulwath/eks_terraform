data "aws_eks_node_group" "eks-node-group" {
  cluster_name = "hr-dev-eks-demo"
  node_group_name = "hr-dev-eks-ng-public"
}

resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        data.aws_eks_cluster.hr-dev-eks-demo
    ]

    create_duration = "20s"
}

resource "kubernetes_namespace" "kube-namespace" {
  depends_on = [data.aws_eks_node_group.eks-node-group, time_sleep.wait_for_kubernetes]
  metadata {
    
    name = "prometheus"
  }
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "62.5.1"
  namespace  = "monitoring"
  create_namespace = true
  timeout    = 3600

  values = [file("${path.module}/values/prometheus.yaml")]
}
