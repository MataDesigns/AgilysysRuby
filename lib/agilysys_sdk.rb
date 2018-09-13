require 'agilysys_sdk/version'
require 'agilysys_sdk/api_client'
require 'agilysys_sdk/models/order'
require 'nokogiri'

module AgilysysSdk
  class AgilysysSdk 
    def initialize(url, client_id, auth_code)
      @client = AgilysysApiClient.new(url, client_id, auth_code)
    end

    def get_all_open_orders
      response = @client.call('order-list-request-Body', 'order-list-request') { |xml| xml.send("order-search-criteria","")}
      response_xml_doc = Nokogiri::XML(response.read_body)
      orders = Array.new
      response_xml_doc.xpath("//order").each do |order|
        orders.push(::AgilysysSdk::Order.new(order.attribute("order-number").text,order.attribute("table").text, order.attribute("employee-id").text))
      end
      orders
    end

    def create_order(new_order)
      response = @client.call('process-order-request-Body', 'process-order-request') { |xml| 
        xml.send("order-type","open")
        xml.send("order-header") {
          xml.send("table-name", new_order.table_name)
          xml.send("employee-id", new_order.employee_id)
          xml.send("check-type-id", 1)
        }
      }
      response_xml_doc = Nokogiri::XML(response.read_body)
      order_number = nil
      response_xml_doc.xpath("//order-number").each do |new_order_number|
        order_number = new_order_number.text
      end

      order_number
    end

    def add_item_to_order(add_order_item) 
      response = @client.call('process-order-request-Body', 'process-order-request') { |xml| 
        xml.send("order-type","open")
        xml.send("order-header") {
          xml.send("order-number", add_order_item.order_id)
          xml.send("employee-id", add_order_item.employee_id)
        }
        xml.send("order-body") {
          xml.send("item") {
            xml.send("item-id", add_order_item.item.id)
            xml.send("item-quantity", add_order_item.item.quantity)
            xml.send("item-price", add_order_item.item.price)
          }
        }
      }
      response_xml_doc = Nokogiri::XML(response.read_body)
      successful = false
      puts response_xml_doc
      response_xml_doc.xpath("//service-completion-status").each do |completion_status|
        successful = completion_status.text == "ok"
      end
      
      successful
    end

  end
end
