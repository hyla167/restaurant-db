<?php
// update.php

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

// Check if form data is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $customerId = $_POST['id'];
    $firstName = $_POST['firstName'];
    $lastName = $_POST['lastName'];
    $sex = $_POST['sex'];
    $birthday = $_POST['birthday'];
    $avatar = $_POST['avatar'];
    $points = $_POST['points'];

    // Update customer data using the UpdateCustomer stored procedure
    $sqlUpdate = "{call UpdateCustomer(?, ?, ?, ?, ?, ?, ?)}";
    $paramsUpdate = array(
        array($customerId, SQLSRV_PARAM_IN),
        array($firstName, SQLSRV_PARAM_IN),
        array($lastName, SQLSRV_PARAM_IN),
        array($sex, SQLSRV_PARAM_IN),
        array($birthday, SQLSRV_PARAM_IN),
        array($avatar, SQLSRV_PARAM_IN),
        array($points, SQLSRV_PARAM_IN)
    );

    $stmtUpdate = sqlsrv_query($conn, $sqlUpdate, $paramsUpdate);

    // if ($stmtUpdate === false) {
    //     die(print_r(sqlsrv_errors(), true));
    // }
    session_start();
    if ($stmtUpdate === false) {
        // Format error message using Bootstrap alert
        $errors = array();
        foreach (sqlsrv_errors() as $error) {
            $errors[] = $error['message'];
        }

        // Store errors in session variable
        $_SESSION['update_errors'] = $errors;
    } else {
        // Success message
        $_SESSION['update_success'] = "User updated successfully!";
    }

    // Redirect back to user.php after update
    header("Location: user.php");
    exit();
} else {
    echo "Invalid request.";
}

// Close the database connection
sqlsrv_close($conn);
?>

<script>
// Handle close button click
$(".close").on("click", function() {
    $(this).parent().alert('close');
});
</script>