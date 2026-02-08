resource "authentik_provider_oauth2" "paperless" {
  name          = "paperless"
  client_id     = data.sops_file.secrets.data["terraform.authentik.oauth.paperless.client_id"]
  client_secret = data.sops_file.secrets.data["terraform.authentik.oauth.paperless.client_secret"]

  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.signing.id

  property_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.email.id,
  ]

  allowed_redirect_uris = [{
    matching_mode = "strict"
    url           = "https://paperless.nemnix.site/accounts/oidc/authentik/login/callback/"
  }]
}

resource "authentik_application" "paperless" {
  name              = "paperless"
  slug              = "paperless"
  protocol_provider = authentik_provider_oauth2.paperless.id
}
