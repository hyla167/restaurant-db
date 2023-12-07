use master
if exists(select * from sysdatabases where name='RESTAURANT')
begin
	drop database [RESTAURANT];
end;

-- create database
create database RESTAURANT;
go
-- use (i.e. change to current) database
use RESTAURANT
go

-- create tables
create table CATEGORY
	(
		ID	int		PRIMARY KEY,
		Cat_name	nvarchar(20)	NOT NULL UNIQUE
	)

create table DISH 
	(
		ID	int	PRIMARY KEY,
		Dish_name	nvarchar(50)	NOT NULL,
		Category	nvarchar(20)	NOT NULL,
		Dish_des	nvarchar(300)	NULL,
		Price	int	NOT NULL,
		Rating decimal(3,2) NOT NULL,
		Num_review int NOT NULL,
		Img	varchar(256) NOT NULL,
		CONSTRAINT Check_Dish CHECK (Price > 0 AND PRICE % 1000 = 0 AND Num_review >= 0
			AND Rating >= 0 AND Rating <= 5),
		FOREIGN KEY (Category) REFERENCES CATEGORY(Cat_name)
	)

create table INGREDIENT
	(
		ID	int	PRIMARY KEY,
		Ing_name	nvarchar(20)	NOT NULL, -- Ten nguyen lieu
		Unit	varchar(20)	NOT NULL, -- Don vi tinh
		Price	int	NOT NULL, -- Don gia nguyen lieu theo unit
		CONSTRAINT CHECK_INGREDIENT_PRICE CHECK (Price > 0)
	)

create table RECIPE 
	(
		Dish_id	int	NOT NULL, -- Ma mon an
		Step	int	NOT NULL, -- Buoc che bien
		Ing_id	int	NULL, -- Ma nguyen lieu
		Amount	real	NULL, -- Luong nguyen lieu su dung
		Step_des	nvarchar(50) NULL, -- Huong dan che bien (neu co)
		CONSTRAINT Check_Recipe CHECK ((Ing_id IS NULL AND Amount IS NULL) 
			OR (Ing_id IS NOT NULL AND Amount IS NOT NULL AND Amount > 0)),
		PRIMARY KEY (Dish_id, Step),
		FOREIGN KEY (Ing_id) REFERENCES INGREDIENT(ID)
	)

create table SUPPLIER 
	(
		ID	int	PRIMARY KEY,
		Sup_name	nvarchar(30)	NOT NULL,
		ContactPerson	varchar(20)	NULL,
		ContactNumber	char(10)	NULL,
		Email	varchar(30)	NOT NULL
	)

create table BRANCH
	(
		ID	int	PRIMARY KEY,
		Branch_name	nvarchar(30)	NOT NULL,
		Branch_add	nvarchar(70)	NOT NULL,
		Branch_des	varchar(50)	NULL
	)

create table INVENTORY 
	(
		ID	int	PRIMARY KEY,
		Branch_id	int NOT NULL,
		Ing_id	int	NOT NULL,
		Amount	real	NOT NULL,
		Unit	varchar(20)	NOT NULL,
		DateRecorded	smalldatetime,
		CONSTRAINT Check_Inventory CHECK (Amount >= 0),
		FOREIGN KEY (Ing_id) REFERENCES INGREDIENT(ID),
		FOREIGN KEY (Branch_id) REFERENCES BRANCH(ID)
	)

create table SUPPLY_ORDER
	(
		ID	int	PRIMARY KEY,
		Supplier_id	int	NOT NULL,
		Branch_id int	NOT NULL,
		Date_order	date	NOT NULL,
		Date_deliver	date	NULL,
		Total	int	NULL,
		CONSTRAINT Check_Supply_Order CHECK (Date_deliver >= Date_order AND Total > 0),
		FOREIGN KEY (Supplier_id) REFERENCES SUPPLIER(ID),
		FOREIGN KEY (Branch_id) REFERENCES BRANCH(ID)
	)

create table B_TABLE
	(
		ID	int	NOT NULL,
		Branch_id	int	NOT NULL,
		T_status	nvarchar(20)	NOT NULL,
		Num_seats	int	NOT	NULL,
		T_location	nvarchar(10) NULL,
		PRIMARY KEY (ID, Branch_id),
		CONSTRAINT Check_Table CHECK (
			(T_status = N'Đã đặt' OR T_status = N'Đang sử dụng' OR T_status = N'Trống')
			AND Num_seats >= 2
		),
		FOREIGN KEY (Branch_id) REFERENCES BRANCH(ID)
	)
	
create table CUSTOMER
	(
		ID	varchar(8)	PRIMARY KEY,
		-- Lname la ho va ten lot, co the NULL
		LName	nvarchar(20)	NOT NULL,
		FName	nvarchar(10)	NOT NULL,
		Sex	char(1)	NOT NULL,
		Birthday	date	NOT NULL,
		Avatar varchar(300) NOT NULL,
		Point	int	NOT NULL,
		CONSTRAINT Check_Customer CHECK ((Sex ='M' OR Sex = 'F') AND Point >= 0 AND (year(CURRENT_TIMESTAMP) - year(Birthday) >= 18))
	)

create table RESERVATION
	(
		Reserve_time smalldatetime	PRIMARY KEY,
		Table_id	int	NOT NULL,
		Branch_id	int	NOT NULL,
		Customer_id	varchar(8)	NOT NULL,
		Num_guests	int	NOT NULL,
		R_status	nvarchar(20)	NOT NULL,
		Start_time	smalldatetime	NOT NULL,
		CONSTRAINT Check_Reservation CHECK ((Num_guests >= 1) AND (Start_time > Reserve_time)
			AND (R_status = N'Đang chờ duyệt' OR R_status = N'Đã duyệt' OR R_status = N'Đã hủy')),
		FOREIGN KEY (Table_id, Branch_id) REFERENCES B_TABLE(ID, Branch_id),
		FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(ID) ON DELETE CASCADE,
		-- FOREIGN KEY (Branch_id) REFERENCES BRANCH(ID)
	)

create table WAITLIST
	(
		ID	int	PRIMARY KEY,
		Customer_id	varchar(8) NOT NULL,
		Num_guests	int	NOT NULL,
		DateRecorded	smalldatetime	NOT NULL,
		Wait_time	int	NULL,
		CONSTRAINT Check_Waitlist CHECK (Num_guests > 0 AND Wait_time >= 0),
		FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(ID) ON DELETE CASCADE
	)

create table CUS_ORDER
	(
		ID	int	PRIMARY KEY,
		Branch_id int	NOT NULL,
		Customer_id	varchar(8)	NOT NULL,
		Original_price	int	NOT NULL,
		Discounted_price	int NULL,
		Order_status	nvarchar(20)	NOT NULL,
		CONSTRAINT Check_Cus_Order CHECK (Original_price > 0 AND (Discounted_price IS NULL OR 
		(Discounted_price < Original_price AND Discounted_price > 0)) AND (Order_status = N'Đã thanh toán' OR Order_status = N'Chưa thanh toán')),
		FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(ID) ON DELETE CASCADE,
		FOREIGN KEY (Branch_id) REFERENCES BRANCH(ID)
	)

