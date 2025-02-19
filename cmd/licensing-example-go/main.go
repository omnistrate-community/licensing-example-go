package main

import (
	"fmt"
	"net/http"

	"github.com/omnistrate-oss/omnistrate-licensing-sdk-go/pkg/validator"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// Validate license key for product
	// err := validator.ValidateLicenseForProduct("PRODUCT-DEV-SKU")
	// Using options to make it work with pre prod environment
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
	http.ListenAndServe(":8080", nil)
}
