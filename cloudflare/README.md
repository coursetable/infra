# Cloudflare infrastructure

This directory manages CourseTable's zone-level Cloudflare configuration. The first managed resource is the URL Transform Rules ruleset that serves link-preview metadata to social crawlers.

## Safety

`cloudflare_ruleset.link_preview` owns the complete `http_request_transform` phase for `coursetable.com`. Cloudflare and Terraform both require all URL Transform Rules in that phase to live in a single ruleset. **Import the existing production ruleset before running `terraform apply`.** Creating a second unmanaged resource or applying before import can conflict with the live rules.

Terraform state and credentials must not be committed. State is stored in the private `coursetable-terraform-state` R2 bucket at `cloudflare/terraform.tfstate`; Terraform's native S3 lockfile prevents concurrent writes. R2 does not support bucket versioning, which is an accepted tradeoff for this small state file.

Wrangler OAuth and the existing Pages deployment token do not grant the Rulesets permissions Terraform needs. Store a separate, narrowly scoped token in the `coursetable/prod` Doppler config as `CLOUDFLARE_TERRAFORM_API_TOKEN`.

Required token permissions:

- Zone / Zone / Read for `coursetable.com`
- Zone / Transform Rules / Edit for `coursetable.com`
- Account / Account Rulesets / Read

The R2 backend also uses a bucket-scoped Object Read & Write API token. Store its S3 credentials in the same Doppler config as:

- `CLOUDFLARE_R2_TERRAFORM_ACCESS_KEY_ID`
- `CLOUDFLARE_R2_TERRAFORM_SECRET_ACCESS_KEY`

Use the wrapper to map that Doppler secret to the environment variable expected by the provider:

```sh
./terraform.sh <terraform arguments...>
```

## Initial import

Initialize the provider:

```sh
cd cloudflare
./terraform.sh init
```

The production zone-level `http_request_transform` ruleset was imported with:

```sh
./terraform.sh import cloudflare_ruleset.link_preview \
  'zones/0daa4530d7630681dc3e3df2480981b7/1fdd71386af14cae9976493922b73eca'
```

Do not import it again when the shared state already contains the resource. Run `./terraform.sh plan` and reconcile every difference before applying. The configuration preserves the existing dashboard-created rule references so that adopting Terraform does not replace the live rules.

## Link-preview behavior

The two rules intentionally match crawler-specific user-agent tokens. Do not broaden `LinkedInBot` back to `LinkedIn`: LinkedIn's human mobile browser is also identified with a LinkedIn token and would be sent to the crawler-only page.

The rules depend on the existing `/link-preview*` forwarding Page Rule, which sends rewritten requests to `https://api.coursetable.com/api/link-preview`. That Page Rule is not yet managed here and must remain active.

Verify production behavior after any rule change:

```sh
# A human LinkedIn browser stays on the real page (expected: 200 and no redirect).
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' \
  -A 'LinkedInApp' \
  'https://coursetable.com/releases/spring26'

# LinkedIn's preview crawler still receives metadata (currently expected: 301 to the API endpoint).
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' \
  -A 'LinkedInBot/1.0 (compatible; Mozilla/5.0; +http://www.linkedin.com)' \
  'https://coursetable.com/releases/spring26'
```

Format and validate changes before review:

```sh
terraform fmt -check -recursive
terraform validate
```
