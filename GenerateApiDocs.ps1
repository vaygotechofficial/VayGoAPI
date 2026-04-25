# VayGo API Documentation Generator
# Creates a professional Word document with all API endpoints, payloads, and data flows

$outputPath = "d:\vaygoApi\VayGoAPI\VayGo_API_Documentation.docx"

# Create Word COM object
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()
$doc.PageSetup.LeftMargin = $word.InchesToPoints(1)
$doc.PageSetup.RightMargin = $word.InchesToPoints(1)
$doc.PageSetup.TopMargin = $word.InchesToPoints(1)
$doc.PageSetup.BottomMargin = $word.InchesToPoints(1)

$selection = $word.Selection

# Helper Functions
function Add-Heading1 {
    param([string]$text)
    $selection.Style = $doc.Styles["Heading 1"]
    $selection.TypeText($text)
    $selection.TypeParagraph()
}

function Add-Heading2 {
    param([string]$text)
    $selection.Style = $doc.Styles["Heading 2"]
    $selection.TypeText($text)
    $selection.TypeParagraph()
}

function Add-Heading3 {
    param([string]$text)
    $selection.Style = $doc.Styles["Heading 3"]
    $selection.TypeText($text)
    $selection.TypeParagraph()
}

function Add-NormalText {
    param([string]$text)
    $selection.Style = $doc.Styles["Normal"]
    $selection.TypeText($text)
    $selection.TypeParagraph()
}

function Add-BoldText {
    param([string]$text)
    $selection.Style = $doc.Styles["Normal"]
    $selection.Font.Bold = $true
    $selection.TypeText($text)
    $selection.Font.Bold = $false
    $selection.TypeParagraph()
}

function Add-CodeBlock {
    param([string]$text)
    $selection.Style = $doc.Styles["Normal"]
    $selection.Font.Name = "Courier New"
    $selection.Font.Size = 9
    $selection.Font.Color = [Microsoft.Office.Interop.Word.WdColor]::wdColorDarkBlue
    foreach ($line in $text -split "`n") {
        $selection.TypeText($line)
        $selection.TypeParagraph()
    }
    $selection.Font.Name = "Calibri"
    $selection.Font.Size = 11
    $selection.Font.Color = [Microsoft.Office.Interop.Word.WdColor]::wdColorAutomatic
}

function Add-Table {
    param(
        [string[]]$headers,
        [string[][]]$rows,
        [string]$caption = ""
    )

    $numCols = $headers.Count
    $numRows = $rows.Count + 1

    $table = $doc.Tables.Add($selection.Range, $numRows, $numCols)
    $table.Style = "Table Grid"
    $table.Borders.Enable = $true

    # Header row
    $table.Rows[1].Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorDarkBlue
    for ($c = 1; $c -le $numCols; $c++) {
        $cell = $table.Cell(1, $c)
        $cell.Range.Text = $headers[$c-1]
        $cell.Range.Font.Bold = $true
        $cell.Range.Font.Color = [Microsoft.Office.Interop.Word.WdColor]::wdColorWhite
        $cell.Range.Font.Size = 10
    }

    # Data rows
    for ($r = 0; $r -lt $rows.Count; $r++) {
        $rowData = $rows[$r]
        if (($r % 2) -eq 0) {
            $table.Rows[$r+2].Shading.BackgroundPatternColor = [Microsoft.Office.Interop.Word.WdColor]::wdColorLightBlue
        }
        for ($c = 1; $c -le [Math]::Min($numCols, $rowData.Count); $c++) {
            $cell = $table.Cell($r+2, $c)
            $cell.Range.Text = $rowData[$c-1]
            $cell.Range.Font.Size = 9
        }
    }

    $table.Columns.AutoFit()

    # Move past table
    $selection.MoveDown([Microsoft.Office.Interop.Word.WdUnits]::wdLine, 1)
    $selection.TypeParagraph()
}

function Add-PageBreak {
    $selection.InsertBreak([Microsoft.Office.Interop.Word.WdBreakType]::wdPageBreak)
}

function Add-HorizontalLine {
    $selection.Style = $doc.Styles["Normal"]
    $selection.TypeText("_" * 80)
    $selection.TypeParagraph()
}

# ============================================================
# TITLE PAGE
# ============================================================
$selection.Style = $doc.Styles["Normal"]
$selection.Font.Size = 36
$selection.Font.Bold = $true
$selection.Font.Color = [Microsoft.Office.Interop.Word.WdColor]::wdColorDarkBlue
$selection.ParagraphFormat.Alignment = [Microsoft.Office.Interop.Word.WdParagraphAlignment]::wdAlignParagraphCenter
$selection.TypeParagraph()
$selection.TypeParagraph()
$selection.TypeParagraph()
$selection.TypeText("VayGo API")
$selection.TypeParagraph()
$selection.Font.Size = 24
$selection.TypeText("Complete API Documentation")
$selection.TypeParagraph()
$selection.TypeParagraph()
$selection.Font.Size = 14
$selection.Font.Bold = $false
$selection.Font.Color = [Microsoft.Office.Interop.Word.WdColor]::wdColorGray50
$selection.TypeText("Ride-Sharing Platform - Backend API Reference")
$selection.TypeParagraph()
$selection.TypeText("Version 1.0  |  Generated: $(Get-Date -Format 'MMMM dd, yyyy')")
$selection.TypeParagraph()
$selection.TypeParagraph()
$selection.Font.Size = 12
$selection.Font.Color = [Microsoft.Office.Interop.Word.WdColor]::wdColorAutomatic
$selection.ParagraphFormat.Alignment = [Microsoft.Office.Interop.Word.WdParagraphAlignment]::wdAlignParagraphLeft

Add-PageBreak

# ============================================================
# TABLE OF CONTENTS
# ============================================================
$selection.Font.Bold = $false
$selection.Font.Size = 11
Add-Heading1 "Table of Contents"
$selection.Style = $doc.Styles["Normal"]
$toc = $doc.TablesOfContents.Add($selection.Range, $true, 1, 3)
$selection.TypeParagraph()

Add-PageBreak

# ============================================================
# SECTION 1: OVERVIEW
# ============================================================
Add-Heading1 "1. System Overview"

Add-NormalText "VayGo is a ride-sharing platform API built with ASP.NET Core 8.0 and MySQL. It supports two user types: Riders (passengers) and Drivers (service providers). The system includes OTP-based authentication, driver KYC verification, subscription-based driver access, real-time ride management, and payment processing."

