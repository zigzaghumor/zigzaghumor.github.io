# zigzaghumor.github.io

[![LICENSE](https://img.shields.io/github/license/zigzaghumor/zigzaghumor.github.io?style=flat-square&logo=creative-commons&color=EF9421)](https://github.com/zigzaghumor/zigzaghumor.github.io/blob/master/LICENSE)

Source code for my personal homepage ([zhihangzhao.com](https://zhihangzhao.com)), built with Jekyll and adapted from [yaoyao-liu/yaoyaoliu-homepage](https://github.com/yaoyao-liu/yaoyaoliu-homepage) / [minimal-light](https://github.com/yaoyao-liu/minimal-light).

### Local Development with Jekyll

Install [Ruby](https://www.ruby-lang.org/en/) and [Jekyll](https://jekyllrb.com/) first, then run:

```bash
bundle install
bundle exec jekyll serve
```

Preview the site at <http://localhost:4000>. Generated static files are written to `_site/`.

### Bilingual Content

English pages are served at the root URLs (`/`, `/experience/`, `/honors/`), and Chinese pages live under `/zh/`. Shared UI strings live in `_data/i18n.yml`, while `_data/translations.yml` tracks page pairs and source hashes.

After editing English content, update the paired Chinese content and refresh the recorded hashes:

```bash
ruby scripts/check-translations.rb --update
ruby scripts/check-translations.rb
```

### Upstream Compatibility

Upstream layouts and partials (`_layouts/`, `_includes/head.html`, `_includes/topnav.html`, `_includes/hero.html`, `_includes/page-end.html`, `_includes/footer.html`, `_sass/minimal-light.scss`, `_sass/nav.scss`) track `yaoyao-liu/yaoyaoliu-homepage`. Local bilingual, SEO, dark-mode, and layout customizations are isolated under `_includes/local/` and `_sass/local-overrides.scss`.

Check for upstream updates and overlapping tracked paths:

```powershell
./scripts/check-upstream-compat.ps1 -Fetch
```

After integrating and verifying upstream updates, record the reviewed commit in `_data/upstream.yml`.

### Acknowledgements

Thanks to [Yaoyao Liu](https://github.com/yaoyao-liu) for the original Minimal Light theme and homepage template.
