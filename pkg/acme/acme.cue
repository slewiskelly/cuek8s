// Package acme contains definitions specific to Acme infrastructure.
package acme

// Cluster specifies an Acme Kubernetes cluster.
#Cluster:
	#DevLondon01 | #DevTokyo01 |
	#ProdLondon01 | #ProdTokyo01

// Country specifies an Acme country.
#Country:
	#JP | #UK

// Environment specifies an Acme environment (short-form).
#Env:
	#Dev | #Prod

// Environment specifies an Acme environment (long-form).
#Environment:
	#Development | #Production

// GCPRegion specifies a GCP region.
#GCPRegion:
	#AsiaNortheast1 | #EuropeWest2

// GCPZone specifies a GCP zone.
#GCPZone:
	#AsiaNortheast1a | #AsiaNortheast1b | #AsiaNortheast1c |
	#EuropeWest2a | #EuropeWest2b | #EuropeWest2c

// GCPProject specifies a valid Acme GCP project ID.
#GCPProject: string & =~#"[a-zA-Z0-9-]+[^\-]-(dev|prod)"#

// Name specifies a valid Acme name, including:
// - Docker image names
// - Kubernetes resource names
// - Service IDs
#Name: string & =~#"[a-zA-Z0-9-]+[^\-]"#

// Namespace specifies a valid Acme namespace.
#Namespace: string & =~#"[a-zA-Z0-9-]+[^\-]-(dev|prod)"#

// Region specifies an Acme region.
#Region:
	#London | #Tokyo

// Acme cluster.
#DevLondon01:  "dev-london-01"
#DevTokyo01:   "dev-tokyo-01"
#ProdLondon01: "prod-london-01"
#ProdTokyo01:  "prod-tokyo-01"

// Acme country.
#JP: "jp"
#UK: "uk"

// Acme environment.
#Dev:         "dev"
#Development: "development"
#Prod:        "prod"
#Production:  "production"

// Acme region.
#London: "london"
#Tokyo:  "tokyo"

// GCP region.
#AsiaNortheast1: "asia-northeast1"
#EuropeWest2:    "europe-west2"

// GCP zone.
#AsiaNortheast1a: "asia-northeast1-a"
#AsiaNortheast1b: "asia-northeast1-b"
#AsiaNortheast1c: "asia-northeast1-c"
#EuropeWest2a:    "europe-west2-a"
#EuropeWest2b:    "europe-west2-b"
#EuropeWest2c:    "europe-west2-c"
