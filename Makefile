# Makefile
#
SHELL := /bin/bash

.PHONY: install_deps cluster delete_cluster target_kind blue-image green-image load-images deploy requests prepare_demo switch-image switch

install_deps:
	@echo "Checking and installing required packages..."
	@# Check if Docker is installed
	@if ! command -v docker &> /dev/null; then \
		echo "Docker not found, installing..."; \
		sudo apt update && sudo apt install -y docker.io; \
	else \
		echo "Docker is already installed"; \
	fi

	@# Check if Kind is installed
	@if ! command -v kind &> /dev/null; then \
		echo "Kind not found, installing..."; \
		go install sigs.k8s.io/kind@latest; \
	else \
		echo "Kind is already installed"; \
	fi

	@# Check if kubectl is installed
	@if ! command -v kubectl &> /dev/null; then \
		echo "kubectl not found, installing..."; \
		curl -LO https://dl.k8s.io/release/$(shell curl -s https://cdn.dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl; \
		chmod +x ./kubectl; \
		sudo mv ./kubectl /usr/local/bin/kubectl; \
	else \
		echo "kubectl is already installed"; \
	fi

	@# Check if Argo Rollouts plugin for kubectl is installed
	@if ! command -v kubectl-argo-rollouts &> /dev/null; then \
		echo "Argo Rollouts plugin not found, installing..."; \
		curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64; \
		chmod +x ./kubectl-argo-rollouts-linux-amd64; \
		sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts; \
	else \
		echo "Argo Rollouts plugin is already installed"; \
	fi

cluster:
	@kind create cluster --name kind-demo --config kind-config.yaml

target_kind:
	kubectl config use-context kind-kind-demo

delete_cluster:
	@kind delete cluster --name kind-demo

install_argo: target_kind
	kubectl get namespace argocd &>/dev/null || kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-rollouts/stable/manifests/install.yaml

blue-image:
	docker build -t blue-demo-image:latest -f blue-green-app/blue/Dockerfile .
	kind load docker-image blue-demo-image:latest --name kind-demo

green-image:
	docker build -t green-demo-image:latest -f blue-green-app/green/Dockerfile .
	kind load docker-image green-demo-image:latest --name kind-demo

load-images: blue-image green-image

ingress-nginx:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	sleep 10
	kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=150s

deploy: target_kind
	kubectl apply --recursive -f blue-green-app/

prepare_demo: cluster install_argo load-images deploy ingress-nginx

requests:
		./bin/simulate-requests.sh 180

status:
	@kubectl argo rollouts get rollout blue-green-app-rollout --watch

switch-image:
	@./bin/switch-image.sh

switch: switch-image status
