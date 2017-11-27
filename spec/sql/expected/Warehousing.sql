CREATE TABLE BackOrderAllocation (
	-- Back Order Allocation involves Purchase Order Item that is part of Purchase Order that has Purchase Order ID
	PurchaseOrderItemPurchaseOrderID        BIGINT NOT NULL,
	-- Back Order Allocation involves Purchase Order Item that is for Product that has Product ID
	PurchaseOrderItemProductID              BIGINT NOT NULL,
	-- Back Order Allocation involves Sales Order Item that is part of Sales Order that has Sales Order ID
	SalesOrderItemSalesOrderID              BIGINT NOT NULL,
	-- Back Order Allocation involves Sales Order Item that is for Product that has Product ID
	SalesOrderItemProductID                 BIGINT NOT NULL,
	-- Back Order Allocation is for Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Back Order Allocation(Purchase Order Item, Sales Order Item in "Purchase Order Item is allocated to Sales Order Item")
	PRIMARY KEY(PurchaseOrderItemPurchaseOrderID, PurchaseOrderItemProductID, SalesOrderItemSalesOrderID, SalesOrderItemProductID)
);


CREATE TABLE Bin (
	-- Bin has Bin ID
	BinID                                   BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Bin contains Quantity
	Quantity                                INTEGER NOT NULL,
	-- maybe Bin contains Product that has Product ID
	ProductID                               BIGINT NULL,
	-- maybe Warehouse contains Bin and Warehouse has Warehouse ID
	WarehouseID                             BIGINT NULL,
	-- Primary index to Bin(Bin ID in "Bin has Bin ID")
	PRIMARY KEY(BinID)
);


CREATE TABLE DispatchItem (
	-- Dispatch Item has Dispatch Item ID
	DispatchItemID                          BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Dispatch Item is Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Dispatch Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- maybe Dispatch Item is for Dispatch that has Dispatch ID
	DispatchID                              BIGINT NULL,
	-- maybe Dispatch Item is for Sales Order Item that is part of Sales Order that has Sales Order ID
	SalesOrderItemSalesOrderID              BIGINT NULL,
	-- maybe Dispatch Item is for Sales Order Item that is for Product that has Product ID
	SalesOrderItemProductID                 BIGINT NULL,
	-- maybe Dispatch Item is for Transfer Request that has Transfer Request ID
	TransferRequestID                       BIGINT NULL,
	-- Primary index to Dispatch Item(Dispatch Item ID in "Dispatch Item has Dispatch Item ID")
	PRIMARY KEY(DispatchItemID)
);


CREATE TABLE Party (
	-- Party has Party ID
	PartyID                                 BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Party(Party ID in "Party has Party ID")
	PRIMARY KEY(PartyID)
);


CREATE TABLE Product (
	-- Product has Product ID
	ProductID                               BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Product(Product ID in "Product has Product ID")
	PRIMARY KEY(ProductID)
);


CREATE TABLE PurchaseOrder (
	-- Purchase Order has Purchase Order ID
	PurchaseOrderID                         BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Purchase Order is to Supplier that is a kind of Party that has Party ID
	SupplierID                              BIGINT NOT NULL,
	-- Purchase Order is to Warehouse that has Warehouse ID
	WarehouseID                             BIGINT NOT NULL,
	-- Primary index to Purchase Order(Purchase Order ID in "Purchase Order has Purchase Order ID")
	PRIMARY KEY(PurchaseOrderID),
	FOREIGN KEY (SupplierID) REFERENCES Party (PartyID)
);


