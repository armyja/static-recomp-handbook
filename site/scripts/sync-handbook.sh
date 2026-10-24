#!/usr/bin/env bash
set -euo pipefail

site_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
repo_dir=$(cd "$site_dir/.." && pwd)
source_dir="$repo_dir/docs/handbook"
content_dir="$site_dir/content/docs/handbook"

mkdir -p "$content_dir"
find "$content_dir" -type f -name '*.md' -delete

for source in "$source_dir"/[0-9][0-9]-*.md; do
  name=$(basename "$source")
  slug=${name%.md}
  public_slug=${slug#[0-9][0-9]-}
  title=$(sed -n 's/^# //p' "$source" | head -n 1)
  # Keep numeric prefixes in filenames and source Markdown for stable ordering,
  # but hide them from the public website's page titles and navigation labels.
  title=$(printf '%s' "$title" | perl -CS -pe 's/^\d{2}\s*[\x{2014}\x{2013}-]\s*//')
  target="$content_dir/$name"

  {
    printf '%s\n' '---'
    printf 'title: "%s"\n' "$title"
    printf 'url: "/docs/handbook/%s/"\n' "$public_slug"
    printf '%s\n' 'aliases:' "  - /docs/handbook/$slug/"
    printf '%s\n' 'path_base_for_github_subdir:' '  from: "^content/docs/"' '  to: "docs/"'
    printf '%s\n' 'type: docs' '---' ''
    sed '1{/^# /d;}' "$source"
  } > "$target"

  for other in "$source_dir"/[0-9][0-9]-*.md; do
    other_name=$(basename "$other")
    other_slug=${other_name%.md}
    other_public_slug=${other_slug#[0-9][0-9]-}
    perl -pi -e "s#\\]\\(${other_name}\\)#](/docs/handbook/${other_public_slug}/)#g" "$target"
  done
  perl -pi -e 's#\]\(symptom-index\.tsv\)#](/symptom-index.tsv)#g' "$target"
done

cp "$source_dir/symptom-index.tsv" "$site_dir/static/symptom-index.tsv"
printf 'synced handbook: %s pages\n' "$(find "$content_dir" -type f -name '*.md' | wc -l | tr -d ' ')"
