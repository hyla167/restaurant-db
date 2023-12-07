<?php
// edit.php
header("Content-type: text/html; charset=utf-8");
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
    $customerId = $_GET['id'];

    // Retrieve customer data for the selected ID
    $sqlSelect = "SELECT ID, LName, FName, Sex, Birthday, Avatar, Point FROM CUSTOMER WHERE ID = ?";
    $paramsSelect = array($customerId);
    $stmtSelect = sqlsrv_query($conn, $sqlSelect, $paramsSelect);

    if ($stmtSelect === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    // Fetch data from the result set
    $row = sqlsrv_fetch_array($stmtSelect, SQLSRV_FETCH_ASSOC);

    // Close the result set
    sqlsrv_free_stmt($stmtSelect);

    // HTML form with Bootstrap styling
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Customer</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/css/bootstrap-datepicker.min.css">
    </head>
    <body>
        <div class="container mt-5">
            <h2 class="mb-4">Chỉnh sửa thông tin khách hàng</h2>
            <form action="update.php" method="post">
                <input type="hidden" name="id" value="<?php echo $row['ID']; ?>">
                <div class="form-group">
                    <label for="firstName">Họ và tên lót:</label>
                    <input type="text" class="form-control" name="firstName" value="<?php echo $row['LName']; ?>" required>
                </div>

                <div class="form-group">
                    <label for="lastName">Tên:</label>
                    <input type="text" class="form-control" name="lastName" value="<?php echo $row['FName']; ?>" required>
                </div>

                <div class="form-group">
                    <label>Giới tính:</label>
                    <div class="form-check">
                        <input type="radio" class="form-check-input" name="sex" value="Male" <?php echo ($row['Sex'] === 'Male') ? 'checked' : ''; ?>>
                        <label class="form-check-label">Nam</label>
                    </div>
                    <div class="form-check">
                        <input type="radio" class="form-check-input" name="sex" value="Female" <?php echo ($row['Sex'] === 'Female') ? 'checked' : ''; ?>>
                        <label class="form-check-label">Nữ</label>
                    </div>
                </div>

                <div class="form-group">
                    <label for="birthday">Ngày sinh:</label>
                    <input type="text" class="form-control datepicker" name="birthday" value="<?php echo $row['Birthday']->format('Y-m-d'); ?>" required>
                </div>

                <div class="form-group">
                    <label for="avatar">Avatar:</label>
                    <input type="text" class="form-control" name="avatar" value="<?php echo $row['Avatar']; ?>" required>
                </div>

                <div class="form-group">
                    <label for="points">Điểm tích lũy:</label>
                    <input type="text" class="form-control" name="points" value="<?php echo $row['Point']; ?>" required>
                </div>

                <button type="submit" class="btn btn-primary">Cập nhật</button>
            </form>
        </div>

        <!-- Optional: Bootstrap JavaScript (if needed) -->
        <!-- <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script> -->
        <!-- <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script> -->
        <!-- <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script> -->
        <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.9.0/js/bootstrap-datepicker.min.js"></script>

        <script>
            // Activate the datepicker
            $(document).ready(function () {
                $('.datepicker').datepicker({
                    format: 'yyyy-mm-dd',
                    autoclose: true,
                    todayHighlight: true
                });
            });
        </script>
    </body>
    </html>
    <?php
} else {
    echo "Customer ID not provided.";
}

// Close the database connection
sqlsrv_close($conn);
?>
