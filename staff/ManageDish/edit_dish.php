<?php
// edit_dish.php

// Replace these values with your SQL Server connection details
$serverName = "HYLA";
$connectionOptions = array(
    "Database" => "RESTAURANT",
    "Uid" => "",
    "PWD" => "",
    "CharacterSet" => "UTF-8"
);

// Establishes the connection
$conn = sqlsrv_connect($serverName, $connectionOptions);

// Check connection
if (!$conn) {
    die(print_r(sqlsrv_errors(), true));
}

// Check if the customer ID is provided
if (isset($_GET['id'])) {
    $dishId = $_GET['id'];

    // Retrieve customer data for the selected ID
    $sqlSelect = "SELECT ID, Dish_name, Category, Dish_des, Price, Img FROM DISH WHERE ID = ?";
    $paramsSelect = array($dishId);
    $stmtSelect = sqlsrv_query($conn, $sqlSelect, $paramsSelect);

    if ($stmtSelect === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    // Fetch data from the result set
    $row = sqlsrv_fetch_array($stmtSelect, SQLSRV_FETCH_ASSOC);

    // Close the result set
    sqlsrv_free_stmt($stmtSelect);

    // Fetch all categories from the database
    $categoriesQuery = "SELECT * FROM CATEGORY";
    $categoriesResult = sqlsrv_query($conn, $categoriesQuery);

    // Check for query execution success
    if ($categoriesResult === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    // Store the categories in a PHP array
    $categories = array();
    while ($category = sqlsrv_fetch_array($categoriesResult, SQLSRV_FETCH_ASSOC)) {
        $categories[] = $category['Cat_name'];
    }

    // Free the result set
    sqlsrv_free_stmt($categoriesResult);
    // HTML form with Bootstrap styling
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Customer</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
    </head>
    <body>
        <div class="container mt-5">
            <h2 class="mb-4">Chỉnh sửa thông tin món ăn</h2>
            <form action="update_dish.php" method="post">
                <input type="hidden" name="id" value="<?php echo $row['ID']; ?>">
                <div class="form-group">
                    <label for="dishID">ID:</label>
                    <input type="text" class="form-control" name="dishID" value="<?php echo $row['ID']; ?>" required>
                </div>

                <div class="form-group">
                    <label for="dishName">Tên món ăn:</label>
                    <input type="text" class="form-control" name="dishName" value="<?php echo $row['Dish_name']; ?>" required>
                </div>
                <div class="form-group">
                        <label for="category">Nhóm món ăn:</label>
                        <select class="form-control" name = "category" id="category">
                            <?php
                            // Display categories in the dropdown
                            foreach ($categories as $category) {
                                $selected = ($row['Category'] == $category) ? 'selected' : '';
                                echo "<option value=\"$category\" $selected>$category</option>";
                            }
                            ?>
                        </select>
                    </div>
                <div class="form-group">
                    <label for="dishDes">Mô tả:</label>
                    <input type="text" class="form-control" name="dishDes" value="<?php echo $row['Dish_des']; ?>" required>
                </div>

                <div class="form-group">
                    <label for="price">Giá tiền:</label>
                    <input type="number" class="form-control" name="price" value="<?php echo $row['Price']; ?>" required>
                </div>
                <!-- <div class="form-group">
                        <label for="img">Ảnh món ăn:</label>
                        <input type="file" class="form-control-file" id="img" name="img" value="<?php echo $row['Img']; ?>" accept="image/*" required>
                </div> -->
                <div class="form-group">
                    <label for="img">Ảnh món ăn:</label>
                    <input type="text" class="form-control" name="img" value="<?php echo $row['Img']; ?>" required>
                </div>
                <button type="submit" class="btn btn-primary">Cập nhật</button>
            </form>
        </div>

        <!-- Optional: Bootstrap JavaScript (if needed) -->
        <!-- <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script> -->
        <!-- <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script> -->
        <!-- <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script> -->
        <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    </body>
    </html>
    <?php
} else {
    echo "Customer ID not provided.";
}

// Close the database connection
sqlsrv_close($conn);
?>

<script>
// Handle close button click
$(".close").on("click", function() {
    $(this).parent().alert('close');
});
</script>