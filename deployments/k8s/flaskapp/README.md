# Flask App

## TL;DR
Edit the default [values.yaml](values.yaml) with your values (Ex: values-production.yaml)
Run the command:
```bash
$ helm install --name my-release -f values-production.yaml stable/python-flask
```

## Introduction

This chart simplifies deployment of a Flask app in Kubernetes.

## Prerequisites

- Kubernetes 1.10+
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - You need to authorize with the K8s cluster. Ask SA team for `config` file, then place it at the kubectl config dir ($HOME/.kube/)
- [Helm](https://helm.sh/docs/using_helm/#installing-helm)
  - Run: `helm init --client-only`

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/python-flask
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the flask app chart and their default values.

|             Parameter                     |                     Description                     |                              Default                              |
|-------------------------------------------|-----------------------------------------------------|-------------------------------------------------------------------|
| `image.repository`                        | Your app Image name                                 | `nil`                                                             |
| `image.tag`                               | MariaDB Image tag                                   | `{VERSION}`                                                       |
| `image.pullPolicy`                        | MariaDB image pull policy                           | `Always` if `imageTag` is `latest`, else `IfNotPresent`           |
| `image.pullSecrets`                       | Specify docker-registry secret names as an array    | `[]` (does not add image pull secrets to deployed pods)           |
| `image.credentialDockerConfig`            | Docker config used to create image pull secret      | `nil`                                                             |
| `liveness`                                | Liveness check with a HTTP GET URL                  | `/`                                                               |
| `readiness`                               | Readiness check with a HTTP GET URL                 | `/`                                                               |
| `service.type`                            | Kubernetes service type                             | `ClusterIP`                                                       |
| `service.port`                            | Service port                                        | `80`                                                              |
| `ingress.hosts`                           | An array of hosts configuration for ingress         | `[]`                                                              |
| `ingress.tls`                             | TLS for ingress                                     | `[]` (does not use TLS)                                           |
| `volumes`                                 | Volumes                                             | `nil` (no volumes used)                                           |
| `volumeMounts`                            | Mount volumes                                       | `nil`                                                             |
| `resources`                               | Resource limitation                                 | `{}`                                                              |
| `autoscaling`                             | HorizontalPodAutoscaler for the Deployment          | `{}`                                                              |
| `autoscaling.enable`                      | Enable autoscaling                                  | `false`                                                           |
| `nodeSelector`                            | Node selector                                       | `{}`                                                              |
| `tolerations`                             | tolerations                                         | `{}`                                                              |
| `affinity`                                | affinity                                            | `{}`                                                              |
| `secrets`                                 | Your app secrets                                    | `[]`                                                              |
| `environmentVariables`                    | Environment variables                               | `[]`                                                              |
| `migration.enable`                        | Enable db migration. Note: Flask-Migration is required to use db migration | `false`                                    |
| `migration.command`                       | Command to migrate db. It must be a string          | `nil`                                                             |
| `migration.environmentVariables`          | Environment variables                               | Environment variables used for run migration container            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set image.repository=gcr.io/teko/example-flask-app \
    stable/python-flask
```


Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/python-flask
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Extra Init Containers

The feature allows for specifying a template string for a initContainer in the master/slave pod. Usecases include situations when you need some pre-run setup. For example, in IKS (IBM Cloud Kubernetes Service), non-root users do not have write permission on the volume mount path for NFS-powered file storage. So, you could use a initcontainer to `chown` the mount. See a example below, where we add an initContainer on the master pod that reports to an external resource that the db is going to starting.
`values.yaml`
```yaml
initContainers: |
  - name: initcontainer
    image: alpine:latest
    command: ["/bin/sh", "-c"]
    args:
      - curl http://api-service.local/db/starting;
```