Add-Heading2 "1.1 Base URL"
Add-CodeBlock "https://<your-domain>/api"

Add-Heading2 "1.2 Authentication"
Add-NormalText "All protected endpoints require a JWT Bearer token obtained from the /api/auth/verify-otp endpoint."
Add-CodeBlock "Authorization: Bearer <jwt_token>"

Add-Heading2 "1.3 User Roles"
$roleHeaders = @("Role", "Description", "Accessible Endpoints")
$roleRows = @(
    @("user", "Regular passenger/rider", "/api/auth, /api/user, /api/ride"),
    @("driver", "Vehicle driver (service provider)", "/api/auth, /api/rider, /api/subscription"),
    @("admin", "Platform administrator", "/api/auth, /api/admin")
)
Add-Table -headers $roleHeaders -rows $roleRows

Add-Heading2 "1.4 API Modules"
$moduleHeaders = @("Module", "Base Route", "Purpose")
$moduleRows = @(
    @("Authentication", "/api/auth", "OTP-based login for users and drivers"),
    @("User", "/api/user", "User profile management"),
    @("Rider (Driver)", "/api/rider", "Driver registration, KYC, ride operations"),
    @("Ride", "/api/ride", "Ride requests and history for passengers"),
    @("Subscription", "/api/subscription", "Driver subscription plans and payments"),
    @("Payment", "/api/payment", "UPI payment webhook processing"),
    @("Admin", "/api/admin", "Driver approval, reports, platform management")
)
Add-Table -headers $moduleHeaders -rows $moduleRows

Add-PageBreak

# ============================================================
# SECTION 2: AUTHENTICATION APIs
# ============================================================
Add-Heading1 "2. Authentication APIs"
Add-NormalText "Base Route: /api/auth  |  Access: Public (No authentication required)"
Add-NormalText "The authentication module uses OTP (One-Time Password) sent to mobile numbers. After OTP verification, a JWT token is issued which must be included in all subsequent requests."

# --- 2.1 Send OTP ---
Add-Heading2 "2.1 Send OTP"
$ep1Headers = @("Property", "Value")
$ep1Rows = @(
    @("Endpoint", "POST /api/auth/send-otp"),
    @("Authentication", "None (Public)"),
    @("Description", "Send a 6-digit OTP to the provided mobile number. OTP expires in 5 minutes.")
)
Add-Table -headers $ep1Headers -rows $ep1Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "mobileNumber": "9876543210",   // Required. Exactly 10 digits.
  "userType": "user"              // Required. "user" or "driver"
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "OTP sent successfully"
}
"@

Add-Heading3 "Response - Validation Error (400)"
Add-CodeBlock @"
{
  "errors": {
    "MobileNumber": ["The field MobileNumber must match the regular expression '^\\d{10}$'."]
  }
}
"@

# --- 2.2 Verify OTP ---
Add-Heading2 "2.2 Verify OTP"
$ep2Headers = @("Property", "Value")
$ep2Rows = @(
    @("Endpoint", "POST /api/auth/verify-otp"),
    @("Authentication", "None (Public)"),
    @("Description", "Verify OTP and receive JWT token. Creates new user/driver account if first-time login.")
)
Add-Table -headers $ep2Headers -rows $ep2Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "mobileNumber": "9876543210",   // Required. Exactly 10 digits.
  "otpCode": "123456",            // Required. Exactly 6 digits.
  "userType": "user"              // Required. "user" or "driver"
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",  // JWT valid for 24 hours
  "userData": {
    "userId": 1,
    "fullName": "",
    "mobileNumber": "9876543210",
    "email": null,
    "isActive": true,
    "isAdmin": false,
    "createdDate": "2024-01-15T10:30:00Z"
  },
  "message": "OTP verified successfully"
}
"@

Add-Heading3 "JWT Token Claims"
$jwtHeaders = @("Claim", "Value", "Description")
$jwtRows = @(
    @("NameIdentifier", "UserId or DriverId", "Unique identifier used in all subsequent API calls"),
    @("mobile", "Mobile number", "User's registered mobile number"),
    @("Role", "user / driver / admin", "Determines endpoint access permissions"),
    @("exp", "Unix timestamp", "Token expiry (24 hours from issue)")
)
Add-Table -headers $jwtHeaders -rows $jwtRows

Add-Heading3 "Data Flow: Auth -> Other APIs"
Add-NormalText "The JWT token returned from verify-otp feeds into ALL protected APIs:"
Add-CodeBlock @"
verify-otp RESPONSE
   token.NameIdentifier (UserId/DriverId) --> Used by:
      - GET /api/user/profile         (GetCurrentUserId())
      - PUT /api/user/update-profile  (GetCurrentUserId())
      - GET /api/rider/profile        (GetCurrentUserId())
      - POST /api/rider/register      (GetCurrentUserId())
      - POST /api/ride/request        (GetCurrentUserId())
      - GET /api/ride/history         (GetCurrentUserId())
      - POST /api/subscription/create-order (GetCurrentUserId())
"@

Add-PageBreak

# ============================================================
# SECTION 3: USER APIs
# ============================================================
Add-Heading1 "3. User APIs"
Add-NormalText "Base Route: /api/user  |  Access: Authorized (Role: user or admin)"

Add-Heading2 "3.1 Get User Profile"
$ep3Headers = @("Property", "Value")
$ep3Rows = @(
    @("Endpoint", "GET /api/user/profile"),
    @("Authentication", "JWT Bearer Token (user/admin role)"),
    @("Description", "Retrieve the profile of the currently authenticated user.")
)
Add-Table -headers $ep3Headers -rows $ep3Rows

Add-Heading3 "Request"
Add-NormalText "No request body. UserId is extracted from JWT token."

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "userId": 1,
  "fullName": "John Doe",
  "mobileNumber": "9876543210",
  "email": "john@example.com",
  "isActive": true,
  "isAdmin": false,
  "createdDate": "2024-01-15T10:30:00Z"
}
"@

Add-Heading2 "3.2 Update User Profile"
$ep4Headers = @("Property", "Value")
$ep4Rows = @(
    @("Endpoint", "PUT /api/user/update-profile"),
    @("Authentication", "JWT Bearer Token (user/admin role)"),
    @("Description", "Update the full name and email of the authenticated user.")
)
Add-Table -headers $ep4Headers -rows $ep4Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "fullName": "John Doe",       // Required. Max 100 characters.
  "email": "john@example.com"   // Optional. Must be valid email format.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Profile updated successfully"
}
"@

Add-PageBreak

