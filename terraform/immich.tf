resource "authentik_provider_oauth2" "immich" {
  name          = "immich"
  client_id     = data.sops_file.secrets.data["terraform.authentik.oauth.immich.client_id"]
  client_secret = data.sops_file.secrets.data["terraform.authentik.oauth.immich.client_secret"]

  authorization_flow = data.authentik_flow.default_authorization.id
  invalidation_flow  = data.authentik_flow.default_invalidation.id
  signing_key        = data.authentik_certificate_key_pair.signing.id

  property_mappings = [
    data.authentik_property_mapping_provider_scope.openid.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.email.id,
  ]

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "app.immich:///oauth-callback"
    },
    {
      matching_mode = "strict"
      url           = "https://immich.nemnix.site/auth/login"
    },
    {
      matching_mode = "strict"
      url           = "https://immich.nemnix.site/user-settings"
    }
  ]
}

resource "authentik_application" "immich" {
  name              = "immich"
  slug              = "immich"
  protocol_provider = authentik_provider_oauth2.immich.id
}
