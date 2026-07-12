# zigzaghumor.github.io

[![LICENSE](https://img.shields.io/github/license/zigzaghumor/zigzaghumor.github.io?style=flat-square&logo=creative-commons&color=EF9421)](https://github.com/zigzaghumor/zigzaghumor.github.io/blob/master/LICENSE)

This is the source code of my homepage. 

Based on this theme: <https://github.com/yaoyao-liu/minimal-light>.

### Using Locally with Jekyll

You need to install [Ruby](https://www.ruby-lang.org/en/) and [Jekyll](https://jekyllrb.com/) fisrt.

Install and run:

```bash
bundle install
bundle exec jekyll server
```
View the live page using `localhost`:
<http://localhost:4000>. You can get the html files in the `_site` folder.

Huge thanks to [Yaoyao Liu](https://github.com/yaoyao-liu)

### Bilingual content

English pages keep the root URLs. Chinese pages use `/zh/`. Shared labels live in `_data/i18n.yml`, and `_data/translations.yml` maps corresponding pages.

After changing English content, review the paired Chinese content and refresh its recorded source hash:

```bash
ruby scripts/check-translations.rb --update
ruby scripts/check-translations.rb
```

### Upstream compatibility

Theme-level additions are isolated under `_includes/local/` and `_sass/local-overrides.scss`. `_data/upstream.yml` records the reviewed upstream baseline and tracked theme paths.

Check for new upstream changes and identify overlapping files:

```powershell
./scripts/check-upstream-compat.ps1 -Fetch
```

After integrating and validating upstream changes, update the baseline commit in `_data/upstream.yml`.
