require 'agilysys_sdk/version'
require 'agilysys_sdk/api_client'
require 'agilysys_sdk/models/order'
require 'agilysys_sdk/models/employee'
require 'nokogiri'

module AgilysysSdk
  class AgilysysSdk
    def initialize(url, client_id, auth_code)
      @client = AgilysysApiClient.new(url, client_id, auth_code)
    end

    def get_all_employees
      response = @client.call('employee-data-request-Body', 'employee-data-request')
      response_xml_doc = Nokogiri::XML(response.read_body)
      employees = []
      response_xml_doc.xpath('//employee').each do |employee|
        id = employee.xpath('.//employee-id').text
        name = employee.xpath('.//employee-name').text
        employees.push(::AgilysysSdk::Employee.new(id, name))
      end
      employees
    end

    def get_all_open_orders
      response = @client.call('order-list-request-Body', 'order-list-request') { |xml| xml.send('order-search-criteria', '') }
      response_xml_doc = Nokogiri::XML(response.read_body)
      orders = []
      response_xml_doc.xpath('//order').each do |order|
        id = order.attribute('order-number').text
        table = order.attribute('table').text
        employee_id = order.attribute('employee-id').text
        orders.push(::AgilysysSdk::Order.new(id, table, employee_id))
      end
      orders
    end

    def create_order(new_order)
      response = @client.call('process-order-request-Body', 'process-order-request') do |xml|
        xml.send('order-type', 'open')
        xml.send('order-header') do
          xml.send('table-name', new_order.table_name)
          xml.send('employee-id', new_order.employee_id)
          xml.send('check-type-id', 1)
        end
      end
      response_xml_doc = Nokogiri::XML(response.read_body)
      order_number = nil
      response_xml_doc.xpath('//order-number').each do |new_order_number|
        order_number = new_order_number.text
      end

      order_number
    end

    def add_item_to_order(add_order_item)
      response = @client.call('process-order-request-Body', 'process-order-request') do |xml|
        xml.send('order-type', 'open')
        xml.send('order-header') do
          xml.send('order-number', add_order_item.order_id)
          xml.send('employee-id', add_order_item.employee_id)
        end
        xml.send('order-body') do
          xml.send('item') do
            xml.send('item-id', add_order_item.item.id)
            xml.send('item-quantity', add_order_item.item.quantity)
            xml.send('item-price', add_order_item.item.price)
          end
        end
      end
      response_xml_doc = Nokogiri::XML(response.read_body)
      successful = false
      puts response_xml_doc
      response_xml_doc.xpath('//service-completion-status').each do |completion_status|
        successful = completion_status.text == 'ok'
      end

      successful
    end
  end
end
