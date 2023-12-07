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

// Get the dish ID from the URL
$dishId = isset($_GET['id']) ? $_GET['id'] : null;

// Retrieve dish details from the database based on the dish ID
$sql = "SELECT * FROM DISH WHERE ID = ?";
$params = array($dishId);
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Check if there are any rows
if (sqlsrv_has_rows($stmt)) {
    // Fetch the dish details
    $dishDetails = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dish Details</title>
        <!-- Bootstrap CSS -->
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <style>
            /* Add your custom styles here */
            .dish-details-container {
                max-width: 600px;
                margin: 50px auto;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 8px;
            }

            .dish-image {
                max-width: 100%;
                height: auto;
                border-radius: 4px;
            }
        </style>
    </head>
    <body class="bg-light">
        <div class="container mt-5">
            <div class="dish-details-container">
                <img class="dish-image" src="<?php echo $dishDetails['Img']; ?>" alt="<?php echo $dishDetails['Dish_name']; ?>">
                <h2 class="mt-3"><?php echo $dishDetails['Dish_name']; ?></h2>
                <p><?php echo $dishDetails['Dish_des']; ?></p> 
                <p>Giá tiền: <?php echo $dishDetails['Price']; ?>đ</p>
            </div>
        </div>

        <!-- Bootstrap JS and Popper.js -->
        <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    </body>
    </html>
    <?php
} else {
    // Handle the case when the query doesn't return any results
    echo "Dish not found.";
}

// Close the database connection
sqlsrv_close($conn);
?>
