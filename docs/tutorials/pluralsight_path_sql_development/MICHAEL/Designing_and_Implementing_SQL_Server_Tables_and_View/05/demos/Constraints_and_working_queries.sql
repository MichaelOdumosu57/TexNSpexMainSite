USE BobsShoes;
GO

-- Remove any existing tables

DROP TABLE IF EXISTS Orders.CityState,Orders.OrderItems, Orders.Orders, Orders.Stock, Orders.Customers, Orders.Salutations;

-- Define a check constraint on the Salutation column
DROP TABLE IF EXISTS Orders.Salutations;
CREATE TABLE Orders.Salutations (
    SalutationID int IDENTITY(1,1) NOT NULL                             -- PRIMARY KEY -- system-generated name
        CONSTRAINT PK_Salutations_SalutationID PRIMARY KEY CLUSTERED,
    Salutation varchar(5) NOT NULL                                      -- UNIQUE -- system-generated name
        CONSTRAINT UQ_Salutations_Salutation UNIQUE NONCLUSTERED
        CONSTRAINT CK_Salutations_Salutation_must_not_be_empty CHECK (Salutation <> '')
)


-- Define the same check constraint, but let SQL Server assign a name.
DROP TABLE IF EXISTS Orders.Salutations;
CREATE TABLE Orders.Salutations (
    SalutationID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Salutations_SalutationID PRIMARY KEY CLUSTERED,
    Salutation varchar(5) NOT NULL CHECK (Salutation <> '')
        CONSTRAINT UQ_Salutations_Salutation UNIQUE NONCLUSTERED
)





CREATE TABLE Orders.CityState(
    CityStateId int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_CityState_CityStateId PRIMARY KEY,
    CityStateCity nvarchar(200) NOT NULL,
    CityStateProv nvarchar(100) NOT NULL,
    CityStateCountry nvarchar(100) NOT NULL
        CONSTRAINT CK_Customers_Country_must_be_US_UK_or_CA 
            CHECK (CityStateCountry IN ('US', 'UK', 'CA')),    
    CityStatePostalCode nvarchar(20) NOT NULL,
    CityStateStreet nvarchar(300) NOT NULL,
);

-- Add constraint restricting customer's country
DROP TABLE IF EXISTS Orders.Customers
CREATE TABLE Orders.Customers (
    CustID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Customers_CustID PRIMARY KEY,
    CustName nvarchar(200) NOT NULL,

    CityStateId int NOT NULL
        CONSTRAINT FK_Customers_CityStateId_CityState_CityStateId 
            REFERENCES Orders.CityState (CityStateId)
    ,
    SalutationID int NOT NULL 
        CONSTRAINT FK_Customers_SaluationID_Salutations_SalutationID 
            REFERENCES Orders.Salutations (SalutationID)
    );

-- Define a table constraint
DROP TABLE IF EXISTS Orders.Stock;
CREATE TABLE Orders.Stock (
    StockID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Stock_StockID PRIMARY KEY CLUSTERED,    
    StockSKU char(8) NOT NULL,
    StockSize varchar(10) NOT NULL,
    StockName varchar(100) NOT NULL,
    StockPrice numeric(7, 2) NOT NULL,
    CONSTRAINT UQ_Stock_StockSKU_StockSize UNIQUE NONCLUSTERED (StockSKU, StockSize),
    CONSTRAINT CK_Stock_SKU_cannot_equal_Description CHECK (StockSKU <> StockName )
);




-- Create a user function to check dates
GO
CREATE OR ALTER FUNCTION Orders.CheckDates 
    (@OrderDate date, @RequestedDate date)
    RETURNS BIT
    AS BEGIN
        RETURN (IIF(@RequestedDate > @OrderDate, 1, 0))
    END
GO

-- Define a table constraint to use the function
DROP TABLE IF EXISTS Orders.Orders;
CREATE TABLE Orders.Orders (  
    OrderID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Orders_OrderID PRIMARY KEY,
    OrderDate date NOT NULL,
    OrderRequestedDate date NOT NULL,
    OrderDeliveryDate datetime2(0) NULL,
    CustID int NOT NULL
        CONSTRAINT FK_Orders_CustID_Customers_CustID 
            FOREIGN KEY REFERENCES Orders.Customers (CustID),
    OrderIsExpedited bit NOT NULL,
    CONSTRAINT CK_Orders_RequestedDate_must_follow_OrderDate
        CHECK (1 = Orders.CheckDates(OrderDate, OrderRequestedDate))
 );



 -- Validate the table against the check constraint
 ALTER TABLE Orders.Orders 
    WITH CHECK CHECK CONSTRAINT 
        CK_Orders_RequestedDate_must_follow_OrderDate;

CREATE TABLE Orders.OrderItems (
    OrderItemID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_OrderItems_OrderItemID PRIMARY KEY,
    OrderID int NOT NULL --,
        CONSTRAINT FK_OrderItems_OrderID_Orders_OrderID
            FOREIGN KEY REFERENCES Orders.Orders (OrderID),
    StockID int NOT NULL --,
        CONSTRAINT FK_OrderItems_StockID_Stock_StockID
            FOREIGN KEY REFERENCES Orders.Stock (StockID),
    Quantity smallint NOT NULL,
    Discount numeric(4, 2) NOT NULL
);




-- Populate the tables

INSERT INTO Orders.Salutations (Salutation)
VALUES ('Mr.'), ('Miss'), ('Mrs.');

INSERT INTO Orders.CityState (
    CityStateStreet,
    CityStateCity,
    CityStateProv,
    CityStateCountry,
    CityStatePostalCode
)
VALUES 
    ( '1 Main St', 'Golgafrincham', 'GuideShire', 'UK', '1MSGGS'),
    ( '42 Cricket St.', 'Islington', 'Greater London', 'UK', '42CSIGL');

INSERT INTO Orders.Customers (
        CustName, 
        CityStateId,
        SalutationID)
VALUES 
    ('Arthur Dent',  1,1),
    ('Trillian Astra', 2, 2);

INSERT INTO Orders.Stock (
        StockSKU, 
        StockName, 
        StockSize, 
        StockPrice)

VALUES
    ('OXFORD01', 'Oxford', '10_D', 50.),
    ('BABYSHO1', 'BabySneakers', '3', 20.),
    ('HEELS001', 'Killer Heels', '7', 75.);

INSERT INTO Orders.Orders(
    OrderDate, 
    OrderRequestedDate, 
    CustID, 
    OrderIsExpedited)

VALUES 
    ('20190301', '20190401', 1, 0),
    ('20190301', '20190401', 2, 0);

INSERT INTO Orders.OrderItems(
    OrderID, 
    StockID,
    Quantity, 
    Discount)

VALUES
    (1, 1, 1, 20.),
    (2, 3, 1, 20.);

SELECT * FROM Orders.Salutations;
SELECT * FROM Orders.Customers;
SELECT * FROM Orders.Stock
SELECT * FROM Orders.Orders;
SELECT * FROM Orders.OrderItems;

RETURN;

-- Can't insert an order item with a non-existent orderid

INSERT INTO Orders.OrderItems(
    OrderID, 
    StockID,
    Quantity, 
    Discount)
VALUES (42,42,42,42.)