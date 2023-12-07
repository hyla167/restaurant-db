<!-- get_customers_by_min_points.php -->

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Customers List</title>
    <!-- Include Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.21/js/dataTables.bootstrap4.min.js"></script>
    <style>
    </style>
</head>

<body>

    <div class="container mt-5">
        <h2 class="mb-4">Lương thưởng cho nhân viên</h2>

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
        session_start();
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            // Retrieve form data
            $eligibleYears = $_POST["eligibleYears"];
            $baseBonusPercentage = $_POST["baseBonusPercentage"];
            
            // Use the function to get bonus salary results
            $sql = "SELECT * FROM CalculateBonusSalaryForManager(?, ?, ?)";
            $params = array($_SESSION['username'], $eligibleYears, $baseBonusPercentage);
        
            $bonusResults = sqlsrv_query($conn, $sql, $params);
        
            // Check for query execution success
            if ($bonusResults === false) {
                die(print_r(sqlsrv_errors(), true));
            }
        
            // Display the results in a table
            // Display the results in a table with Bootstrap styling and pagination
    if (sqlsrv_has_rows($bonusResults)) {
        echo '<div class="table-responsive">';
    echo '<table class="table table-bordered table-striped" id="bonusTable">';
    echo '<thead><tr><th>ID</th><th>Họ và tên lót</th><th>Tên</th><th>Ngày sinh</th><th>Lương</th><th>Lương sau thưởng</th></tr></thead>';
    echo '<tbody>';

    while ($row = sqlsrv_fetch_array($bonusResults, SQLSRV_FETCH_ASSOC)) {
        echo '<tr>';
        echo '<td>' . $row['StaffID'] . '</td>';
        echo '<td>' . $row['LName'] . '</td>';
        echo '<td>' . $row['FName'] . '</td>';
        echo '<td>' . $row['Birthday']->format('Y-m-d') . '</td>';
        echo '<td>' . $row['Salary'] . 'đ</td>';
        echo '<td>' . $row['BonusSalary'] . 'đ</td>';
        echo '</tr>';
    }

    echo '</tbody>';
    echo '</table>';
    echo '</div>';

    // Initialize DataTables
    echo '<script>
        $(document).ready(function() {
            $("#bonusTable").DataTable();
        });
    </script>';
} else {
    echo '<div class="alert alert-info" role="alert">No results found.</div>';
}

    // Free the result set
    sqlsrv_free_stmt($bonusResults);
        }
        ?>

    </div>

    <!-- Include Bootstrap JavaScript and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script>

</body>

</html>