create table VOUCHER
	(
		ID	int	PRIMARY KEY,
		Customer_id	varchar(8)	NOT NULL,
		Point	int	NOT NULL,
		Percent_discount	int	NOT NULL,
		Date_expired	date	NOT NULL,
		CONSTRAINT Check_Voucher CHECK (Point > 0 AND Percent_discount >= 5 AND Percent_discount <= 20
			AND NOT (Date_expired < DATEADD(month, -1, GETDATE()))),
		FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(ID) ON DELETE CASCADE
	)

create table VOUCHER_ORDER
	(
		ID int PRIMARY KEY
		FOREIGN KEY (ID) REFERENCES VOUCHER(ID) ON DELETE CASCADE
	)

create table VOUCHER_CAT 
	(
		ID int PRIMARY KEY,
		Category_id	int NOT NULL
		FOREIGN KEY (ID) REFERENCES VOUCHER(ID) ON DELETE CASCADE,
		FOREIGN KEY (Category_id) REFERENCES CATEGORY(ID)
	)

create table REVIEW 
	(
		ID	int	PRIMARY KEY,
		Customer_id varchar(8)	NOT NULL,
		Order_id	int	NOT NULL,
		Dish_id	int	NOT NULL,
		Rating	int	NOT NULL,
		Content	nvarchar(50)	NOT NULL,
		DateRecorded smalldatetime	NOT NULL,
		CONSTRAINT Check_Review CHECK (Rating >= 1 AND Rating <= 5),
		FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(ID) ON DELETE CASCADE,
		FOREIGN KEY (Order_id) REFERENCES CUS_ORDER(ID),
		FOREIGN KEY (Dish_id) REFERENCES DISH(ID)
	)

create table STAFF 
	(
		ID	varchar(8) PRIMARY KEY,
		LName	nvarchar(20)	NOT NULL,
		FName	nvarchar(10) NOT NULL,
		Sex	char(1)	NOT NULL,
		Birthday	date	NOT NULL,
		Branch_id	int	NOT NULL,
		Mgr_id	varchar(8)	NULL,
		Salary	int		NOT NULL, 
		Email varchar(30)	NULL,
		Start_Day date	NOT NULL,
		CONSTRAINT Check_Staff CHECK ((Sex ='M' OR Sex = 'F')
			AND (year(CURRENT_TIMESTAMP) - year(Birthday) >= 18) AND Salary > 0 AND Salary % 1000 = 0),
		FOREIGN KEY (Branch_id)	REFERENCES BRANCH(ID),
		FOREIGN KEY (Mgr_id) REFERENCES STAFF(ID)
	)

create table SCHEDULE
	(
		ID	int	PRIMARY KEY,
		Staff_id	varchar(8)	NOT NULL,
		Date_time	date	NOT NULL,
		Start_hour	int	NOT NULL,
		End_hour	int	NOT NULL,
		CONSTRAINT Check_Schedule CHECK ((End_hour > Start_hour) AND (End_hour - Start_hour <= 10)),
		FOREIGN KEY (Staff_id) REFERENCES STAFF(ID)
	)

create table CUSTOMER_PHONE
	(
		Customer_id	varchar(8)	NOT NULL,
		Phone	int	NOT NULL
		PRIMARY KEY (Customer_id, Phone)
		FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(ID) ON DELETE CASCADE
	)

create table STAFF_PHONE 
	(
		Staff_id	varchar(8)	NOT NULL,
		Phone	int	NOT NULL

		FOREIGN KEY (Staff_id) REFERENCES STAFF(ID)
	)

create table STAFF_ACCOUNT 
	(
		ID varchar(8) PRIMARY KEY,
		Username	varchar(20)	NOT NULL,
		Pass	varchar(20)	NOT NULL,
		CONSTRAINT Check_Staff_Account CHECK (Pass like '%[0-9]%' and Pass like '%[a-zA-Z]%' and
			Pass like '%[!@#$%a^&*()-_+=.,;:"`~]%' AND len(pass) >= 8),
		FOREIGN KEY (ID) REFERENCES STAFF(ID)
	)

create table CUSTOMER_ACCOUNT 
	(
		ID varchar(8) PRIMARY KEY,
		Username	varchar(20)	NOT NULL,
		Pass	varchar(20)	NOT NULL,
		CONSTRAINT Check_Customer_Account CHECK (Pass like '%[0-9]%' and Pass like '%[a-zA-Z]%' and
			Pass like '%[!@#$%a^&*()-_+=.,;:"`~]%' AND len(pass) >= 8),
		FOREIGN KEY (ID) REFERENCES CUSTOMER(ID) ON DELETE CASCADE
	)

-- create relationship tables

create table ING_IN_BRANCH
	(
		Branch_id	int		NOT NULL,
		Ing_id	int		NOT NULL,
		Amount	real	NOT NULL,
		CONSTRAINT CHECK_INGREDIENT_AMOUNT CHECK (Amount > 0),
		PRIMARY KEY (Branch_id, Ing_id),
		FOREIGN KEY (Branch_id) REFERENCES BRANCH(ID),
		FOREIGN KEY (Ing_id) REFERENCES INGREDIENT(ID)
	)

create table EAT_WITH
	(
		Dish_id_1	int NOT NULL,
		Dish_id_2	int NOT NULL
		PRIMARY KEY (Dish_id_1, Dish_id_2)
		FOREIGN KEY (Dish_id_1) REFERENCES DISH(ID),
		FOREIGN KEY (Dish_id_2) REFERENCES DISH(ID)
	)

create table DISH_ING 
	(
		Dish_id	int	NOT NULL,
		Ing_id	int	NOT NULL
		PRIMARY KEY (Dish_id, Ing_id)
		FOREIGN KEY (Dish_id) REFERENCES DISH(ID),
		FOREIGN KEY (Ing_id) REFERENCES INGREDIENT(ID)
	)

create table SUPPLIES
	(
		Sup_order_id	int	NOT NULL,
		Ing_id	int	NOT NULL,
		Amount	int	NOT NULL
		PRIMARY KEY (Sup_order_id, Ing_id),
		CONSTRAINT Check_Supplies CHECK (Amount > 0),
		FOREIGN KEY (Sup_order_id) REFERENCES SUPPLY_ORDER(ID),
		FOREIGN KEY (Ing_id) REFERENCES INGREDIENT(ID)
	)

create table OrderItem
	(
		Order_id	int	NOT NULL,
		Dish_id	int	NOT NULL, 
		Amount int	NOT NULL, -- Amount here means "Number of dishes"
		SubTotal	int	NULL
		PRIMARY KEY (Order_id, Dish_id),
		CONSTRAINT Check_OrderItem CHECK (Amount > 0),
		FOREIGN KEY (Order_id) REFERENCES CUS_ORDER(ID),
		FOREIGN KEY (Dish_id) REFERENCES DISH(ID)
	)
/*
ALTER TABLE SUPPLY_ORDER
ADD CONSTRAINT CheckTotalAmount
CHECK (Total >= (
    SELECT SUM(Dish.Price * OrderItem.Amount)
    FROM OrderItem
    INNER JOIN Dish ON OrderItem.Dish_id = Dish.ID
    WHERE OrderItem.Order_Id = SUPPLY_ORDER.ID
));
*/
create table APPLY_VOUCHER
	(
		Voucher_id	int PRIMARY KEY,
		Order_id	int	NOT NULL
		FOREIGN KEY (Voucher_id) REFERENCES VOUCHER(ID),
		FOREIGN KEY (Order_id) REFERENCES CUS_ORDER(ID)
	)

