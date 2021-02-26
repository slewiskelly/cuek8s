package kube

base: {
	service:     "ratings"
	environment: "dev"
	region:      "osaka"
}

application: ratings: {
	expose: http: port: 9080

	sql: instances: ["acme-ratings-dev:asia-northeast1:sql=tcp:3306"]

	envFrom: [{configMapRef: {name: "sql-config"}}]
}

configMap: "sql-config": data: {
	"DB_TYPE":           "mysql"
	"MYSQL_DB_HOST":     "127.0.0.1"
	"MYSQL_DB_PORT":     "3306"
	"MYSQL_DB_USER":     "root"
	"MYSQL_DB_PASSWORD": "password"
}
