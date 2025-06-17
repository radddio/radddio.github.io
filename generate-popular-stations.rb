require 'json'
require 'fileutils'

# CONFIGURATION
SOURCE = "_data/popular-list.json"         # path to your popular stations JSON
TARGET_DIR = "pages/popular-stations"      # where to create station folders
INCLUDE_NAME = "station-page.html"          # your station component

# Ensure the target folder exists
FileUtils.mkdir_p(TARGET_DIR)

# Load the list of stations
stations = JSON.parse(File.read(SOURCE))

stations.each do |station|
  name = station["name"] || "unknown-station"
  slug = name.downcase.strip.gsub(/[^\w]+/, "-").gsub(/^-|-$/, "") # clean slug

  folder_path = "#{TARGET_DIR}/#{slug}"
  file_path = "#{folder_path}/index.html"   # ⚡ Save as index.html

  # Create folder
  FileUtils.mkdir_p(folder_path)

  # Write the HTML page
  File.open(file_path, "w") do |f|
    f.puts <<~HEREDOC
      ---
      layout: default
      title: "#{station["name"].gsub('"', '\"')}"
      station_slug: "#{slug}"
      category: "popular"
      permalink: /popular/#{slug}/
      ---
      {% include #{INCLUDE_NAME} %}
    HEREDOC
  end

  puts "✅ Created #{file_path}"
end

puts "🎉 Done creating #{stations.size} station pages in /pages/popular-stations/"