# ============================================================
# SECTION 4: DRIVER (RIDER) APIs
# ============================================================
Add-Heading1 "4. Driver (Rider) APIs"
Add-NormalText "Base Route: /api/rider  |  Access: Authorized (Role: driver)"
Add-NormalText "Driver registration follows a two-step process: (1) Register basic profile, (2) Upload KYC documents. After admin approval and an active subscription, drivers can go online and accept rides."

Add-Heading2 "4.1 Register Driver Profile (Step 1)"
$ep5Headers = @("Property", "Value")
$ep5Rows = @(
    @("Endpoint", "POST /api/rider/register"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Register or update driver's basic profile. Sets status to 'Pending'.")
)
Add-Table -headers $ep5Headers -rows $ep5Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "fullName": "Ravi Kumar",       // Required. Max 100 characters.
  "mobileNumber": "9876543210"    // Required. Exactly 10 digits.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Driver registered successfully",
  "data": {
    "driverId": 5,
    "fullName": "Ravi Kumar",
    "mobileNumber": "9876543210",
    "isApproved": false,
    "registrationStatus": "Pending",
    "subscriptionExpiryDate": null,
    "isOnline": false,
    "createdDate": "2024-01-15T10:30:00Z"
  }
}
"@

Add-Heading3 "Data Flow: register -> upload-documents"
Add-CodeBlock @"
register RESPONSE
   data.driverId --> Stored in JWT (NameIdentifier)

JWT NameIdentifier (driverId) --> POST /api/rider/upload-documents
   - Attaches KYC and vehicle details to this driverId
"@

Add-Heading2 "4.2 Upload KYC Documents (Step 2)"
$ep6Headers = @("Property", "Value")
$ep6Rows = @(
    @("Endpoint", "POST /api/rider/upload-documents"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Upload KYC and vehicle documents. Sets status to 'DocumentsUploaded'. Aadhaar is AES-256 encrypted.")
)
Add-Table -headers $ep6Headers -rows $ep6Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  // KYC Details
  "aadhaarNumber": "123412341234",          // Required. Exactly 12 digits. Stored encrypted.
  "aadhaarDocUrl": "https://cdn.../aadh.pdf", // Required. URL to uploaded Aadhaar scan.
  "drivingLicenseNumber": "DL-1420110012345", // Required.
  "licenseExpiryDate": "2027-06-30T00:00:00Z",// Required. Must be future date.
  "licenseDocUrl": "https://cdn.../license.pdf",// Required. URL to license scan.

  // Vehicle Details
  "vehicleType": "Car",                     // Required. "Bike", "Auto", or "Car".
  "vehicleNumber": "KA01AB1234",            // Required.
  "rcUrl": "https://cdn.../rc.pdf",         // Required. URL to RC (Registration Certificate).
  "insuranceUrl": "https://cdn.../ins.pdf", // Required. URL to insurance document.
  "insuranceExpiryDate": "2025-12-31T00:00:00Z" // Required. Must be future date.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Documents uploaded successfully"
}
"@

Add-Heading3 "Data Flow: upload-documents -> admin/approve"
Add-CodeBlock @"
upload-documents ACTION
   Sets Driver.RegistrationStatus = "DocumentsUploaded"

This triggers:
   GET /api/admin/drivers/pending --> Returns this driver for admin review
   POST /api/admin/driver/approve --> Admin approves after review
   POST /api/admin/driver/reject  --> Admin rejects with reason
"@

Add-Heading2 "4.3 Get Driver Profile"
$ep7Headers = @("Property", "Value")
$ep7Rows = @(
    @("Endpoint", "GET /api/rider/profile"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Get driver's complete profile including KYC and vehicle information.")
)
Add-Table -headers $ep7Headers -rows $ep7Rows

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "driverId": 5,
  "fullName": "Ravi Kumar",
  "mobileNumber": "9876543210",
  "isApproved": true,
  "registrationStatus": "Approved",  // Pending|DocumentsUploaded|Approved|Rejected
  "subscriptionExpiryDate": "2024-02-15T00:00:00Z",
  "isOnline": false,
  "rejectionReason": null,
  "currentLat": null,
  "currentLong": null,
  "kyc": {
    "kycId": 3,
    "aadhaarMasked": "XXXX-XXXX-1234",
    "drivingLicenseNumber": "DL-1420110012345",
    "licenseExpiryDate": "2027-06-30T00:00:00Z",
    "aadhaarVerified": true,
    "licenseVerified": true
  },
  "vehicle": {
    "vehicleId": 4,
    "vehicleType": "Car",
    "vehicleNumber": "KA01AB1234",
    "insuranceExpiryDate": "2025-12-31T00:00:00Z"
  }
}
"@

Add-Heading2 "4.4 Go Online"
$ep8Headers = @("Property", "Value")
$ep8Rows = @(
    @("Endpoint", "POST /api/rider/go-online"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Mark driver as online and available for rides. Requires: IsApproved=true AND active subscription.")
)
Add-Table -headers $ep8Headers -rows $ep8Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "currentLat": 12.9716,    // Required. Driver's current GPS latitude.
  "currentLong": 77.5946    // Required. Driver's current GPS longitude.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "You are now online"
}
"@

Add-Heading3 "Response - Error (400) - Not Approved"
Add-CodeBlock @"
{
  "message": "Driver is not approved yet"
}
"@

Add-Heading3 "Response - Error (400) - Expired Subscription"
Add-CodeBlock @"
{
  "message": "Subscription expired. Please renew to go online."
}
"@

Add-Heading3 "Data Flow: go-online -> ride/request"
Add-CodeBlock @"
go-online ACTION
   Sets Driver.IsOnline = true
   Sets Driver.CurrentLat = currentLat
   Sets Driver.CurrentLong = currentLong

This enables:
   POST /api/ride/request --> System finds this driver using Haversine distance
      - Driver must be IsOnline=true
      - Driver must be IsApproved=true
      - Driver must have active subscription
      - Distance must be <= 10km from pickup point
"@

Add-Heading2 "4.5 Go Offline"
$ep9Headers = @("Property", "Value")
$ep9Rows = @(
    @("Endpoint", "POST /api/rider/go-offline"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Mark driver as offline. Driver will not receive new ride requests.")
)
Add-Table -headers $ep9Headers -rows $ep9Rows

Add-Heading3 "Request"
Add-NormalText "No request body required."

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "You are now offline"
}
"@

