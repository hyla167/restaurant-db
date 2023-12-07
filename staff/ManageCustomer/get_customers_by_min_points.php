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
        .avatar-image {
            max-width: 50px; /* Set a maximum width for the image */
            max-height: 50px; /* Set a maximum height for the image */
            width: auto; /* Ensure the image maintains its aspect ratio */
            height: auto; /* Ensure the image maintains its aspect ratio */
            border-radius: 50%; /* Make the image round */
        }
    </style>
</head>

<body>

    <div class="container mt-5">
        <h2 class="mb-4">Customers List</h2>

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

        if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["minPoints"])) {
            $minPoints = $_POST["minPoints"];

            // Call the stored procedure to get the list of customers
            $sqlFindCustomers = "{call GetCustomersByMinPoints(?)}";
            $paramsFindCustomers = array(array($minPoints, SQLSRV_PARAM_IN));
            $stmtFindCustomers = sqlsrv_query($conn, $sqlFindCustomers, $paramsFindCustomers);

            if ($stmtFindCustomers === false) {
                die(print_r(sqlsrv_errors(), true));
            }

            // Display the result in a Bootstrap table
            echo '<table class="table">';
            echo '<thead class="thead-dark">';
            echo '<tr>';
            echo '<th>ID</th>';
            echo '<th>First Name</th>';
            echo '<th>Last Name</th>';
            echo '<th>Sex</th>';
            echo '<th>Birthday</th>';
            echo '<th>Avatar</th>';
            echo '<th>Points</th>';
            // Add more columns as needed
            echo '<th>Actions</th>';
            echo '</tr>';
            echo '</thead>';
            echo '<tbody>';

            // Fetch and display the result
            while ($row = sqlsrv_fetch_array($stmtFindCustomers, SQLSRV_FETCH_ASSOC)) {
                echo '<tr>';
                echo '<td>' . $row['ID'] . '</td>';
                echo '<td>' . $row['LName'] . '</td>';
                echo '<td>' . $row['FName'] . '</td>';
                echo '<td>' . $row['Sex'] . '</td>';
                echo '<td>' . $row['Birthday']->format('Y-m-d') . '</td>';
                echo '<td><img src="' . $row['Avatar'] . '" alt="Avatar" class="avatar-image"></td>';
                echo '<td>' . $row['Point'] . '</td>';
                // Add more columns as needed
                echo "<td>";
                echo '<div style="display: flex;">';
                echo '<form action="edit.php?id=' . $row['ID'] . '" method="post">';
                echo '<button type="submit" class="btn btn-primary">Edit</button>';
                echo '</form>';
                echo '<form action="delete.php?id=' . $row['ID'] . '" method="post" onsubmit="return confirm(\'Are you sure you want to delete this customer?\');">';
                echo '<button type="submit" class="btn btn-danger">Delete</button>';
                echo '</form>';
                echo '</div>';
                echo "</td>";
                echo "</tr>";
            }

            echo '</tbody>';
            echo '</table>';

            // Free the statement resources
            sqlsrv_free_stmt($stmtFindCustomers);
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