create table CHEF 
	(
		ID	varchar(8) PRIMARY KEY
		FOREIGN KEY (ID) REFERENCES STAFF(ID)
	)

create table WAITER
	(
		ID	varchar(8) PRIMARY KEY
		FOREIGN KEY (ID) REFERENCES STAFF(ID)
	)

create table SHIPPER
	(
		ID	varchar(8) PRIMARY KEY
		FOREIGN KEY (ID) REFERENCES STAFF(ID)
	)

-- Don hang tai cho
create table TABLE_ORDER 
	(
		Order_id int	PRIMARY KEY,
		Branch_id int NOT NULL,
		Table_id	int	NOT NULL,
		FOREIGN KEY (Table_id, Branch_id) REFERENCES B_TABLE(ID, Branch_id),
		FOREIGN KEY (Order_id) REFERENCES CUS_ORDER(ID)
	)

-- Don hang mang ve
create table ONLINE_ORDER
	(
		Order_id int	PRIMARY KEY,
		Shipper_id	varchar(8)	NOT NULL,
		Order_add nvarchar(150) NOT NULL,
		Start_time	smalldatetime	NOT NULL,
		End_time	smalldatetime	NULL
		FOREIGN KEY (Order_id) REFERENCES CUS_ORDER(ID),
		FOREIGN KEY (Shipper_id) REFERENCES SHIPPER(ID),
		CONSTRAINT Check_Online_Order CHECK (End_time > Start_time)
	)
GO
-- Create a function to check the time constraint
/*
CREATE FUNCTION dbo.CheckOrderTimeConstraint (
    @OrderId INT,
    @Start_Time smalldatetime,
    @End_Time smalldatetime
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;

    -- Check if there is any overlapping time with existing orders
    SELECT @Result = CASE
        WHEN EXISTS (
            SELECT 1
            FROM ONLINE_ORDER
            WHERE Order_id = @OrderId
              AND ((Start_Time <= @Start_Time AND @Start_Time < End_Time)
                OR (Start_Time < @End_Time AND @End_Time <= End_Time))
        ) THEN 0
        ELSE 1
    END;

    RETURN @Result;
END;
GO

-- Add a CHECK constraint using the function
ALTER TABLE ONLINE_ORDER
ADD CONSTRAINT CHK_OrderTimeConstraint
CHECK (dbo.CheckOrderTimeConstraint(Order_id, Start_time, End_time) = 1);
*/

-- insert CATEGORY data
INSERT INTO CATEGORY(ID, Cat_name) values (1, N'Khai vị')
INSERT INTO CATEGORY(ID, Cat_name) values (2, N'Món chính')
INSERT INTO CATEGORY(ID, Cat_name) values (3, N'Tráng miệng')
INSERT INTO CATEGORY(ID, Cat_name) values (4, N'Thức uống')
INSERT INTO CATEGORY(ID, Cat_name) values (5, N'Món ăn kèm') 
INSERT INTO CATEGORY(ID, Cat_name) values (6, N'Món chay')

