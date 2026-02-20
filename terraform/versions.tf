terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.1"
    }
  }
}
