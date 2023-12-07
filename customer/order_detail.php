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

$customerAvatar = $_SESSION['avatar'];
$customerFirstName = $_SESSION['fname'];

// Fetch order items from the database based on the order ID (use prepared statements to prevent SQL injection)
$orderId = $_GET['id']; // Assuming you are passing the order ID through the URL
$query = "SELECT Dish_name, Amount, SubTotal FROM OrderItem 
          INNER JOIN DISH ON OrderItem.Dish_id = DISH.ID
          WHERE OrderItem.Order_id = ?";
$params = array($_GET['id']);
$result = sqlsrv_query($conn, $query, $params);

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Chi tiết đơn hàng</title>
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
        <h2 class="mb-4">Chi tiết đơn hàng</h2>
        <!-- Add a select element for order type -->
        <?php
        // Display the table structure for TABLE_ORDER
        echo '<table border="1" id="orderDetail" class="table table-bordered">';
        echo '<thead>';
        echo '<tr>';
        echo '<th>Tên món ăn</th>';
        echo '<th>Số lượng</th>';
        echo '<th>Tổng tiền (VND)</th>';
        echo '</tr>';
        echo '</thead>';
        echo '<tbody>';
        
        $totalQuantity = 0;
        $totalPrice = 0;
        // Fetch data for TABLE_ORDER
        while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC)) {
            echo '<tr>';
            echo '<td>' . $row['Dish_name'] . '</td>';
            echo '<td>' . $row['Amount'] . '</td>';
            echo '<td>' . $row['SubTotal'] . '</td>';
            echo '</tr>';
            // Update total quantity and total price
            $totalQuantity += $row['Amount'];
            $totalPrice += $row['SubTotal'];
        }
        // Display the total line
        echo '<tr>';
        echo '<td><b><u>Tổng cộng</b></u></td>';
        echo '<td><b>' . $totalQuantity . '</b></td>';
        echo '<td><b>' . $totalPrice . '</b></td>';
        echo '</tr>';
        
        echo '</tbody>';
        echo '</table>';
        ?>
    </div>
</div>

    <!-- Bootstrap JS and Popper.js -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <!-- DataTables JS -->
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <script>
    $(document).ready(function () {
      var orderDetailTable = $('#orderDetail').DataTable({
        // Add any additional configuration options here
      });
    });
    </script>
</body>
</html>

<?php
// Close the database connection
sqlsrv_close($conn);
?>
