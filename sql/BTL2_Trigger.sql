-- Test CalculateSubTotalOnInsert trigger
SELECT * FROM OrderItem
GO

CREATE TRIGGER UpdateTotalPriceOnInsert
ON OrderItem
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @orderTotal int;

    -- Calculate the total price for the order
    SELECT @orderTotal = SUM(SubTotal)
    FROM OrderItem
    WHERE Order_id IN (SELECT Order_id FROM inserted WHERE Order_id = inserted.Order_id);

    -- Update the TotalPrice in the ORDER entity
    UPDATE [CUS_ORDER]
    SET Original_price = @orderTotal
    WHERE ID IN (SELECT Order_id FROM inserted);
END;
GO

-- Test UpdateTotalPriceOnInsert trigger:
SELECT * FROM CUS_ORDER
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 10, 1, NULL)
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 11, 1, NULL)
SELECT * FROM OrderItem
GO

CREATE TRIGGER UpdateTotalPriceOnDelete
ON OrderItem
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @orderTotal int;

    -- Calculate the total price for the order
    SELECT @orderTotal = SUM(SubTotal)
    FROM OrderItem
    WHERE Order_id IN (SELECT Order_id FROM deleted WHERE Order_id = deleted.Order_id);

    -- Update the TotalPrice in the ORDER entity
    UPDATE [CUS_ORDER]
    SET Original_price = @orderTotal
    WHERE ID IN (SELECT Order_id FROM deleted);
END;
GO

-- Test UpdateTotalPriceOnInsert trigger:
SELECT * FROM CUS_ORDER
DELETE FROM OrderItem WHERE (Order_id = 1 AND Dish_id = 1)
SELECT * FROM OrderItem
GO

-- Trigger to update amount of ingredient after insert/delete OrderItem
CREATE TRIGGER update_ingredient_amount_insert
ON OrderItem
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @branch_id INT;
    DECLARE @dish_id INT;

    -- Fetch the Branch_id and Dish_id for the given Order_id
    SELECT @branch_id = CUS_ORDER.Branch_id, @dish_id = inserted.Dish_id
    FROM CUS_ORDER
    INNER JOIN inserted ON CUS_ORDER.ID = inserted.Order_id;

    -- Update the ingredient amount in the branch for each ingredient in the dish
    UPDATE ING_IN_BRANCH
    SET Amount = ING_IN_BRANCH.Amount - (RECIPE.Amount * ins.Amount)
    FROM ING_IN_BRANCH
    INNER JOIN RECIPE ON ING_IN_BRANCH.Ing_id = RECIPE.Ing_id
    INNER JOIN inserted AS ins ON RECIPE.Dish_id = ins.Dish_id
    WHERE ING_IN_BRANCH.Branch_id = @branch_id AND RECIPE.Dish_id = @dish_id;
END;

-- Test update_ingredient_amount_insert trigger:
SELECT * FROM OrderItem
SELECT * FROM RECIPE
SELECT * FROM ING_IN_BRANCH
SELECT * FROM CUS_ORDER
INSERT INTO OrderItem(Order_id, Dish_id, Amount, SubTotal) values (1, 1, 1, NULL)
GO

CREATE TRIGGER update_ingredient_amount_delete
ON OrderItem
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @branch_id INT;
    DECLARE @dish_id INT;

    -- Fetch the Branch_id and Dish_id for the given Order_id
    SELECT @branch_id = CUS_ORDER.Branch_id, @dish_id = deleted.Dish_id
    FROM CUS_ORDER
    INNER JOIN deleted ON CUS_ORDER.ID = deleted.Order_id;

    -- Update the ingredient amount in the branch for each ingredient in the dish
    UPDATE ING_IN_BRANCH
    SET Amount = ING_IN_BRANCH.Amount + (RECIPE.Amount * del.Amount)
    FROM ING_IN_BRANCH
    INNER JOIN RECIPE ON ING_IN_BRANCH.Ing_id = RECIPE.Ing_id
    INNER JOIN deleted AS del ON RECIPE.Dish_id = del.Dish_id
    WHERE ING_IN_BRANCH.Branch_id = @branch_id AND RECIPE.Dish_id = @dish_id;
END;

-- Test update_ingredient_amount_delete trigger:
SELECT * FROM OrderItem
SELECT * FROM RECIPE
SELECT * FROM ING_IN_BRANCH
SELECT * FROM CUS_ORDER
DELETE FROM OrderItem WHERE (Order_id = 1 AND Dish_id = 1)
GO
