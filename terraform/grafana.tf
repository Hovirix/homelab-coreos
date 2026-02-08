resource "authentik_provider_oauth2" "grafana" {
  name          = "Grafana"
  client_id     = data.sops_file.secrets.data["terraform.authentik.oauth.grafana.client_id"]
  client_secret = data.sops_file.secrets.data["terraform.authentik.oauth.grafana.client_secret"]

  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.signing.id

  allowed_redirect_uris = [{
    matching_mode = "strict",
    url           = "https://grafana.nemnix.site/login/generic_oauth",
  }]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.email.id,
  ]
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
}