Add-Heading2 "4.6 Accept Ride"
$ep10Headers = @("Property", "Value")
$ep10Rows = @(
    @("Endpoint", "POST /api/rider/accept-ride"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Driver accepts an assigned ride request. Changes ride status from 'Requested' to 'Accepted'.")
)
Add-Table -headers $ep10Headers -rows $ep10Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "rideId": 42    // Required. RideId received when ride was assigned.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Ride accepted successfully"
}
"@

Add-Heading3 "Data Flow: accept-ride -> start-ride"
Add-CodeBlock @"
POST /api/ride/request (user) --> Creates Ride with status="Requested", assigns driverId

POST /api/rider/accept-ride (driver) --> rideId from ride assignment
   Sets Ride.RideStatus = "Accepted"

POST /api/rider/start-ride/{rideId} (driver) --> Uses same rideId
   Sets Ride.RideStatus = "Started"
   Sets Ride.StartTime = DateTime.UtcNow
"@

Add-Heading2 "4.7 Start Ride"
$ep11Headers = @("Property", "Value")
$ep11Rows = @(
    @("Endpoint", "POST /api/rider/start-ride/{rideId}"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Driver starts the ride. Changes status to 'Started' and records start time.")
)
Add-Table -headers $ep11Headers -rows $ep11Rows

Add-Heading3 "Path Parameter"
Add-CodeBlock @"
rideId: integer    // The ride ID to start.
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Ride started"
}
"@

Add-Heading2 "4.8 End Ride"
$ep12Headers = @("Property", "Value")
$ep12Rows = @(
    @("Endpoint", "POST /api/rider/end-ride/{rideId}"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Driver ends and completes the ride. Records final fare and end time.")
)
Add-Table -headers $ep12Headers -rows $ep12Rows

Add-Heading3 "Path Parameter"
Add-CodeBlock @"
rideId: integer    // The ride ID to end.
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Ride completed",
  "data": {
    "rideId": 42,
    "rideNumber": "RIDE20240115001",
    "finalFare": 125.50,
    "startTime": "2024-01-15T10:00:00Z",
    "endTime": "2024-01-15T10:35:00Z"
  }
}
"@

Add-Heading3 "Data Flow: end-ride -> ride/rate"
Add-CodeBlock @"
POST /api/rider/end-ride/{rideId} ACTION
   Sets Ride.RideStatus = "Completed"
   Sets Ride.EndTime = DateTime.UtcNow
   Sets Ride.FinalFare = Ride.EstimatedFare

This enables:
   POST /api/ride/rate/{rideId} (user) --> User can now rate this completed ride
"@

Add-PageBreak

# ============================================================
# SECTION 5: RIDE APIs
# ============================================================
Add-Heading1 "5. Ride APIs"
Add-NormalText "Base Route: /api/ride  |  Access: Authorized (Role: user)"

Add-Heading2 "5.1 Request a Ride"
$ep13Headers = @("Property", "Value")
$ep13Rows = @(
    @("Endpoint", "POST /api/ride/request"),
    @("Authentication", "JWT Bearer Token (user role)"),
    @("Description", "Request a new ride. System finds nearest available driver using Haversine distance formula.")
)
Add-Table -headers $ep13Headers -rows $ep13Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "pickupLat": 12.9716,              // Required. Pickup location latitude.
  "pickupLong": 77.5946,             // Required. Pickup location longitude.
  "dropLat": 13.0358,                // Required. Drop location latitude.
  "dropLong": 77.5970,               // Required. Drop location longitude.
  "pickupAddress": "MG Road, Bangalore", // Optional. Human-readable pickup address.
  "dropAddress": "Hebbal, Bangalore"     // Optional. Human-readable drop address.
}
"@

Add-Heading3 "Fare Calculation Logic"
Add-CodeBlock @"
Fare = Base Fare + (Distance in KM x Per KM Rate)
Fare = 30.00 + (distanceKm x 15.00)

Example: 5 km ride = 30 + (5 x 15) = Rs. 105.00
"@

Add-Heading3 "Driver Selection Logic"
Add-CodeBlock @"
1. Find all drivers where: IsOnline=true AND IsApproved=true AND SubscriptionExpiryDate > NOW
2. Calculate Haversine distance from pickup point to each driver's CurrentLat/Long
3. Filter drivers within 10 km radius
4. Select nearest driver (minimum distance)
5. Assign that driver's DriverId to the Ride
"@

Add-Heading3 "Response - Success (200) - Driver Found"
Add-CodeBlock @"
{
  "message": "Ride requested successfully",
  "data": {
    "rideId": 42,
    "rideNumber": "RIDE20240115001",
    "rideStatus": "Requested",
    "estimatedFare": 125.50,
    "pickupAddress": "MG Road, Bangalore",
    "dropAddress": "Hebbal, Bangalore",
    "driver": {
      "driverId": 5,
      "fullName": "Ravi Kumar",
      "mobileNumber": "9876543210",
      "vehicleType": "Car",
      "vehicleNumber": "KA01AB1234"
    }
  }
}
"@

Add-Heading3 "Response - Error (400) - No Driver Available"
Add-CodeBlock @"
{
  "message": "No driver available nearby"
}
"@

Add-Heading3 "Data Flow: ride/request -> rider endpoints"
Add-CodeBlock @"
POST /api/ride/request RESPONSE
   data.rideId --> Shared with driver via push notification (external)

Driver uses rideId for:
   POST /api/rider/accept-ride    { "rideId": 42 }
   POST /api/rider/start-ride/42
   POST /api/rider/end-ride/42

User uses rideId for:
   POST /api/ride/rate/42         { "rating": 5, "feedback": "Great ride!" }
"@

Add-Heading2 "5.2 Get Ride History"
$ep14Headers = @("Property", "Value")
$ep14Rows = @(
    @("Endpoint", "GET /api/ride/history"),
    @("Authentication", "JWT Bearer Token (user role)"),
    @("Description", "Retrieve all past rides for the authenticated user, ordered by most recent first.")
)
Add-Table -headers $ep14Headers -rows $ep14Rows

Add-Heading3 "Request"
Add-NormalText "No request body. UserId is extracted from JWT token."

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
[
  {
    "rideId": 42,
    "rideNumber": "RIDE20240115001",
    "userId": 1,
    "driverId": 5,
    "pickupLat": 12.9716,
    "pickupLong": 77.5946,
    "dropLat": 13.0358,
    "dropLong": 77.5970,
    "pickupAddress": "MG Road, Bangalore",
    "dropAddress": "Hebbal, Bangalore",
    "estimatedFare": 125.50,
    "finalFare": 125.50,
    "rideStatus": "Completed",
    "rating": 5,
    "feedback": "Great ride!",
    "requestedTime": "2024-01-15T10:00:00Z",
    "startTime": "2024-01-15T10:05:00Z",
    "endTime": "2024-01-15T10:35:00Z"
  }
]
"@

