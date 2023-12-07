use RESTAURANT
GO

-- insert BRANCH data
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(1, 'Nha hang ABC Chi nhanh 1', '32 Hoa Mai, P.2, Q.Phu Nhuan, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(2, 'Nha hang ABC Chi nhanh 2', '120 Nguyen Dinh Chieu, P.Da Kao, Q.1, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(3, 'Nha hang ABC Chi nhanh 3', '1 Nguyen Huu Cau, P.Tan Dinh, Q.1, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(4, 'Nha hang ABC Chi nhanh 4', '74 Truong Quoc Dung, P.10, Q.Phu Nhuan, TPHCM', NULL)

-- INSERT STAFF data
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S1', 'Nguyen Thi', 'M', 'F', '1998-02-23', 2, NULL, 4500000, 'nguyenthim@gmail.com', '2022-02-10')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S2', 'Nguyen Thi', 'N', 'F', '1997-06-21', 2, 'S1', 4000000, 'nguyenthin@gmail.com', '2021-11-30')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S3', 'Nguyen Thi', 'P', 'F', '1996-10-10', 2, 'S1', 3500000, NULL, '2020-01-02')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S4', 'Nguyen Thi', 'Q', 'F', '1990-01-06', 2, NULL, 7000000, NULL, '2019-03-03')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S5', 'Nguyen Van', 'Q', 'M', '1991-04-09', 2, NULL, 2500000, NULL, '2018-04-13')

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S6', 'Nguyen Van', 'M', 'M', '1998-07-29', 3, NULL, 5000000, 'nguyenvanm@gmail.com', '2018-05-03')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S7', 'Nguyen Van', 'N', 'M', '2001-10-11', 3, 'S6', 4500000, 'nguyenvann@gmail.com', '2017-02-23')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S8', 'Nguyen Van', 'P', 'M', '2000-02-02', 3, 'S6', 4000000, NULL, '2017-03-23')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S9', 'Nguyen Van', 'Q', 'M', '1975-05-31', 3, NULL, 8000000, NULL, '2020-10-10')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S10', 'Nguyen Thi', 'Q', 'F', '1990-02-11', 3, NULL, 3000000, NULL, '2019-07-10')

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S11', 'Tran Van', 'M', 'M', '1995-06-06', 4, NULL, 4500000, 'tranvanm@gmail.com', '2016-11-11')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S12', 'Tran Van', 'N', 'M', '1996-08-09', 4, NULL, 5500000, 'tranvann@gmail.com', '2020-11-10')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S13', 'Tran Van', 'P', 'M', '2000-01-20', 4, 'S12', 5000000, NULL, '2023-01-03')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S14', 'Tran Van', 'Q', 'M', '1989-03-31', 4, NULL, 9000000, NULL, '2022-04-05')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S15', 'Tran Thi', 'Q', 'F', '1990-02-13', 4, NULL, 2800000, NULL, '2023-11-01')
GO

CREATE FUNCTION CalculateStaffBonus
    (@staffID varchar(8))
RETURNS INT
AS
BEGIN
    DECLARE @bonus int;
    DECLARE @baseSalary int;
    DECLARE @bonusPercentage DECIMAL(5, 2);
    DECLARE @eligibleYears INT;

    -- Check if the staff ID is valid
    IF NOT EXISTS (SELECT 1 FROM STAFF WHERE ID = @staffID)
    BEGIN
        RETURN NULL; -- Invalid staff ID
    END;

    -- Initialize variables
    SET @bonus = 0;
    SET @bonusPercentage = 0.05; -- 5% bonus
    SET @eligibleYears = 2; -- Minimum years of service for bonus eligibility

    -- Retrieve the base salary and start date for the employee
    SELECT @baseSalary = Salary,
           @eligibleYears = DATEDIFF(YEAR, Start_Day, GETDATE())
    FROM STAFF
    WHERE ID = @staffID;

    -- Validate the years of service
    IF @eligibleYears < 2
    BEGIN
        SET @bonusPercentage = 0; -- No bonus for less than the minimum eligible years
    END
    ELSE
    BEGIN
        -- Calculate additional bonus for each extra year of service
        DECLARE @extraYears INT;
        SET @extraYears = @eligibleYears - 2;

        WHILE @extraYears > 0
        BEGIN
            SET @bonusPercentage = @bonusPercentage + 0.02; -- 2% additional bonus for each extra year
            SET @extraYears = @extraYears - 1;
        END;
    END;

    -- Calculate the bonus
    SET @bonus = @baseSalary * @bonusPercentage;

    RETURN @bonus;
END;

-- Execute the function
DECLARE @bonus int;
SET @bonus = dbo.CalculateStaffBonus('S3');

-- Display the result
IF @bonus IS NOT NULL
    PRINT 'Bonus for Staff ' + 'S3' + ': ' + CAST(@bonus AS VARCHAR);
