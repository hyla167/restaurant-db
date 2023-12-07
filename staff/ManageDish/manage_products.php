<!-- manage_products.php -->

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Manage Products</title>
    <!-- Include Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <style>
        /* Add your custom styles here */
        .dish-table-container {
            margin: 20px;
        }
    </style>
</head>
<?php
    session_start();
    if (isset($_SESSION['insert_dish_errors'])) {
        echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
        echo '<strong>Error:</strong> ';

        // Display each error
        foreach ($_SESSION['insert_dish_errors'] as $error) {
            echo $error . '<br>';
        }

        echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
        echo '<span aria-hidden="true">&times;</span>';
        echo '</button>';
        echo '</div>';

        unset($_SESSION['insert_dish_errors']);
    }

    // Check for insert success
    if (isset($_SESSION['insert_dish_success'])) {
        echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . $_SESSION['insert_dish_success'];
        echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
        echo '<span aria-hidden="true">&times;</span>';
        echo '</button>';
        echo '</div>';

        unset($_SESSION['insert_dish_success']);
    }

    if (isset($_SESSION['update_dish_errors'])) {
        echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
        echo '<strong>Error:</strong> ';

        // Display each error
        foreach ($_SESSION['update_dish_errors'] as $error) {
            echo $error . '<br>';
        }

        echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
        echo '<span aria-hidden="true">&times;</span>';
        echo '</button>';
        echo '</div>';

        unset($_SESSION['update_dish_errors']);
    }

    // Check for update success
    if (isset($_SESSION['update_dish_success'])) {
        echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . $_SESSION['update_dish_success'];
        echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
        echo '<span aria-hidden="true">&times;</span>';
        echo '</button>';
        echo '</div>';

        unset($_SESSION['update_dish_success']);
    }

    if (isset($_SESSION['delete_dish_errors'])) {
        echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
        echo '<strong>Error:</strong> ';

        // Display each error
        foreach ($_SESSION['delete_dish_errors'] as $error) {
            echo $error . '<br>';
        }

        echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
        echo '<span aria-hidden="true">&times;</span>';
        echo '</button>';
        echo '</div>';

        unset($_SESSION['delete_dish_errors']);
    }

    // Check for delete success
    if (isset($_SESSION['delete_dish_success'])) {
        echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . $_SESSION['delete_dish_success'];
        echo '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
        echo '<span aria-hidden="true">&times;</span>';
        echo '</button>';
        echo '</div>';

        unset($_SESSION['delete_dish_success']);
    }
?>
<body>

    <div class="container mt-5">
        <h2 class="mb-4">Quản lý món ăn</h2>
        <button type="button" class="btn btn-success" data-toggle="modal" data-target="#addDishModal">
            Thêm món ăn
        </button>
        <button class="btn btn-primary" data-toggle="modal" data-target="#countDishesModal">
            Số món ăn theo nhóm và giá tiền
        </button>
        <button type="button" class="btn btn-info" data-toggle="modal" data-target="#findBestDishesModal">
            Tìm món ăn tốt nhất
        </button>
<!-- Modal for count dishes with price over threshold -->
<div class="modal" id="countDishesModal">
    <div class="modal-dialog">
        <div class="modal-content">

            <!-- Modal Header -->
            <div class="modal-header">
                <h4 class="modal-title">Số món ăn có giá tiền không ít hơn...</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            
            <!-- Modal Body -->
            <div class="modal-body">
                <form action="count_dishes.php" method="post">
            <div class="form-group">
                <label for="threshold">Giá tiền tối thiểu:</label>
                <input type="number" class="form-control" name="threshold" required>
            </div>
            <button type="submit" class="btn btn-primary" name="countDishes">Xong</button>
                </form>
            </div>

            <!-- Modal Footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
            </div>

        </div>
    </div>
</div>

<div class="modal fade" id="findBestDishesModal" tabindex="-1" role="dialog" aria-labelledby="findBestDishesModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="findBestDishesModalLabel">Find Best Dishes</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="bestDishesForm">
                    <div class="form-group">
                        <label for="minRating">Minimum Rating:</label>
                        <input type="number" step="0.01" class="form-control" name="minRating" required>
                    </div>
                    <div class="form-group">
                        <label for="minNumReviews">Minimum Number of Reviews:</label>
                        <input type="number" class="form-control" name="minNumReviews" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Find</button>
                </form>
            </div>
        </div>
    </div>
