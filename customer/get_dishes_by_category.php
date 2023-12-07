<?php
// Include your database connection code here
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

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['category'])) {
    $selectedCategory = $_POST['category'];

    // Use a prepared statement to prevent SQL injection
    $query = "SELECT * FROM DISH WHERE Category = ?";
    $params = array($selectedCategory);

    $stmt = sqlsrv_query($conn, $query, $params);

    if ($stmt === false) {
        die(print_r(sqlsrv_errors(), true));
    }

     while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
         echo '<div class="dish-card">';
         echo '<div class="dish-image-container">';
         echo '<img class="dish-image" src="' . $row['Img'] . '" alt="' . $row['Dish_name'] . '">';
         echo '</div>';
         echo '<h4>' . $row['Dish_name'] . '</h4>';
         echo '<p>' . $row['Dish_des'] . '</p>';
         echo '<p>Price: ' . $row['Price'] . 'đ</p>';
         echo '<a href="dish_details.php?id=' . $row['ID'] . '" class="btn btn-primary">View</a>';
         echo '</div>';
     }

    // Free the result set
    sqlsrv_free_stmt($stmt);
}
?>