Add-Heading2 "5.3 Rate a Ride"
$ep15Headers = @("Property", "Value")
$ep15Rows = @(
    @("Endpoint", "POST /api/ride/rate/{rideId}"),
    @("Authentication", "JWT Bearer Token (user role)"),
    @("Description", "Rate a completed ride. Can only rate rides with status 'Completed'.")
)
Add-Table -headers $ep15Headers -rows $ep15Rows

Add-Heading3 "Path Parameter"
Add-CodeBlock @"
rideId: integer    // The completed ride ID to rate.
"@

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "rating": 5,                          // Required. Integer 1-5 (1=worst, 5=best).
  "feedback": "Smooth and safe ride!"  // Optional. Max 500 characters.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Ride rated successfully"
}
"@

Add-PageBreak

# ============================================================
# SECTION 6: SUBSCRIPTION APIs
# ============================================================
Add-Heading1 "6. Subscription APIs"
Add-NormalText "Base Route: /api/subscription"
Add-NormalText "Drivers must purchase an active subscription to go online and accept rides. Plans are based on vehicle type."

Add-Heading2 "6.1 Get Subscription Plans"
$ep16Headers = @("Property", "Value")
$ep16Rows = @(
    @("Endpoint", "GET /api/subscription/plans"),
    @("Authentication", "None (Public)"),
    @("Description", "Retrieve all available and active subscription plans.")
)
Add-Table -headers $ep16Headers -rows $ep16Rows

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
[
  {
    "planId": 1,
    "vehicleType": "Bike",
    "amount": 299.00,
    "durationInDays": 30,
    "isActive": true
  },
  {
    "planId": 2,
    "vehicleType": "Auto",
    "amount": 399.00,
    "durationInDays": 30,
    "isActive": true
  },
  {
    "planId": 3,
    "vehicleType": "Car",
    "amount": 499.00,
    "durationInDays": 30,
    "isActive": true
  }
]
"@

Add-Heading3 "Data Flow: plans -> create-order"
Add-CodeBlock @"
GET /api/subscription/plans RESPONSE
   [].planId --> Used in:

POST /api/subscription/create-order
   { "planId": 1 }  // Driver selects a plan to purchase
"@

Add-Heading2 "6.2 Create Payment Order"
$ep17Headers = @("Property", "Value")
$ep17Rows = @(
    @("Endpoint", "POST /api/subscription/create-order"),
    @("Authentication", "JWT Bearer Token (driver role)"),
    @("Description", "Create a UPI payment order for a subscription plan. Returns payment gateway details.")
)
Add-Table -headers $ep17Headers -rows $ep17Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "planId": 3    // Required. PlanId from GET /api/subscription/plans response.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Order created successfully",
  "data": {
    "paymentId": 10,
    "gatewayOrderId": "ORD_a1b2c3d4-e5f6-...",  // Use this for UPI payment
    "planId": 3,
    "vehicleType": "Car",
    "amount": 499.00,
    "durationInDays": 30,
    "upiUrl": "upi://pay?pa=vaygo@upi&pn=VayGo&am=499&cu=INR&tn=ORD_a1b2c3d4..."
  }
}
"@

Add-Heading3 "Data Flow: create-order -> payment/webhook"
Add-CodeBlock @"
POST /api/subscription/create-order RESPONSE
   data.gatewayOrderId --> User pays via UPI app
   data.paymentId      --> Created internally

After UPI payment:
   Payment gateway sends callback to:
   POST /api/payment/webhook
   {
     "gatewayOrderId": "ORD_a1b2c3d4...",   // From create-order
     "upiTransactionId": "TXN123456",
     "status": "Success",
     "signature": "HMAC-SHA256-hash"
   }
"@

Add-PageBreak

# ============================================================
# SECTION 7: PAYMENT APIs
# ============================================================
Add-Heading1 "7. Payment APIs"
Add-NormalText "Base Route: /api/payment  |  Access: Public (called by payment gateway)"

Add-Heading2 "7.1 Payment Webhook"
$ep18Headers = @("Property", "Value")
$ep18Rows = @(
    @("Endpoint", "POST /api/payment/webhook"),
    @("Authentication", "None (HMAC-SHA256 signature verification instead)"),
    @("Description", "Receives UPI payment gateway callback. Verifies signature, updates payment status, and activates subscription on success.")
)
Add-Table -headers $ep18Headers -rows $ep18Rows

Add-Heading3 "Request Payload (from Payment Gateway)"
Add-CodeBlock @"
{
  "gatewayOrderId": "ORD_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "upiTransactionId": "TXN987654321",
  "status": "Success",       // "Success" or "Failed"
  "signature": "sha256_hmac_signature_from_gateway"
}
"@

Add-Heading3 "Signature Verification"
Add-CodeBlock @"
HMAC-SHA256(gatewayOrderId + "|" + upiTransactionId + "|" + status, WebhookSecretKey)
// WebhookSecretKey configured in appsettings.json
"@

Add-Heading3 "Response - Success (200) - Payment Successful"
Add-CodeBlock @"
{
  "success": true,
  "message": "Subscription activated successfully"
}
"@

Add-Heading3 "Response - Success (200) - Payment Failed"
Add-CodeBlock @"
{
  "success": false,
  "message": "Payment failed"
}
"@

Add-Heading3 "Response - Error (400) - Invalid Signature"
Add-CodeBlock @"
{
  "success": false,
  "message": "Invalid signature"
}
"@

Add-Heading3 "Data Flow: webhook -> driver activation"
Add-CodeBlock @"
POST /api/payment/webhook (status="Success") TRIGGERS:

SubscriptionService.ActivateSubscriptionAsync(driverId, paymentId):
   1. Deactivates all previous DriverSubscriptions (IsActive=false)
   2. Creates new DriverSubscription:
      - StartDate = DateTime.UtcNow
      - EndDate = StartDate + Plan.DurationInDays
      - IsActive = true
   3. Updates Driver.SubscriptionExpiryDate = EndDate

This enables:
   POST /api/rider/go-online --> Driver can now go online (subscription check passes)
"@

Add-PageBreak

# ============================================================
# SECTION 8: ADMIN APIs
# ============================================================
Add-Heading1 "8. Admin APIs"
Add-NormalText "Base Route: /api/admin  |  Access: Authorized (Role: admin)"

