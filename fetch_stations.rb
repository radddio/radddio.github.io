require 'json'
require 'net/http'
require 'uri'
require 'fileutils'
require 'open-uri'
require 'countries' # requires `gem install countries`

MIRRORS = [
  "https://fi1.api.radio-browser.info",
  "https://de1.api.radio-browser.info",
  "https://de2.api.radio-browser.info",
  "https://at1.api.radio-browser.info"
]

def fetch_from_mirrors(path)
  MIRRORS.each do |base|
    begin
      url = "#{base}#{path}"
      puts "🌐 Trying #{url}"
      return URI.open(url, "Accept" => "application/json") { |res| JSON.parse(res.read) }
    rescue => e
      puts "❌ Failed on #{base}: #{e.message}"
    end
  end
  raise "All Radio Browser API mirrors failed for #{path}"
end

def save_json(path, data)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, JSON.pretty_generate(data))
  puts "✅ Saved #{data.size} items to #{path}"
end

# Resolve country name to ISO alpha-2 code
def resolve_country_code(name)
  normalized = name.downcase.sub(/^the\s+/i, "").strip

  ISO3166::Country.all.each do |country|
    official = country.data["iso_short_name"]&.downcase
    long_name = country.data["iso_long_name"]&.downcase
    alt_names = (country.data["unofficial_names"] || []).map(&:downcase)
    translated = (country.data["translations"] || {}).values.map(&:downcase)

    all_names = [official, long_name, *alt_names, *translated].compact

    return country.alpha2 if all_names.include?(normalized)
  end

  nil
end

# 1. Popular stations
popular = fetch_from_mirrors("/json/stations/topvote/5")
save_json("_data/popular-list.json", popular)

# 2. Top 5 genres by station count
tags = fetch_from_mirrors("/json/tags")
top_tags = tags
  .select { |t| t["name"].to_s.strip != "" && t["stationcount"].to_i > 0 }
  .sort_by { |t| -t["stationcount"].to_i }
  .first(10)

top_tags.each do |tag|
  name = tag["name"]
  slug = name.downcase.strip.gsub(/[^\w]/, '-')
  puts "🎧 Fetching top 5 stations for genre: #{name}"

  stations = fetch_from_mirrors("/json/stations/bytag/#{URI.encode_www_form_component(name)}?limit=5&order=vote")
  save_json("_data/genres/#{slug}.json", stations)
end

save_json("_data/genres-list.json", top_tags)

# 3. Top 5 countries by station count
countries = fetch_from_mirrors("/json/countries")
top_countries = countries
  .sort_by { |c| -c["stationcount"].to_i }
  .first(5)

top_countries.each do |country|
  radio_browser_name = country["name"]
  slug = radio_browser_name.downcase.strip.gsub(/[^\w]/, '-')

  # 1. Try full name first
  query_name = radio_browser_name
  puts "🔍 Trying country name: #{query_name}"
  stations = fetch_from_mirrors("/json/stations/bycountry/#{URI.encode_www_form_component(query_name)}?limit=5&order=vote")

  # 2. Fallback to ISO alpha-2 (with UK fix)
  if stations.empty?
    iso_code = resolve_country_code(radio_browser_name)
    if iso_code
      query_name = (iso_code == "GB") ? "UK" : iso_code
      puts "🔁 Fallback to ISO: #{query_name}"
      stations = fetch_from_mirrors("/json/stations/bycountry/#{URI.encode_www_form_component(query_name)}?limit=5&order=vote")
    end
  end

  if stations.empty?
    puts "⚠️  No stations found for #{radio_browser_name}"
  else
    save_json("_data/countries/#{slug}.json", stations)
  end
end

save_json("_data/countries-list.json", top_countries)