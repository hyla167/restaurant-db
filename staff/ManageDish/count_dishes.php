<!-- get_customers_by_min_points.php -->

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Customers List</title>
    <!-- Include Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
    <style>
    </style>
</head>

<body>

    <div class="container mt-5">
        <h2 class="mb-4">Number of dishes with price at least by category</h2>

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

        if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["threshold"])) {
            $threshold = $_POST["threshold"];

            $sqlCountDishes = "{call GetDishCountByCategoryWithPrice(?)}";
            $paramsCountDishes = array(array($threshold, SQLSRV_PARAM_IN));
            $stmtCountDishes = sqlsrv_query($conn, $sqlCountDishes, $paramsCountDishes);

            if ($stmtCountDishes === false) {
                die(print_r(sqlsrv_errors(), true));
            }

            // Display the result in a Bootstrap table
            echo '<table class="table">';
            echo '<thead class="thead-dark">';
            echo '<tr>';
            echo '<th>Category name</th>';
            echo '<th>Count</th>';
            echo '</tr>';
            echo '</thead>';
            echo '<tbody>';

            // Fetch and display the result
            while ($row = sqlsrv_fetch_array($stmtCountDishes, SQLSRV_FETCH_ASSOC)) {
                echo '<tr>';
                echo '<td>' . $row['Category'] . '</td>';
                echo '<td>' . $row['DishCount'] . '</td>';
                echo "</tr>";
            }

            echo '</tbody>';
            echo '</table>';

            // Free the statement resources
            sqlsrv_free_stmt($stmtCountDishes);
        }

        // Close the database connection
        sqlsrv_close($conn);
        ?>

    </div>

    <!-- Include Bootstrap JavaScript and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script>

</body>

</html>