Add-Heading2 "8.1 Get Pending Driver Approvals"
$ep19Headers = @("Property", "Value")
$ep19Rows = @(
    @("Endpoint", "GET /api/admin/drivers/pending"),
    @("Authentication", "JWT Bearer Token (admin role)"),
    @("Description", "Get all drivers with 'DocumentsUploaded' status awaiting admin approval.")
)
Add-Table -headers $ep19Headers -rows $ep19Rows

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
[
  {
    "driverId": 5,
    "fullName": "Ravi Kumar",
    "mobileNumber": "9876543210",
    "registrationStatus": "DocumentsUploaded",
    "createdDate": "2024-01-15T08:00:00Z",
    "kyc": {
      "kycId": 3,
      "aadhaarMasked": "XXXX-XXXX-1234",
      "drivingLicenseNumber": "DL-1420110012345",
      "licenseExpiryDate": "2027-06-30T00:00:00Z",
      "aadhaarDocUrl": "https://cdn.../aadh.pdf",
      "licenseDocUrl": "https://cdn.../license.pdf"
    },
    "vehicle": {
      "vehicleId": 4,
      "vehicleType": "Car",
      "vehicleNumber": "KA01AB1234",
      "rcUrl": "https://cdn.../rc.pdf",
      "insuranceUrl": "https://cdn.../ins.pdf",
      "insuranceExpiryDate": "2025-12-31T00:00:00Z"
    }
  }
]
"@

Add-Heading2 "8.2 Approve Driver"
$ep20Headers = @("Property", "Value")
$ep20Rows = @(
    @("Endpoint", "POST /api/admin/driver/approve"),
    @("Authentication", "JWT Bearer Token (admin role)"),
    @("Description", "Approve a driver after reviewing their KYC documents. Sets IsApproved=true and marks KYC as verified.")
)
Add-Table -headers $ep20Headers -rows $ep20Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "driverId": 5    // Required. DriverId from pending drivers list.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Driver approved successfully"
}
"@

Add-Heading3 "Data Flow: approve -> driver go-online"
Add-CodeBlock @"
POST /api/admin/driver/approve ACTIONS:
   Sets Driver.IsApproved = true
   Sets Driver.RegistrationStatus = "Approved"
   Sets DriverKYC.AadhaarVerified = true
   Sets DriverKYC.LicenseVerified = true

This enables:
   POST /api/rider/go-online --> IsApproved check now passes (still needs active subscription)
"@

Add-Heading2 "8.3 Reject Driver"
$ep21Headers = @("Property", "Value")
$ep21Rows = @(
    @("Endpoint", "POST /api/admin/driver/reject"),
    @("Authentication", "JWT Bearer Token (admin role)"),
    @("Description", "Reject a driver's application with a reason.")
)
Add-Table -headers $ep21Headers -rows $ep21Rows

Add-Heading3 "Request Payload"
Add-CodeBlock @"
{
  "driverId": 5,
  "reason": "License document is blurry. Please re-upload a clear photo."
  // Required. Max 500 characters.
}
"@

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "message": "Driver rejected"
}
"@

Add-Heading2 "8.4 Subscription Revenue Report"
$ep22Headers = @("Property", "Value")
$ep22Rows = @(
    @("Endpoint", "GET /api/admin/subscription/report"),
    @("Authentication", "JWT Bearer Token (admin role)"),
    @("Description", "Get subscription revenue report grouped by vehicle type.")
)
Add-Table -headers $ep22Headers -rows $ep22Rows

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "totalRevenue": 15000.00,
  "totalSubscriptions": 35,
  "byVehicleType": {
    "Bike": { "count": 15, "revenue": 4485.00 },
    "Auto": { "count": 10, "revenue": 3990.00 },
    "Car": { "count": 10, "revenue": 4990.00 }
  }
}
"@

Add-Heading2 "8.5 Rides Summary Report"
$ep23Headers = @("Property", "Value")
$ep23Rows = @(
    @("Endpoint", "GET /api/admin/rides/report"),
    @("Authentication", "JWT Bearer Token (admin role)"),
    @("Description", "Get platform-wide rides statistics.")
)
Add-Table -headers $ep23Headers -rows $ep23Rows

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
{
  "totalRides": 200,
  "completed": 180,
  "cancelled": 5,
  "requested": 15,
  "totalRevenue": 22500.00,
  "averageRating": 4.3
}
"@

Add-Heading2 "8.6 Get All Users"
$ep24Headers = @("Property", "Value")
$ep24Rows = @(
    @("Endpoint", "GET /api/admin/users"),
    @("Authentication", "JWT Bearer Token (admin role)"),
    @("Description", "Get a list of all registered users on the platform.")
)
Add-Table -headers $ep24Headers -rows $ep24Rows

Add-Heading3 "Response - Success (200)"
Add-CodeBlock @"
[
  {
    "userId": 1,
    "fullName": "John Doe",
    "mobileNumber": "9876543210",
    "email": "john@example.com",
    "isActive": true,
    "isAdmin": false,
    "createdDate": "2024-01-10T08:00:00Z"
  }
]
"@

Add-PageBreak

# ============================================================
# SECTION 9: COMPLETE DATA FLOW DIAGRAMS
# ============================================================
Add-Heading1 "9. Complete API Data Flow"

Add-Heading2 "9.1 User Journey Flow"
Add-CodeBlock @"
[USER ONBOARDING & RIDE FLOW]

STEP 1: Authentication
POST /api/auth/send-otp
   { mobileNumber: "9876543210", userType: "user" }

STEP 2: Verify & Get Token
POST /api/auth/verify-otp
   { mobileNumber: "9876543210", otpCode: "123456", userType: "user" }
   --> Returns: JWT token (valid 24 hrs)

STEP 3: Update Profile
PUT /api/user/update-profile                    [Uses JWT]
   { fullName: "John Doe", email: "j@ex.com" }

STEP 4: Request Ride
POST /api/ride/request                          [Uses JWT]
   { pickupLat, pickupLong, dropLat, dropLong,
     pickupAddress, dropAddress }
   --> Returns: rideId, estimatedFare, driver info

STEP 5: Rate Completed Ride
POST /api/ride/rate/{rideId}                    [Uses JWT]
   { rating: 5, feedback: "Great ride!" }

STEP 6: View History
GET /api/ride/history                           [Uses JWT]
   --> Returns: All past rides
"@

