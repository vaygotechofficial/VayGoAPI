-- ============================================================
-- VayGo Ride App - Database Schema
-- Generated: April 2026
-- Database: MySQL
-- ============================================================

-- Drop tables in reverse FK dependency order
DROP TABLE IF EXISTS OTPLogs;
DROP TABLE IF EXISTS Rides;
DROP TABLE IF EXISTS SubscriptionPayments;
DROP TABLE IF EXISTS DriverSubscriptions;
DROP TABLE IF EXISTS SubscriptionPlans;
DROP TABLE IF EXISTS Vehicles;
DROP TABLE IF EXISTS DriverKYC;
DROP TABLE IF EXISTS Drivers;
DROP TABLE IF EXISTS Users;

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE Users (
    UserId       INT AUTO_INCREMENT PRIMARY KEY,
    FullName     VARCHAR(100)  NOT NULL DEFAULT '',
    MobileNumber VARCHAR(15)   NOT NULL UNIQUE,
    Email        VARCHAR(100)  NULL,
    IsActive     TINYINT(1)    NOT NULL DEFAULT 1,
    IsAdmin      TINYINT(1)    NOT NULL DEFAULT 0,
    CreatedDate  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. DRIVERS
-- ============================================================
CREATE TABLE Drivers (
    DriverId               INT AUTO_INCREMENT PRIMARY KEY,
    FullName               VARCHAR(100)  NOT NULL DEFAULT '',
    MobileNumber           VARCHAR(15)   NOT NULL UNIQUE,
    IsApproved             TINYINT(1)    NOT NULL DEFAULT 0,
    RegistrationStatus     VARCHAR(50)   NOT NULL DEFAULT 'Pending',
    -- Pending | DocumentsUploaded | Approved | Rejected
    SubscriptionExpiryDate DATETIME      NULL,
    IsOnline               TINYINT(1)    NOT NULL DEFAULT 0,
    RejectionReason        VARCHAR(500)  NULL,
    CurrentLat             DECIMAL(10,8) NULL,
    CurrentLong            DECIMAL(11,8) NULL,
    CreatedDate            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. DRIVER KYC
-- ============================================================
CREATE TABLE DriverKYC (
    KYCId                INT AUTO_INCREMENT PRIMARY KEY,
    DriverId             INT           NOT NULL,
    AadhaarMasked        VARCHAR(20)   NULL,
    AadhaarEncrypted     TEXT          NULL,
    DrivingLicenseNumber VARCHAR(50)   NULL,
    LicenseExpiryDate    DATE          NULL,
    AadhaarDocUrl        VARCHAR(500)  NULL,
    LicenseDocUrl        VARCHAR(500)  NULL,
    AadhaarVerified      TINYINT(1)    NOT NULL DEFAULT 0,
    LicenseVerified      TINYINT(1)    NOT NULL DEFAULT 0,
    CONSTRAINT fk_kyc_driver FOREIGN KEY (DriverId) REFERENCES Drivers(DriverId)
);

-- ============================================================
-- 4. VEHICLES
-- ============================================================
CREATE TABLE Vehicles (
    VehicleId          INT AUTO_INCREMENT PRIMARY KEY,
    DriverId           INT          NOT NULL,
    VehicleType        VARCHAR(20)  NOT NULL,   -- Bike | Auto | Car
    VehicleNumber      VARCHAR(20)  NOT NULL,
    RCUrl              VARCHAR(500) NULL,
    InsuranceUrl       VARCHAR(500) NULL,
    InsuranceExpiryDate DATE        NULL,
    CONSTRAINT fk_vehicle_driver FOREIGN KEY (DriverId) REFERENCES Drivers(DriverId)
);

-- ============================================================
-- 5. SUBSCRIPTION PLANS
-- ============================================================
CREATE TABLE SubscriptionPlans (
    PlanId        INT AUTO_INCREMENT PRIMARY KEY,
    VehicleType   VARCHAR(20)    NOT NULL,   -- Bike | Auto | Car
    Amount        DECIMAL(10,2)  NOT NULL,
    DurationInDays INT           NOT NULL,
    IsActive      TINYINT(1)     NOT NULL DEFAULT 1
);

-- Seed default plans as per business model
INSERT INTO SubscriptionPlans (VehicleType, Amount, DurationInDays) VALUES
('Bike', 299.00, 30),
('Auto', 399.00, 30),
('Car',  499.00, 30);

-- ============================================================
-- 6. DRIVER SUBSCRIPTIONS
-- ============================================================
CREATE TABLE DriverSubscriptions (
    SubscriptionId INT AUTO_INCREMENT PRIMARY KEY,
    DriverId       INT       NOT NULL,
    PlanId         INT       NOT NULL,
    StartDate      DATETIME  NOT NULL,
    EndDate        DATETIME  NOT NULL,
    IsActive       TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_sub_driver FOREIGN KEY (DriverId) REFERENCES Drivers(DriverId),
    CONSTRAINT fk_sub_plan   FOREIGN KEY (PlanId)   REFERENCES SubscriptionPlans(PlanId)
);

-- ============================================================
-- 7. SUBSCRIPTION PAYMENTS
-- ============================================================
CREATE TABLE SubscriptionPayments (
    PaymentId        INT AUTO_INCREMENT PRIMARY KEY,
    DriverId         INT          NOT NULL,
    PlanId           INT          NOT NULL,
    GatewayOrderId   VARCHAR(100) NULL,
    UpiTransactionId VARCHAR(100) NULL,
    PaymentStatus    VARCHAR(20)  NOT NULL DEFAULT 'Pending',
    -- Pending | Success | Failed
    PaidDate         DATETIME     NULL,
    CreatedDate      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pay_driver FOREIGN KEY (DriverId) REFERENCES Drivers(DriverId),
    CONSTRAINT fk_pay_plan   FOREIGN KEY (PlanId)   REFERENCES SubscriptionPlans(PlanId)
);

-- ============================================================
-- 8. RIDES
-- ============================================================
CREATE TABLE Rides (
    RideId         INT AUTO_INCREMENT PRIMARY KEY,
    RideNumber     VARCHAR(25)    NOT NULL UNIQUE,
    UserId         INT            NOT NULL,
    DriverId       INT            NULL,
    PickupLat      DECIMAL(10,8)  NOT NULL,
    PickupLong     DECIMAL(11,8)  NOT NULL,
    DropLat        DECIMAL(10,8)  NOT NULL,
    DropLong       DECIMAL(11,8)  NOT NULL,
    PickupAddress  VARCHAR(500)   NULL,
    DropAddress    VARCHAR(500)   NULL,
    EstimatedFare  DECIMAL(10,2)  NULL,
    FinalFare      DECIMAL(10,2)  NULL,
    RideStatus     VARCHAR(20)    NOT NULL DEFAULT 'Requested',
    -- Requested | Accepted | Started | Completed | Cancelled
    Rating         INT            NULL,     -- 1-5
    Feedback       VARCHAR(500)   NULL,
    RequestedTime  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    StartTime      DATETIME       NULL,
    EndTime        DATETIME       NULL,
    CONSTRAINT fk_ride_user   FOREIGN KEY (UserId)   REFERENCES Users(UserId),
    CONSTRAINT fk_ride_driver FOREIGN KEY (DriverId) REFERENCES Drivers(DriverId)
);

-- ============================================================
-- 9. OTP LOGS
-- ============================================================
CREATE TABLE OTPLogs (
    OTPId        INT AUTO_INCREMENT PRIMARY KEY,
    MobileNumber VARCHAR(15) NOT NULL,
    OTPCode      VARCHAR(6)  NOT NULL,
    IsVerified   TINYINT(1)  NOT NULL DEFAULT 0,
    ExpiryTime   DATETIME    NOT NULL,
    CreatedDate  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_otp_mobile (MobileNumber)
);

-- ============================================================
-- USEFUL QUERIES
-- ============================================================

-- Get all pending drivers for admin review
-- SELECT d.*, k.DrivingLicenseNumber, k.LicenseExpiryDate, v.VehicleType, v.VehicleNumber
-- FROM Drivers d
-- LEFT JOIN DriverKYC k ON k.DriverId = d.DriverId
-- LEFT JOIN Vehicles  v ON v.DriverId = d.DriverId
-- WHERE d.RegistrationStatus = 'DocumentsUploaded';

-- Check active subscription for a driver
-- SELECT ds.*, sp.VehicleType, sp.Amount
-- FROM DriverSubscriptions ds
-- JOIN SubscriptionPlans sp ON sp.PlanId = ds.PlanId
-- WHERE ds.DriverId = ? AND ds.IsActive = 1 AND ds.EndDate >= NOW();

-- Subscription report
-- SELECT sp.VehicleType, COUNT(*) AS TotalSubscriptions, SUM(spm.Amount * sp.DurationInDays / 30) AS Revenue
-- FROM SubscriptionPayments spm
-- JOIN SubscriptionPlans sp ON sp.PlanId = spm.PlanId
-- WHERE spm.PaymentStatus = 'Success'
-- GROUP BY sp.VehicleType;

-- Daily expiry check (for background job)
-- SELECT d.DriverId, d.FullName, d.MobileNumber
-- FROM Drivers d
-- WHERE d.SubscriptionExpiryDate < NOW() AND d.IsApproved = 1;

-- Rides report
-- SELECT DATE(RequestedTime) AS RideDate, COUNT(*) AS TotalRides,
--        SUM(CASE WHEN RideStatus = 'Completed' THEN 1 ELSE 0 END) AS Completed,
--        SUM(CASE WHEN RideStatus = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
--        SUM(FinalFare) AS TotalRevenue
-- FROM Rides
-- GROUP BY DATE(RequestedTime)
-- ORDER BY RideDate DESC;
