#!/usr/bin/env ruby

require "digest"
require "yaml"

ROOT = File.expand_path("..", __dir__)
DATA_PATH = File.join(ROOT, "_data", "translations.yml")
UPDATE = ARGV.include?("--update")

def front_matter(path)
  content = File.read(path, encoding: "UTF-8")
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "missing front matter: #{path}" unless match

  YAML.safe_load(match[1]) || {}
end

translations = YAML.safe_load(File.read(DATA_PATH, encoding: "UTF-8"))
errors = []

translations.each do |key, entry|
  source = File.join(ROOT, entry.fetch("source"))
  target = File.join(ROOT, entry.fetch("target"))
  source_page = File.join(ROOT, entry.fetch("source_page"))
  target_page = File.join(ROOT, entry.fetch("target_page"))

  [source, target, source_page, target_page].each do |path|
    errors << "#{key}: missing #{path.delete_prefix(ROOT + File::SEPARATOR)}" unless File.file?(path)
  end
  next unless [source, target, source_page, target_page].all? { |path| File.file?(path) }

  current_hash = Digest::SHA256.file(source).hexdigest
  if UPDATE
    entry["source_hash"] = current_hash
  elsif current_hash != entry["source_hash"]
    errors << "#{key}: English source changed; review #{entry['target']} and run this script with --update"
  end

  source_meta = front_matter(source_page)
  target_meta = front_matter(target_page)
  errors << "#{key}: English translation_key mismatch" unless source_meta["translation_key"] == key
  errors << "#{key}: Chinese translation_key mismatch" unless target_meta["translation_key"] == key
  errors << "#{key}: English lang must be en" unless source_meta["lang"] == "en"
  errors << "#{key}: Chinese lang must be zh-CN" unless target_meta["lang"] == "zh-CN"
  errors << "#{key}: English permalink mismatch" unless source_meta["permalink"] == entry["en"]
  errors << "#{key}: Chinese permalink mismatch" unless target_meta["permalink"] == entry["zh-CN"]
end

if UPDATE && errors.empty?
  File.write(DATA_PATH, YAML.dump(translations), encoding: "UTF-8")
  puts "Updated translation source hashes."
elsif errors.empty?
  puts "Translation mappings and source hashes are current."
else
  warn errors.map { |error| "- #{error}" }.join("\n")
  exit 1
end
