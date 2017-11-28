CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

CREATE TABLE back_order_allocation (
	-- Back Order Allocation surrogate key
	back_order_allocation_id                BIGSERIAL NOT NULL,
	-- Back Order Allocation involves Purchase Order Item
	purchase_order_item_id                  BIGINT NOT NULL,
	-- Back Order Allocation involves Sales Order Item
	sales_order_item_id                     BIGINT NOT NULL,
	-- Back Order Allocation is for Quantity
	quantity                                INTEGER NOT NULL,
	-- Natural index to Back Order Allocation(Purchase Order Item, Sales Order Item in "Purchase Order Item is allocated to Sales Order Item")
	UNIQUE(purchase_order_item_id, sales_order_item_id),
	-- Primary index to Back Order Allocation
	PRIMARY KEY(back_order_allocation_id)
);


CREATE TABLE bin (
	-- Bin has Bin ID
	bin_id                                  BIGSERIAL NOT NULL,
	-- Bin contains Quantity
	quantity                                INTEGER NOT NULL,
	-- maybe Bin contains Product that has Product ID
	product_id                              BIGINT NULL,
	-- maybe Warehouse contains Bin and Warehouse has Warehouse ID
	warehouse_id                            BIGINT NULL,
	-- Primary index to Bin(Bin ID in "Bin has Bin ID")
	PRIMARY KEY(bin_id)
);


CREATE TABLE dispatch_item (
	-- Dispatch Item has Dispatch Item ID
	dispatch_item_id                        BIGSERIAL NOT NULL,
	-- Dispatch Item is Product that has Product ID
	product_id                              BIGINT NOT NULL,
	-- Dispatch Item is in Quantity
	quantity                                INTEGER NOT NULL,
	-- maybe Dispatch Item is for Dispatch that has Dispatch ID
	dispatch_id                             BIGINT NULL,
	-- maybe Dispatch Item is for Sales Order Item
	sales_order_item_id                     BIGINT NULL,
	-- maybe Dispatch Item is for Transfer Request that has Transfer Request ID
	transfer_request_id                     BIGINT NULL,
	-- Primary index to Dispatch Item(Dispatch Item ID in "Dispatch Item has Dispatch Item ID")
	PRIMARY KEY(dispatch_item_id)
);


CREATE TABLE party (
	-- Party has Party ID
	party_id                                BIGSERIAL NOT NULL,
	-- Primary index to Party(Party ID in "Party has Party ID")
	PRIMARY KEY(party_id)
);


CREATE TABLE product (
	-- Product has Product ID
	product_id                              BIGSERIAL NOT NULL,
	-- Primary index to Product(Product ID in "Product has Product ID")
	PRIMARY KEY(product_id)
);


CREATE TABLE purchase_order (
	-- Purchase Order has Purchase Order ID
	purchase_order_id                       BIGSERIAL NOT NULL,
	-- Purchase Order is to Supplier that is a kind of Party that has Party ID
	supplier_id                             BIGINT NOT NULL,
	-- Purchase Order is to Warehouse that has Warehouse ID
	warehouse_id                            BIGINT NOT NULL,
	-- Primary index to Purchase Order(Purchase Order ID in "Purchase Order has Purchase Order ID")
	PRIMARY KEY(purchase_order_id),
	FOREIGN KEY (supplier_id) REFERENCES party (party_id)
);


CREATE TABLE purchase_order_item (
	-- Purchase Order Item surrogate key
	purchase_order_item_id                  BIGSERIAL NOT NULL,
	-- Purchase Order Item is part of Purchase Order that has Purchase Order ID
	purchase_order_id                       BIGINT NOT NULL,
	-- Purchase Order Item is for Product that has Product ID
	product_id                              BIGINT NOT NULL,
	-- Purchase Order Item is in Quantity
	quantity                                INTEGER NOT NULL,
	-- Natural index to Purchase Order Item(Purchase Order, Product in "Purchase Order includes Purchase Order Item", "Purchase Order Item is for Product")
	UNIQUE(purchase_order_id, product_id),
	-- Primary index to Purchase Order Item
	PRIMARY KEY(purchase_order_item_id),
	FOREIGN KEY (product_id) REFERENCES product (product_id),
	FOREIGN KEY (purchase_order_id) REFERENCES purchase_order (purchase_order_id)
);


