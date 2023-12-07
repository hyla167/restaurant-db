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

// Retrieve users from the database
$sql = "SELECT C.ID, A.Username, C.LName, C.FName, C.Sex, C.Birthday, C.Avatar, C.Point
        FROM CUSTOMER C
        FULL OUTER JOIN CUSTOMER_ACCOUNT A ON C.ID = A.ID";
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Check if the form for finding customers by minPoints is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["findCustomers"])) {
    // Open the modal when the form is submitted
    echo "<script>$('#findCustomersModal').modal('show');</script>";
}

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["manageProducts"])) {
    // Redirect to the manage_products.php page
    echo "<script>window.location.href = '../ManageDish/manage_products.php';</script>";
    // Stop further execution to prevent including manage_products.php in the current page
    exit();
}

session_start();
if (isset($_SESSION['insert_errors'])) {
    echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
    echo '<strong>Error:</strong> ';

    // Display each error
    foreach ($_SESSION['insert_errors'] as $error) {
        echo $error . '<br>';
    }

    echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    echo '<span aria-hidden="true">&times;</span>';
    echo '</button>';
    echo '</div>';

    unset($_SESSION['insert_errors']);
}

// Check for insert success
if (isset($_SESSION['insert_success'])) {
    echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . $_SESSION['insert_success'];
    echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    echo '<span aria-hidden="true">&times;</span>';
    echo '</button>';
    echo '</div>';

    unset($_SESSION['insert_success']);
}

if (isset($_SESSION['update_errors'])) {
    echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
    echo '<strong>Error:</strong> ';

    // Display each error
    foreach ($_SESSION['update_errors'] as $error) {
        echo $error . '<br>';
    }

    echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    echo '<span aria-hidden="true">&times;</span>';
    echo '</button>';
    echo '</div>';

    unset($_SESSION['update_errors']);
}

// Check for update success
if (isset($_SESSION['update_success'])) {
    echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . $_SESSION['update_success'];
    echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    echo '<span aria-hidden="true">&times;</span>';
    echo '</button>';
    echo '</div>';

    unset($_SESSION['update_success']);
}

if (isset($_SESSION['delete_errors'])) {
    echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
    echo '<strong>Error:</strong> ';

    // Display each error
    foreach ($_SESSION['delete_errors'] as $error) {
        echo $error . '<br>';
    }

    echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    echo '<span aria-hidden="true">&times;</span>';
    echo '</button>';
    echo '</div>';

    unset($_SESSION['delete_errors']);
}

// Check for delete success
if (isset($_SESSION['delete_success'])) {
    echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . $_SESSION['delete_success'];
    echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    echo '<span aria-hidden="true">&times;</span>';
    echo '</button>';
    echo '</div>';

    unset($_SESSION['delete_success']);
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
        <h2 class="mb-4">Danh sách khách hàng</h2>
        <div class="mb-3">
            <form method="post">
            <button class="btn btn-info float-right" name="manageProducts">Quản lý món ăn</button>
            </form>
        </div>
        <div style="display: flex;">
        <button type="button" class="btn btn-success" data-toggle="modal" data-target="#addUserModal">
            Thêm khách hàng
        </button>

        <!-- Add the button and form for finding customers by minPoints -->

        <button class="btn btn-primary" data-toggle="modal" data-target="#findCustomersModal">
            Tìm khách hàng có điểm tích lũy không ít hơn...
        </button>

        <!-- Add the "Manage Products" button on top of the user table -->
        </div>
<!-- Modal for finding customers by minPoints -->
<div class="modal" id="findCustomersModal">
    <div class="modal-dialog">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header">
                <h4 class="modal-title">Tìm khách hàng có điểm tích lũy không ít hơn...</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            
            <!-- Modal Body -->
            <div class="modal-body">
                <form action="get_customers_by_min_points.php" method="post">
            <div class="form-group">
                <label for="minPoints">Điểm tối thiểu:</label>
                <input type="number" class="form-control" name="minPoints" required>
            </div>
            <button type="submit" class="btn btn-primary" name="findCustomers">Tìm khách hàng</button>
                </form>
            </div>

            <!-- Modal Footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
            </div>

        </div>
    </div>
</div>


<!-- The modal for adding a new user -->
<div class="modal fade" id="addUserModal" tabindex="-1" role="dialog" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addUserModalLabel">Thêm khách hàng</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <!-- Add the form for adding a new user -->
                <form action="insert.php" method="post" enctype="multipart/form-data">
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
                            <label class="form-check-label" for="maleCheckbox">Nam</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input type="checkbox" class="form-check-input" id="femaleCheckbox" name="sex[]" value="F">
                            <label class="form-check-label" for="femaleCheckbox">Nữ</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="birthday">Ngày sinh:</label>
                        <input type="date" class="form-control" id="birthday" name="birthday" required>
                    </div>
                    <div class="form-group">
                        <label for="avatar">Avatar:</label>
                        <input type="file" class="form-control-file" id="avatar" name="avatar" accept="image/*" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Thêm</button>
                </form>
            </div>
        </div>
    </div>
</div>
        <div class="user-table-container">
            <table id="userTable" class="table">
                <thead>
                    <tr>
                        <th>Tên đăng nhập</th>
                        <th>Họ và tên lót</th>
                        <th>Tên</th>
                        <th>Giới tính</th>
                        <th>Ngày sinh</th>
                        <th>Avatar</th>
                        <th>Điểm</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                        echo '<tr>';
                        echo '<td>' . $row['Username'] . '</td>';
                        echo '<td>' . $row['LName'] . '</td>';
                        echo '<td>' . $row['FName'] . '</td>';
                        echo '<td>' . $row['Sex'] . '</td>';
                        echo '<td>' . $row['Birthday']->format('Y-m-d') . '</td>';
                        echo '<td><img src="' . $row['Avatar'] . '" alt="Avatar" class="avatar-image"></td>';
                        echo '<td>' . $row['Point'] . '</td>';
                        echo "<td>";
                        echo '<div style="display: flex;">';
                        echo '<form action="edit.php?id=' . $row['ID'] . '" method="post">';
                        echo '<button type="submit" class="btn btn-primary">Chỉnh sửa</button>';
                        echo '</form>';
                        echo '<form action="delete.php?id=' . $row['ID'] . '" method="post" onsubmit="return confirm(\'Are you sure you want to delete this customer?\');">';
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
