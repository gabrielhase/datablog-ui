require 'json'

# MAIN ENTRY
if __FILE__ == $PROGRAM_NAME

  paths = {}

  File.open('world.geojson') do |file|
    world = JSON.parse(file.read())
    countries = File.readlines('europe.list')
    countries.each do |country|
      country.sub!("\n", "")
    end
    world['features'].each do |feature|
      isCountry = false
      geometry = nil
      country = nil
      feature['properties'].each do |key, value|
        if key == 'ADMIN'
          if countries.index(value)
            isCountry = true
          end
        end
        if key == 'SOVEREIGNT'
          if idx = countries.index(value)
            geometry = feature["geometry"]
            country = countries[idx]
          end
        end
      end

      if isCountry && country && geometry
        paths[country] = geometry
      end

    end
  end

  File.open('europe.geojson', 'w') do |output|
    output.puts '{"type": "FeatureCollection","features":['

    paths.each_with_index do |(country, geometry), index|
      if index == paths.count - 1
        separator = ''
      else
        separator = ','
      end
      output.puts "{\"type\":\"Feature\",\"properties\":{\"SOVEREIGNT\":\"#{country}\"},\"geometry\":#{geometry.to_json}}#{separator}"
    end
    output.puts("]}")
  end
end