-- insert DISH data
-- Appetizer
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (1, N'Gỏi củ hủ dừa', N'Khai vị', N'Đây là món đặc sản mà người dân thường dùng để đãi khách quý. Củ hũ dừa là phần trên của cây dừa, nằm sâu trong thân, bao gồm chồi non chưa nhú ra bên ngoài và cuống lá. Vì vậy để lấy củ hũ phải chặt cả cây dừa. Gỏi củ hũ dừa có vị chua ngọt vừa ăn, mát, giòn, thơm và lại thanh đạm, ít béo', 60000, 4.25, 26, 'https://cdn.tgdd.vn/Files/2021/11/15/1398044/chieu-dai-ca-nha-voi-mon-goi-cu-hu-dua-tom-thit-dam-vi-mien-tay-202111151144117180.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (2, N'Gỏi ngó sen tôm thịt', N'Khai vị', N'Gỏi ngó sen tôm thịt là món gỏi phổ biến trong các bữa tiệc, được nhiều người yêu thích bởi hương vị thanh ngọt của tôm, thịt, giòn giòn chua chua của rau củ', 50000, 4.02, 34, 'https://cdn.tgdd.vn/Files/2018/04/26/1084621/cach-lam-goi-ngo-sen-tom-thit-gion-ngon-202205281123151148.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (3, N'Súp hải sản', N'Khai vị', N'Súp hải sản là món khai vị được rất nhiều người lựa chọn cho những buổi tiệc lớn nhỏ khác nhau. Một tô súp là sự kết hợp của nhiều nguyên liệu như các loại hải sản gồm tôm, mực cùng trứng, nấm, bắp…', 50000, 4.53, 102, 'https://cdn.tgdd.vn/Files/2020/02/07/1234859/cach-nau-sup-hai-san-thom-ngon-bo-duong-cho-ca-gia-dinh-202203151808152700.jpg')
-- Main dish
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (4, N'Mực hấp hành gừng', N'Món chính', N'Mực hấp gừng là món ăn yêu thích của nhiều tín đồ của hải sản. Vị mực ngọt tự nhiên xen lẫn với mùi gừng thơm nồng chắc chắn sẽ cuốn hút bạn ngay từ lần đầu thưởng thức.', 65000, 3.97, 47, 'https://cdn.tgdd.vn/Files/2019/10/04/1204819/cach-lam-muc-hap-gung-ngon-com-am-bung-ngay-mua-202209082237265886.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (5, N'Hàu nướng mỡ hành', N'Món chính', N'Hàu sữa nướng mỡ hành là một món ăn ngon được kết hợp bởi vị ngọt, mềm, béo của thịt hàu và vị thơm béo ngậy của sốt mỡ hành. Món ăn được chế biến theo công thức riêng biệt bởi đội ngũ đầu bếp chuyên nghiệp với hơn 10 năm kinh nghiệm', 40000, 4.24, 31, 'https://cdn.tgdd.vn/Files/2018/12/20/1139386/cong-thuc-cach-lam-hau-nuong-mo-hanh-bang-lo-vi-song-cuc-ngon-7-760x367.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (6, N'Sườn heo sốt chua ngọt', N'Món chính', NULL, 50000, 3.52, 12, 'https://cdn.tgdd.vn/Files/2017/03/24/964475/suon-xao-chua-ngot-ngon-bat-bai-dam-bao-het-sach-com-trong-tich-tac-202110271045485869.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (7, N'Lẩu hải sản', N'Món chính', N'Lẩu hải sản luôn là một món ăn mang lại cho bạn cảm giác lạ miệng bởi trong hải sản chứa nhiều chất đạm, canxi giàu bổ dưỡng.', 150000, 4.67, 92, 'https://cdn.tgdd.vn/Files/2021/02/25/1330480/tong-hop-3-cach-nau-lau-hai-san-thom-ngon-tai-nha-202103121351124334.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (8, N'Gà hấp lá chanh', N'Món chính', N'Gà hấp lá chanh là món ăn quen thuộc với người Việt Nam chúng ta, thịt gà săn chắc, có màu vàng ươm, dậy mùi thơm của lá chanh, gà và lá chanh hòa quyện vào nhau. Hòa quyện lại tạo nên một hương vị khiến ai đã ăn rồi cũng phải lưu luyến.', 70000, 4.32, 56, 'https://cdn.tgdd.vn/Files/2020/05/25/1258229/cach-lam-ga-hap-la-chanh-thom-ngon-vang-uom-tai-nh-6-760x367.jpg')
-- Drinks
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (9, N'Nước cam', N'Thức uống', N'Nước cam không chỉ có hương vị tuyệt vời mà còn chứa nhiều chất dinh dưỡng tốt cho sức khỏe', 55000, 4.23, 35, 'https://cdn.tgdd.vn/Files/2018/11/27/1134029/cong-dung-cua-nuoc-cam-tuoi-va-cach-bao-quan-nuoc-cam-tot-nhat-6.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (10, N'Nước chanh', N'Thức uống', N'Nước chanh tươi là một món đồ uống giải khát, thanh nhiệt quen thuộc với mọi người. Nước chanh chứa nhiều dưỡng chất tốt cho sức khỏe giúp giảm cân, làm đẹp da, giúp hỗ trợ tiêu hóa, bổ sung vitamin C,…', 39000, 4.56, 48, 'https://media.baobinhphuoc.com.vn/upload/news/5_2023/img_8476_06413001052023.jpeg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (11, N'Coca', N'Thức uống', NULL, 25000, 4.78, 6, 'https://www.coca-cola.com/content/dam/onexp/vn/home-image/coca-cola/Coca-Cola_OT%20320ml_VN-EX_Desktop.png/width1960.png')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (12, N'Bia', N'Thức uống', NULL, 30000, 4.53, 10, 'https://product.hstatic.net/200000264775/product/tiger_c8e92828562346e2bd927bfef3533507_1024x1024.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (13, N'Dasani', N'Thức uống', NULL, 25000, 4.32, 7, 'https://bizweb.dktcdn.net/thumb/1024x1024/100/446/647/products/nuoc-dasani-500ml-rth534yff.jpg?v=1679481131690')
-- Dessert
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (14, N'Trái cây thập cẩm', N'Tráng miệng', N'Trái cây có rất nhiều chất dinh dưỡng, chất xơ và các vitamin nên nó sẽ giúp bạn khỏe mạnh cả về thể chất lẫn tinh thần, giảm nguy cơ mắc bệnh tật...', 70000, 3.46, 68, 'https://img-global.cpcdn.com/recipes/b6fc5026ee7010b2/590x315cq70/photo.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (15, N'Chè khúc bạch', N'Tráng miệng', N'Chè khúc bạch là một loại chè có thạch trông giống với rau câu nhưng có vị béo và độ mịn đặc trưng vì được làm từ sữa béo', 40000, 4.89, 129, 'https://cdn.tgdd.vn/2022/07/CookRecipe/Avatar/che-khuc-bach-cong-thuc-duoc-chia-se-boi-nguoi-dung-thumbnail.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (16, N'Panna Cotta', N'Tráng miệng', N'Panna Cotta (trong tiếng Italia nghĩa là kem nấu) là một món tráng miệng nấu kem, sữa và đường với bột thạch rồi đợi cho hỗn hợp đông lại', 50000, 4.01, 24, 'https://chefjob.vn/wp-content/uploads/2020/07/trang-mien-panna-cotta-don-gian-de-lam.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (17, N'Kem (Vani/Chocolate)', N'Tráng miệng', NULL, 45000, 4.87, 45, 'https://dayphache.edu.vn/wp-content/uploads/2016/02/kem-vani.jpg')
-- Complement
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (18, N'Bún tươi', N'Món ăn kèm', NULL, 10000, 4.78, 9, 'https://cdn.tgdd.vn/Files/2020/04/16/1249471/huong-dan-cach-lam-bun-tuoi-tai-nha-don-gian-khon-7.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (19, N'Kim chi', N'Món ăn kèm', NULL, 10000, 4.85, 5, 'https://cdn.tgdd.vn/Files/2019/12/22/1227977/8-cach-lam-kim-chi-han-quoc-thom-ngon-gion-cay-chuan-vi-202202211103238108.jpg')
-- Vegetarian
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (20, N'Bánh hỏi thịt heo quay chay', N'Món chay', N' Bánh hỏi thường ăn chung với mỡ hành, thịt quay, thịt nướng, lòng heo... đây là món ăn không thể thiếu trong những dịp lễ, cúng giỗ, cưới hỏi, lễ cúng ở đình, chùa của người dân', 50000, 4.50, 49, 'https://cdn.tgdd.vn/Files/2022/11/18/1487768/cach-nau-cac-mon-chay-dai-tiec-goi-y-thuc-don-chay-gia-dinh-202211180645067648.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (21, N'Súp khoai tây', N'Món chay', N'Khoai tây là nguyên liệu rất dễ ăn, chúng dùng để chiên, luộc, nấu súp hoặc xào đều được. Nhưng bổ dưỡng nhất vẫn là khoai tây nấu súp được cả người lớn lẫn trẻ em yêu thích.', 60000 , 4.85, 123, 'https://cdn.tgdd.vn/Files/2021/08/17/1375884/cach-nau-sup-khoai-tay-thom-ngon-bo-duong-cho-ngay-chay-thanh-dam-202108171948565517.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (22, N'Há cảo chay', N'Món chay', N'Há cảo chay mềm ngon với vỏ ngoài mềm dai, nhân nấm ngọt ngào, tự nhiên thanh đạm. Món ăn này sẽ làm phong phú những bữa ăn chay trong gia đình bạn', 40000, 4.19, 67, 'https://cdn.tgdd.vn/2020/07/CookProduct/Moms-Special-Vegan-Dumplings-%E5%AE%B6%E5%82%B3%E7%B4%94%E7%B4%A0%E6%B0%B4%E9%A4%83Resize-11-1200x676.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (23, N'Ragu chay', N'Món chay', N'Lagu hay ragu là một món hầm ngon, thường được dùng để ăn kèm với bánh mì. Thông thường, người ta hay nấu lagu với các loại rau củ, kết hợp với thịt gà, thịt bò,…', 55000, 4.35, 98, 'https://cdn.tgdd.vn/2020/09/CookProduct/Untitled-2-Recovered-1200x676-8.jpg')
INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
	values (24, N'Lẩu chay', N'Món chay', N'Lẩu chay là một trong những món ăn ngon, chế biến đơn giản, lẩu có hương vị thanh đạm, thích hợp khi ăn cùng gia đình vào những dịp đầu tháng hay rằm', 150000, 3.87, 130, 'https://cdn.tgdd.vn/2020/07/CookRecipe/Avatar/lau-nam-chay-thumbnail.jpg')


-- insert INGREDIENT data
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(1, N'Tôm', 'kg', 110000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(2, N'Củ hủ dừa', 'kg', 100000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(3, N'Bạch tuộc', 'kg', 90000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(4, N'Nước cốt chanh', 'l', 60000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(5, N'Đường', 'kg', 15000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(6, N'Muối', 'kg', 8000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(7, N'Đậu phộng', 'kg', 20000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(8, N'Sữa tươi', 'l', 40000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(9, N'Bột cacao', 'kg', 80000)
INSERT INTO INGREDIENT(ID, Ing_name, Unit, Price) values
	(10, N'Siro socola', 'kg', 150000)

-- insert RECIPE data
-- Example for 'Goi cu hu dua'
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 1, 2, 1, N'So che cu hu dua')
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 2, 3, 0.5, N'So che va luoc bach tuoc')
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 3, 1, 0.3, N'So che va luoc tom')
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 4, 4, 0.2, N'Lam nuoc tron goi')
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 5, 5, 0.02, N'Lam nuoc tron goi')
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 6, NULL, NULL, N'Tron goi va ruoi nuoc tron goi len tren')
INSERT INTO RECIPE(Dish_id, Step, Ing_id, Amount, Step_des) values
	(1, 7, 7, 0.02, N'Them mot it dau phong')

-- insert SUPPLIER data
INSERT INTO SUPPLIER(ID, Sup_name, ContactPerson, ContactNumber, Email) values
	(1, N'Công ty TNHH Muối Thành Phát', N'Nguyễn Văn A', '0912345678', 'mtp@gmail.com')
INSERT INTO SUPPLIER(ID, Sup_name, ContactPerson, ContactNumber, Email) values
	(2, N'Công ty TNHH Đường Cát Trắng', N'Nguyễn Văn B', '0912345679', 'dct@gmail.com')
INSERT INTO SUPPLIER(ID, Sup_name, ContactPerson, ContactNumber, Email) values
	(3, N'Công ty CP Thủy sản Minh Phú', N'Nguyễn Văn C', '0912345670', 'tsmp@gmail.com')
INSERT INTO SUPPLIER(ID, Sup_name, ContactPerson, ContactNumber, Email) values
	(4, N'Công ty Đậu Phộng Tân Tân', N'Nguyễn Văn D', '0912345671', 'dptt@gmail.com')

-- insert BRANCH data
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(1, N'Nhà hàng ABC Chi nhánh 1', N'32 Hoa Mai, P.2, Q.Phú Nhuận, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(2, N'Nhà hàng ABC Chi nhánh 2', N'120 Nguyễn Đình Chiểu, P.Đa Kao, Q.1, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(3, N'Nhà hàng ABC Chi nhánh 3', N'1 Nguyễn Hữu Cầu, P.Tân Định, Q.1, TPHCM', NULL)
INSERT INTO BRANCH(ID, Branch_name, Branch_add, Branch_des) values
	(4, N'Nhà hàng ABC Chi nhánh 4', N'74 Trương Quốc Dung, P.10, Q.Phú Nhuận, TPHCM', NULL)

-- insert INVENTORY data
	-- Ing_id = 1 (Tom)
INSERT INTO INVENTORY(ID, Branch_id, Ing_id, Amount, Unit, DateRecorded) values
	(1, 1, 1, 12, 'kg', '2023-11-25 9:00:00')
INSERT INTO INVENTORY(ID, Branch_id, Ing_id, Amount, Unit, DateRecorded) values
	(2, 1, 1, 7, 'kg', '2023-11-25 21:00:00')
INSERT INTO INVENTORY(ID, Branch_id, Ing_id, Amount, Unit, DateRecorded) values
	(3, 1, 1, 15, 'kg', '2023-11-26 9:00:00')
	-- Ing_id = 2 (Cu hu dua)
INSERT INTO INVENTORY(ID, Branch_id, Ing_id, Amount, Unit, DateRecorded) values
	(4, 3, 2, 10, 'kg', '2023-11-26 12:00:00')
INSERT INTO INVENTORY(ID, Branch_id, Ing_id, Amount, Unit, DateRecorded) values
	(5, 3, 2, 5, 'kg', '2023-11-26 21:00:00')
INSERT INTO INVENTORY(ID, Branch_id, Ing_id, Amount, Unit, DateRecorded) values
	(6, 4, 2, 2, 'kg', '2023-11-27 18:00:00')

-- insert ING_IN_BRANCH data
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 1, 20)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 2, 15)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 3, 20)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 4, 15)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 5, 30)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 6, 9)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (1, 7, 8)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (2, 6, 40)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (2, 7, 50)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (2, 8, 15)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (2, 9, 10)
INSERT INTO ING_IN_BRANCH(Branch_id, Ing_id, Amount) values (2, 10, 7)

-- insert SUPPLY_ORDER data
INSERT INTO SUPPLY_ORDER(ID, Supplier_id, Branch_id, Date_order, Date_deliver, Total) values
	(1, 1, 1, '2023-11-20', '2023-11-23', 2000000)
INSERT INTO SUPPLY_ORDER(ID, Supplier_id, Branch_id, Date_order, Date_deliver, Total) values
	(2, 2, 1, '2023-11-21', '2023-11-22', 3200000)
INSERT INTO SUPPLY_ORDER(ID, Supplier_id, Branch_id, Date_order, Date_deliver, Total) values
	(3, 4, 4, '2023-11-24', '2023-11-26', 5300000)
INSERT INTO SUPPLY_ORDER(ID, Supplier_id, Branch_id, Date_order, Date_deliver, Total) values
	(4, 3, 3, '2023-11-25', '2023-11-28', 1200000)
INSERT INTO SUPPLY_ORDER(ID, Supplier_id, Branch_id, Date_order, Date_deliver, Total) values
	(5, 2, 2, '2023-11-26', '2023-11-27', 15000000)
INSERT INTO SUPPLY_ORDER(ID, Supplier_id, Branch_id, Date_order, Date_deliver, Total) values
	(6, 4, 2, '2023-11-27', '2023-11-29', 9000000)

-- insert B_TABLE data
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(1, 1, N'Đã đặt', 4, N'Tầng 1')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(2, 1, N'Đang sử dụng', 6, N'Tầng 2')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(3, 1, N'Trống', 8, N'Tầng 3')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(4, 1, N'Đã đặt', 10, N'Tầng 1')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(5, 1, N'Đã đặt', 4, N'Tầng 2')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(1, 2, N'Đã đặt', 6, N'Tầng 1')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(2, 2, N'Đang sử dụng', 6, N'Tầng 2')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(3, 2, N'Trống', 6, N'Tầng 3')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(4, 2, N'Đã đặt', 10, N'Tầng 1')
INSERT INTO B_TABLE(ID, Branch_id, T_status, Num_seats, T_location) values
	(5, 2, N'Đang sử dụng', 10, N'Tầng 2')

-- insert CUSTOMER data
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C1', N'Nguyễn Văn', N'An', 'M', '1999-04-25', 'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes.png', 0)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C2', N'Nguyễn Thị', N'A', 'F', '1998-08-21', 'https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg?w=740', 20)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C3', N'Nguyễn Văn', N'A', 'M', '1997-11-01', 'https://w7.pngwing.com/pngs/312/283/png-transparent-man-s-face-avatar-computer-icons-user-profile-business-user-avatar-blue-face-heroes.png', 47)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C4', N'Nguyễn Văn', N'B', 'M', '1992-12-13', 'https://w7.pngwing.com/pngs/178/419/png-transparent-man-illustration-computer-icons-avatar-login-user-avatar-child-web-design-face.png', 10)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C5', N'Trần Thị', N'B', 'F', '2000-03-03', 'https://img.freepik.com/premium-vector/avatar-woman-flat-design-people-characters-vector-illustration-eps-10_505557-932.jpg', 60)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C6', N'Đặng Văn', N'C', 'M', '2004-05-05', 'https://w7.pngwing.com/pngs/1008/377/png-transparent-computer-icons-avatar-user-profile-avatar-heroes-black-hair-computer.png', 25)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C7', N'Hoàng Văn', N'D', 'M', '2002-03-05', 'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes.png', 45)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C8', N'Huỳnh Thị', N'C', 'M', '2001-02-03', 'https://img.freepik.com/premium-vector/avatar-icon002_750950-52.jpg?w=740', 54)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C9', N'Nguyễn Văn', N'E', 'M', '1980-12-05', 'https://w7.pngwing.com/pngs/312/283/png-transparent-man-s-face-avatar-computer-icons-user-profile-business-user-avatar-blue-face-heroes.png', 45)
INSERT INTO CUSTOMER(ID, LName, FName, Sex, Birthday, Avatar, Point) values
	('C10', N'Nguyễn Văn', N'T', 'M', '2001-09-23', 'https://w7.pngwing.com/pngs/178/419/png-transparent-man-illustration-computer-icons-avatar-login-user-avatar-child-web-design-face.png', 54)

-- insert RESERVATION data
INSERT INTO RESERVATION(Reserve_time, Table_id, Branch_id, Customer_id, Num_guests, R_status, Start_time) values
	('2023-11-25 9:24:47', 1, 1, 'C2', 3, N'Đang chờ duyệt', '2023-11-30 19:00:00')
INSERT INTO RESERVATION(Reserve_time, Table_id, Branch_id, Customer_id, Num_guests, R_status, Start_time) values
	('2023-11-25 12:34:56', 2, 2, 'C3', 4, N'Đã duyệt', '2023-11-29 18:00:00')
INSERT INTO RESERVATION(Reserve_time, Table_id, Branch_id, Customer_id, Num_guests, R_status, Start_time) values
	('2023-11-26 10:20:15', 3, 1, 'C6', 2, N'Đã hủy', '2023-12-01 19:30:00')
INSERT INTO RESERVATION(Reserve_time, Table_id, Branch_id, Customer_id, Num_guests, R_status, Start_time) values
	('2023-11-27 9:10:05', 5, 1, 'C1', 4, N'Đã duyệt', '2023-11-29 17:00:00')
INSERT INTO RESERVATION(Reserve_time, Table_id, Branch_id, Customer_id, Num_guests, R_status, Start_time) values
	('2023-11-27 9:59:57', 4, 2, 'C5', 9, N'Đã duyệt', '2023-12-02 12:00:00')
	
-- insert WAITLIST data
INSERT INTO WAITLIST(ID, Customer_id, Num_guests, DateRecorded, Wait_time) values
	(1, 'C6', 2, '2023-10-31 18:25:00', 21)
INSERT INTO WAITLIST(ID, Customer_id, Num_guests, DateRecorded, Wait_time) values
	(2, 'C1', 3, '2023-11-07 18:34:01', NULL)
INSERT INTO WAITLIST(ID, Customer_id, Num_guests, DateRecorded, Wait_time) values
	(3, 'C5', 4, '2023-11-08 19:02:05', 10)
INSERT INTO WAITLIST(ID, Customer_id, Num_guests, DateRecorded, Wait_time) values
	(4, 'C5', 10, '2023-11-20 12:03:16', 15)

-- insert CUS_ORDER data
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(1, 1, 'C6', 400000, 360000, N'Đã thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(2, 2, 'C1', 297000, NULL, N'Chưa thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(3, 3, 'C5', 1200000, NULL, N'Đã thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(4, 4, 'C5', 1500000, 1200000, N'Chưa thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(5, 1, 'C4', 650000, NULL, N'Chưa thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(6, 2, 'C3', 1000000, NULL, N'Đã thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(7, 3, 'C2', 6500000, NULL, N'Chưa thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(8, 4, 'C1', 5400000, NULL, N'Đã thanh toán')
INSERT INTO CUS_ORDER(ID, Branch_id, Customer_id, Original_price, Discounted_price, Order_status) values
	(9, 1, 'C1', 2500000, 2350000, N'Đã thanh toán')

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

-- insert VOUCHER_CAT data
INSERT INTO VOUCHER_CAT(ID, Category_id) values (2, 1) -- Appetizer
INSERT INTO VOUCHER_CAT(ID, Category_id) values (4, 2) -- Main Dish
INSERT INTO VOUCHER_CAT(ID, Category_id) values (6, 3) -- Drinks

-- insert REVIEW data
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(1, 'C6', 1, 1, 5, N'Món gỏi củ hủ dừa rất ngon!', '2023-11-15 13:13:16')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(2, 'C1', 2, 3, 3, N'Món súp hải sản quá mặn. Cần cho ít muối lại', '2023-11-18 13:24:15')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(3, 'C5', 3, 7, 4, N'Món lẩu hải sản ăn được, nhưng mà giá đắt quá :(', '2023-11-20 20:28:16')
INSERT INTO REVIEW(ID, Customer_id, Order_id, Dish_id, Rating, Content, DateRecorded) values
	(4, 'C5', 3, 15, 5, N'Chè khúc bạch ngon, sẽ tiếp tục ăn lần sau', '2023-11-20 20:29:15')

-- INSERT STAFF data
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S1', N'Nguyễn Thị', 'M', 'F', '1998-02-23', 2, NULL, 4500000, 'nguyenthim@gmail.com', '2022-02-10')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S2', N'Nguyễn Thị', 'N', 'F', '1997-06-21', 2, 'S1', 4000000, 'nguyenthin@gmail.com', '2021-11-30')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S3', N'Nguyễn Thị', 'P', 'F', '1996-10-10', 2, 'S1', 3500000, NULL, '2020-01-02')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S4', N'Nguyễn Thị', 'Q', 'F', '1990-01-06', 2, 'S1', 3000000, NULL, '2019-03-03')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S5', N'Nguyễn Văn', 'Q', 'M', '1991-04-09', 2, NULL, 2500000, NULL, '2018-04-13')

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S6', N'Nguyễn Văn', 'M', 'M', '1998-07-29', 3, NULL, 5000000, 'nguyenvanm@gmail.com', '2018-05-03')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S7', N'Nguyễn Văn', 'N', 'M', '2001-10-11', 3, 'S6', 4500000, 'nguyenvann@gmail.com', '2017-02-23')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S8', N'Nguyễn Văn', 'P', 'M', '2000-02-02', 3, 'S6', 4000000, NULL, '2017-03-23')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S9', N'Nguyễn Văn', 'Q', 'M', '1975-05-31', 3, NULL, 8000000, NULL, '2020-10-10')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S10', N'Nguyễn Văn', 'Q', 'F', '1990-02-11', 3, NULL, 3000000, NULL, '2019-07-10')

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S11', N'Trần Văn', 'M', 'M', '1995-06-06', 4, NULL, 4500000, 'tranvanm@gmail.com', '2016-11-11')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S12', N'Trần Văn', 'N', 'M', '1996-08-09', 4, NULL, 5500000, 'tranvann@gmail.com', '2020-11-10')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S13', N'Trần Văn', 'P', 'M', '2000-01-20', 4, 'S12', 5000000, NULL, '2023-01-03')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S14', N'Trần Văn', 'Q', 'M', '1989-03-31', 4, NULL, 9000000, NULL, '2022-04-05')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S15', N'Trần Thị', 'Q', 'F', '1990-02-13', 4, NULL, 2800000, NULL, '2023-11-01')

INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S16', N'Nguyễn Hoàng', 'K', 'F', '1997-06-21', 2, 'S1', 4200000, 'nguyenhoangk@gmail.com', '2018-08-30')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S17', N'Nguyễn Quốc', 'P', 'M', '1996-10-10', 2, 'S1', 3700000, 'nguyenquocp@gmail.com', '2020-01-02')
INSERT INTO STAFF(ID, LName, FName, Sex, Birthday, Branch_id, Mgr_id, Salary, Email, Start_Day) values
	('S18', N'Nguyễn Minh', 'Q', 'M', '1990-01-06', 2, 'S1', 2900000, 'nguyenminhq@gmail.com', '2019-03-03')

UPDATE STAFF SET Mgr_id = 'S12' WHERE ID = 'S11';

-- INSERT CHEF data
INSERT INTO CHEF(ID) values ('S4')
INSERT INTO CHEF(ID) values ('S9')
INSERT INTO CHEF(ID) values ('S14')

-- INSERT SHIPPER data
INSERT INTO SHIPPER(ID) values ('S5')
INSERT INTO SHIPPER(ID) values ('S10')
INSERT INTO SHIPPER(ID) values ('S15')

-- INSERT WAITER data
INSERT INTO WAITER(ID) values ('S1')
INSERT INTO WAITER(ID) values ('S2')
INSERT INTO WAITER(ID) values ('S3')
INSERT INTO WAITER(ID) values ('S6')
INSERT INTO WAITER(ID) values ('S7')
INSERT INTO WAITER(ID) values ('S8')
INSERT INTO WAITER(ID) values ('S11')
INSERT INTO WAITER(ID) values ('S12')
INSERT INTO WAITER(ID) values ('S13')

