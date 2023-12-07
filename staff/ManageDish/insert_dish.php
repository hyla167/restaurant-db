<?php
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

// Check if the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $ID = $_POST['ID'];
    $dishName = $_POST['dishName'];
    $category = $_POST['category'];
    $description = $_POST['description'];
    $price = $_POST['price'];

    // Upload avatar image
    $imgFileName = $_FILES['img']['name'];
    $imgTempName = $_FILES['img']['tmp_name'];
    $imgPath = "img/" . $imgFileName; // Adjust the path as needed

    move_uploaded_file($imgTempName, $imgPath);

    // Call the InsertDish stored procedure
    $sql = "{call InsertDish(?, ?, ?, ?, ?, ?)}";
    $params = array($ID, $dishName, $category, $description, $price, $imgPath);
    $stmt = sqlsrv_query($conn, $sql, $params);
    session_start();
    if ($stmt === false) {
        // Format error message using Bootstrap alert
        $errors = array();
        foreach (sqlsrv_errors() as $error) {
            $errors[] = $error['message'];
        }

        // Store errors in session variable
        $_SESSION['insert_dish_errors'] = $errors;
    } else {
        // Success message
        $_SESSION['insert_dish_success'] = "Dish inserted successfully!";
    }

    // Close the database connection
    sqlsrv_close($conn);

    // Redirect back to user.php after successful insertion
    header("Location: manage_products.php");
    exit();
}
?>

<script>
// Handle close button click
$(".close").on("click", function() {
    $(this).parent().alert('close');
});
</script>