Add-Heading2 "9.2 Driver Journey Flow"
Add-CodeBlock @"
[DRIVER ONBOARDING & RIDE ACCEPTANCE FLOW]

STEP 1: Authentication
POST /api/auth/send-otp
   { mobileNumber: "9988776655", userType: "driver" }
POST /api/auth/verify-otp
   { mobileNumber: "9988776655", otpCode: "654321", userType: "driver" }
   --> Returns: JWT token with role="driver"

STEP 2: Register Profile
POST /api/rider/register                        [Uses JWT]
   { fullName: "Ravi Kumar", mobileNumber: "9988776655" }
   --> Creates driver with status="Pending"

STEP 3: Upload Documents
POST /api/rider/upload-documents                [Uses JWT]
   { aadhaarNumber, drivingLicenseNumber, licenseExpiryDate,
     aadhaarDocUrl, licenseDocUrl,
     vehicleType: "Car", vehicleNumber, rcUrl, insuranceUrl,
     insuranceExpiryDate }
   --> Status changes to "DocumentsUploaded"

STEP 4: Admin Review (Admin action - see Admin Flow)
   --> Status changes to "Approved"

STEP 5: Subscribe
GET /api/subscription/plans                     [Public]
   --> Returns: planId for desired vehicle type

POST /api/subscription/create-order            [Uses JWT]
   { planId: 3 }
   --> Returns: gatewayOrderId, upiUrl

[User pays via UPI app]

POST /api/payment/webhook (from gateway)
   { gatewayOrderId, upiTransactionId, status: "Success", signature }
   --> Subscription activated, SubscriptionExpiryDate set

STEP 6: Go Online
POST /api/rider/go-online                      [Uses JWT]
   { currentLat: 12.9716, currentLong: 77.5946 }
   --> Driver now visible for ride requests

STEP 7: Accept & Complete Ride
POST /api/rider/accept-ride                    [Uses JWT]
   { rideId: 42 }  -- rideId received via push notification

POST /api/rider/start-ride/42                  [Uses JWT]

POST /api/rider/end-ride/42                    [Uses JWT]
   --> Returns: finalFare, start/end times

STEP 8: Go Offline
POST /api/rider/go-offline                     [Uses JWT]
"@

Add-Heading2 "9.3 Admin Flow"
Add-CodeBlock @"
[ADMIN MANAGEMENT FLOW]

STEP 1: Authentication
POST /api/auth/send-otp
   { mobileNumber: "adminMobile", userType: "user" }
   --> Admin user has IsAdmin=true flag in DB
POST /api/auth/verify-otp
   { mobileNumber: "adminMobile", otpCode: "111111", userType: "user" }
   --> Returns: JWT with role="admin"

STEP 2: Review Pending Drivers
GET /api/admin/drivers/pending                  [Uses JWT - admin]
   --> Returns: drivers with status="DocumentsUploaded"

STEP 3a: Approve Driver
POST /api/admin/driver/approve                  [Uses JWT - admin]
   { driverId: 5 }
   --> Driver.IsApproved = true, status = "Approved"

STEP 3b: Reject Driver
POST /api/admin/driver/reject                   [Uses JWT - admin]
   { driverId: 6, reason: "Invalid documents" }

STEP 4: View Reports
GET /api/admin/subscription/report              [Uses JWT - admin]
GET /api/admin/rides/report                     [Uses JWT - admin]
GET /api/admin/users                            [Uses JWT - admin]
"@

Add-Heading2 "9.4 Cross-API Data Dependencies"
$depHeaders = @("Source API", "Data Produced", "Consumed By API", "Field Used")
$depRows = @(
    @("POST /auth/verify-otp", "JWT token", "ALL protected APIs", "Authorization header"),
    @("POST /auth/verify-otp", "userId (in JWT)", "GET /user/profile, PUT /user/update-profile, POST /ride/request, GET /ride/history, POST /ride/rate/{id}", "NameIdentifier claim"),
    @("POST /auth/verify-otp", "driverId (in JWT)", "POST /rider/register, POST /rider/upload-documents, POST /rider/go-online, POST /rider/accept-ride, POST /subscription/create-order", "NameIdentifier claim"),
    @("POST /rider/upload-documents", "RegistrationStatus=DocumentsUploaded", "GET /admin/drivers/pending", "Filter condition"),
    @("POST /admin/driver/approve", "IsApproved=true", "POST /rider/go-online", "Prerequisite check"),
    @("GET /subscription/plans", "planId", "POST /subscription/create-order", "Body: planId"),
    @("POST /subscription/create-order", "gatewayOrderId, paymentId", "POST /payment/webhook", "gatewayOrderId"),
    @("POST /payment/webhook (Success)", "SubscriptionExpiryDate", "POST /rider/go-online", "Expiry check"),
    @("POST /rider/go-online", "IsOnline=true, CurrentLat/Long", "POST /ride/request", "Driver finding algorithm"),
    @("POST /ride/request", "rideId, driverId", "POST /rider/accept-ride, start-ride, end-ride", "rideId parameter"),
    @("POST /rider/end-ride", "RideStatus=Completed", "POST /ride/rate/{rideId}", "Prerequisite check")
)
Add-Table -headers $depHeaders -rows $depRows

Add-PageBreak

# ============================================================
# SECTION 10: DATABASE SCHEMA
# ============================================================
Add-Heading1 "10. Database Schema & Relationships"

Add-Heading2 "10.1 Entity Relationship Summary"
$erHeaders = @("Table", "Primary Key", "Foreign Keys", "Key Fields")
$erRows = @(
    @("Users", "UserId", "None", "MobileNumber, FullName, Email, IsActive, IsAdmin"),
    @("Drivers", "DriverId", "None", "MobileNumber, IsApproved, RegistrationStatus, IsOnline, CurrentLat, CurrentLong, SubscriptionExpiryDate"),
    @("DriverKYC", "KYCId", "DriverId -> Drivers", "AadhaarMasked, AadhaarEncrypted, DrivingLicenseNumber, LicenseExpiryDate, AadhaarVerified, LicenseVerified"),
    @("Vehicles", "VehicleId", "DriverId -> Drivers", "VehicleType (Bike/Auto/Car), VehicleNumber, InsuranceExpiryDate"),
    @("SubscriptionPlans", "PlanId", "None", "VehicleType, Amount, DurationInDays, IsActive"),
    @("DriverSubscriptions", "SubscriptionId", "DriverId -> Drivers, PlanId -> SubscriptionPlans", "StartDate, EndDate, IsActive"),
    @("SubscriptionPayments", "PaymentId", "DriverId -> Drivers, PlanId -> SubscriptionPlans", "GatewayOrderId, UpiTransactionId, PaymentStatus, PaidDate"),
    @("Rides", "RideId", "UserId -> Users, DriverId -> Drivers", "RideNumber, PickupLat/Long, DropLat/Long, EstimatedFare, FinalFare, RideStatus, Rating, Feedback"),
    @("OTPLogs", "OTPId", "None (standalone)", "MobileNumber, OTPCode, IsVerified, ExpiryTime")
)
Add-Table -headers $erHeaders -rows $erRows

