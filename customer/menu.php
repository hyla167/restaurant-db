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

// Retrieve dishes from the database
$sql = "SELECT * FROM DISH";
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Fetch all categories from the database
$categoriesQuery = "SELECT * FROM CATEGORY";
$categoriesResult = sqlsrv_query($conn, $categoriesQuery);

// Check for query execution success
if ($categoriesResult === false) {
    die(print_r(sqlsrv_errors(), true));
}

// Store the categories in a PHP array
$categories = array();
while ($category = sqlsrv_fetch_array($categoriesResult, SQLSRV_FETCH_ASSOC)) {
    $categories[] = $category['Cat_name'];
}

// Free the result set
sqlsrv_free_stmt($categoriesResult);

session_start();
// Check if the customer is logged in
if (isset($_SESSION['username'])) {
    // Fetch customer information based on the stored username
    $username = $_SESSION['username'];
    $query = "SELECT c.ID, c.Avatar, c.FName FROM CUSTOMER c INNER JOIN CUSTOMER_ACCOUNT ca ON c.ID = ca.ID WHERE ca.Username = ?";
    $params = array($username);
    $result = sqlsrv_query($conn, $query, $params);

    if ($result && sqlsrv_has_rows($result)) {
        $row = sqlsrv_fetch_array($result, SQLSRV_FETCH_ASSOC);
        $customerAvatar = $row['Avatar'];
        $customerFirstName = $row['FName'];
        $_SESSION['customer_id'] = $row['ID'];
        $_SESSION['avatar'] = $row['Avatar'];
        $_SESSION['fname'] = $row['FName'];
    } else {
        // Handle the case where customer information is not found
        $customerAvatar = 'default_avatar.jpg'; // Replace with a default avatar path
        $customerFirstName = 'Customer';
    }
} else {
    // Redirect to the login page if the customer is not logged in
    header("Location: login.php");
    exit();
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu</title>
    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <style>
        /* Add your custom styles here */
        .dish-container {
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

        .dish-image-container {
            height: 150px; /* Set a fixed height for all dish image containers */
            overflow: hidden;
        }

        .dish-image {
            max-width: 100%;
            height: auto;
        }

        body {
            padding-top: 56px; /* Adjust for the fixed top navigation bar */
        }

    </style>
</head>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <a class="navbar-brand" href="#">Restaurant</a>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item active">
                    <a class="nav-link" href="menu.php">Menu</a>
                </li>
                <!-- Order History link -->
                <li class="nav-item">
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


<body class="bg-light">
    <div class="container mt-5">
        <h2 class="mb-4">Menu</h2>
    <div class="container mt-3">
        <!-- Category filter dropdown -->
        <div class="form-group">
            <label for="categoryFilter">Chọn nhóm món ăn:</label>
            <select class="form-control" id="categoryFilter">
                <option value="all">Tất cả</option>
                <?php
                // Display categories in the dropdown
                foreach ($categories as $category) {
                    echo "<option value=\"$category\">$category</option>";
                }
                ?>
            </select>
    </div>
        <div class="dish-container">
            <?php
            while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                echo '<div class="dish-card" data-category="' . $row['Category'] . '">';
                echo '<div class="dish-image-container">';
                echo '<img class="dish-image" src="' . $row['Img'] . '" alt="' . $row['Dish_name'] . '">';
                echo '</div>';
                echo '<h4>' . $row['Dish_name'] . '</h4>';
                echo '<p>' . $row['Dish_des'] . '</p>';
                echo '<p>Giá tiền: ' . $row['Price'] . 'đ</p>';
                echo '<a href="dish_details.php?id=' . $row['ID'] . '" class="btn btn-primary">View</a>';
                echo '</div>';
            }
            ?>
        </div>
    </div>
</div>

    <!-- Bootstrap JS and Popper.js -->
    
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>

    $(document).ready(function () {
        $('#categoryFilter').change(function () {
            var selectedCategory = $(this).val();

            // Show all dishes if "All categories" is selected
            if (selectedCategory === 'all') {
                $('.dish-card').show();
            } else {
                // Hide dishes that don't match the selected category
                $('.dish-card').hide().filter('[data-category="' + selectedCategory + '"]').show();
            }
        });
    });
    </script>
</body>
</html>

<?php
// Close the database connection
sqlsrv_close($conn);
?>
