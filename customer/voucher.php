<?php
// Start the session (this should be at the top of your PHP files)
session_start();

// Assume you have a database connection established
// Replace with your actual database connection code
$serverName = "HYLA";
$connectionOptions = array(
    "Database" => "RESTAURANT",
    "Uid" => "",
    "PWD" => "",
    "CharacterSet" => "UTF-8"
);

$conn = sqlsrv_connect($serverName, $connectionOptions);

// Check connection
if (!$conn) {
    die(print_r(sqlsrv_errors(), true));
}

// Check if the customer ID is provided in the URL
if (isset($_GET['id'])) {
    $customerID = $_GET['id'];
    $customerAvatar = $_SESSION['avatar'];
    $customerFirstName = $_SESSION['fname'];

// Query for VOUCHER_ORDER
$voucherOrderQuery = "SELECT VOUCHER.ID, VOUCHER.Point, VOUCHER.Percent_discount, VOUCHER.Date_expired
                   FROM VOUCHER
                   INNER JOIN VOUCHER_ORDER ON VOUCHER.ID = VOUCHER_ORDER.ID
                   WHERE VOUCHER.Customer_id = ?";

// Query for VOUCHER_CAT
$voucherCatQuery = "SELECT VOUCHER.ID, CATEGORY.Cat_name, VOUCHER.Point, VOUCHER.Percent_discount, VOUCHER.Date_expired
                    FROM VOUCHER
                    INNER JOIN VOUCHER_CAT ON VOUCHER.ID = VOUCHER_CAT.ID
                    INNER JOIN CATEGORY ON VOUCHER_CAT.Category_id = CATEGORY.ID
                    WHERE VOUCHER.Customer_id = ?";
// Parameters for both queries
$params = array($_GET['id']);  // Assuming you get the customer ID from the URL parameter

// Execute queries
$voucherOrderStmt = sqlsrv_query($conn, $voucherOrderQuery, $params);
$voucherCatStmt = sqlsrv_query($conn, $voucherCatQuery, $params);


    // Rest of the code remains the same
} else {
    // Redirect to the login page if the customer ID is not provided
    header("Location: login.php");
    exit();
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Order History</title>
    <!-- Include Bootstrap CSS (adjust the path accordingly) -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    
    <style>
        /* Add your custom styles here */
        .voucher-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-around;
            margin: 20px;
        }

        .dish-card {
            width: 300px;
            margin: 10px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }
        body {
            padding-top: 56px; /* Adjust for the fixed top navigation bar */
        }

    </style>
