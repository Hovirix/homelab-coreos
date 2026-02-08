provider "sops" {}
provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
}

data "sops_file" "secrets" {
  source_file = "../secrets.yaml"
}
