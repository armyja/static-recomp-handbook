# Static Recompilation Handbook site

This directory is the Hugo/OINK presentation layer for the root Markdown handbook.
The canonical content lives in `../docs/handbook/`; the build synchronizes it into
`content/docs/handbook/` before Hugo renders the site.

## Local preview

Requirements: Hugo Extended 0.168.0 or newer and Go 1.27 or newer.

```bash
./scripts/sync-handbook.sh
hugo server
```

Or use the Makefile, which synchronizes the handbook automatically:

```bash
make serve
make build
```

## Cloudflare Pages

The repository-level workflow at `.github/workflows/cloudflare-pages.yaml` builds
this directory and deploys `site/public` with Wrangler. Configure the Cloudflare
account and API token secrets, then set `CLOUDFLARE_PAGES_ENABLED=true` for
automatic deployment on pushes to `main`.
