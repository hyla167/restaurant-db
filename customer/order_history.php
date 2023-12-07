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

// Query for TABLE_ORDER
$tableOrderQuery = "SELECT CUS_ORDER.ID, BRANCH.Branch_add, CUS_ORDER.Original_price, CUS_ORDER.Discounted_price, CUS_ORDER.Order_status
                   FROM CUS_ORDER
                   INNER JOIN TABLE_ORDER ON CUS_ORDER.ID = TABLE_ORDER.Order_id
                   INNER JOIN BRANCH ON CUS_ORDER.Branch_id = BRANCH.ID
                   WHERE CUS_ORDER.Customer_id = ?";

// Query for ONLINE_ORDER
$onlineOrderQuery = "SELECT CUS_ORDER.ID, CUS_ORDER.Original_price, CUS_ORDER.Discounted_price, ONLINE_ORDER.Order_add, CONVERT(VARCHAR, ONLINE_ORDER.Start_time, 120) AS Start_time, CONVERT(VARCHAR, ONLINE_ORDER.End_time, 120) AS End_time, CUS_ORDER.Order_status
                     FROM CUS_ORDER
                     INNER JOIN ONLINE_ORDER ON CUS_ORDER.ID = ONLINE_ORDER.Order_id
                     WHERE CUS_ORDER.Customer_id = ?";
// Parameters for both queries
$params = array($_GET['id']);  // Assuming you get the customer ID from the URL parameter

// Execute queries
$tableOrderStmt = sqlsrv_query($conn, $tableOrderQuery, $params);
$onlineOrderStmt = sqlsrv_query($conn, $onlineOrderQuery, $params);


    // Rest of the code remains the same
} else {
    // Redirect to the login page if the customer ID is not provided
    header("Location: login.php");
    exit();
}

// Fetch order history based on the provided customer ID
// $query = "SELECT ID AS OrderID, Original_price, Discounted_price, Order_status
// FROM CUS_ORDER
// WHERE Customer_id = ?";
// $params = array($customerID);
// $result = sqlsrv_query($conn, $query, $params);

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
        .order-history-container {
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
                <li class="nav-item active">
                    <?php
                    if (isset($_SESSION['customer_id'])) {
                        $customerID = $_SESSION['customer_id'];
                        echo "<a class='nav-link' href='order_history.php?id=$customerID'>Lịch sử đơn hàng</a>";
                    }
                    ?>
                </li>

                <!-- Voucher link -->
                <li class="nav-item">
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
        <h2 class="mb-4">Lịch sử đơn hàng</h2>
        <!-- Add a select element for order type -->
        <?php
        echo '<label for="orderTypeSelect">Chọn loại đơn hàng:</label>';
        echo '<select id="orderTypeSelect" name="orderTypeSelect" class="form-select" onchange="toggleOrderType()">';
        echo '<option value="table" selected>Đơn hàng tại chỗ</option>';
        echo '<option value="online">Đơn hàng mang về</option>';
        echo '</select>';
        
        // Display the table structure for TABLE_ORDER
        echo '<table border="1" id="tableOrder" class="table table-bordered">';
        echo '<thead>';
        echo '<tr>';
        echo '<th>ID</th>';
        echo '<th>Địa chỉ chi nhánh</th>';
        echo '<th>Tổng tiền gốc</th>';
        echo '<th>Tổng tiền thực tế</th>';
        echo '<th>Tình trạng</th>';
        echo '<th>Thao tác</th>';
        echo '</tr>';
        echo '</thead>';
        echo '<tbody>';
        
        // Fetch data for TABLE_ORDER
        while ($tableOrder = sqlsrv_fetch_array($tableOrderStmt, SQLSRV_FETCH_ASSOC)) {
            echo '<tr>';
            echo '<td>' . $tableOrder['ID'] . '</td>';
            echo '<td>' . $tableOrder['Branch_add'] . '</td>';
            echo '<td>' . $tableOrder['Original_price'] . '</td>';
            echo '<td>' . $tableOrder['Discounted_price'] . '</td>';
            echo '<td>' . $tableOrder['Order_status'] . '</td>';
            echo '<td>';
            echo '<button type="button" class="btn btn-primary" onclick="viewOrderDetail(' . $tableOrder['ID'] . ')">Xem chi tiết</button>';
            echo '</td>';
            echo '</tr>';
        }
        
        echo '</tbody>';
        echo '</table>';
        
        // Display the table structure for ONLINE_ORDER
        echo '<table border="1" id="onlineOrder" class="table table-bordered">';
        echo '<thead>';
        echo '<tr>';
        echo '<th>ID</th>';
        echo '<th>Tổng tiền gốc</th>';
        echo '<th>Tổng tiền thực tế</th>';
        echo '<th>Địa chỉ mang về</th>';
        echo '<th>Thời gian bắt đầu</th>';
        echo '<th>Thời gian kết thúc</th>';
        echo '<th>Tình trạng đơn hàng</th>';
        echo '<th>Thao tác</th>';
        echo '</tr>';
        echo '</thead>';
        echo '<tbody>';
        
        // Fetch data for ONLINE_ORDER
        while ($onlineOrder = sqlsrv_fetch_array($onlineOrderStmt, SQLSRV_FETCH_ASSOC)) {
            echo '<tr>';
            echo '<td>' . $onlineOrder['ID'] . '</td>';
            echo '<td>' . $onlineOrder['Original_price'] . '</td>';
            echo '<td>' . $onlineOrder['Discounted_price'] . '</td>';
            echo '<td>' . $onlineOrder['Order_add'] . '</td>';
            echo '<td>' . $onlineOrder['Start_time'] . '</td>';
            echo '<td>' . $onlineOrder['End_time'] . '</td>';
            echo '<td>' . $onlineOrder['Order_status'] . '</td>';
            echo '<td>';
            echo '<button type="button" class="btn btn-primary" onclick="viewOrderDetail(' . $onlineOrder['ID'] . ')">Xem chi tiết</button>';
            echo '</td>';
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
            $('#tableOrder').DataTable();
            // $('#onlineOrder').DataTable();
        });
    // document.getElementById('tableOrder').style.display = 'table';
    document.getElementById('onlineOrder').style.display = 'none';
  };

        function toggleOrderType() {
        var selectedType = document.getElementById('orderTypeSelect').value;

        if (selectedType === 'table') {
        document.getElementById('tableOrder').style.display = 'table';
        document.getElementById('onlineOrder').style.display = 'none';
        $(document).ready(function() {
            $('#onlineOrder').DataTable().destroy();
            $('#tableOrder').DataTable();
        });
        } else if (selectedType === 'online') {
        document.getElementById('tableOrder').style.display = 'none';
        document.getElementById('onlineOrder').style.display = 'table';
        $(document).ready(function() {
            $('#tableOrder').DataTable().destroy();
            $('#onlineOrder').DataTable();
        });
        }
    }

    function viewOrderDetail(orderId) {
        window.location.href = 'order_detail.php?id=' + orderId;
    }
 
    </script>
</body>
</html>

<?php
// Close the database connection
sqlsrv_close($conn);
?>
