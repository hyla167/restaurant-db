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

// Check if the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $ID = $_POST['ID'];
    $lastName = $_POST['lastName'];
    $firstName = $_POST['firstName'];
    $sexArray = isset($_POST['sex']) ? $_POST['sex'] : array();
    $sex = implode(", ", $sexArray); // Convert array to comma-separated string
    $birthday = $_POST['birthday'];

    // Upload avatar image
    $avatarFileName = $_FILES['avatar']['name'];
    $avatarTempName = $_FILES['avatar']['tmp_name'];
    $avatarPath = "img/" . $avatarFileName; // Adjust the path as needed

    move_uploaded_file($avatarTempName, $avatarPath);

    // Call the InsertCustomer stored procedure
    $sql = "{call InsertCustomer(?, ?, ?, ?, ?, ?)}";
    $params = array($ID, $lastName, $firstName, $sex, $birthday, $avatarPath);
    $stmt = sqlsrv_query($conn, $sql, $params);
    session_start();
    if ($stmt === false) {
        // Format error message using Bootstrap alert
        $errors = array();
        foreach (sqlsrv_errors() as $error) {
            $errors[] = $error['message'];
        }

        // Store errors in session variable
        $_SESSION['insert_errors'] = $errors;
    } else {
        // Success message
        $_SESSION['insert_success'] = "User inserted successfully!";
    }

    // Close the database connection
    sqlsrv_close($conn);

    // Redirect back to user.php after successful insertion
    header("Location: user.php");
    exit();
}
?>

<script>
// Handle close button click
$(".close").on("click", function() {
    $(this).parent().alert('close');
});
</script>
