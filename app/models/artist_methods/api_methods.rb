module ArtistMethods
  module ApiMethods
    def api_attributes
      return {
        :id => id, 
        :name => name, 
        :other_names => other_names,
        :group_name => group_name,
        :urls => artist_urls.map {|x| x.url},
        :is_active => is_active,
        :version => version,
        :updater_id => updater_id
      }
    end

    def to_xml(options = {})
      attribs = api_attributes
      attribs[:urls] = attribs[:urls].join(" ")
      attribs.to_xml(options.merge(:root => "artist"))
    end

    def to_json(*args)
      return api_attributes.to_json(*args)
    end
  end
end
