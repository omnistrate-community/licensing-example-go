package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/omnistrate-oss/omnistrate-licensing-sdk-go/pkg/validator"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// Validate license key for product

	// This is the validation method that can be used to validate license key for a product in Omnistrate
	// err := validator.ValidateLicenseForProduct("PRODUCT-DEV-SKU")

	// Using options to make it work with Omnistrate pre prod environment
	err := validator.ValidateLicenseWithOptions(validator.ValidationOptions{
		SKU:               "PRODUCT-DEV-SKU",
		CertificateDomain: "licensing.omnistrate.dev",
	})
	if err != nil {
		// Print error information in html format
		fmt.Fprintf(w, "<h1>Error</h1><p>%s</p>", err.Error())
		return
	}
	// Print success message in html format
	fmt.Fprintf(w, "<h1>Success</h1><p>License is valid</p>")
}

func main() {
	http.HandleFunc("/", handler)
	// certFile := "/etc/tls/tls.crt"
	// keyFile := "/etc/tls/tls.key"

	// // check if the certificate and key files exist
	// if _, err := os.Stat(certFile); os.IsNotExist(err) {
	// 	log.Printf("Starting server on :8443 with TLS...")
	// 	err := http.ListenAndServeTLS(":8443", certFile, keyFile, nil)
	// 	if err != nil {
	// 		log.Fatalf("Server failed to start: %v", err)
	// 	}
	// } else {
	// start server without TLS
	log.Printf("Starting server on :8080 without TLS...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
	// }
}