-- insert TABLE_ORDER data
INSERT INTO TABLE_ORDER(Order_id, Branch_id, Table_id) values (2, 1, 1)
INSERT INTO TABLE_ORDER(Order_id, Branch_id, Table_id) values (4, 1, 1)
INSERT INTO TABLE_ORDER(Order_id, Branch_id, Table_id) values (6, 2, 2)
INSERT INTO TABLE_ORDER(Order_id, Branch_id, Table_id) values (8, 2, 2)
-- insert CUS_ORDER data
INSERT INTO ONLINE_ORDER(Order_id, Shipper_id, Order_add, Start_time, End_time) 
	values (1, 'S5', N'30 Trịnh Đình Thảo, P.Hòa Thạnh, Q. Tân Phú', '2023-12-04 12:23:34', '2023-12-04 12:48:45')
INSERT INTO ONLINE_ORDER(Order_id, Shipper_id, Order_add, Start_time, End_time) 
	values (3, 'S10', N'32 Nguyễn Chí Thanh, P.10, Q.5', '2023-12-02 19:23:34', '2023-12-04 19:45:45')
INSERT INTO ONLINE_ORDER(Order_id, Shipper_id, Order_add, Start_time, End_time) 
	values (5, 'S15', N'34 Nguyễn Thái Học, P.Bến Thành, Quận 1', '2023-11-30 11:00:00', '2023-11-30 11:30:00')