CREATE TABLE received_item (
	-- Received Item has Received Item ID
	received_item_id                        BIGSERIAL NOT NULL,
	-- Received Item is Product that has Product ID
	product_id                              BIGINT NOT NULL,
	-- Received Item is in Quantity
	quantity                                INTEGER NOT NULL,
	-- maybe Received Item is for Purchase Order Item
	purchase_order_item_id                  BIGINT NULL,
	-- maybe Received Item has Receipt that has Receipt ID
	receipt_id                              BIGINT NULL,
	-- maybe Received Item is for Transfer Request that has Transfer Request ID
	transfer_request_id                     BIGINT NULL,
	-- Primary index to Received Item(Received Item ID in "Received Item has Received Item ID")
	PRIMARY KEY(received_item_id),
	FOREIGN KEY (product_id) REFERENCES product (product_id),
	FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_item (purchase_order_item_id)
);


CREATE TABLE sales_order (
	-- Sales Order has Sales Order ID
	sales_order_id                          BIGSERIAL NOT NULL,
	-- Sales Order was made by Customer that is a kind of Party that has Party ID
	customer_id                             BIGINT NOT NULL,
	-- Sales Order is from Warehouse that has Warehouse ID
	warehouse_id                            BIGINT NOT NULL,
	-- Primary index to Sales Order(Sales Order ID in "Sales Order has Sales Order ID")
	PRIMARY KEY(sales_order_id),
	FOREIGN KEY (customer_id) REFERENCES party (party_id)
);


CREATE TABLE sales_order_item (
	-- Sales Order Item surrogate key
	sales_order_item_id                     BIGSERIAL NOT NULL,
	-- Sales Order Item is part of Sales Order that has Sales Order ID
	sales_order_id                          BIGINT NOT NULL,
	-- Sales Order Item is for Product that has Product ID
	product_id                              BIGINT NOT NULL,
	-- Sales Order Item is in Quantity
	quantity                                INTEGER NOT NULL,
	-- Natural index to Sales Order Item(Sales Order, Product in "Sales Order includes Sales Order Item", "Sales Order Item is for Product")
	UNIQUE(sales_order_id, product_id),
	-- Primary index to Sales Order Item
	PRIMARY KEY(sales_order_item_id),
	FOREIGN KEY (product_id) REFERENCES product (product_id),
	FOREIGN KEY (sales_order_id) REFERENCES sales_order (sales_order_id)
);


CREATE TABLE transfer_request (
	-- Transfer Request has Transfer Request ID
	transfer_request_id                     BIGSERIAL NOT NULL,
	-- Transfer Request is from From Warehouse and Warehouse has Warehouse ID
	from_warehouse_id                       BIGINT NOT NULL,
	-- Transfer Request is for Product that has Product ID
	product_id                              BIGINT NOT NULL,
	-- Transfer Request is for Quantity
	quantity                                INTEGER NOT NULL,
	-- Transfer Request is to To Warehouse and Warehouse has Warehouse ID
	to_warehouse_id                         BIGINT NOT NULL,
	-- Primary index to Transfer Request(Transfer Request ID in "Transfer Request has Transfer Request ID")
	PRIMARY KEY(transfer_request_id),
	FOREIGN KEY (product_id) REFERENCES product (product_id)
);


CREATE TABLE warehouse (
	-- Warehouse has Warehouse ID
	warehouse_id                            BIGSERIAL NOT NULL,
	-- Primary index to Warehouse(Warehouse ID in "Warehouse has Warehouse ID")
	PRIMARY KEY(warehouse_id)
);


ALTER TABLE back_order_allocation
	ADD FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_item (purchase_order_item_id);

ALTER TABLE back_order_allocation
	ADD FOREIGN KEY (sales_order_item_id) REFERENCES sales_order_item (sales_order_item_id);

ALTER TABLE bin
	ADD FOREIGN KEY (product_id) REFERENCES product (product_id);

ALTER TABLE bin
	ADD FOREIGN KEY (warehouse_id) REFERENCES warehouse (warehouse_id);

ALTER TABLE dispatch_item
	ADD FOREIGN KEY (product_id) REFERENCES product (product_id);

ALTER TABLE dispatch_item
	ADD FOREIGN KEY (sales_order_item_id) REFERENCES sales_order_item (sales_order_item_id);

ALTER TABLE dispatch_item
	ADD FOREIGN KEY (transfer_request_id) REFERENCES transfer_request (transfer_request_id);

ALTER TABLE purchase_order
	ADD FOREIGN KEY (warehouse_id) REFERENCES warehouse (warehouse_id);

ALTER TABLE received_item
	ADD FOREIGN KEY (transfer_request_id) REFERENCES transfer_request (transfer_request_id);

ALTER TABLE sales_order
	ADD FOREIGN KEY (warehouse_id) REFERENCES warehouse (warehouse_id);

ALTER TABLE transfer_request
	ADD FOREIGN KEY (from_warehouse_id) REFERENCES warehouse (warehouse_id);

ALTER TABLE transfer_request
	ADD FOREIGN KEY (to_warehouse_id) REFERENCES warehouse (warehouse_id);
