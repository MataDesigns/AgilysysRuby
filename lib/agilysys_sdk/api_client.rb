require 'uri'
require 'net/http'

module AgilysysSdk
    class AgilysysApiClient
      # Your code goes here...
      def initialize(url, client_id, auth_code)
        @url = url
        @client_id = client_id
        @auth_code = auth_code
        url = URI(url)
        @http = Net::HTTP.new(url.host, url.port)
      end
  
      def build_xml(body_tag, request_tag, &body_block)
        xml = Nokogiri::XML::Builder.new do |xml|
          xml.send(body_tag){
            xml.send(request_tag) {
              xml.send(:'trans-services-header') {
                xml.send(:'client-id', @client_id)
                xml.send(:'authentication-code', @auth_code)
              }
              if body_block
                body_block.call(xml)
              end
            }
          }
        end
        xml.to_xml
      end
  
      def call(body_tag, request_tag, &xml_body) 
        request = Net::HTTP::Post.new(@url)
        request["content-type"] = 'application/xml'
        request.body = build_xml(body_tag, request_tag) {|xml| xml_body.call(xml)}
        puts "Body: #{request.body}"
        @http.request(request)
      end
    end
end