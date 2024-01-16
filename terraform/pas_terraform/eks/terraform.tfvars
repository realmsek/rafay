# Poject name variable
project               = "terraform-caas-58"

# Cloud Credentials specific variables
cloud_credentials_name  = "rafay-cloud-credential"
# Specify Role ARN & externalid info below for EKS.
rolearn                 = "arn:aws:iam::679196758854:role/dreta-provisioning-role"
externalid              = "c685-9ce7-7fbe-c971-5163"

# Instance profile Name for Karpenter nodes
instance_profile       = "arn:aws:iam::679196758854:role/KarpenterNodeRole-Rafay"

# Cluster variables
cluster_name           =  "terraform-caas-58"
# Cluster Region
cluster_location       =  "us-west-2"
# K8S Version
k8s_version            =  "1.27"

# TAGS
cluster_tags = {
    "email" = "david@rafay.co"
    "env"    = "dev"
    "orchestrator" = "k8s"
    "cluster-name" = "terraform-caas-58"
}

# S3 bucket name for Backup/Restore
s3_bucket = "terraform-caas-58"

# K8s cluster labels
cluster_labels = {
  "nginx" = "",
  "karpenter" = "",
  "region" = "us-west-2"
}

# IAM Roles to access EKS provided endpoint
cluster_admin_iam_roles = ["arn:aws:iam::679196758854:user/david@rafay.co"]

# ID and AZ of private subnets (optional: must have proper permissions to create VPC)
private_subnet_ids = {
  "subnet-01bc23afc0744c4aa" = "us-west-2a",
  "subnet-04e1e5616bde25473" = "us-west-2b"
}

# ID and AZ of public subnets (optional)
public_subnet_ids = {
  "subnet-0cde3009a8e9b04f2" = "us-west-2a",
  "subnet-02d30b8e8c56b142a" = "us-west-2b"
}

# Systems Components Placement
rafay_tol_key         = "nodeInfra"
rafay_tol_operator    = "Exists"
rafay_tol_effect      = "NoSchedule"

# EKS Nodegroups
managed_nodegroups = {
  "ng-1" = {
    ng_name         = "infra-terraform"
    node_count      = 1
    node_max_count  = 5
    node_min_count  = 1
    k8s_version     = "1.27"
    instance_type   = "t3.xlarge"
    taint_key       = "nodeInfra"
    taint_operator  = "Exists"
    taint_effect    = "NoSchedule"
    labels          = {
      "node" = "infra"
    }
  }
}

node_tags = {
  "env" = "dev"
}

# Blueprint/Addons specific variables
blueprint_name         = "custom-blueprint"
blueprint_version      = "v1"
base_blueprint         = "minimal"
base_blueprint_version = "2.2.0"
namespaces             = [
  "ingress-nginx", 
  "cert-manager",
  "karpenter",
  "default",
  "kube-node-lease",
  "kube-public",
  "wordpress"
]
infra_addons = {
    "addon1" = {
         name          = "cert-manager"
         namespace     = "cert-manager"
         type          = "Helm"
         addon_version = "v1.12.3.1"
         catalog       = null
         chart_name    = "cert-manager"
         chart_version = "v1.12.3"
         repository    = "cert-manager"
         file_path     = "file://../artifacts/cert-manager/custom_values.yaml"
         depends_on    = []
    }
    "addon2" = {
         name          = "ingress-nginx"
         namespace     = "ingress-nginx"
         type          = "Helm"
         addon_version = "v4.8.3.1"
         catalog       = null
         chart_name    = "ingress-nginx"
         chart_version = "4.8.3"
         repository    = "nginx-controller"
         file_path     = null
         depends_on    = ["cert-manager"]
    }
    "addon3" = {
         name          = "karpenter"
         namespace     = "karpenter"
         type          = "Helm"
         addon_version = "v0.32.1.1"
         catalog       = "default-rafay"
         chart_name    = "karpenter"
         chart_version = "v0.32.1"
         repository    = ""
         file_path     = "file://../artifacts/karpenter/custom_values.yaml"
         depends_on    = []
    }
    "addon4" = {
         name          = "karpenter-nodepool"
         namespace     = "karpenter"
         type          = "Yaml"
         addon_version = "v1"
         file_path     = "file://../artifacts/karpenter/nodepool.yaml"
         depends_on    = ["karpenter"]
    }
}