</div>

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

        // Fetch and display the dishes from the DISH entity
        $sqlGetDishes = "SELECT ID, Dish_name, Category, Dish_des, Price, Rating FROM DISH";
        $stmtGetDishes = sqlsrv_query($conn, $sqlGetDishes);

        if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["countDishes"])) {
            // Open the modal when the form is submitted
            echo "<script>$('#countDishesModal').modal('show');</script>";
        }

        if ($stmtGetDishes === false) {
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
        ?>
        <div class="dish-table-container">
            <table id="dishTable" class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên</th>
                        <th>Nhóm</th>
                        <th>Mô tả</th>
                        <th>Rating</th>
                        <th>Giá tiền</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    while ($row = sqlsrv_fetch_array($stmtGetDishes, SQLSRV_FETCH_ASSOC)) {
                        echo '<tr>';
                        echo '<td>' . $row['ID'] . '</td>';
                        echo '<td>' . $row['Dish_name'] . '</td>';
                        echo '<td>' . $row['Category'] . '</td>';
                        echo '<td>' . $row['Dish_des'] . '</td>';
                        echo '<td>' . $row['Rating'] . '</td>';
                        echo '<td>' . $row['Price'] . 'đ</td>';
                        echo "<td>";
                        echo '<div style="display: flex;">';
                        echo '<form action="edit_dish.php?id=' . $row['ID'] . '" method="post">';
                        echo '<button type="submit" class="btn btn-primary">Sửa</button>';
                        echo '</form>';
                        echo '<form action="delete_dish.php?id=' . $row['ID'] . '" method="post" onsubmit="return confirm(\'Are you sure you want to delete this dish?\');">';
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

<!-- The modal for adding a new user -->
<div class="modal fade" id="addDishModal" tabindex="-1" role="dialog" aria-labelledby="addDishModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addDishModalLabel">Thêm món ăn</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <!-- Add the form for adding a new user -->
                <form action="insert_dish.php" method="post" enctype="multipart/form-data">
                    <!-- Add your form fields here -->
                    <div class="form-group">
                        <label for="ID">ID:</label>
                        <input type="number" class="form-control" id="ID" name="ID" required>
                    </div>
                    <div class="form-group">
                        <label for="dishName">Tên món ăn:</label>
                        <input type="text" class="form-control" id="dishName" name="dishName" required>
                    </div>
                    <div class="form-group">
                        <label for="category">Nhóm món ăn:</label>
                        <select class="form-control" name = 'category' id="category">
                            <?php
                            // Display categories in the dropdown
                            foreach ($categories as $category) {
                                echo "<option value=\"$category\">$category</option>";
                            }
                            ?>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="description">Mô tả:</label>
                        <input type="text" class="form-control" id="description" name="description">
                    </div>
                    <div class="form-group">
                        <label for="price">Giá tiền:</label>
                        <input type="number" class="form-control" id="price" name="price" required>
                    </div>
                    <div class="form-group">
                        <label for="img">Ảnh món ăn:</label>
                        <input type="file" class="form-control-file" id="img" name="img" accept="image/*" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Thêm</button>
                </form>
            </div>
        </div>
    </div>
</div>

    <!-- Include Bootstrap JavaScript and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <!-- DataTables JS -->
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <script>
        // Initialize DataTable
        $(document).ready(function() {
            $('#dishTable').DataTable();
        });

        $(document).ready(function () {
        $("#bestDishesForm").submit(function (event) {
            event.preventDefault();
            let minRating = $("input[name='minRating']").val();
            let minNumReviews = $("input[name='minNumReviews']").val();

            // Redirect to find_best_dishes.php with parameters
            window.location.href = `find_best_dishes.php?minRating=${minRating}&minNumReviews=${minNumReviews}`;
        });
    });
    </script>

</body>

</html>
<?php
        // Free the statement resources
        sqlsrv_free_stmt($stmtGetDishes);

        // Close the database connection
        sqlsrv_close($conn);
        ?>