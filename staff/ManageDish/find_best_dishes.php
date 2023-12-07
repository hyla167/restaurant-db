<!-- find_best_dishes.php -->

<?php
// Include your database connection file here

// Execute the stored procedure and fetch the result
// Replace the placeholders with your database connection code and the correct stored procedure name
$serverName = "HYLA";
$connectionOptions = array(
    "Database" => "RESTAURANT",
    "Uid" => "",
    "PWD" => "",
    "CharacterSet" => "UTF-8"
);

$conn = sqlsrv_connect($serverName, $connectionOptions);

if (!$conn) {
    die(print_r(sqlsrv_errors(), true));
}

if (isset($_GET['minRating']) && isset($_GET['minNumReviews'])) {
    $minRating = floatval($_GET['minRating']);
    $minNumReviews = intval($_GET['minNumReviews']);

    $sql = "EXEC GetBestDishes @minRating = ?, @minNumReviews = ?";
    $params = array($minRating, $minNumReviews);
    $stmt = sqlsrv_query($conn, $sql, $params);

    
} else {
    // Handle the case when parameters are not set
    echo "Invalid parameters.";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Best Dishes</title>
    <!-- Include Bootstrap CSS and DataTables CSS here -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <style>
        /* Add your custom styles here */
        .table-container {
            margin: 20px;
        }
    </style>
</head>
<body>

<div class="container mt-5">
    <h2>Tìm món ăn tốt nhất theo rating và số lượng review</h2>
    <div class="table-container">
<table id="bestDishesTable" class="table table-striped table-bordered" style="width:100%">
        <thead>
        <tr>
            <th>Tên món ăn</th>
            <th>Nhóm món ăn</th>
            <th>Rating</th>
            <th>Số lượng review</th>
        </tr>
        </thead>
        <tbody>
        <?php
        // Fetch and display the results
        while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            echo "<tr>";
            echo "<td>{$row['Dish_name']}</td>";
            echo "<td>{$row['Category']}</td>";
            echo "<td>{$row['Rating']}</td>";
            echo "<td>{$row['Num_review']}</td>";
            echo "</tr>";
        }
        ?>
    </tbody>
    </table>
    </div>
    </div>
</html>
<!-- Include Bootstrap JavaScript and jQuery -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <!-- DataTables JS -->
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
<script>
$(document).ready(function () {
        // DataTable initialization
        $('#bestDishesTable').DataTable();
});
</script>

<?php
sqlsrv_close($conn);
?>

