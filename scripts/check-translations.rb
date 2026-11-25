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

def check_parity(en_data, zh_data, errors)
  if en_data.dig("skills", "groups")&.length != zh_data.dig("skills", "groups")&.length
    errors << "content parity: skills.groups count mismatch between en and zh"
  end
  if en_data.dig("education", "entries")&.length != zh_data.dig("education", "entries")&.length
    errors << "content parity: education.entries count mismatch between en and zh"
  end
  en_companies = en_data.dig("experience", "companies") || []
  zh_companies = zh_data.dig("experience", "companies") || []
  if en_companies.length != zh_companies.length
    errors << "content parity: experience.companies count mismatch between en and zh"
  else
    en_companies.zip(zh_companies).each_with_index do |(ec, zc), idx|
      er = ec["roles"] || []
      zr = zc["roles"] || []
      if er.length != zr.length
        errors << "content parity: experience.companies[#{idx}].roles count mismatch"
        next
      end
      er.zip(zr).each_with_index do |(r1, r2), ridx|
        if (r1["bullets"] || []).length != (r2["bullets"] || []).length
          errors << "content parity: experience.companies[#{idx}].roles[#{ridx}].bullets count mismatch"
        end
      end
    end
  end
  if en_data.dig("honors", "items")&.length != zh_data.dig("honors", "items")&.length
    errors << "content parity: honors.items count mismatch between en and zh"
  end
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

  normalized_source = File.binread(source).gsub("\r\n", "\n")
  current_hash = Digest::SHA256.hexdigest(normalized_source)
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

en_content_path = File.join(ROOT, "_data", "content_en.yml")
zh_content_path = File.join(ROOT, "_data", "content_zh.yml")
if File.file?(en_content_path) && File.file?(zh_content_path)
  en_data = YAML.safe_load(File.read(en_content_path, encoding: "UTF-8"))
  zh_data = YAML.safe_load(File.read(zh_content_path, encoding: "UTF-8"))
  check_parity(en_data, zh_data, errors)
end

if UPDATE && errors.empty?
  File.write(DATA_PATH, YAML.dump(translations), encoding: "UTF-8")
  puts "Updated translation source hashes."
elsif errors.empty?
  puts "Translation mappings, structural parity, and source hashes are current."
else
  warn errors.map { |error| "- #{error}" }.join("\n")
  exit 1
end
