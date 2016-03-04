CREATE TABLE BackOrderAllocation (
	-- Back Order Allocation ID
	BackOrderAllocationID                   BIGINT IDENTITY NOT NULL,
	-- Purchase Order Item ID
	PurchaseOrderItemID                     BIGINT IDENTITY NOT NULL,
	-- Sales Order Item ID
	SalesOrderItemID                        BIGINT IDENTITY NOT NULL,
	-- Back Order Allocation is for Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Back Order Allocation
	PRIMARY KEY CLUSTERED(BackOrderAllocationID),
	-- Unique index to Back Order Allocation over PresenceConstraint over (Purchase Order Item, Sales Order Item in "Purchase Order Item is allocated to Sales Order Item") occurs at most one time
	UNIQUE NONCLUSTERED(PurchaseOrderItemID, SalesOrderItemID)
)
GO

CREATE TABLE Bin (
	-- Bin has Bin ID
	BinID                                   BIGINT NOT NULL IDENTITY,
	-- Bin contains Quantity
	Quantity                                INTEGER NOT NULL,
	-- maybe Bin contains Product that has Product ID
	ProductID                               BIGINT NULL,
	-- maybe Warehouse contains Bin and Warehouse has Warehouse ID
	WarehouseID                             BIGINT NULL,
	-- Primary index to Bin over PresenceConstraint over (Bin ID in "Bin has Bin ID") occurs at most one time
	PRIMARY KEY CLUSTERED(BinID)
)
GO

CREATE TABLE DispatchItem (
	-- Dispatch Item has Dispatch Item ID
	DispatchItemID                          BIGINT NOT NULL IDENTITY,
	-- Dispatch Item is Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Dispatch Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- maybe Dispatch Item is for Dispatch that has Dispatch ID
	DispatchID                              BIGINT NULL IDENTITY,
	-- Sales Order Item ID
	SalesOrderItemID                        BIGINT IDENTITY NOT NULL,
	-- maybe Dispatch Item is for Transfer Request that has Transfer Request ID
	TransferRequestID                       BIGINT NULL,
	-- Primary index to Dispatch Item over PresenceConstraint over (Dispatch Item ID in "Dispatch Item has Dispatch Item ID") occurs at most one time
	PRIMARY KEY CLUSTERED(DispatchItemID)
)
GO

CREATE TABLE Party (
	-- Party has Party ID
	PartyID                                 BIGINT NOT NULL IDENTITY,
	-- Primary index to Party over PresenceConstraint over (Party ID in "Party has Party ID") occurs at most one time
	PRIMARY KEY CLUSTERED(PartyID)
)
GO

CREATE TABLE Product (
	-- Product has Product ID
	ProductID                               BIGINT NOT NULL IDENTITY,
	-- Primary index to Product over PresenceConstraint over (Product ID in "Product has Product ID") occurs at most one time
	PRIMARY KEY CLUSTERED(ProductID)
)
GO

CREATE TABLE PurchaseOrder (
	-- Purchase Order has Purchase Order ID
	PurchaseOrderID                         BIGINT NOT NULL IDENTITY,
	-- Purchase Order is to Supplier that is a kind of Party that has Party ID
	SupplierID                              BIGINT NOT NULL,
	-- Purchase Order is to Warehouse that has Warehouse ID
	WarehouseID                             BIGINT NOT NULL,
	-- Primary index to Purchase Order over PresenceConstraint over (Purchase Order ID in "Purchase Order has Purchase Order ID") occurs at most one time
	PRIMARY KEY CLUSTERED(PurchaseOrderID),
	FOREIGN KEY (SupplierID) REFERENCES Party (PartyID)
)
GO

