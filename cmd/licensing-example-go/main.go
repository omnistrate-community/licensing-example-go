package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/omnistrate-oss/omnistrate-licensing-sdk-go/pkg/validator"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// Validate license key for product

	// Unique ID provided by Omnistrate for your organization
	orgID := "org-4xihABXKyq"
	// Unique Product ID provided that can be configured in Omnistrate, by default it is the Product Plan ID
	productUniqueID := "PRODUCT-SAMPLE-SKU-UNIQUE-VALUE"

	// This is the validation method that can be used to validate license key for a product in Omnistrate
	// With a simple call to this method, you can:
	// - confirm the validity of the certificate that signed the license
	// - validate the license signature
	// - validate the license expiration date
	// - validate the unique product id configured in omnistrate maps with the product your organization
	// - validate that the injected variable containing the instance-id maps with the license
	err := validator.ValidateLicense(orgID, productUniqueID)
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
	log.Printf("Starting server on :8080 without TLS...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
