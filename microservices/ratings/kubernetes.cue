package kubernetes

import (
	"github.com/slewiskelly/cuek8s/pkg/delivery/kubectl"
	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/kit"
)

Metadata: kit.#Metadata & {
	serviceID: "ratings"
}

App: Ratings: kit.#Application & {
	metadata: Metadata

	spec: {
		env: {
			DB_TYPE:           "mysql"
			MYSQL_DB_HOST:     "mysqldb"
			MYSQL_DB_PORT:     "3306"
			MYSQL_DB_USER:     "root"
			MYSQL_DB_PASSWORD: "password"
		}
	}
}

ConfigMap: MySQL: kit.#ConfigMap & {
	metadata: Metadata & {
		name: "mysql-credentials"
	}

	data: {
		rootpasswd: "password"
	}
}

Deployment: MySQL: k8s.#Deployment & {
	metadata: Metadata.metadata & {
		name: "mysqldb"
	}

	spec: {
		replicas: 1
		selector: matchLabels: {
			app: "mysqldb"
		}
		template: {
			metadata: labels: {
				app: "mysqldb"
			}
			spec: {
				containers: [{
					name:  "mysqldb"
					image: "docker.io/slewiskelly/acme-mysqldb"
					ports: [{
						containerPort: 3306
					}]
					env: [{
						name: "MYSQL_ROOT_PASSWORD"
						valueFrom: configMapKeyRef: {
							name: ConfigMap.MySQL.metadata.name
							key:  "rootpasswd"
						}
					}]
					args: ["--default-authentication-plugin", "mysql_native_password"]
					volumeMounts: [{
						name:      "var-lib-mysql"
						mountPath: "/var/lib/mysql"
					}]
				}]
				volumes: [{
					name: "var-lib-mysql"
					emptyDir: {}
				}]
			}
		}
	}
}

Service: MySQL: kit.#Service & {
	metadata: Metadata & {
		name: "mysqldb"
	}

	spec: {
		expose: tcp: port: 3306
		selector: Deployment.MySQL.metadata.labels
	}
}

Delivery: {
	ratings: kubectl.#Delivery & {
		resources: App.Ratings.resources
	}

	mysqldb: kubectl.#Delivery & {
		resources: [Deployment.MySQL] +
			ConfigMap.MySQL.resources +
			Service.MySQL.resources
	}
}
