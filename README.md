# Sample Flask project deploying on Kubernetes
This repository is a sample python Flask app, that can be deployed on Kubernetes using CircleCI.
You can use this project as a template to deploy your app on Teko Kubernetes cluster, CI/CD pipeline with CircleCI.

## Integration Guide
In order to deploy your app on Kubernetes, some basic knowledge about Kubernetes and Docker is required.
The template uses [helm](https://helm.sh) to simplify the deployment.

### Prerequisites
- Installing [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
	- To access Kubernetes cluster, ask SA team to obtain your `config` file, then place it at $HOME/.kube
- Installing [helm](https://helm.sh/docs/using_helm/#installing-helm)
	- Initialize `helm` using command: `helm init --client-only`
- An account to access Docker registry and helm chart repository which is [Harbor](https://hub.k8s.teko.vn)
  - Ask SA team to create your project and account.

### Edit your values.yaml

  A helm chart is created to simplify deployment: https://github.com/teko-vn/helm-charts/tree/master/flaskapp. Just copy [values.yaml](https://github.com/teko-vn/helm-charts/blob/master/flaskapp/values.yaml) then edit its values to your own values.
  
  In this repo, [values-tpl.yaml](https://github.com/teko-vn/helm-sample-projects/blob/master/deployments/k8s/values-tpl.yaml) is used with a placeholder `{{ branch }}`. This placeholder will be replaced to deploy your app in different environments.

1. `nameOverride`, `fullnameOverride`: Your app name in short and long description. You need to provide both.

2. `replicaCount`: The number of instances your app will launch.

3. `image`: Docker Image config
	- `registry`: Docker image registry. Ex: gcr.io (Google Cloud Container Registry), docker.io (Docker Hub), hub.k8s.teko.vn (Teko Harbor). If you leave this empty, Docker Hub will be used.
	- `repository`: The path your Docker image. Ex: `hello-flask/hell-flask`
	- `tag`: The image tag. Ex: 1.0.0, 1.2.0...
	- `port`: The container's port.
	- `pullPolicy`: Image pull policy. Ex: `Always`, `IfNotPresent`

4. `healthcheck`: Health-check
	- `enabled`: `true` to enable heath-check.
	- `liveness`: HTTP URL to check your app's liveness.
	- `readiness`: HTTP URL to check your app's readiness.
	- `host`: HTTP `host` header when calling HTTP GET request to health-check URLs.

5. `hosts`: An array of your app's hosts.
	- `host`: your app's host. Ex: myapp.k8s.teko.vn
	- `paths`: an array of URI paths. Leave it `""`, so all requests to `host` will be routed to your service.
	- Example
		```
		- host: myapp.k8s.teko.vn
		  paths:
		    - "/api"
        - "/api/v1"
		```
		so all requests to myapp.k8s.teko.vn/api and myapp.k8s.teko.vn/api/v1 will be routed to your service.

6. `secrets`: your app's secrets

    It is an array of key-value pair.
    Example:
    ```
    secrets:
      - db-url: "mysql://user:passw@host:3306/mydb"
      - amqp-url: "amqp://user:passw@intelligent-hawk.rmq.cloudamqp.com/teko-prod"
    ```

7. `environmentVariables`: your app's environment variables.

    It can be a string or a value from your apps' secrets. 
    Example:
    ```
    environmentVariables:
    - name: FLASK_CONFIG
      value: production
    - name: DATABASE_URL
      valueFromSecret: db-url
    ```

### Configure CI

  Sample CircleCI configuration file at [config.yml](https://github.com/teko-vn/helm-sample-projects/blob/master/.circleci/config.yml).
  A [Makefile](https://github.com/teko-vn/helm-sample-projects/blob/master/Makefile) is created for some commands.
  You can edit these files to suit your needs.
  
  1. Makefile

      You need to provide your project' values, which are at top of the Makefile:
        ```
        PROJECT_NAME := hello-flask
        IMAGE_REPO := hub.k8s.teko.vn/hello-flask/hello-flask
        HARBOR_SERVER := https://hub.k8s.teko.vn
        ```
  
  2. .circleci/config.yml
  
      There are two workflows configured:
      
      - `feature-development`
        
        When a feature is developed at `feature/*` branch, it can be deployed at `<your-app>-<short-branch-name>.k8s.teko.vn`.

        ![](https://raw.githubusercontent.com/teko-vn/helm-sample-projects/feature/README-integration-guide/docs/img/feature-feature-deployment.png)

        When feature is merged to `master` branch, it can be deployed to staging for UAT testing.

        ![](https://raw.githubusercontent.com/teko-vn/helm-sample-projects/feature/README-integration-guide/docs/img/master-feature-development.png)
      
      - `deploy-production`
        
        When a git tag is created, following [semver](https://semver.org/) convention (Ex: v0.1.1, v1.2.0...), your app is ready to deploy on production environment.
        
        ![](https://raw.githubusercontent.com/teko-vn/helm-sample-projects/feature/README-integration-guide/docs/img/tag-deploy-production.png)
  
  3. Configure CirleCI environments

      Some environment variables is required to configure at your project CircleCI settings. These values must be **base64 encoded**.

      - `DEV_KUBE_CONFIG`: kubectl config file for k8s development cluster.
      - `PROD_KUBE_CONFIG`: kubectl config file for k8s production cluster.
      - `HARBOR_USERNAME`: [Harbor](https://hub.k8s.teko.vn) username, which is needed to use Teko Harbor for image registry and `flaskapp` helm chart.
      - `HARBOR_PASSWORD`: [Harbor](https://hub.k8s.teko.vn) password, which is needed to use Teko Harbor for image registry and `flaskapp` helm chart.