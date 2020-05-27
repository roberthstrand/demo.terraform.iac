variable "deployname" {
    default = "demo-terraform-iac"
}
variable "location" {
    default  = "West Europe"
}

variable tags {
	default = {
		environment = "demo"
		source      = "terraform"
	}
}