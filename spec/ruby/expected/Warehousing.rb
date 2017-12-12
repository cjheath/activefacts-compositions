require 'activefacts/api'

module Warehousing
  class ProductID < AutoCounter
    value_type
  end

  class Product
    identified_by   :product_id
    one_to_one      :product_id, mandatory: true, class: ProductID  # Product has Product ID, see ProductID#product_as_product_id
  end

  class PurchaseOrderID < AutoCounter
    value_type
  end

  class Party
    identified_by   :party_id
    one_to_one      :party_id, mandatory: true, class: "PartyID"  # Party has Party ID, see PartyID#party_as_party_id
  end

  class Supplier < Party
  end

  class WarehouseID < AutoCounter
    value_type
  end

  class Warehouse
    identified_by   :warehouse_id
    one_to_one      :warehouse_id, mandatory: true, class: WarehouseID  # Warehouse has Warehouse ID, see WarehouseID#warehouse_as_warehouse_id
  end

  class PurchaseOrder
    identified_by   :purchase_order_id
    one_to_one      :purchase_order_id, mandatory: true, class: PurchaseOrderID  # Purchase Order has Purchase Order ID, see PurchaseOrderID#purchase_order_as_purchase_order_id
    has_one         :supplier, mandatory: true          # Purchase Order is to Supplier, see Supplier#all_purchase_order
    has_one         :warehouse, mandatory: true         # Purchase Order is to Warehouse, see Warehouse#all_purchase_order
  end

  class Quantity < UnsignedInteger
    value_type      length: 32
  end

  class PurchaseOrderItem
    identified_by   :purchase_order, :product
    has_one         :purchase_order, mandatory: true    # Purchase Order Item is part of Purchase Order, see PurchaseOrder#all_purchase_order_item
    has_one         :product, mandatory: true           # Purchase Order Item is for Product, see Product#all_purchase_order_item
    has_one         :quantity, mandatory: true          # Purchase Order Item is in Quantity, see Quantity#all_purchase_order_item
  end

  class Customer < Party
  end

  class SalesOrderID < AutoCounter
    value_type
  end

  class SalesOrder
    identified_by   :sales_order_id
    one_to_one      :sales_order_id, mandatory: true, class: SalesOrderID  # Sales Order has Sales Order ID, see SalesOrderID#sales_order_as_sales_order_id
    has_one         :customer, mandatory: true          # Sales Order was made by Customer, see Customer#all_sales_order
    has_one         :warehouse, mandatory: true         # Sales Order is from Warehouse, see Warehouse#all_sales_order
  end

  class SalesOrderItem
    identified_by   :sales_order, :product
    has_one         :sales_order, mandatory: true       # Sales Order Item is part of Sales Order, see SalesOrder#all_sales_order_item
    has_one         :product, mandatory: true           # Sales Order Item is for Product, see Product#all_sales_order_item
    has_one         :quantity, mandatory: true          # Sales Order Item is in Quantity, see Quantity#all_sales_order_item
  end

  class BackOrderAllocation
    identified_by   :purchase_order_item, :sales_order_item
    has_one         :purchase_order_item, mandatory: true  # Back Order Allocation involves Purchase Order Item, see PurchaseOrderItem#all_back_order_allocation
    has_one         :sales_order_item, mandatory: true  # Back Order Allocation involves Sales Order Item, see SalesOrderItem#all_back_order_allocation
    has_one         :quantity, mandatory: true          # Back Order Allocation is for Quantity, see Quantity#all_back_order_allocation
  end

  class BinID < AutoCounter
    value_type
  end

  class Bin
    identified_by   :bin_id
    one_to_one      :bin_id, mandatory: true, class: BinID  # Bin has Bin ID, see BinID#bin_as_bin_id
    has_one         :quantity, mandatory: true          # Bin contains Quantity, see Quantity#all_bin
    has_one         :product                            # Bin contains Product, see Product#all_bin
    has_one         :warehouse                          # Warehouse contains Bin, see Warehouse#all_bin
  end

  class DispatchID < AutoCounter
    value_type
  end

  class Dispatch
    identified_by   :dispatch_id
    one_to_one      :dispatch_id, mandatory: true, class: DispatchID  # Dispatch has Dispatch ID, see DispatchID#dispatch_as_dispatch_id
  end

  class DispatchItemID < AutoCounter
    value_type
  end

  class TransferRequestID < AutoCounter
    value_type
  end

  class TransferRequest
    identified_by   :transfer_request_id
    one_to_one      :transfer_request_id, mandatory: true, class: TransferRequestID  # Transfer Request has Transfer Request ID, see TransferRequestID#transfer_request_as_transfer_request_id
    has_one         :from_warehouse, mandatory: true, class: Warehouse  # Transfer Request is from From Warehouse, see Warehouse#all_transfer_request_as_from_warehouse
    has_one         :product, mandatory: true           # Transfer Request is for Product, see Product#all_transfer_request
    has_one         :quantity, mandatory: true          # Transfer Request is for Quantity, see Quantity#all_transfer_request
    has_one         :to_warehouse, mandatory: true, class: Warehouse  # Transfer Request is to To Warehouse, see Warehouse#all_transfer_request_as_to_warehouse
  end

  class DispatchItem
    identified_by   :dispatch_item_id
    one_to_one      :dispatch_item_id, mandatory: true, class: DispatchItemID  # Dispatch Item has Dispatch Item ID, see DispatchItemID#dispatch_item_as_dispatch_item_id
    has_one         :dispatch, mandatory: true          # Dispatch Item is for Dispatch, see Dispatch#all_dispatch_item
    has_one         :product, mandatory: true           # Dispatch Item is Product, see Product#all_dispatch_item
    has_one         :quantity, mandatory: true          # Dispatch Item is in Quantity, see Quantity#all_dispatch_item
    has_one         :sales_order_item                   # Dispatch Item is for Sales Order Item, see SalesOrderItem#all_dispatch_item
    has_one         :transfer_request                   # Dispatch Item is for Transfer Request, see TransferRequest#all_dispatch_item
  end

  class PartyID < AutoCounter
    value_type
  end

  class ReceiptID < AutoCounter
    value_type
  end

  class Receipt
    identified_by   :receipt_id
    one_to_one      :receipt_id, mandatory: true, class: ReceiptID  # Receipt has Receipt ID, see ReceiptID#receipt_as_receipt_id
  end

  class ReceivedItemID < AutoCounter
    value_type
  end

  class ReceivedItem
    identified_by   :received_item_id
    one_to_one      :received_item_id, mandatory: true, class: ReceivedItemID  # Received Item has Received Item ID, see ReceivedItemID#received_item_as_received_item_id
    has_one         :product, mandatory: true           # Received Item is Product, see Product#all_received_item
    has_one         :quantity, mandatory: true          # Received Item is in Quantity, see Quantity#all_received_item
    has_one         :receipt, mandatory: true           # Received Item has Receipt, see Receipt#all_received_item
    has_one         :purchase_order_item                # Received Item is for Purchase Order Item, see PurchaseOrderItem#all_received_item
    has_one         :transfer_request                   # Received Item is for Transfer Request, see TransferRequest#all_received_item
  end
end