Add-Heading2 "10.2 Driver Registration Status Flow"
Add-CodeBlock @"
Driver.RegistrationStatus Values:

"Pending"             -- After POST /api/rider/register
    |
    v
"DocumentsUploaded"   -- After POST /api/rider/upload-documents
    |
    +---> "Approved"  -- After POST /api/admin/driver/approve
    |        (IsApproved=true, KYC verified)
    |
    +---> "Rejected"  -- After POST /api/admin/driver/reject
             (IsApproved=false, RejectionReason set)
"@

Add-Heading2 "10.3 Ride Status Flow"
Add-CodeBlock @"
Ride.RideStatus Values:

"Requested"   -- After POST /api/ride/request (by user)
    |
    v
"Accepted"    -- After POST /api/rider/accept-ride (by driver)
    |
    v
"Started"     -- After POST /api/rider/start-ride/{id} (by driver)
    |
    v
"Completed"   -- After POST /api/rider/end-ride/{id} (by driver)
    |
    v
[Rating]      -- After POST /api/ride/rate/{id} (by user) [optional]
"@

Add-Heading2 "10.4 Payment Status Flow"
Add-CodeBlock @"
SubscriptionPayment.PaymentStatus Values:

"Pending"    -- After POST /api/subscription/create-order
    |
    +---> "Success" -- After POST /api/payment/webhook (status="Success")
    |                  --> DriverSubscription created
    |                  --> Driver.SubscriptionExpiryDate updated
    |
    +---> "Failed"  -- After POST /api/payment/webhook (status="Failed")
"@

Add-PageBreak

# ============================================================
# SECTION 11: ERROR CODES & COMMON RESPONSES
# ============================================================
Add-Heading1 "11. Common HTTP Status Codes & Error Responses"

$errHeaders = @("HTTP Status", "Scenario", "Example Response")
$errRows = @(
    @("200 OK", "Successful operation", "{ ""message"": ""Success"" }"),
    @("400 Bad Request", "Validation error or business logic error", "{ ""message"": ""OTP expired or invalid"" }"),
    @("401 Unauthorized", "Missing or invalid JWT token", "{ ""message"": ""Unauthorized"" }"),
    @("403 Forbidden", "Valid token but insufficient role", "{ ""message"": ""Forbidden"" }"),
    @("404 Not Found", "Resource not found", "{ ""message"": ""User not found"" }"),
    @("500 Internal Server Error", "Unexpected server error", "{ ""message"": ""An error occurred"" }")
)
Add-Table -headers $errHeaders -rows $errRows

Add-Heading2 "11.1 Validation Error Format"
Add-CodeBlock @"
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "MobileNumber": [
      "The MobileNumber field is required.",
      "The field MobileNumber must match the regular expression '^\\d{10}$'."
    ]
  }
}
"@

Add-PageBreak

# ============================================================
# SECTION 12: BACKGROUND JOBS
# ============================================================
Add-Heading1 "12. Background Jobs (Automated Tasks)"

Add-Heading2 "12.1 Deactivate Expired Drivers"
Add-NormalText "AdminService.DeactivateExpiredDriversAsync() - Runs periodically to keep driver status current."
Add-CodeBlock @"
Logic:
   Find all drivers where: IsOnline=true AND SubscriptionExpiryDate < DateTime.UtcNow
   For each: Set IsOnline = false (driver forced offline)

Effect: These drivers can no longer receive ride requests until they renew subscription.
"@

Add-Heading2 "12.2 Clean Expired OTPs"
Add-NormalText "AdminService.CleanExpiredOtpsAsync() - Cleans up old OTP records."
Add-CodeBlock @"
Logic:
   Delete all OTPLogs where: CreatedDate < DateTime.UtcNow.AddDays(-1)

Effect: Keeps OTPLogs table clean. Expired OTPs are already unusable (ExpiryTime check).
"@

Add-PageBreak

# ============================================================
# SECTION 13: SECURITY
# ============================================================
Add-Heading1 "13. Security Implementation"

Add-Heading2 "13.1 JWT Token"
$jwtSecHeaders = @("Property", "Value")
$jwtSecRows = @(
    @("Algorithm", "HMAC-SHA256"),
    @("Expiry", "24 hours from issue"),
    @("Issuer", "Configured in appsettings.json"),
    @("Audience", "Configured in appsettings.json"),
    @("Claims", "NameIdentifier (UserId/DriverId), mobile, Role")
)
Add-Table -headers $jwtSecHeaders -rows $jwtSecRows

Add-Heading2 "13.2 Data Encryption"
$encHeaders = @("Data", "Method", "Storage")
$encRows = @(
    @("Aadhaar Number", "AES-256-CBC encryption", "AadhaarEncrypted column (full) + AadhaarMasked (XXXX-XXXX-LAST4)"),
    @("Webhook Payload", "HMAC-SHA256 verification", "Signature validated before processing"),
    @("Passwords", "No passwords (OTP-based auth)", "N/A"),
    @("OTP Codes", "Plaintext (short-lived 5 min)", "OTPLogs table, auto-cleaned after 1 day")
)
Add-Table -headers $encHeaders -rows $encRows

Add-Heading2 "13.3 Role-Based Access Control"
$rbacHeaders = @("Endpoint Pattern", "Required Role")
$rbacRows = @(
    @("/api/auth/*", "None (Public)"),
    @("/api/subscription/plans", "None (Public)"),
    @("/api/payment/webhook", "None (Signature-based)"),
    @("/api/user/*", "user OR admin"),
    @("/api/ride/*", "user"),
    @("/api/rider/*", "driver"),
    @("/api/subscription/create-order", "driver"),
    @("/api/admin/*", "admin")
)
Add-Table -headers $rbacHeaders -rows $rbacRows

# Update TOC
try { $toc.Update() } catch {}

# Save document
$doc.SaveAs([ref]$outputPath)
$doc.Close()
$word.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null

Write-Host "SUCCESS: Document saved to: $outputPath"