INSERT INTO ONLINE_ORDER(Order_id, Shipper_id, Order_add, Start_time, End_time) 
	values (7, 'S5', N'30 Trịnh Đình Trọng, P.Hòa Thạnh, Q. Tân Phú', '2023-11-27 12:23:21', '2023-11-27 12:50:59')
INSERT INTO ONLINE_ORDER(Order_id, Shipper_id, Order_add, Start_time, End_time) 
	values (9, 'S10', N'153 Nguyễn Chí Thanh, P.9, Q.5', '2023-12-05 14:15:00', '2023-12-05 14:39:12')

-- INSERT SCHEDULE data
INSERT INTO SCHEDULE(ID, Staff_id, Date_time, Start_hour, End_hour) values
	(1, 'S1', '2023-11-27', 9, 18)
INSERT INTO SCHEDULE(ID, Staff_id, Date_time, Start_hour, End_hour) values
	(2, 'S1', '2023-11-28', 12, 21)
INSERT INTO SCHEDULE(ID, Staff_id, Date_time, Start_hour, End_hour) values
	(3, 'S2', '2023-11-27', 18, 22)
INSERT INTO SCHEDULE(ID, Staff_id, Date_time, Start_hour, End_hour) values
	(4, 'S2', '2023-11-28', 9, 12)
INSERT INTO SCHEDULE(ID, Staff_id, Date_time, Start_hour, End_hour) values
	(5, 'S3', '2023-11-27', 12, 18)
INSERT INTO SCHEDULE(ID, Staff_id, Date_time, Start_hour, End_hour) values
	(6, 'S3', '2023-11-28', 12, 18)

-- INSERT CUSTOMER_PHONE data
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C1', '0921234567')
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C1', '0921234568')
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C2', '0921234569')
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C2', '0921234560')
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C2', '0921234561')
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C3', '0921234562')
INSERT INTO CUSTOMER_PHONE(Customer_id, Phone) values ('C3', '0921234563')

-- INSERT STAFF_PHONE data
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S1', '0931234567')
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S1', '0931234568')
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S2', '0931234569')
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S2', '0931234560')
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S2', '0931234561')
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S3', '0931234562')
INSERT INTO STAFF_PHONE(Staff_id, Phone) values ('S3', '0931234563')

-- INSERT ACCOUNT data
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C1', 'khachhangc1', 'wogi2no@#')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C3', 'khachhangc3', 'anig02(*!s')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C5', 'khachhangc5', 'wwijh2bpj!')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C2', 'khachhangc2', 'avmnk1!#(dak')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C4', 'khachhangc4', 'bnajdkbp5<#>%')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C6', 'khachhangc6', 'canjko3qeo)_@>')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C7', 'khachhangc7', 'joiwv902(@)18na')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C8', 'khachhangc8', 'euoqvboq*(@0')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C9', 'khachhangc9', 'vm,a.><dke21')
INSERT INTO CUSTOMER_ACCOUNT(ID, Username, Pass) values ('C10', 'khachhangc10', 'pojvopqni(@19')
INSERT INTO STAFF_ACCOUNT(ID, Username, Pass) values ('S1', 'nhanviens1', 'wogi2no@#')
INSERT INTO STAFF_ACCOUNT(ID, Username, Pass) values ('S3', 'nhanviens3', 'apbo5pk)@_>')
INSERT INTO STAFF_ACCOUNT(ID, Username, Pass) values ('S5', 'nhanviens5', 'klnspo1e[/')
INSERT INTO STAFF_ACCOUNT(ID, Username, Pass) values ('S7', 'nhanviens7', 'mdqlv90)!@')
INSERT INTO STAFF_ACCOUNT(ID, Username, Pass) values ('S9', 'nhanviens9', 'apbo6pk)@_>')
INSERT INTO STAFF_ACCOUNT(ID, Username, Pass) values ('S10', 'nhanviens10', 'klnspo2e[/')