constraint_templates   = ["allowed-users-custom",
                          /*"app-armor-custom",
                          "forbidden-sysctls-custom",
                          "host-filesystem-custom",
                          "host-namespace-custom",
                          "host-network-ports-custom",
                          "linux-capabilities-custom",
                          "privileged-container-custom",
                          "proc-mount-custom",
                          "read-only-root-filesystem-custom",
                          "se-linux-custom",
                          "seccomp-custom",
                          "volume-types-custom",
                          "disallowed-tags-custom",
                          "replica-limits-custom",
                          "required-annotations-custom",
                          "required-labels-custom",
                          "required-probes-custom",
                          "allowed-repos-custom",
                          "block-nodeport-services-custom",
                          "https-only-custom",
                          "image-digests-custom",
                          "container-limits-custom",*/
                          "container-resource-ratios-custom"
]

# repo housing OPA constraints and constraint templates
opa-repo = "rafay-gs"
opa-branch = "caas-eks-gen-2"
opa_excluded_namespaces = ["default", "kube-node-lease", "kube-public"]

# Repository specific variables
public_repositories = {
    "nginx-controller" = {
        type = "Helm"
        endpoint = "https://kubernetes.github.io/ingress-nginx"
    }
    "cert-manager" = {
        type = "Helm"
        endpoint = "https://charts.jetstack.io"
    }
    "rafay-gs" = {
        type = "Git"
        endpoint = "https://github.com/RafaySystems/getstarted.git"
    }
}

# Override config
overrides_config = {
    "ingress-nginx" = {
      override_addon_name = "ingress-nginx"
      override_values = <<-EOT
      defaultBackend:
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
        replicaCount: 3
      commonLabels:
        owner: rafay
      controller:
        admissionWebhooks:
          resources:
            limits:
              cpu: 10m
              memory: 20Mi
            requests:
              cpu: 10m
              memory: 20Mi
        resources:
          limits:
            cpu: 100m
            memory: 90Mi
          requests:
            cpu: 100m
            memory: 90Mi
        service:
          annotations:
            a8r.io/owner: "user@k8s.com"
            a8r.io/runbook: "http://www.k8s.com"
        tolerations:
        - key: nodeInfra
          operator: Exists
          effect: NoSchedule
        replicaCount: 3
        admissionWebhooks:
          service:
            annotations:
              a8r.io/owner: "user@k8s.com"
              a8r.io/runbook: "http://www.k8s.com"
          patch:
            tolerations:
            - key: nodeInfra
              operator: Exists
              effect: NoSchedule
      defaultBackend:
        tolerations:
        - key: nodeInfra
          operator: Exists
          effect: NoSchedule
      EOT
    },
    "cert-manager" = {
      override_addon_name = "cert-manager"
      override_values = <<-EOT
      tolerations:
      - key: nodeInfra
        operator: Exists
        effect: NoSchedule
      webhook:
        tolerations:
        - key: nodeInfra
          operator: Exists
          effect: NoSchedule
      cainjector:
        tolerations:
        - key: nodeInfra
          operator: Exists
          effect: NoSchedule
      startupapicheck:
        tolerations:
        - key: nodeInfra
          operator: Exists
          effect: NoSchedule
      EOT
    }
    "karpenter" = {
      override_addon_name = "karpenter"
      override_values = <<-EOT
      controller:
        resources:
          requests:
            cpu: 1
            memory: 1Gi
          limits:
            cpu: 1
            memory: 1Gi
      additionalAnnotations:
        a8r.io/owner: "user@k8s.com"
        a8r.io/runbook: "http://www.k8s.com"
      replicas: 1
      tolerations:
      - key: nodeInfra
        operator: Exists
        effect: NoSchedule
      EOT
    }
}
