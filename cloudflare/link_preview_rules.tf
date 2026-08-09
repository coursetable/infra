locals {
  link_preview_bot_expression = "((http.user_agent contains \"facebook\") or (http.user_agent contains \"LinkedInBot\") or (http.user_agent contains \"Twitter\") or (http.user_agent contains \"pinterest\") or (http.user_agent contains \"discord\") or (http.user_agent contains \"bing\") or (http.user_agent contains \"WhatsApp\") or (http.user_agent contains \"Slack\") or (http.user_agent contains \"vercel edge functions\"))"
}

# This resource owns the entire zone-level http_request_transform phase. Import
# the existing production ruleset before planning or applying; see README.md.
resource "cloudflare_ruleset" "link_preview" {
  zone_id     = var.cloudflare_zone_id
  name        = "default"
  description = ""
  kind        = "zone"
  phase       = "http_request_transform"

  rules = [
    {
      # Preserve the existing dashboard-created reference to avoid replacing
      # the live rule during the initial Terraform adoption.
      ref         = "19b1d0a623394809867af715f580d6f3"
      description = "Serve link preview card (courses)"
      expression  = "${local.link_preview_bot_expression} and ((http.request.uri.query contains \"course-modal=\") or (http.request.uri.query contains \"ws=\")) and ((http.request.uri.path eq \"/catalog\") or (http.request.uri.path eq \"/worksheet\"))"
      action      = "rewrite"
      enabled     = true
      action_parameters = {
        uri = {
          path = {
            value = "/link-preview"
          }
        }
      }
    },
    {
      # Preserve the existing dashboard-created reference to avoid replacing
      # the live rule during the initial Terraform adoption.
      ref         = "a504a04e707f417eb476b2147db33e39"
      description = "Serve link preview card (pages)"
      expression  = "${local.link_preview_bot_expression} and starts_with(http.request.uri.path, \"/releases/\")"
      action      = "rewrite"
      enabled     = true
      action_parameters = {
        uri = {
          path = {
            value = "/link-preview"
          }
          query = {
            expression = "concat(\"url=\", http.request.uri.path)"
          }
        }
      }
    },
  ]

  lifecycle {
    prevent_destroy = true
  }
}