ELSE
    PRINT 'Invalid Staff ID';
GO

CREATE FUNCTION CalculateOrderTotalBillWithVoucher
    (@orderID INT)
RETURNS INT
AS
BEGIN
    DECLARE @totalBill INT;


    -- Check if the order ID is valid
    IF NOT EXISTS (SELECT 1 FROM [CUS_ORDER] WHERE ID = @orderID)
    BEGIN
        RETURN NULL; -- Invalid order ID
    END;

    -- Initialize variables
    SET @totalBill = 0;

    -- Calculate the total bill for the order
    SELECT @totalBill = SUM(oi.Amount * d.Price)
    FROM OrderItem oi
    JOIN Dish d ON oi.Dish_id = d.ID
    WHERE oi.Order_id = @orderID;

    -- Apply voucher discount if available
    DECLARE @voucherOrderDiscount DECIMAL(5, 2);
	DECLARE @voucherCatDiscount DECIMAL(5, 2);
    DECLARE @customerIDFromOrder varchar(8);

    -- Get the Customer_id from the ORDER
    SELECT @customerIDFromOrder = Customer_id
    FROM [CUS_ORDER]
    WHERE ID = @orderID;

    -- Check for VOUCHER_ORDER
	
    SELECT @voucherOrderDiscount = v.Percent_Discount
    FROM APPLY_VOUCHER av
    JOIN VOUCHER v ON av.Voucher_id = v.ID
    JOIN VOUCHER_ORDER vo ON v.ID = vo.ID
    WHERE av.Order_id = @orderID AND v.Customer_id = @customerIDFromOrder;

    IF @voucherOrderDiscount IS NOT NULL
    BEGIN
        SET @totalBill = @totalBill - (@totalBill * (@voucherOrderDiscount / 100.0));
    END;

    -- Check for VOUCHER_CAT
    SELECT @voucherCatDiscount = v.Percent_Discount
    FROM APPLY_VOUCHER av
    JOIN VOUCHER v ON av.Voucher_id = v.ID
    JOIN VOUCHER_CAT vc ON v.ID = vc.ID
    JOIN Dish d ON vc.Category_id = d.Category_id
    JOIN OrderItem oi ON oi.Dish_id = d.ID
    WHERE av.Order_id = @orderID AND v.Customer_id = @customerIDFromOrder;

    IF @voucherCatDiscount IS NOT NULL
    BEGIN
        SET @totalBill = @totalBill - (@totalBill * (@voucherCatDiscount / 100.0));
    END;
	
    RETURN @totalBill;
END;

-- insert CUSTOMER data
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Point) values
	('C1', 'Nguyen Van', 'A', 'M', '1999-04-25', 0)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Point) values
	('C2', 'Nguyen Thi', 'A', 'F', '1998-08-21', 20)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Point) values
	('C3', 'Nguyen Van', 'A', 'M', '1997-11-01', 47)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Point) values
	('C4', 'Nguyen Van', 'B', 'M', '1992-12-13', 10)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Point) values
	('C5', 'Tran Thi', 'B', 'F', '2000-03-03', 60)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Point) values
	('C6', 'Dang Van', 'C', 'M', '2004-05-05', 25)

-- insert CUS_ORDER data
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(1, 1, 'C6', 400000, 360000, 'Da thanh toan')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(2, 2, 'C1', 500000, NULL, 'Chua thanh toan')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(3, 3, 'C5', 1200000, NULL, 'Da thanh toan')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(4, 4, 'C5', 1500000, 1200000, 'Da thanh toan')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(5, 1, 'C4', 650000, NULL, 'Chua thanh toan')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(6, 2, 'C3', 1000000, NULL, 'Da thanh toan')

-- insert VOUCHER data
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(1, 'C1', 50, 10, '2024-01-01')
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(2, 'C3', 75, 15, '2024-02-01')
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(3, 'C5', 100, 20, '2024-03-01')
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(4, 'C1', 25, 5, '2024-01-01')
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(5, 'C4', 75, 15, '2024-02-01')
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(6, 'C6', 50, 10, '2024-03-01')
INSERT INTO VOUCHER(ID, Customer_id, Point, Percent_discount, Date_expired) values
	(7, 'C6', 50, 10, '2024-02-01')

-- insert VOUCHER_ORDER data
INSERT INTO VOUCHER_ORDER(ID) values (1)
INSERT INTO VOUCHER_ORDER(ID) values (3)
INSERT INTO VOUCHER_ORDER(ID) values (5)
INSERT INTO VOUCHER_ORDER(ID) values (7)