-- INSERT EAT_WITH data
INSERT INTO EAT_WITH(Dish_id_1, Dish_id_2) values (7, 18) -- Lau an kem voi bun
INSERT INTO EAT_WITH(Dish_id_1, Dish_id_2) values (8, 19)

-- INSERT DISH_ING data
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 1)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 2)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 3)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 4)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 5)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 6)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (1, 7)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (17, 8)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (17, 9)
INSERT INTO DISH_ING(Dish_id, Ing_id) values (17, 10)

-- INSERT SUPPLIES data
INSERT INTO SUPPLIES(Sup_order_id, Ing_id, Amount) values (1, 6, 10)
INSERT INTO SUPPLIES(Sup_order_id, Ing_id, Amount) values (2, 5, 15)
INSERT INTO SUPPLIES(Sup_order_id, Ing_id, Amount) values (3, 1, 20)
INSERT INTO SUPPLIES(Sup_order_id, Ing_id, Amount) values (3, 3, 12)
INSERT INTO SUPPLIES(Sup_order_id, Ing_id, Amount) values (4, 7, 20)

-- INSERT APPLY_VOUCHER data
INSERT INTO APPLY_VOUCHER(Voucher_id, Order_id) values (7, 1)
INSERT INTO APPLY_VOUCHER(Voucher_id, Order_id) values (3, 4)
GO
-- 1.2.1 Create procedures for CUSTOMER table
-- Insert Procedure
-- DROP PROCEDURE InsertCustomer
-- GO
CREATE PROCEDURE InsertCustomer
	@ID varchar(8),
    @LName varchar(20),
    @FName varchar(10),
    @Sex char(1),
    @Birthday date,
    @Avatar varchar(300)
AS
BEGIN
    -- Data validation checks
    IF FLOOR(DATEDIFF(DAY, @Birthday , GETDATE()) / 365.25) < 18
    BEGIN
        RAISERROR(' Customer must be at least 18 years old.', 16, 1);
        RETURN;
    END;

	IF EXISTS (SELECT * FROM CUSTOMER WHERE ID = @ID)
	BEGIN
        RAISERROR(' This ID has already been in use', 16, 4);
        RETURN;
    END;

    -- Insert data
    INSERT INTO CUSTOMER (ID, LName, FName, Sex, Birthday, Avatar, Point)
    VALUES (@ID, @LName, @FName, @Sex, @Birthday, @Avatar, 0);
END;
GO

-- Update Procedure
CREATE PROCEDURE UpdateCustomer
    @ID varchar(8),
    @LName varchar(20),
    @FName varchar(10),
    @Sex char(1),
    @Birthday date,
    @Avatar varchar(300),
	@Point int
AS
BEGIN
    -- Data validation checks
    IF FLOOR(DATEDIFF(DAY, @Birthday , GETDATE()) / 365.25) < 18
    BEGIN
        RAISERROR(' Customer must be at least 18 years old.', 16, 5);
        RETURN;
    END;

	IF NOT EXISTS (SELECT * FROM CUSTOMER WHERE ID = @ID)
	BEGIN
        RAISERROR(' Invalid Customer ID', 16, 6);
        RETURN;
    END;
	
	IF @Point < 0
	BEGIN
        RAISERROR(' Points cannot be negative', 16, 7);
        RETURN;
    END;
    -- Update data
    UPDATE CUSTOMER
    SET LName = @LName,
		FName = @FName,
		Sex = @Sex,
		Birthday = @Birthday,
		Avatar = @Avatar,
		Point = @Point
    WHERE ID = @ID;
END;
GO

-- DROP PROCEDURE DeleteCustomer
-- GO
CREATE PROCEDURE DeleteCustomer
    @ID varchar(8)
AS
BEGIN
	-- Check if ID exists
	IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE ID = @ID)
    BEGIN
        RAISERROR(' Invalid Customer ID.', 16, 101);
        RETURN;
    END;

    -- Delete data
    DELETE FROM CUSTOMER WHERE ID = @ID;
END;
GO

-- Insert Dish Procedure
CREATE PROCEDURE InsertDish
	@ID int,
    @Dish_name nvarchar(50),
	@Category nvarchar(20),
    @Dish_des nvarchar(300),
    @Price	int,
	@Img varchar(256)
AS
BEGIN
	-- Data validation checks
	IF EXISTS (SELECT * FROM DISH WHERE ID = @ID)
	BEGIN
        RAISERROR(' ID has already been in used', 16, 6);
        RETURN;
    END;

	IF @Price <= 0 
	BEGIN
		RAISERROR(' Price cannot be nonnegative', 16, 6);
        RETURN;
	END;

	IF NOT (@Price % 1000 = 0)
	BEGIN
		RAISERROR(' Price must be divisible by 1000', 16, 6);
        RETURN;
	END;

	-- Insert data
    INSERT INTO DISH(ID, Dish_name, Category, Dish_des, Price, Rating, Num_review, Img)
    VALUES (@ID, @Dish_name, @Category, @Dish_des, @Price, 0, 0, @Img);
END;
GO

-- Update Dish Procedure
CREATE PROCEDURE UpdateDish
    @ID int,
    @Dish_name nvarchar(50),
	@Category nvarchar(20),
    @Dish_des nvarchar(300),
    @Price	int,
	@Img varchar(256)
AS
BEGIN
    -- Data validation checks
	IF NOT EXISTS (SELECT * FROM DISH WHERE ID = @ID)
	BEGIN
        RAISERROR('Invalid Customer', 16, 6);
        RETURN;
    END;
	
	IF @Price <= 0
	BEGIN
        RAISERROR('Price cannot be non-negative', 16, 7);
        RETURN;
    END;

	IF NOT (@Price % 1000 = 0)
	BEGIN
        RAISERROR('Price is not divisible by 1000', 16, 7);
        RETURN;
    END;
    -- Update data
    UPDATE DISH
    SET Dish_name = @Dish_name,
		Category = @Category,
		Dish_des = @Dish_des,
		Price = @Price,
		Img = @Img
    WHERE ID = @ID;
END;
GO

-- Delete dish procedure
CREATE PROCEDURE DeleteDish
    @ID int
AS
BEGIN
	-- Check if ID exists
	IF NOT EXISTS (SELECT 1 FROM DISH WHERE ID = @ID)
    BEGIN
        RAISERROR('Invalid Dish ID.', 16, 101);
        RETURN;
    END;

    -- Delete data
    DELETE FROM DISH WHERE ID = @ID;
END;
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
-- SELECT * FROM OrderItem
GO

CREATE PROCEDURE GetBestDishes
  @minRating DECIMAL(3,2),
  @minNumReviews INT
AS
BEGIN
  SELECT
    D.ID,
    D.Dish_name,
    D.Category,
    D.Rating,
    D.Num_review
  FROM
    DISH D
  WHERE
    D.Rating >= @minRating
    AND D.Num_review >= @minNumReviews
  ORDER BY
    D.Category,
    D.Rating DESC;
END;