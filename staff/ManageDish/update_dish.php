<?php
// update_dish.php

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

// Check if form data is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $dishId = $_POST['id'];
    $dishName = $_POST['dishName'];
    $cat = $_POST['category'];
    $dishDes = $_POST['dishDes'];
    $price = $_POST['price'];
    $img = $_POST['img'];

    // Update customer data using the UpdateCustomer stored procedure
    $sqlUpdate = "{call UpdateDish(?, ?, ?, ?, ?, ?)}";
    $paramsUpdate = array(
        array($dishId, SQLSRV_PARAM_IN),
        array($dishName, SQLSRV_PARAM_IN),
        array($cat, SQLSRV_PARAM_IN),
        array($dishDes, SQLSRV_PARAM_IN),
        array($price, SQLSRV_PARAM_IN),
        array($img, SQLSRV_PARAM_IN)
    );

    $stmtUpdate = sqlsrv_query($conn, $sqlUpdate, $paramsUpdate);

    session_start();
    if ($stmtUpdate === false) {
        // Format error message using Bootstrap alert
        $errors = array();
        foreach (sqlsrv_errors() as $error) {
            $errors[] = $error['message'];
        }

        // Store errors in session variable
        $_SESSION['update_dish_errors'] = $errors;
    } else {
        // Success message
        $_SESSION['update_dish_success'] = "Dish updated successfully!";
    }

    // Redirect back to user.php after update
    header("Location: manage_products.php");
    exit();
} else {
    echo "Invalid request.";
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