-- insert CATEGORY data
INSERT INTO CATEGORY(ID, Cat_name) values (1, 'Appetizer')
INSERT INTO CATEGORY(ID, Cat_name) values (2, 'Main Dish')
INSERT INTO CATEGORY(ID, Cat_name) values (3, 'Dessert')
INSERT INTO CATEGORY(ID, Cat_name) values (4, 'Drinks')
INSERT INTO CATEGORY(ID, Cat_name) values (5, 'Complement') -- mon an kem

-- insert VOUCHER_CAT data
INSERT INTO VOUCHER_CAT(ID, Category_id) values (2, 1) -- Appetizer
INSERT INTO VOUCHER_CAT(ID, Category_id) values (4, 2) -- Main Dish
INSERT INTO VOUCHER_CAT(ID, Category_id) values (6, 3) -- Drinks
GO

CREATE TRIGGER CalculateSubTotalOnInsert
ON OrderItem
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate the SubTotal based on the amount and price of the Dish
    UPDATE OrderItem
    SET SubTotal = i.Amount * (SELECT Price FROM DISH WHERE ID = i.Dish_id)
    FROM inserted i
    WHERE OrderItem.Order_id = i.Order_id AND OrderItem.Dish_id = i.Dish_id;
END;
GO

-- insert DISH data
-- Appetizer
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (1, 'Goi cu hu dua', 'Appetizer', 1, NULL, 60000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (2, 'Goi ngo sen tom thit', 'Appetizer', 1, NULL, 50000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (3, 'Sup hai san', 'Appetizer', 1, NULL, 50000)
-- Main dish
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (4, 'Muc hap hanh gung', 'Main Dish', 2, NULL, 65000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (5, 'Hau nuong mo hanh', 'Main Dish', 2, NULL, 40000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (6, 'Suon heo sot chua ngot', 'Main Dish', 2, NULL, 50000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (7, 'Lau hai san', 'Main Dish', 2, NULL, 150000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (8, 'Ga hap la chanh', 'Main Dish', 2, NULL, 70000)
-- Drinks
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (9, 'Nuoc cam', 'Drinks', 4, NULL, 55000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (10, 'Nuoc chanh', 'Drinks', 4, NULL, 39000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (11, 'Coca', 'Drinks', 4, NULL, 25000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (12, 'Bia', 'Drinks', 4, NULL, 30000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (13, 'Dasani', 'Drinks', 4, NULL, 25000)
-- Dessert
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (14, 'Trai cay thap cam', 'Dessert', 3, NULL, 70000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (15, 'Che khuc banh', 'Dessert', 3, NULL, 40000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (16, 'Panna Cotta', 'Dessert', 3, NULL, 50000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (17, 'Kem (Vani/Chocolate)', 'Dessert', 3, NULL, 45000)
-- Complement
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (18, 'Bun tuoi', 'Complement', 5, NULL, 10000)
INSERT INTO DISH(ID, Dish_name, Category, Category_id, Dish_des, Price)
	values (19, 'Kim chi', 'Complement', 5, NULL, 10000)

-- INSERT ORDER_ITEM data
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 1, 2, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 4, 3, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 9, 1, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 14, 1, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (2, 2, 2, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (2, 5, 1, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (2, 10, 3, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (2, 15, 1, NULL)

-- Test CalculateSubTotalOnInsert trigger
SELECT * FROM OrderItem
GO

-- INSERT APPLY_VOUCHER data
SELECT * FROM OrderItem
SELECT * FROM VOUCHER
SELECT * FROM CUS_ORDER
INSERT INTO APPLY_VOUCHER(Voucher_id, Order_id) values (7, 1)
INSERT INTO APPLY_VOUCHER(Voucher_id, Order_id) values (3, 4)

DECLARE @totalBill int;
SET @totalBill = dbo.CalculateOrderTotalBillWithVoucher(1); -- orderID = 1

-- Display the result
IF @totalBill IS NOT NULL
    PRINT 'Total Bill (After discount) for Order ' + '1' + ': ' + CAST(@totalBill AS VARCHAR);
ELSE
    PRINT 'Invalid Order ID';

CREATE FUNCTION CalculateBonusSalaryForManager
    (@managerUsername NVARCHAR(50), @eligibleYears INT, @bonusPercentage DECIMAL(5, 2))
RETURNS TABLE
AS
RETURN
(
    SELECT
        s.ID AS StaffID,
        s.LName,
        s.FName,
        s.Salary,
        s.Birthday,
        CASE
            WHEN DATEDIFF(YEAR, s.Birthday, GETDATE()) >= @eligibleYears THEN
                FLOOR(s.Salary * (1 + @bonusPercentage / 100) + (DATEDIFF(YEAR, s.Birthday, GETDATE()) - @eligibleYears) * (s.Salary * 0.02))
            ELSE
                FLOOR(s.Salary)
        END AS BonusSalary
    FROM
        STAFF s
    WHERE
        s.Mgr_id = (SELECT ID FROM STAFF_ACCOUNT WHERE username = @managerUsername)
);