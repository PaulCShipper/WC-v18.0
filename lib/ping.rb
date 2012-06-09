module Danbooru
  # ping the given URL to see if it's there.  returns false if not there
  def http_ping(source, options = {})

      url = URI.parse(source)

      headers = {
        "User-Agent" => "#{CONFIG["app_name"]}/#{CONFIG["version"]}"
      }
 
      if source =~ /pixiv\.net/
        headers["Referer"] = "http://www.pixiv.net"
      end
   
      touch = Net::HTTP.start(url.host, url.port)
      result = touch.get2(url.request_uri, headers)
      touch.finish
      result.code
  end

  module_function :http_ping
end