CREATE TABLE PurchaseOrderItem (
	-- Purchase Order Item is part of Purchase Order that has Purchase Order ID
	PurchaseOrderID                         BIGINT NOT NULL,
	-- Purchase Order Item is for Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Purchase Order Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Purchase Order Item(Purchase Order, Product in "Purchase Order includes Purchase Order Item", "Purchase Order Item is for Product")
	PRIMARY KEY(PurchaseOrderID, ProductID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
	FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrder (PurchaseOrderID)
);


CREATE TABLE ReceivedItem (
	-- Received Item has Received Item ID
	ReceivedItemID                          BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Received Item is Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Received Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- maybe Received Item is for Purchase Order Item that is part of Purchase Order that has Purchase Order ID
	PurchaseOrderItemPurchaseOrderID        BIGINT NULL,
	-- maybe Received Item is for Purchase Order Item that is for Product that has Product ID
	PurchaseOrderItemProductID              BIGINT NULL,
	-- maybe Received Item has Receipt that has Receipt ID
	ReceiptID                               BIGINT NULL,
	-- maybe Received Item is for Transfer Request that has Transfer Request ID
	TransferRequestID                       BIGINT NULL,
	-- Primary index to Received Item(Received Item ID in "Received Item has Received Item ID")
	PRIMARY KEY(ReceivedItemID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
	FOREIGN KEY (PurchaseOrderItemPurchaseOrderID, PurchaseOrderItemProductID) REFERENCES PurchaseOrderItem (PurchaseOrderID, ProductID)
);


CREATE TABLE SalesOrder (
	-- Sales Order has Sales Order ID
	SalesOrderID                            BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Sales Order was made by Customer that is a kind of Party that has Party ID
	CustomerID                              BIGINT NOT NULL,
	-- Sales Order is from Warehouse that has Warehouse ID
	WarehouseID                             BIGINT NOT NULL,
	-- Primary index to Sales Order(Sales Order ID in "Sales Order has Sales Order ID")
	PRIMARY KEY(SalesOrderID),
	FOREIGN KEY (CustomerID) REFERENCES Party (PartyID)
);


CREATE TABLE SalesOrderItem (
	-- Sales Order Item is part of Sales Order that has Sales Order ID
	SalesOrderID                            BIGINT NOT NULL,
	-- Sales Order Item is for Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Sales Order Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Sales Order Item(Sales Order, Product in "Sales Order includes Sales Order Item", "Sales Order Item is for Product")
	PRIMARY KEY(SalesOrderID, ProductID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
	FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder (SalesOrderID)
);


CREATE TABLE TransferRequest (
	-- Transfer Request has Transfer Request ID
	TransferRequestID                       BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Transfer Request is from From Warehouse and Warehouse has Warehouse ID
	FromWarehouseID                         BIGINT NOT NULL,
	-- Transfer Request is for Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Transfer Request is for Quantity
	Quantity                                INTEGER NOT NULL,
	-- Transfer Request is to To Warehouse and Warehouse has Warehouse ID
	ToWarehouseID                           BIGINT NOT NULL,
	-- Primary index to Transfer Request(Transfer Request ID in "Transfer Request has Transfer Request ID")
	PRIMARY KEY(TransferRequestID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
);


CREATE TABLE Warehouse (
	-- Warehouse has Warehouse ID
	WarehouseID                             BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY,
	-- Primary index to Warehouse(Warehouse ID in "Warehouse has Warehouse ID")
	PRIMARY KEY(WarehouseID)
);


ALTER TABLE BackOrderAllocation
	ADD FOREIGN KEY (PurchaseOrderItemPurchaseOrderID, PurchaseOrderItemProductID) REFERENCES PurchaseOrderItem (PurchaseOrderID, ProductID);


ALTER TABLE BackOrderAllocation
	ADD FOREIGN KEY (SalesOrderItemSalesOrderID, SalesOrderItemProductID) REFERENCES SalesOrderItem (SalesOrderID, ProductID);


ALTER TABLE Bin
	ADD FOREIGN KEY (ProductID) REFERENCES Product (ProductID);


ALTER TABLE Bin
	ADD FOREIGN KEY (WarehouseID) REFERENCES Warehouse (WarehouseID);


ALTER TABLE DispatchItem
	ADD FOREIGN KEY (ProductID) REFERENCES Product (ProductID);


ALTER TABLE DispatchItem
	ADD FOREIGN KEY (SalesOrderItemSalesOrderID, SalesOrderItemProductID) REFERENCES SalesOrderItem (SalesOrderID, ProductID);


ALTER TABLE DispatchItem
	ADD FOREIGN KEY (TransferRequestID) REFERENCES TransferRequest (TransferRequestID);


ALTER TABLE PurchaseOrder
	ADD FOREIGN KEY (WarehouseID) REFERENCES Warehouse (WarehouseID);


ALTER TABLE ReceivedItem
	ADD FOREIGN KEY (TransferRequestID) REFERENCES TransferRequest (TransferRequestID);


ALTER TABLE SalesOrder
	ADD FOREIGN KEY (WarehouseID) REFERENCES Warehouse (WarehouseID);


ALTER TABLE TransferRequest
	ADD FOREIGN KEY (FromWarehouseID) REFERENCES Warehouse (WarehouseID);


ALTER TABLE TransferRequest
	ADD FOREIGN KEY (ToWarehouseID) REFERENCES Warehouse (WarehouseID);

