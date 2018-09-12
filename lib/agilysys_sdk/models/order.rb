module AgilysysSdk

    class OrderItem
        attr_accessor :id, :quantity, :price
        def initialize(id, quantity, price)
            @id = id
            @quantity = quantity
            @price = price
        end
    end

    class AddOrderItem
        attr_accessor :order_id, :employee_id, :item
        def initialize(order_id, employee_id, item)
            @order_id = order_id
            @employee_id = employee_id
            @item = item
        end
    end

    class CreateOrder
        attr_accessor :table_name, :employee_id, :guest_count
        def initialize(table_name, employee_id, guest_count)
            @table_name = table_name
            @employee_id = employee_id
            @guest_count = guest_count
        end
    end

    class Order
        attr_accessor :id, :table_name, :employee_id
        def initialize(id, table_name, employee_id)
            @id = id
            @table_name = table_name
            @employee_id = employee_id
        end
    end
end