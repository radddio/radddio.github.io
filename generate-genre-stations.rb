require 'json'
require 'fileutils'
require 'unidecoder'

SOURCE_DIR = "_data/genres"
TARGET_DIR = "pages/genres"
INCLUDE_NAME = "station-page.html"

Dir.entries(SOURCE_DIR).each do |genre_file|
  next unless genre_file.end_with?(".json")

  genre_slug = File.basename(genre_file, ".json")
  stations = JSON.parse(File.read("#{SOURCE_DIR}/#{genre_file}"))

  stations.each do |station|
    station_name = station["name"] || "unknown-station"

    # ➡️ Using unidecoder to generate slug
    slug = station_name.to_ascii.downcase.strip
    slug = slug.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    slug = slug[0..100] # optional limit

    station_folder = "#{TARGET_DIR}/#{genre_slug}/#{slug}"
    file_path = "#{station_folder}/index.html"

    FileUtils.mkdir_p(station_folder)

    File.open(file_path, "w") do |f|
      f.puts <<~HEREDOC
        ---
        layout: default
        title: "#{station_name.gsub('"', '\"')}"
        genre_slug: "#{genre_slug}"
        station_name: "#{station_name.gsub('"', '\"')}"
        category: "genres"
        permalink: /genres/#{genre_slug}/#{slug}/
        ---
        {% include station-page.html %}
      HEREDOC
    end

    puts "✅ Created station page: #{file_path}"
  end
end

puts "🎉 Done creating station pages without modifying JSON!"