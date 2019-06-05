PROJECT_NAME := hello-flask
VERSION := 0.0.1
IMAGE_REPO := harbor.sample.teko.vn/hello-flask/hello-flask
HARBOR_SERVER := https://harbor.sample.teko.vn

RELEASE_NAME := $(PROJECT_NAME)
IMAGE_TAG := $(VERSION)
BRANCH := ""
ifdef CIRCLE_BRANCH
	ifneq ($(CIRCLE_BRANCH), master)
		BRANCH = $(shell echo $(CIRCLE_BRANCH) | sed 's/.*\///g' | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
		RELEASE_NAME := $(shell echo $(RELEASE_NAME)-$(BRANCH) | cut -c1-30)
		REVISION := $(shell echo $(CIRCLE_SHA1) | cut -c1-7)
		IMAGE_TAG := dev-$(REVISION)
	endif
endif
IMAGE := $(IMAGE_REPO):$(IMAGE_TAG)

k8s-login-dev:
	@mkdir -p $(HOME)/.kube
	@echo "$(DEV_KUBE_CONFIG)" | base64 --decode > $(HOME)/.kube/config

k8s-login-prod:
	@mkdir -p $(HOME)/.kube
	@echo "$(PROD_KUBE_CONFIG)" | base64 --decode > $(HOME)/.kube/config

docker-login:
	@echo "$(HARBOR_PASSWORD)" | docker login --username $(HARBOR_USERNAME) --password-stdin $(HARBOR_SERVER)

build-image:
	docker image build -t $(IMAGE) .

push-image:
	docker image push $(IMAGE)

helm-add-repo:
	@helm repo add --username $(HARBOR_USERNAME) --password $(HARBOR_PASSWORD) teko $(HARBOR_SERVER)/chartrepo
	helm repo update

feed-values:
	sed "s/{{ branch }}/$(BRANCH)/g" deployments/k8s/values-tpl.yaml > deployments/k8s/values.yaml
	
feed-values-staging:
	sed "s/{{ branch }}/staging/g" deployments/k8s/values-tpl.yaml > deployments/k8s/values.yaml

helm-deploy:
	@helm upgrade $(RELEASE_NAME) teko/library/flaskapp -i \
		--username $(HARBOR_USERNAME) --password $(HARBOR_PASSWORD) \
		--version 0.0.1 \
		--namespace $(RELEASE_NAME) \
		-f deployments/k8s/values.yaml \
		--set image.tag=$(IMAGE_TAG)

helm-deploy-staging:
	@helm upgrade staging-$(RELEASE_NAME) teko/library/flaskapp -i \
		--username $(HARBOR_USERNAME) --password $(HARBOR_PASSWORD) \
		--version 0.0.1 \
		--namespace staging-$(RELEASE_NAME) \
		-f deployments/k8s/values.yaml \
		--set image.tag=$(IMAGE_TAG)
