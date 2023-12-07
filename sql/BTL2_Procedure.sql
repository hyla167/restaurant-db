use RESTAURANT
go

-- Thu tuc tim cac khach hang co diem tich luy 
-- it nhat minPoints, xep theo chieu tang dan
CREATE PROCEDURE GetCustomersByMinPoints
    @minPoints INT
AS
BEGIN
    SELECT
        ID,
        LName,
        FName,
        Sex,
        Birthday,
        Avatar,
        Point
    FROM
        CUSTOMER
    WHERE
        Point >= @minPoints
    ORDER BY
        Point ASC;
END;

-- Thu tuc tim cac mon an duoc danh gia it nhat n lan,
-- cung voi danh gia trung binh cua cac mon an nay
CREATE PROCEDURE GetDishesWithAverageRatingOverThreshold
    @numRatings INT
AS
BEGIN
    SELECT
        d.Dish_name,
        AVG(1.0 * r.Rating) AS AverageRating
    FROM
        DISH d
    JOIN
        REVIEW r ON d.ID = r.Dish_id
    GROUP BY
        d.ID, d.Dish_name
    HAVING
        COUNT(r.Rating) > @numRatings;
END;

-- insert CATEGORY data
INSERT INTO CATEGORY(ID, Cat_name) values (1, 'Appetizer')
INSERT INTO CATEGORY(ID, Cat_name) values (2, 'Main Dish')
INSERT INTO CATEGORY(ID, Cat_name) values (3, 'Dessert')
INSERT INTO CATEGORY(ID, Cat_name) values (4, 'Drinks')
INSERT INTO CATEGORY(ID, Cat_name) values (5, 'Complement') -- mon an kem

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

-- insert BRANCH data
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(1, 'Nha hang ABC Chi nhanh 1', '32 Hoa Mai, P.2, Q.Phu Nhuan, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(2, 'Nha hang ABC Chi nhanh 2', '120 Nguyen Dinh Chieu, P.Da Kao, Q.1, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(3, 'Nha hang ABC Chi nhanh 3', '1 Nguyen Huu Cau, P.Tan Dinh, Q.1, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(4, 'Nha hang ABC Chi nhanh 4', '74 Truong Quoc Dung, P.10, Q.Phu Nhuan, TPHCM', NULL)
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

INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(1, 'C6', 1, 1, 5, 'Mon goi cu hu dua rat ngon!', '2023-11-15 13:13:16')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(2, 'C1', 2, 3, 3, 'Mon sup hai san qua man. Can cho it muoi lai', '2023-11-18 13:24:15')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(3, 'C5', 3, 7, 4, 'Mon lau hai san an duoc, nhung ma gia dat qua :(', '2023-11-20 20:28:16')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(4, 'C5', 3, 15, 5, 'Che khuc bach ngon, se tiep tuc an lan sau', '2023-11-20 20:29:15')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(5, 'C1', 2, 1, 2, NULL, '2023-11-20 20:29:16')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(6, 'C5', 3, 1, 4, NULL, '2023-11-20 20:29:17')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(7, 'C4', 5, 1, 4, NULL, '2023-11-20 20:29:18')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(8, 'C5', 4, 1, 1, NULL, '2023-11-20 20:29:19')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(9, 'C3', 6, 1, 5, NULL, '2023-11-20 20:29:20')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(10, 'C5', 3, 3, 4, NULL, '2023-11-20 20:29:21')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(11, 'C4', 5, 3, 4, NULL, '2023-11-20 20:29:22')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(12, 'C5', 4, 3, 4, NULL, '2023-11-20 20:29:23')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(13, 'C3', 6, 3, 4, NULL, '2023-11-20 20:29:24')


EXEC GetDishesWithAverageRatingOverThreshold @numRatings = 4;
GO

-- Thu tuc tim cac chi nhanh ma co luong nhan vien trung binh
-- lon hon mot nguong nao do
CREATE PROCEDURE GetBranchesWithAverageSalaryAboveThreshold
    @salaryThreshold INT
AS
BEGIN
    SELECT
        B.ID,
        B.Branch_name,
        AVG(1.0 * S.Salary) AS AverageSalary
    FROM
        BRANCH B
    JOIN
        STAFF S ON B.ID = S.Branch_id
    GROUP BY
        B.ID, B.Branch_name
    HAVING
        AVG(1.0 * S.Salary) > @salaryThreshold
    ORDER BY
        AverageSalary DESC;
END;

-- INSERT STAFF data
-- Avg Branch 2 = 
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S1', 'Nguyen Thi', 'M', 'F', '1998-02-23', 2, NULL, 4500000, 'nguyenthim@gmail.com')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S2', 'Nguyen Thi', 'N', 'F', '1997-06-21', 2, 'S1', 4000000, 'nguyenthin@gmail.com')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S3', 'Nguyen Thi', 'P', 'F', '1996-10-10', 2, 'S1', 3500000, NULL)
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S4', 'Nguyen Thi', 'Q', 'F', '1990-01-06', 2, NULL, 7000000, NULL)
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S5', 'Nguyen Van', 'Q', 'M', '1991-04-09', 2, NULL, 2500000, NULL)

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S6', 'Nguyen Van', 'M', 'M', '1998-07-29', 3, NULL, 5000000, 'nguyenvanm@gmail.com')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S7', 'Nguyen Van', 'N', 'M', '2001-10-11', 3, 'S6', 4500000, 'nguyenvann@gmail.com')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S8', 'Nguyen Van', 'P', 'M', '2000-02-02', 3, 'S6', 4000000, NULL)
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S9', 'Nguyen Van', 'Q', 'M', '1975-05-31', 3, NULL, 8000000, NULL)
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S10', 'Nguyen Thi', 'Q', 'F', '1990-02-11', 3, NULL, 3000000, NULL)

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S11', 'Tran Van', 'M', 'M', '1995-06-06', 4, NULL, 4500000, 'tranvanm@gmail.com')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S12', 'Tran Van', 'N', 'M', '1996-08-09', 4, NULL, 5500000, 'tranvann@gmail.com')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S13', 'Tran Van', 'P', 'M', '2000-01-20', 4, 'S12', 5000000, NULL)
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S14', 'Tran Van', 'Q', 'M', '1989-03-31', 4, NULL, 9000000, NULL)
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email) values
	('S15', 'Tran Thi', 'Q', 'F', '1990-02-13', 4, NULL, 2800000, NULL)

EXEC GetBranchesWithAverageSalaryAboveThreshold @salaryThreshold = 4500000
GO

-- Thu tuc dem so luong mon an co gia tien lon hon mot nguong nao do,
-- xep theo nhom mon an
CREATE PROCEDURE GetDishCountByCategoryWithPrice
    @N INT
AS
BEGIN
    SELECT
        c.Cat_name AS Category,
        COUNT(d.ID) AS DishCount
    FROM
        CATEGORY c
    LEFT JOIN
        DISH d ON c.Cat_name = d.Category
    WHERE
        d.price >= @N OR d.price IS NULL
    GROUP BY
        c.Cat_name;
END;
