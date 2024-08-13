terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}

provider "local" {
  # Using the local provider for running shell commands
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

resource "local_file" "clone_repo" {
  content  = <<EOT
  #!/bin/bash
  set -e
  git clone https://github.com/MuhammadYaseenDevOps/Jenkinks_Pipeline_Landing_Page.git
  cd Jenkinks_Pipeline_Landing_Page
  npm install --force
  docker build -t ensmuhammadyaseen/landing-page-image .
  docker push ensmuhammadyaseen/landing-page-image
  EOT

  filename = "${path.module}/clone_repo.sh"
}

resource "null_resource" "run_clone_repo" {
  provisioner "local-exec" {
    command = "bash ${local_file.clone_repo.filename}"
  }

  depends_on = [local_file.clone_repo]
}

resource "kubectl_manifest" "deploy_app" {
  yaml_body = <<EOT
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: landing-page-app
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: landing-page-app
    template:
      metadata:
        labels:
          app: landing-page-app
      spec:
        containers:
        - name: landing-page-container
          image: ensmuhammadyaseen/landing-page-image
          ports:
          - containerPort: 80
  EOT

  depends_on = [null_resource.run_clone_repo]
}

resource "kubectl_manifest" "service_app" {
  yaml_body = <<EOT
  apiVersion: v1
  kind: Service
  metadata:
    name: landing-page-service
  spec:
    selector:
      app: landing-page-app
    ports:
    - protocol: TCP
      port: 80
      targetPort: 80
    type: LoadBalancer
  EOT

  depends_on = [kubectl_manifest.deploy_app]
}