</head>
<body class="bg-light">
    <!-- Navigation Bar (if needed) -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <a class="navbar-brand" href="#">Restaurant</a>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item">
                    <a class="nav-link" href="menu.php">Menu</a>
                </li>
                <li class="nav-item">
                    <?php
                    if (isset($_SESSION['customer_id'])) {
                        $customerID = $_SESSION['customer_id'];
                        echo "<a class='nav-link' href='order_history.php?id=$customerID'>Lịch sử đơn hàng</a>";
                    }
                    ?>
                </li>

                <!-- Voucher link -->
                <li class="nav-item active">
                    <?php
                    if (isset($_SESSION['customer_id'])) {
                        $customerID = $_SESSION['customer_id'];
                        echo "<a class='nav-link' href='voucher.php?id=$customerID'>Voucher</a>";
                    }
                    ?>
                </li>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <img src="<?php echo $customerAvatar; ?>" alt="Customer Avatar" width="40" class="rounded-circle mr-2">
                    <span class="navbar-text mr-2"><?php echo $customerFirstName; ?></span>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="logout.php">Logout</a>
                </li>
            </ul>
        </div>
    </nav>

    <div class="container mt-5">
        <h2 class="mb-4">Danh sách voucher</h2>
        <!-- Add a select element for order type -->
        <?php
        echo '<label for="orderTypeSelect">Chọn loại voucher:</label>';
        echo '<select id="orderTypeSelect" name="orderTypeSelect" class="form-select" onchange="toggleOrderType()">';
        echo '<option value="order" selected>Voucher theo hóa đơn</option>';
        echo '<option value="category">Voucher theo nhóm món ăn</option>';
        echo '</select>';
        
        // Display the table structure for TABLE_ORDER
        echo '<table border="1" id="voucherOrder" class="table table-bordered">';
        echo '<thead>';
        echo '<tr>';
        echo '<th>ID</th>';
        echo '<th>Điểm quy đổi</th>';
        echo '<th>Phần trăm giảm</th>';
        echo '<th>Ngày hết hạn</th>';
        echo '</tr>';
        echo '</thead>';
        echo '<tbody>';
        
        // Fetch data for TABLE_ORDER
        while ($voucherOrder = sqlsrv_fetch_array($voucherOrderStmt, SQLSRV_FETCH_ASSOC)) {
            echo '<tr>';
            echo '<td>' . $voucherOrder['ID'] . '</td>';
            echo '<td>' . $voucherOrder['Point'] . '</td>';
            echo '<td>' . $voucherOrder['Percent_discount'] . '</td>';
            echo '<td>' . $voucherOrder['Date_expired']->format('Y-m-d') . '</td>';
            echo '</tr>';
        }
        
        echo '</tbody>';
        echo '</table>';
        
        // Display the table structure for ONLINE_ORDER
        echo '<table border="1" id="voucherCat" class="table table-bordered">';
        echo '<thead>';
        echo '<tr>';
        echo '<th>ID</th>';
        echo '<th>Nhóm món ăn</th>';
        echo '<th>Điểm quy đổi</th>';
        echo '<th>Phần trăm giảm</th>';
        echo '<th>Ngày hết hạn</th>';
        echo '</tr>';
        echo '</thead>';
        echo '<tbody>';
        
        // Fetch data for ONLINE_ORDER
        while ($voucherCat = sqlsrv_fetch_array($voucherCatStmt, SQLSRV_FETCH_ASSOC)) {
            echo '<tr>';
            echo '<td>' . $voucherCat['ID'] . '</td>';
            echo '<td>' . $voucherCat['Cat_name'] . '</td>';
            echo '<td>' . $voucherCat['Point'] . '</td>';
            echo '<td>' . $voucherCat['Percent_discount'] . '</td>';
            echo '<td>' . $voucherCat['Date_expired']->format('Y-m-d') . '</td>';
            echo '</tr>';
        }
        
        echo '</tbody>';
        echo '</table>';
        ?>
    </div>
</div>

    <!-- Bootstrap JS and Popper.js -->
    
    <!-- Bootstrap JS and Popper.js -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <!-- DataTables JS -->
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <script>

        window.onload = function () {
            $(document).ready(function() {
            $('#voucherOrder').DataTable();
            // $('#voucherCat').DataTable();
        });
    // document.getElementById('voucherOrder').style.display = 'table';
    document.getElementById('voucherCat').style.display = 'none';
  };

        function toggleOrderType() {
        var selectedType = document.getElementById('orderTypeSelect').value;

        if (selectedType === 'order') {
        document.getElementById('voucherOrder').style.display = 'table';
        document.getElementById('voucherCat').style.display = 'none';
        $(document).ready(function() {
            $('#voucherCat').DataTable().destroy();
            $('#voucherOrder').DataTable();
        });
        } else if (selectedType === 'category') {
        document.getElementById('voucherOrder').style.display = 'none';
        document.getElementById('voucherCat').style.display = 'table';
        $(document).ready(function() {
            $('#voucherOrder').DataTable().destroy();
            $('#voucherCat').DataTable();
        });
        }
    }

    function viewVoucher(orderId) {
        window.location.href = 'voucher.php?id=' + orderId;
    }
 
    </script>
</body>
</html>

<?php
// Close the database connection
sqlsrv_close($conn);
?>