CREATE TABLE PurchaseOrderItem (
	-- Purchase Order Item ID
	PurchaseOrderItemID                     BIGINT IDENTITY NOT NULL,
	-- Purchase Order Item is part of Purchase Order that has Purchase Order ID
	PurchaseOrderID                         BIGINT NOT NULL,
	-- Purchase Order Item is for Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Purchase Order Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Purchase Order Item
	PRIMARY KEY CLUSTERED(PurchaseOrderItemID),
	-- Unique index to Purchase Order Item over PresenceConstraint over (Purchase Order, Product in "Purchase Order includes Purchase Order Item", "Purchase Order Item is for Product") occurs at most one time
	UNIQUE NONCLUSTERED(PurchaseOrderID, ProductID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
	FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrder (PurchaseOrderID)
)
GO

CREATE TABLE ReceivedItem (
	-- Received Item has Received Item ID
	ReceivedItemID                          BIGINT NOT NULL IDENTITY,
	-- Received Item is Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Received Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- Purchase Order Item ID
	PurchaseOrderItemID                     BIGINT IDENTITY NOT NULL,
	-- maybe Received Item has Receipt that has Receipt ID
	ReceiptID                               BIGINT NULL IDENTITY,
	-- maybe Received Item is for Transfer Request that has Transfer Request ID
	TransferRequestID                       BIGINT NULL,
	-- Primary index to Received Item over PresenceConstraint over (Received Item ID in "Received Item has Received Item ID") occurs at most one time
	PRIMARY KEY CLUSTERED(ReceivedItemID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
	FOREIGN KEY (PurchaseOrderItemID) REFERENCES PurchaseOrderItem (PurchaseOrderItemID)
)
GO

CREATE TABLE SalesOrder (
	-- Sales Order has Sales Order ID
	SalesOrderID                            BIGINT NOT NULL IDENTITY,
	-- Sales Order was made by Customer that is a kind of Party that has Party ID
	CustomerID                              BIGINT NOT NULL,
	-- Sales Order is from Warehouse that has Warehouse ID
	WarehouseID                             BIGINT NOT NULL,
	-- Primary index to Sales Order over PresenceConstraint over (Sales Order ID in "Sales Order has Sales Order ID") occurs at most one time
	PRIMARY KEY CLUSTERED(SalesOrderID),
	FOREIGN KEY (CustomerID) REFERENCES Party (PartyID)
)
GO

CREATE TABLE SalesOrderItem (
	-- Sales Order Item ID
	SalesOrderItemID                        BIGINT IDENTITY NOT NULL,
	-- Sales Order Item is part of Sales Order that has Sales Order ID
	SalesOrderID                            BIGINT NOT NULL,
	-- Sales Order Item is for Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Sales Order Item is in Quantity
	Quantity                                INTEGER NOT NULL,
	-- Primary index to Sales Order Item
	PRIMARY KEY CLUSTERED(SalesOrderItemID),
	-- Unique index to Sales Order Item over PresenceConstraint over (Sales Order, Product in "Sales Order includes Sales Order Item", "Sales Order Item is for Product") occurs at most one time
	UNIQUE NONCLUSTERED(SalesOrderID, ProductID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
	FOREIGN KEY (SalesOrderID) REFERENCES SalesOrder (SalesOrderID)
)
GO

CREATE TABLE TransferRequest (
	-- Transfer Request has Transfer Request ID
	TransferRequestID                       BIGINT NOT NULL IDENTITY,
	-- Transfer Request is from From Warehouse and Warehouse has Warehouse ID
	FromWarehouseID                         BIGINT NOT NULL,
	-- Transfer Request is for Product that has Product ID
	ProductID                               BIGINT NOT NULL,
	-- Transfer Request is for Quantity
	Quantity                                INTEGER NOT NULL,
	-- Transfer Request is to To Warehouse and Warehouse has Warehouse ID
	ToWarehouseID                           BIGINT NOT NULL,
	-- Primary index to Transfer Request over PresenceConstraint over (Transfer Request ID in "Transfer Request has Transfer Request ID") occurs at most one time
	PRIMARY KEY CLUSTERED(TransferRequestID),
	FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
)
GO

CREATE TABLE Warehouse (
	-- Warehouse has Warehouse ID
	WarehouseID                             BIGINT NOT NULL IDENTITY,
	-- Primary index to Warehouse over PresenceConstraint over (Warehouse ID in "Warehouse has Warehouse ID") occurs at most one time
	PRIMARY KEY CLUSTERED(WarehouseID)
)
GO

ALTER TABLE Product
	ADD FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
GO

ALTER TABLE Product
	ADD FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
GO

ALTER TABLE PurchaseOrderItem
	ADD FOREIGN KEY (PurchaseOrderItemID) REFERENCES PurchaseOrderItem (PurchaseOrderItemID)
GO

ALTER TABLE SalesOrderItem
	ADD FOREIGN KEY (SalesOrderItemID) REFERENCES SalesOrderItem (SalesOrderItemID)
GO

ALTER TABLE SalesOrderItem
	ADD FOREIGN KEY (SalesOrderItemID) REFERENCES SalesOrderItem (SalesOrderItemID)
GO

ALTER TABLE TransferRequest
	ADD FOREIGN KEY (TransferRequestID) REFERENCES TransferRequest (TransferRequestID)
GO

ALTER TABLE TransferRequest
	ADD FOREIGN KEY (TransferRequestID) REFERENCES TransferRequest (TransferRequestID)
GO

ALTER TABLE Warehouse
	ADD FOREIGN KEY (FromWarehouseID) REFERENCES Warehouse (WarehouseID)
GO

ALTER TABLE Warehouse
	ADD FOREIGN KEY (ToWarehouseID) REFERENCES Warehouse (WarehouseID)
GO

ALTER TABLE Warehouse
	ADD FOREIGN KEY (WarehouseID) REFERENCES Warehouse (WarehouseID)
GO

ALTER TABLE Warehouse
	ADD FOREIGN KEY (WarehouseID) REFERENCES Warehouse (WarehouseID)
GO

ALTER TABLE Warehouse
	ADD FOREIGN KEY (WarehouseID) REFERENCES Warehouse (WarehouseID)
GO
