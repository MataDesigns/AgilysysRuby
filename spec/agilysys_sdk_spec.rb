RSpec.describe AgilysysSdk do
  it "has a version number" do
    expect(AgilysysSdk::VERSION).not_to be nil
  end

  # Helpers

  it "build xml without body" do
    client_id = "3213143124"
    auth_code = "secret"
    expected_text = "<item-data-request-Body><item-data-request><trans-services-header><client-id>#{client_id}</client-id><authentication-code>#{auth_code}</authentication-code></trans-services-header></item-data-request></item-data-request-Body>"
    doc = Nokogiri::XML(expected_text)
    api_client = AgilysysSdk::AgilysysApiClient.new('http://agilysysurl.com', client_id, auth_code)
    expect(api_client.build_xml('item-data-request-Body', 'item-data-request')).to eq(doc.to_xml)
  end

  it "build xml with body" do
    client_id = "CLIENT_ID"
    auth_code = "AUTH_CODE"
    expected_text = "<order-list-request-Body><order-list-request><trans-services-header><client-id>#{client_id}</client-id><authentication-code>#{auth_code}</authentication-code></trans-services-header><order-search-criteria></order-search-criteria></order-list-request></order-list-request-Body>"
    doc = Nokogiri::XML(expected_text)
    api_client = AgilysysSdk::AgilysysApiClient.new('AGILYSYS_URL', client_id, auth_code)
    xml_with_body = api_client.build_xml('order-list-request-Body', 'order-list-request') { |xml| xml.send("order-search-criteria","")}
    expect(xml_with_body).to eq(doc.to_xml)
  end

  # Orders

  it "get all orders" do
    client_id = "CLIENT_ID"
    auth_code = "AUTH_CODE"
    sdk = AgilysysSdk::AgilysysSdk.new('AGILYSYS_URL', client_id, auth_code)
    orders = sdk.get_all_open_orders()
    puts orders.first.id
  end

  it "create order" do
    client_id = "CLIENT_ID"
    auth_code = "AUTH_CODE"
    sdk = AgilysysSdk::AgilysysSdk.new('AGILYSYS_URL', client_id, auth_code)

    order = AgilysysSdk::CreateOrder.new("Tiki: 1234", 3005)
    new_order_number = sdk.create_order(order)
    puts new_order_number
  end

  it "add item to order" do
    client_id = "CLIENT_ID"
    auth_code = "AUTH_CODE"
    sdk = AgilysysSdk::AgilysysSdk.new('AGILYSYS_URL', client_id, auth_code)
    item = AgilysysSdk::OrderItem.new(101, 1, 20)
    order = AgilysysSdk::AddOrderItem.new(CLIENT_ID0011, 3005, item)
    successful = sdk.add_item_to_order(order)
    puts successful

    expect(successful).to eq(true)
  end

  # Employees

  it "get all employees" do
    client_id = "CLIENT_ID"
    auth_code = "AUTH_CODE"
    sdk = AgilysysSdk::AgilysysSdk.new('AGILYSYS_URL', client_id, auth_code)
    employees = sdk.get_all_employees
  end

end
