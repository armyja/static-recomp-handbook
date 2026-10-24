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

## Cloudflare deployment

The current Cloudflare dashboard may present this as a Worker with Static Assets
rather than a separate Pages project. Keep the deploy command as:

```text
npx wrangler deploy
```

`wrangler.jsonc` maps the generated `public/` directory to the Worker assets.
The repository-level workflow at `.github/workflows/cloudflare-pages.yaml` is an
alternative Pages API path for accounts that still expose Pages projects.

Cloudflare's standard Hugo binary does not include the Extended SCSS compiler.
The Pages build command therefore downloads the pinned Extended binary through
`scripts/hugo-extended.sh` before rendering the site.
