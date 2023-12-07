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
// Retrieve values from the form
session_start();
$username = $_SESSION['username'];
// Check connection
if (!$conn) {
    die(print_r(sqlsrv_errors(), true));
}

// Retrieve users from the database
$sql = "SELECT S.ID, S.LName, S.FName, S.Sex, S.Birthday, S.Salary, S.Start_day
        FROM STAFF S JOIN STAFF_ACCOUNT A ON S.Mgr_id = A.ID
        WHERE A.Username = ?";
$param = array(array($username, SQLSRV_PARAM_IN));
$stmt = sqlsrv_query($conn, $sql, $param);

if ($stmt === false) {
    die(print_r(sqlsrv_errors(), true));
}

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
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Table</title>
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <!-- DataTables CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <style>
        /* Add your custom styles here */
        .user-table-container {
            margin: 20px;
        }

        .avatar-image {
        max-width: 50px; /* Set a maximum width for the image */
        max-height: 50px; /* Set a maximum height for the image */
        width: auto; /* Ensure the image maintains its aspect ratio */
        height: auto; /* Ensure the image maintains its aspect ratio */
        border-radius: 50%; /* Make the image round */
    }
        /* ... other styles ... */
    </style>
</head>
<body class="bg-light">
    <div class="container mt-5">
        <h2 class="mb-4">Danh sách nhân viên</h2>
        <div class="float-right">
    <a href="../../ManageCustomer/user.php" class="btn btn-warning">Quản lý khách hàng</a>
    <a href="../../ManageDish/manage_products.php" class="btn btn-info">Quản lý món ăn</a>
</div>
        
        <button type="button" class="btn btn-success" data-toggle="modal" data-target="#addStaffModal">
            Thêm nhân viên
        </button>
        <!-- Add the button to trigger the form -->
        <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#bonusFormModal">
            Tính tiền thưởng
        </button>

        <!-- Add the "Manage Products" button on top of the user table -->

<!-- Modal for the bonus calculation form -->
<div class="modal" id="bonusFormModal" tabindex="-1" role="dialog" aria-labelledby="bonusFormModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="bonusFormModalLabel">Bonus Calculation Form</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <!-- Form for entering parameters -->
                <form action="calculate_bonus.php" method="post">
                    <div class="form-group">
                        <label for="eligibleYears">Số năm làm việc tối thiểu:</label>
                        <input type="number" class="form-control" id="eligibleYears" name="eligibleYears" required>
                    </div>
                    <div class="form-group">
                        <label for="baseBonusPercentage">Phần trăm thưởng cơ bản:</label>
                        <input type="number" class="form-control" id="baseBonusPercentage" name="baseBonusPercentage" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Submit</button>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- The modal for adding a new user -->
<div class="modal fade" id="addStaffModal" tabindex="-1" role="dialog" aria-labelledby="addStaffModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addStaffModalLabel">Add Staff</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <!-- Add the form for adding a new user -->
                <form action="insert_staff.php" method="post" enctype="multipart/form-data">
                    <!-- Add your form fields here -->
                    <div class="form-group">
                        <label for="lastName">ID:</label>
                        <input type="text" class="form-control" id="ID" name="ID" required>
                    </div>
                    <div class="form-group">
                        <label for="lastName">Họ và tên lót:</label>
                        <input type="text" class="form-control" id="lastName" name="lastName" required>
                    </div>
                    <div class="form-group">
                        <label for="firstName">Tên:</label>
                        <input type="text" class="form-control" id="firstName" name="firstName" required>
                    </div>
                    <div class="form-group">
                        <label class="d-block">Giới tính:</label>
                        <div class="form-check form-check-inline">
                            <input type="checkbox" class="form-check-input" id="maleCheckbox" name="sex[]" value="M">
                            <label class="form-check-label" for="maleCheckbox">Male</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input type="checkbox" class="form-check-input" id="femaleCheckbox" name="sex[]" value="F">
                            <label class="form-check-label" for="femaleCheckbox">Female</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="birthday">Ngày sinh:</label>
                        <input type="date" class="form-control" id="birthday" name="birthday" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="text" class="form-control" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="startDate">Ngày bắt đầu làm:</label>
                        <input type="date" class="form-control" id="startDate" name="startDate" required>
                    </div>
                    <div class="form-group">
                        <label for="salary">Lương:</label>
                        <input type="number" class="form-control" id="salary" name="salary" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Thêm</button>
                </form>
            </div>
        </div>
    </div>
</div>
        <div class="staff-table-container">
            <table id="staffTable" class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Họ và tên lót</th>
                        <th>Tên</th>
                        <th>Giới tính</th>
                        <th>Ngày sinh</th>
                        <th>Ngày bắt đầu làm</th>
                        <th>Lương</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                        echo '<tr>';
                        echo '<td>' . $row['ID'] . '</td>';
                        echo '<td>' . $row['LName'] . '</td>';
                        echo '<td>' . $row['FName'] . '</td>';
                        echo '<td>' . $row['Sex'] . '</td>';
                        echo '<td>' . $row['Birthday']->format('Y-m-d') . '</td>';
                        echo '<td>' . $row['Start_day']->format('Y-m-d') . '</td>';
                        echo '<td>' . $row['Salary'] . '</td>';
                        echo "<td>";
                        echo '<div style="display: flex;">';
                        echo '<form action="edit_staff.php?id=' . $row['ID'] . '" method="post">';
                        echo '<button type="submit" class="btn btn-primary">Sửa</button>';
                        echo '</form>';
                        echo '<form action="delete_staff.php?id=' . $row['ID'] . '" method="post" onsubmit="return confirm(\'Are you sure you want to delete this staff?\');">';
                        echo '<button type="submit" class="btn btn-danger">Xóa</button>';
                        echo '</form>';
                        echo '</div>';
                        echo "</td>";
                        echo "</tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Bootstrap JS and Popper.js -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <!-- DataTables JS -->
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <script>
        // Initialize DataTable
        $(document).ready(function() {
            $('#userTable').DataTable();
        });
    </script>
</body>
</html>

<?php
// Close the database connection
sqlsrv_close($conn);
?>
