require 'json'
require 'fileutils'

SOURCE = "_data/countries-list.json"   # JSON with country names
TARGET_DIR = "pages/countries"
INCLUDE_NAME = "country-page.html"

FileUtils.mkdir_p(TARGET_DIR)

countries = JSON.parse(File.read(SOURCE))

countries.each do |country|
  name = country["name"] || "unknown-country"
  slug = name.downcase.strip.gsub(/[^\w]+/, "-").gsub(/^-|-$/, "")

  folder_path = "#{TARGET_DIR}/#{slug}"
  file_path = "#{folder_path}/index.html"

  FileUtils.mkdir_p(folder_path)

  File.open(file_path, "w") do |f|
    f.puts <<~HEREDOC
      ---
      layout: default
      title: "#{country["name"].gsub('"', '\"')}"
      country_slug: "#{slug}"
      category: "countries"
      permalink: /countries/#{slug}/
      ---
      {% include country-page.html %}
    HEREDOC
  end

  puts "✅ Created #{file_path}"
end

puts "🎉 Done creating #{countries.size} country pages!"