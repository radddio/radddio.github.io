require 'json'
require 'fileutils'
require 'unidecoder'

SOURCE_DIR = "_data/countries"   # Your JSONs per country
TARGET_DIR = "pages/countries"   # Save pages here
INCLUDE_NAME = "station-page.html" # Include to render each station

Dir.entries(SOURCE_DIR).each do |country_file|
  next unless country_file.end_with?(".json")

  country_slug = File.basename(country_file, ".json")
  stations = JSON.parse(File.read("#{SOURCE_DIR}/#{country_file}"))

  stations.each do |station|
    station_name = station["name"] || "unknown-station"

    # ➡️ Generate SEO-friendly slug safely
    slug = station_name.to_ascii.downcase.strip
    slug = slug.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    slug = slug[0..100] # optional truncate to 100 characters

    station_folder = "#{TARGET_DIR}/#{country_slug}/#{slug}"
    file_path = "#{station_folder}/index.html"

    FileUtils.mkdir_p(station_folder)

    File.open(file_path, "w") do |f|
      f.puts <<~HEREDOC
        ---
        layout: default
        title: "#{station_name.gsub('"', '\"')}"
        country_slug: "#{country_slug}"
        station_name: "#{station_name.gsub('"', '\"')}"
        category: "countries"
        permalink: /countries/#{country_slug}/#{slug}/
        ---
        {% include station-page.html %}
      HEREDOC
    end

    puts "✅ Created station page: #{file_path}"
  end
end

puts "🎉 Done creating station pages for countries!"