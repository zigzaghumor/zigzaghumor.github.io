#!/usr/bin/env ruby

ROOT = File.expand_path("..", __dir__)
SITE = File.join(ROOT, "_site")

pages = {
  "index.html" => ["en", "https://zhihangzhao.com/"],
  "experience/index.html" => ["en", "https://zhihangzhao.com/experience/"],
  "honors/index.html" => ["en", "https://zhihangzhao.com/honors/"],
  "zh/index.html" => ["zh-CN", "https://zhihangzhao.com/zh/"],
  "zh/experience/index.html" => ["zh-CN", "https://zhihangzhao.com/zh/experience/"],
  "zh/honors/index.html" => ["zh-CN", "https://zhihangzhao.com/zh/honors/"]
}

errors = []
pages.each do |relative_path, (lang, canonical)|
  path = File.join(SITE, relative_path)
  unless File.file?(path)
    errors << "missing generated page: #{relative_path}"
    next
  end

  html = File.read(path, encoding: "UTF-8")
  errors << "#{relative_path}: incorrect html lang" unless html.include?(%(<html lang="#{lang}">))
  errors << "#{relative_path}: incorrect canonical" unless html.include?(%(rel="canonical" href="#{canonical}"))
  %w[en zh-CN x-default].each do |hreflang|
    errors << "#{relative_path}: missing hreflang #{hreflang}" unless html.include?(%(hreflang="#{hreflang}"))
  end
  errors << "#{relative_path}: missing accessible language switch" unless html.include?("language-link") && html.include?("hreflang=")
end

%w[index.html zh/index.html].each do |relative_path|
  path = File.join(SITE, relative_path)
  next unless File.file?(path)

  html = File.read(path, encoding: "UTF-8")
  errors << "#{relative_path}: missing Contact section" unless html.include?(%(<div class="contact-panel" id="contact" role="region"))
end

if errors.empty?
  puts "Validated six localized pages, Contact sections, canonical URLs, and hreflang links."
else
  warn errors.map { |error| "- #{error}" }.join("\n")
  exit 1
end
