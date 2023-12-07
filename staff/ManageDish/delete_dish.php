<?php
// delete_dish.php

// Replace these values with your SQL Server connection details
$serverName = "HYLA";
$connectionOptions = array(
    "Database" => "RESTAURANT",
    "Uid" => "",
    "PWD" => ""
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

    // Call the stored procedure to delete the customer
    $sqlDelete = "{call DeleteDish(?)}";
    $paramsDelete = array($dishId);
    $stmtDelete = sqlsrv_query($conn, $sqlDelete, $paramsDelete);

    session_start();
    if ($stmtDelete === false) {
        // Format error message using Bootstrap alert
        $errors = array();
        foreach (sqlsrv_errors() as $error) {
            $errors[] = $error['message'];
        }

        // Store errors in session variable
        $_SESSION['delete_dish_errors'] = $errors;
    } else {
        // Success message
        $_SESSION['delete_dish_success'] = "Dish deleted successfully!";
    }

    // Redirect back to the user.php page after deletion
    header("Location: manage_products.php");
    exit();
} else {
    echo "Dish ID not provided.";
    exit();
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