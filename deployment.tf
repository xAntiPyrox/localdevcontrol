terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "apache2" {
  metadata {
    name = "apache2"
  }
}

resource "kubernetes_service" "apache2" {
  metadata {
    name      = "apache2"
    namespace = kubernetes_namespace.apache2.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.apache2.spec.0.template.0.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      port        = 80
      node_port   = 30201
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "apache2" {
  metadata {
    name      = "apache2"
    namespace = kubernetes_namespace.apache2.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "apache2"
      }
    }
    template {
      metadata {
        labels = {
          app = "apache2"
        }
      }
      spec {
        container {
          image = "testweb:latest"
          name  = "apache2"
          image_pull_policy = "Never"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

