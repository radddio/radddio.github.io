require 'json'
require 'fileutils'

SOURCE = "_data/genres-list.json"   # This now contains genre names
TARGET_DIR = "pages/genres"          # Create pages inside /pages/genres/
INCLUDE_NAME = "genre-page.html"     # Use your _includes/genre-page.html

FileUtils.mkdir_p(TARGET_DIR)

genres = JSON.parse(File.read(SOURCE))

genres.each do |genre|
  name = genre["name"] || "unknown-genre"
  slug = name.downcase.strip.gsub(/[^\w]+/, "-").gsub(/^-|-$/, "")

  folder_path = "#{TARGET_DIR}/#{slug}"
  file_path = "#{folder_path}/index.html"

  FileUtils.mkdir_p(folder_path)

  File.open(file_path, "w") do |f|
    f.puts <<~HEREDOC
      ---
      layout: default
      title: "#{genre["name"].gsub('"', '\"')}"
      genre_slug: "#{slug}"
      category: "genres"
      permalink: /genres/#{slug}/
      ---
      {% include genre-page.html %}
    HEREDOC
  end

  puts "✅ Created #{file_path}"
end

puts "🎉 Done creating #{genres.size} genre pages!"