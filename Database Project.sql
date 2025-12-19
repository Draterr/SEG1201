/* PART 2 Q1
*/
DROP TABLE Assignment CASCADE CONSTRAINTS;
DROP TABLE Incident_Report CASCADE CONSTRAINTS;
DROP TABLE Alert CASCADE CONSTRAINTS;
DROP TABLE Victim CASCADE CONSTRAINTS;
DROP TABLE Vehicle CASCADE CONSTRAINTS;
DROP TABLE Personnel CASCADE CONSTRAINTS;
DROP TABLE Roles CASCADE CONSTRAINTS;
DROP TABLE Disaster CASCADE CONSTRAINTS;
DROP TABLE Station CASCADE CONSTRAINTS;
DROP TABLE Shelter CASCADE CONSTRAINTS;
DROP TABLE Area CASCADE CONSTRAINTS;
DROP TABLE Caller CASCADE CONSTRAINTS;
DROP TABLE Disaster_Type CASCADE CONSTRAINTS;
DROP TABLE Deployment CASCADE CONSTRAINTS;
DROP TABLE Volunteer CASCADE CONSTRAINTS;
DROP TABLE Item_Catalog CASCADE CONSTRAINTS;
DROP TABLE Shelter_Inventory CASCADE CONSTRAINTS;
DROP TABLE Distribution_Record CASCADE CONSTRAINTS;


CREATE TABLE Area (
    AreaID NUMBER  PRIMARY KEY,
    AreaName VARCHAR2(100),
    AreaCode VARCHAR2(10) NOT NULL
);

CREATE TABLE Item_Catalog (
    ItemID NUMBER  PRIMARY KEY,
    Item_Name VARCHAR2(100) NOT NULL,
    Item_Category VARCHAR2(100) NOT NULL,
    Is_Perishable CHAR(5) DEFAULT 'FALSE', 
    CONSTRAINT chk_Is_Perishable CHECK (Is_Perishable IN ('TRUE', 'FALSE'))
);

CREATE TABLE Roles (
    RoleID NUMBER PRIMARY KEY,
    RoleName VARCHAR2(50) NOT NULL UNIQUE
);

CREATE TABLE Caller (
    CallerID NUMBER PRIMARY KEY,
    Mobile_No VARCHAR2(15) NOT NULL,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Date_Of_Birth Date,
    Gender char(1)
);

CREATE TABLE Station (
    StationID NUMBER PRIMARY KEY,
    Name VARCHAR2(50) NOT NULL,
    AreaID NUMBER NOT NULL,
    FOREIGN KEY (AreaID) REFERENCES Area(AreaID)
);

CREATE TABLE Shelter (
    ShelterID NUMBER PRIMARY KEY,
    ShelterName VARCHAR2(100) NOT NULL,
    AreaID NUMBER,
    Max_Capacity NUMBER NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Open',
    FOREIGN KEY (AreaID) REFERENCES Area(AreaID),
    CONSTRAINT chk_Max_Capacity CHECK (Max_Capacity > 0),
    CONSTRAINT chk_Status CHECK (Status in ('Open','Closed'))
);

CREATE TABLE Vehicle(
    VehicleID NUMBER PRIMARY KEY,
    StationID NUMBER NOT NULL,
    License_Plate VARCHAR2(20) UNIQUE NOT NULL,
    Brand VARCHAR2(30),
    Model VARCHAR2(50),
    Status VARCHAR2(20),
    Capacity NUMBER NOT NULL,
    fuel_range_km NUMERIC(5,2) NOT NULL,
    FOREIGN KEY (StationID) REFERENCES Station(StationID),
    CONSTRAINT chk_license_upper CHECK (License_Plate = UPPER(License_Plate)),
    CONSTRAINT chk_capacity CHECK (Capacity > 0)
);

CREATE TABLE Personnel (
    PersonnelID NUMBER PRIMARY KEY,
    StationID NUMBER NOT NULL, 
    RoleID NUMBER NOT NULL,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Date_Of_Birth DATE,
    Gender Char(1),
    FOREIGN KEY (StationID) REFERENCES Station(StationID),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

CREATE TABLE Disaster_Type(
    Type varchar2(30) PRIMARY KEY,
    Name varchar2(100),
    Description varchar2(200)
);

CREATE TABLE Disaster (
    DisasterID NUMBER PRIMARY KEY,
    DisasterName varchar2(50) NOT NULL,
    AreaID NUMBER NOT NULL,
    DisasterType VARCHAR2(50) NOT NULL,
    Severity_Level NUMBER,
    Start_Date DATE NOT NULL,
    End_Date DATE,
    Status VARCHAR2(30),
    FOREIGN KEY (AreaID) REFERENCES Area(AreaID),
    FOREIGN KEY (DisasterType) REFERENCES Disaster_Type(Type),
    CONSTRAINT chk_disaster_date CHECK (End_Date >= Start_Date),
    CONSTRAINT chk_severity CHECK (severity_level >= 1 and severity_level <= 5)
);

CREATE TABLE Shelter_Inventory (
    InventoryID NUMBER PRIMARY KEY,
    ItemID NUMBER,
    ShelterID NUMBER,
    Quantity NUMBER DEFAULT 0,
    ExpiryDate DATE,
    StorageLocation VARCHAR2(50),
    FOREIGN KEY (ItemID) REFERENCES Item_Catalog(ItemID),
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    CONSTRAINT chk_inventory_quantity CHECK (Quantity >= 0)
);

CREATE TABLE Deployment (
    DeploymentID NUMBER PRIMARY KEY,
    PersonnelID NUMBER NOT NULL,
    ShelterID NUMBER,
    DisasterID NUMBER,
    Start_Date DATE NOT NULL,
    End_Date DATE,
    FOREIGN KEY (PersonnelID) REFERENCES Personnel(PersonnelID),
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    FOREIGN KEY (DisasterID) REFERENCES Disaster(DisasterID),
    CONSTRAINT chk_staff_dest CHECK (
        (DisasterID IS NOT NULL AND ShelterID IS NULL)
        OR 
        (DisasterID IS NULL AND ShelterID IS NOT NULL)
    ),
    CONSTRAINT chk_assign_dates CHECK (End_Date >= Start_Date)
);

CREATE TABLE Incident_Report (
    IncidentID NUMBER PRIMARY KEY,
    CallerID NUMBER NOT NULL,
    DisasterID NUMBER NOT NULL,
    Dispatcher_ID NUMBER NOT NULL,
    Status VARCHAR2(30),
    Report_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CallerID) REFERENCES Caller(CallerID),
    FOREIGN KEY (DisasterID)  REFERENCES Disaster(DisasterID),
    FOREIGN KEY (Dispatcher_ID) REFERENCES Personnel(PersonnelID)
);

CREATE TABLE Volunteer(
    VolunteerID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Date_Of_Birth DATE,
    Gender char(1)
);

CREATE TABLE Assignment(
    AssignmentID NUMBER PRIMARY KEY,
    VolunteerID NUMBER NOT NULL,
    ShelterID NUMBER NOT NULL,
    StartDate DATE,
    EndDate DATE,
    DisasterID NUMBER NOT NULL,
    FOREIGN KEY (VolunteerID) REFERENCES Volunteer(VolunteerID),
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    FOREIGN KEY (DisasterID) REFERENCES Disaster(DisasterID)
);

CREATE TABLE Victim (
    VictimID NUMBER PRIMARY KEY,
    DisasterID NUMBER NOT NULL,
    ShelterID NUMBER NOT NULL,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Gender char(1),
    Status VARCHAR2(30),
    FOREIGN KEY (DisasterID)  REFERENCES Disaster(DisasterID), 
    FOREIGN KEY (ShelterID) REFERENCES Shelter(ShelterID),
    CONSTRAINT chk_Gender CHECK (Gender in ('M','F'))
);

CREATE TABLE Distribution_Record (
    DistID NUMBER PRIMARY KEY,
    VictimID NUMBER NOT NULL,
    InventoryID NUMBER NOT NULL,
    Quantity_Distributed NUMBER NOT NULL,
    Dist_Date DATE DEFAULT SYSDATE,
    FOREIGN KEY (VictimID)  REFERENCES Victim(VictimID),
    FOREIGN KEY (InventoryID) REFERENCES Shelter_Inventory(InventoryID)
);

CREATE TABLE Alert (
    AlertID NUMBER PRIMARY KEY,
    DisasterID NUMBER NOT NULL,
    Message_Body VARCHAR2(255),
    Sent_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Delivery_Method VARCHAR2(20),
    Severity NUMERIC,
    AreaAffected NUMERIC,
    FOREIGN KEY (DisasterID) REFERENCES Disaster(DisasterID),
    FOREIGN KEY (AreaAffected) REFERENCES Area(AreaID),
    CONSTRAINT chk_delivery_method CHECK (Delivery_Method in ('SMS','APP')),
    CONSTRAINT chk_alert_severity CHECK (severity >= 1 and severity <= 5)
);

/* PART 2 Q2 
INSERT DATA
*/

-- Areas
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (1, 'Downtown District', 'DT-01');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (2, 'North Hills', 'NH-02');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (3, 'Industrial Zone', 'IZ-03');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (4, 'Westside Suburbs', 'WS-04');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (5, 'East River Bank', 'ER-05');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (6, 'Central Park', 'CP-06');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (7, 'Harbor Front', 'HF-07');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (8, 'South Tech Park', 'ST-08');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (9, 'Airport Hub', 'AH-09');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (10, 'Lake Shore', 'LS-10');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (11, 'Old Town', 'OT-11');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (12, 'Forest Reserve', 'FR-12');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (13, 'East Bridge', 'EB-13');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (14, 'South Flats', 'SF-14');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (15, 'Rail Yard', 'RY-15');
INSERT INTO Area (AreaID, AreaName, AreaCode) VALUES (16, 'Northwest Mesa', 'NM-16');

-- Roles
INSERT INTO Roles (RoleID, RoleName) VALUES (1, 'Dispatcher');
INSERT INTO Roles (RoleID, RoleName) VALUES (2, 'Medical Specialist');
INSERT INTO Roles (RoleID, RoleName) VALUES (3, 'Search and Rescue Lead');
INSERT INTO Roles (RoleID, RoleName) VALUES (4, 'Logistics Manager');
INSERT INTO Roles (RoleID, RoleName) VALUES (5, 'Field Driver');
INSERT INTO Roles (RoleID, RoleName) VALUES (6, 'Hazmat Technician');
INSERT INTO Roles (RoleID, RoleName) VALUES (7, 'Station Commander');
INSERT INTO Roles (RoleID, RoleName) VALUES (8, 'Security Officer');
INSERT INTO Roles (RoleID, RoleName) VALUES (9, 'Database Administrator');
INSERT INTO Roles (RoleID, RoleName) VALUES (10, 'IT Support');
INSERT INTO Roles (RoleID, RoleName) VALUES (11, 'Public Relations');
INSERT INTO Roles (RoleID, RoleName) VALUES (12, 'Triage Nurse');
INSERT INTO Roles (RoleID, RoleName) VALUES (13, 'Logistics Assistant');
INSERT INTO Roles (RoleID, RoleName) VALUES (14, 'Heavy Equipment Operator');
INSERT INTO Roles (RoleID, RoleName) VALUES (15, 'Fire Fighter');
INSERT INTO Roles (RoleID, RoleName) VALUES (16, 'Counselor');

-- Item Types
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (1, 'Bottled Water', 'Food_Water', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (2, 'Rice', 'Food_Water', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (3, 'Thermal Blanket', 'Shelter_Clothing', 'FALSE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (4, 'First Aid Kit', 'Medical', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (5, 'Canned Beans', 'Food_Water', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (6, 'Hygiene Pack', 'Sanitation', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (7, 'Flashlight', 'Tools_Equipment', 'FALSE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (8, 'Baby Formula', 'Medical', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (9, 'Baby Diapers', 'Sanitation', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (10, 'Batteries', 'Tools_Equipment', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (11, 'Shovel', 'Tools_Equipment', 'FALSE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (12, 'Gloves', 'Safety', 'FALSE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (13, 'Tarp', 'Shelter_Clothing', 'FALSE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (14, 'Candles', 'Tools_Equipment', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (15, 'Salty Snacks', 'Food_Water', 'TRUE');
INSERT INTO Item_Catalog (ItemID, Item_Name, Item_Category, Is_Perishable) VALUES (16, 'Medical Mask', 'Safety', 'FALSE');

-- Disaster Types
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('FLOOD', 'Urban Flooding', 'Rising water levels.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('FIRE', 'Structural Fire', 'Large scale fire.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('QUAKE', 'Earthquake', 'Seismic activity.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('STORM', 'Severe Thunderstorm', 'High winds and rain.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('HAZMAT', 'Chemical Spill', 'Dangerous leakage.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('HEAT', 'Heatwave', 'Excessive heat.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('LANDSLIDE', 'Mudslide', 'Earth collapse.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('PANDEMIC', 'Viral Outbreak', 'Contagious disease.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('SNOW', 'Heavy Snowfall', 'Extreme cold and whiteout conditions.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('TSUNAMI', 'Coastal Wave', 'Large wave affecting the coastline.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('DROUGHT', 'Water Shortage', 'Prolonged dry spell.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('WILDFIRE', 'Forest Fire', 'Uncontrolled fire in rural area.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('VOLCANO', 'Ashfall Event', 'Volcanic activity with airborne ash.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('AVALANCHE', 'Snow Slide', 'Large mass of snow sliding down hill.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('BIOHAZ', 'Biological Contamination', 'Localized virus or toxin spread.');
INSERT INTO Disaster_Type (Type, Name, Description) VALUES ('FOG', 'Heavy Fog Event', 'Low visibility event causing travel issues.');

-- Callers
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (1, '0123456789', 'John', 'Smith', TO_DATE('1985-05-15', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (2, '0129876543', 'Mary', 'Johnson', TO_DATE('1990-11-20', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (3, '0175551234', 'Robert', 'Williams', TO_DATE('1978-03-10', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (4, '0198887777', 'Patricia', 'Brown', TO_DATE('1995-07-25', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (5, '0134445555', 'Michael', 'Jones', TO_DATE('1982-09-05', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (6, '0162223333', 'Linda', 'Miller', TO_DATE('1998-12-12', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (7, '0119998888', 'William', 'Davis', TO_DATE('1970-01-30', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (8, '0147776666', 'Elizabeth', 'Garcia', TO_DATE('1992-06-18', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (9, '0121112222', 'Jessica', 'Hall', TO_DATE('1994-04-01', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (10, '0123334444', 'Gary', 'Allen', TO_DATE('1976-02-14', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (11, '0125556666', 'Cheryl', 'Young', TO_DATE('1983-10-22', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (12, '0127778888', 'Peter', 'King', TO_DATE('1991-09-03', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (13, '0129990000', 'Maria', 'Wright', TO_DATE('1965-08-01', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (14, '0120001111', 'Kevin', 'Lopez', TO_DATE('1989-03-05', 'YYYY-MM-DD'), 'M');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (15, '0120002222', 'Sarah', 'Hill', TO_DATE('1997-12-19', 'YYYY-MM-DD'), 'F');
INSERT INTO Caller (CallerID, Mobile_No, FirstName, LastName, Date_Of_Birth, Gender) VALUES (16, '0120003333', 'Robert', 'Scott', TO_DATE('1974-06-28', 'YYYY-MM-DD'), 'M');

-- Stations
INSERT INTO Station (StationID, Name, AreaID) VALUES (101, 'Central Command HQ', 1);
INSERT INTO Station (StationID, Name, AreaID) VALUES (102, 'North Fire Station', 2);
INSERT INTO Station (StationID, Name, AreaID) VALUES (103, 'Industrial Response Unit', 3);
INSERT INTO Station (StationID, Name, AreaID) VALUES (104, 'Westside Medic Base', 4);
INSERT INTO Station (StationID, Name, AreaID) VALUES (105, 'River Rescue Post', 5);
INSERT INTO Station (StationID, Name, AreaID) VALUES (106, 'Park Ranger Station', 6);
INSERT INTO Station (StationID, Name, AreaID) VALUES (107, 'Harbor Logistics Hub', 7);
INSERT INTO Station (StationID, Name, AreaID) VALUES (108, 'Tech Park Security', 8);
INSERT INTO Station (StationID, Name, AreaID) VALUES (109, 'Airport Maintenance', 9);
INSERT INTO Station (StationID, Name, AreaID) VALUES (110, 'Lake Rescue Base', 10);
INSERT INTO Station (StationID, Name, AreaID) VALUES (111, 'Old Town Police', 11);
INSERT INTO Station (StationID, Name, AreaID) VALUES (112, 'Forest Fire HQ', 12);
INSERT INTO Station (StationID, Name, AreaID) VALUES (113, 'East Bridge Command', 13);
INSERT INTO Station (StationID, Name, AreaID) VALUES (114, 'South Flats Logistics', 14);
INSERT INTO Station (StationID, Name, AreaID) VALUES (115, 'Rail Yard Security', 15);
INSERT INTO Station (StationID, Name, AreaID) VALUES (116, 'Mesa Satellite', 16);

-- Shelters
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (201, 'City Hall Gym', 1, 500, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (202, 'North High School', 2, 300, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (203, 'Factory Warehouse B', 3, 1000, 'Closed');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (204, 'Community Center West', 4, 200, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (205, 'Riverside Church', 5, 150, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (206, 'Stadium Arena', 6, 2000, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (207, 'Harbor Warehouse 9', 7, 800, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (208, 'Tech Convention Hall', 8, 600, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (209, 'Airport Terminal A', 9, 3000, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (210, 'Lake View Lodge', 10, 150, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (211, 'Old Town Hall', 11, 80, 'Closed');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (212, 'Green Valley School', 12, 400, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (213, 'Bridge Community Hub', 13, 250, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (214, 'South Church Basement', 14, 100, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (215, 'Rail Yard Admin Bld', 15, 50, 'Open');
INSERT INTO Shelter (ShelterID, ShelterName, AreaID, Max_Capacity, Status) VALUES (216, 'Mesa Conference Ctr', 16, 1200, 'Open');

-- Vehicles
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (1, 101, 'CMD-001', 'Ford', 'Explorer', 'Available', 5, 600.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (2, 102, 'FIRE-101', 'Mercedes', 'Fire Truck', 'Available', 6, 400.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (3, 103, 'HAZ-202', 'Volvo', 'Hazmat Truck', 'Maintenance', 3, 500.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (4, 104, 'MED-303', 'Ford', 'Ambulance', 'Deployed', 4, 450.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (5, 105, 'BOAT-404', 'Yamaha', 'Rescue Boat', 'Available', 8, 200.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (6, 106, 'RNG-505', 'Jeep', 'Wrangler', 'Deployed', 4, 550.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (7, 107, 'TRK-606', 'Scania', 'Logistics Truck', 'Available', 2, 800.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (8, 101, 'CMD-002', 'Toyota', 'Land Cruiser', 'Maintenance', 5, 700.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (9, 109, 'AIR-100', 'GMC', 'Van', 'Available', 6, 450.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (10, 110, 'LAKE-200', 'Kawasaki', 'Jet Ski', 'Available', 2, 100.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (11, 111, 'POL-300', 'Chevy', 'Cruiser', 'Available', 4, 650.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (12, 112, 'FOREST-400', 'KTM', 'ATV', 'Maintenance', 2, 300.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (13, 113, 'BRIDGE-500', 'Scania', 'Crane', 'Available', 1, 400.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (14, 114, 'FLAT-600', 'Ford', 'Transit', 'Deployed', 10, 750.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (15, 115, 'RAIL-700', 'CAT', 'Excavator', 'Available', 1, 250.00);
INSERT INTO Vehicle (VehicleID, StationID, License_Plate, Brand, Model, Status, Capacity, fuel_range_km) VALUES (16, 116, 'MESA-800', 'Toyota', 'Highlander', 'Available', 7, 600.00);


-- Personnel
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1001, 101, 1, 'James', 'Wilson', TO_DATE('1980-01-01', 'YYYY-MM-DD'),'M');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1002, 101, 7, 'Barbara', 'Moore', TO_DATE('1975-05-20', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1003, 102, 3, 'Richard', 'Taylor', TO_DATE('1988-08-08', 'YYYY-MM-DD'),'M');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1004, 104, 2, 'Susan', 'Anderson', TO_DATE('1982-03-15', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1005, 107, 4, 'Joseph', 'Thomas', TO_DATE('1990-11-11', 'YYYY-MM-DD'),'M');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1006, 105, 3, 'Margaret', 'Jackson', TO_DATE('1995-02-28', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1007, 103, 6, 'Charles', 'White', TO_DATE('1987-07-07', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1008, 101, 1, 'Thomas', 'Harris', TO_DATE('1992-09-19', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1009, 109, 15, 'Janet', 'Smith', TO_DATE('1985-04-10', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1010, 110, 3, 'David', 'Harris', TO_DATE('1978-11-20', 'YYYY-MM-DD'),'M');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1011, 111, 8, 'Anna', 'Clark', TO_DATE('1993-01-05', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1012, 112, 3, 'Paul', 'Lewis', TO_DATE('1981-06-25', 'YYYY-MM-DD'),'M');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1013, 113, 14, 'Emily', 'Walker', TO_DATE('1972-09-15', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1014, 114, 4, 'Mark', 'Hall', TO_DATE('1996-03-20', 'YYYY-MM-DD'),'M');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1015, 115, 8, 'Laura', 'Allen', TO_DATE('1984-12-05', 'YYYY-MM-DD'),'F');
INSERT INTO Personnel (PersonnelID, StationID, RoleID, FirstName, LastName, Date_Of_Birth,Gender) VALUES (1016, 116, 1, 'Steven', 'Young', TO_DATE('1990-07-28', 'YYYY-MM-DD'),'M');

-- Volunteers
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (501, 'Christopher', 'Martin', TO_DATE('2000-01-01', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (502, 'Daniel', 'Thompson', TO_DATE('1999-05-05', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (503, 'Lisa', 'Garcia', TO_DATE('2001-12-25', 'YYYY-MM-DD'), 'F');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (504, 'Matthew', 'Martinez', TO_DATE('1998-08-14', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (505, 'Nancy', 'Robinson', TO_DATE('2002-03-30', 'YYYY-MM-DD'), 'F');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (506, 'Paul', 'Clark', TO_DATE('1985-06-10', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (507, 'Karen', 'Rodriguez', TO_DATE('1990-09-09', 'YYYY-MM-DD'), 'F');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (508, 'Steven', 'Lewis', TO_DATE('1975-11-20', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (509, 'George', 'Miller', TO_DATE('1988-10-10', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (510, 'Helen', 'King', TO_DATE('1977-04-20', 'YYYY-MM-DD'), 'F');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (511, 'Joe', 'Wright', TO_DATE('1992-01-01', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (512, 'Maria', 'Scott', TO_DATE('1985-08-05', 'YYYY-MM-DD'), 'F');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (513, 'Alex', 'Green', TO_DATE('1996-03-17', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (514, 'Betty', 'Adams', TO_DATE('1981-11-29', 'YYYY-MM-DD'), 'F');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (515, 'Charles', 'Baker', TO_DATE('1994-07-04', 'YYYY-MM-DD'), 'M');
INSERT INTO Volunteer (VolunteerID, FirstName, LastName, Date_Of_Birth, Gender) VALUES (516, 'Diane', 'Cook', TO_DATE('1970-02-02', 'YYYY-MM-DD'), 'F');


-- Disasters
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (901, 'Downtown Flash Flood', 1, 'FLOOD', 4, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-12', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (902, 'North Hills Fire', 2, 'FIRE', 5, TO_DATE('2025-02-15', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (903, 'River Bank Overflow', 5, 'FLOOD', 3, TO_DATE('2025-03-01', 'YYYY-MM-DD'), TO_DATE('2025-03-02', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (904, 'Industrial Chem Leak', 3, 'HAZMAT', 5, TO_DATE('2025-04-20', 'YYYY-MM-DD'), TO_DATE('2025-04-21', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (905, 'Summer Heatwave', 6, 'HEAT', 2, TO_DATE('2025-06-01', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (906, 'Suburban Storm', 4, 'STORM', 3, TO_DATE('2025-07-15', 'YYYY-MM-DD'), TO_DATE('2025-07-16', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (907, 'Harbor Oil Spill', 7, 'HAZMAT', 4, TO_DATE('2025-08-10', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (908, 'Minor Tremor', 8, 'QUAKE', 1, TO_DATE('2025-09-05', 'YYYY-MM-DD'), TO_DATE('2025-09-05', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (909, 'Airport Tsunami Scare', 9, 'TSUNAMI', 3, TO_DATE('2025-09-20', 'YYYY-MM-DD'), TO_DATE('2025-09-20', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (910, 'Lake Shore Drought', 10, 'DROUGHT', 4, TO_DATE('2025-10-01', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (911, 'Old Town Wildfire', 11, 'WILDFIRE', 5, TO_DATE('2025-10-15', 'YYYY-MM-DD'), TO_DATE('2025-10-18', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (912, 'Forest Reserve Avalanche', 12, 'AVALANCHE', 5, TO_DATE('2025-11-01', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (913, 'East Bridge Volcano Ash', 13, 'VOLCANO', 3, TO_DATE('2025-11-15', 'YYYY-MM-DD'), TO_DATE('2025-11-17', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (914, 'South Flats Snow Storm', 14, 'SNOW', 4, TO_DATE('2025-11-25', 'YYYY-MM-DD'), TO_DATE('2025-11-27', 'YYYY-MM-DD'), 'Resolved');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (915, 'Rail Yard Biohazard', 15, 'BIOHAZ', 5, TO_DATE('2025-12-01', 'YYYY-MM-DD'), NULL, 'Active');
INSERT INTO Disaster (DisasterID, DisasterName, AreaID, DisasterType, Severity_Level, Start_Date, End_Date, Status) VALUES (916, 'Mesa Fog Event', 16, 'FOG', 1, TO_DATE('2025-12-05', 'YYYY-MM-DD'), TO_DATE('2025-12-06', 'YYYY-MM-DD'), 'Resolved');

-- Incident Reports
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (1, 1, 901, 1001, 'Confirmed', SYSTIMESTAMP - 100);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (2, 2, 902, 1008, 'Confirmed', SYSTIMESTAMP - 50);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (3, 3, 902, 1001, 'Pending Confirmation', SYSTIMESTAMP - 40);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (4, 4, 904, 1008, 'Confirmed', SYSTIMESTAMP - 200);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (5, 5, 904, 1001, 'Confirmed', SYSTIMESTAMP - 199);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (6, 6, 905, 1008, 'Pending Confirmation', SYSTIMESTAMP - 10);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (7, 7, 907, 1001, 'Pending Confirmation', SYSTIMESTAMP - 2);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (8, 8, 901, 1008, 'Unconfirmed', SYSTIMESTAMP - 99);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (9, 9, 909, 1016, 'Confirmed', SYSTIMESTAMP - 80);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (10, 10, 910, 1001, 'Confirmed', SYSTIMESTAMP - 70);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (11, 11, 911, 1008, 'Pending Confirmation', SYSTIMESTAMP - 65);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (12, 12, 912, 1016, 'Confirmed', SYSTIMESTAMP - 55);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (13, 13, 913, 1001, 'Confirmed', SYSTIMESTAMP - 45);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (14, 14, 914, 1008, 'Pending Confirmation', SYSTIMESTAMP - 30);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (15, 15, 915, 1016, 'Unconfirmed', SYSTIMESTAMP - 15);
INSERT INTO Incident_Report (IncidentID, CallerID, DisasterID, Dispatcher_ID, Status, Report_Time) VALUES (16, 16, 916, 1001, 'Confirmed', SYSTIMESTAMP - 5);


-- Deployments
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (1, 1003, 901, NULL, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-12', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (2, 1006, 901, NULL, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-12', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (3, 1004, NULL, 201, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-15', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (4, 1005, NULL, 201, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-15', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (5, 1003, 902, NULL, TO_DATE('2025-02-15', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (6, 1006, 902, NULL, TO_DATE('2025-02-15', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (7, 1007, 904, NULL, TO_DATE('2025-04-20', 'YYYY-MM-DD'), TO_DATE('2025-04-21', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (8, 1004, NULL, 202, TO_DATE('2025-02-15', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (9, 1002, 901, NULL, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-11', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (10, 1005, NULL, 207, TO_DATE('2025-08-10', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (11, 1007, 907, NULL, TO_DATE('2025-08-10', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (12, 1003, 903, NULL, TO_DATE('2025-03-01', 'YYYY-MM-DD'), TO_DATE('2025-03-02', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (13, 1006, 903, NULL, TO_DATE('2025-03-01', 'YYYY-MM-DD'), TO_DATE('2025-03-02', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (14, 1004, NULL, 206, TO_DATE('2025-06-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (15, 1005, NULL, 206, TO_DATE('2025-06-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (16, 1009, 909, NULL, TO_DATE('2025-09-20', 'YYYY-MM-DD'), TO_DATE('2025-09-20', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (17, 1010, 910, NULL, TO_DATE('2025-10-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (18, 1011, NULL, 211, TO_DATE('2025-10-15', 'YYYY-MM-DD'), TO_DATE('2025-10-18', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (19, 1012, 912, NULL, TO_DATE('2025-11-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (20, 1013, 913, NULL, TO_DATE('2025-11-15', 'YYYY-MM-DD'), TO_DATE('2025-11-17', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (21, 1014, NULL, 214, TO_DATE('2025-11-25', 'YYYY-MM-DD'), TO_DATE('2025-11-27', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (22, 1015, 915, NULL, TO_DATE('2025-12-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (23, 1004, NULL, 209, TO_DATE('2025-09-20', 'YYYY-MM-DD'), TO_DATE('2025-09-21', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (24, 1007, 911, NULL, TO_DATE('2025-10-15', 'YYYY-MM-DD'), TO_DATE('2025-10-18', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (25, 1005, NULL, 213, TO_DATE('2025-11-15', 'YYYY-MM-DD'), TO_DATE('2025-11-17', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (26, 1003, 914, NULL, TO_DATE('2025-11-25', 'YYYY-MM-DD'), TO_DATE('2025-11-27', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (27, 1006, 914, NULL, TO_DATE('2025-11-25', 'YYYY-MM-DD'), TO_DATE('2025-11-27', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (28, 1004, NULL, 216, TO_DATE('2025-12-05', 'YYYY-MM-DD'), TO_DATE('2025-12-06', 'YYYY-MM-DD'));
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (29, 1014, NULL, 201, TO_DATE('2025-12-10', 'YYYY-MM-DD'), NULL);
INSERT INTO Deployment (DeploymentID, PersonnelID, DisasterID, ShelterID, Start_Date, End_Date) VALUES (30, 1007, 915, NULL, TO_DATE('2025-12-01', 'YYYY-MM-DD'), NULL);

-- Assignments 
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (1, 501, 201, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-15', 'YYYY-MM-DD'), 901);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (2, 502, 201, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_DATE('2025-01-15', 'YYYY-MM-DD'), 901);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (3, 503, 201, TO_DATE('2025-01-11', 'YYYY-MM-DD'), TO_DATE('2025-01-14', 'YYYY-MM-DD'), 901);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (4, 504, 202, TO_DATE('2025-02-15', 'YYYY-MM-DD'), TO_DATE('2025-02-20', 'YYYY-MM-DD'), 902);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (5, 505, 202, TO_DATE('2025-02-15', 'YYYY-MM-DD'), TO_DATE('2025-02-20', 'YYYY-MM-DD'), 902);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (6, 506, 202, TO_DATE('2025-02-16', 'YYYY-MM-DD'), TO_DATE('2025-02-19', 'YYYY-MM-DD'), 902);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (7, 507, 203, TO_DATE('2025-04-20', 'YYYY-MM-DD'), TO_DATE('2025-04-21', 'YYYY-MM-DD'), 904);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (8, 508, 204, TO_DATE('2025-07-15', 'YYYY-MM-DD'), TO_DATE('2025-07-16', 'YYYY-MM-DD'), 906);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (9, 501, 206, TO_DATE('2025-06-01', 'YYYY-MM-DD'), NULL, 905);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (10, 502, 206, TO_DATE('2025-06-01', 'YYYY-MM-DD'), NULL, 905);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (11, 503, 207, TO_DATE('2025-08-10', 'YYYY-MM-DD'), NULL, 907);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (12, 504, 207, TO_DATE('2025-08-10', 'YYYY-MM-DD'), NULL, 907);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (13, 505, 205, TO_DATE('2025-03-01', 'YYYY-MM-DD'), TO_DATE('2025-03-02', 'YYYY-MM-DD'), 903);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (14, 506, 201, TO_DATE('2025-01-20', 'YYYY-MM-DD'), TO_DATE('2025-01-22', 'YYYY-MM-DD'), 901);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (15, 507, 202, TO_DATE('2025-02-25', 'YYYY-MM-DD'), TO_DATE('2025-02-28', 'YYYY-MM-DD'), 902);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (16, 509, 209, TO_DATE('2025-09-20', 'YYYY-MM-DD'), TO_DATE('2025-09-20', 'YYYY-MM-DD'), 909);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (24, 509, 209, TO_DATE('2025-09-22', 'YYYY-MM-DD'), TO_DATE('2025-09-23', 'YYYY-MM-DD'), 909);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (25, 509, 209, TO_DATE('2025-09-25', 'YYYY-MM-DD'), TO_DATE('2025-09-26', 'YYYY-MM-DD'), 909);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (19, 512, 212, TO_DATE('2025-11-01', 'YYYY-MM-DD'), NULL, 912);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (27, 512, 212, TO_DATE('2025-11-03', 'YYYY-MM-DD'), TO_DATE('2025-11-05', 'YYYY-MM-DD'), 912);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (30, 512, 212, TO_DATE('2025-11-10', 'YYYY-MM-DD'), TO_DATE('2025-11-12', 'YYYY-MM-DD'), 912);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (17, 510, 210, TO_DATE('2025-10-01', 'YYYY-MM-DD'), NULL, 910);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (18, 511, 211, TO_DATE('2025-10-15', 'YYYY-MM-DD'), TO_DATE('2025-10-18', 'YYYY-MM-DD'), 911);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (20, 513, 213, TO_DATE('2025-11-15', 'YYYY-MM-DD'), TO_DATE('2025-11-17', 'YYYY-MM-DD'), 913);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (21, 514, 214, TO_DATE('2025-11-25', 'YYYY-MM-DD'), TO_DATE('2025-11-27', 'YYYY-MM-DD'), 914);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (22, 515, 215, TO_DATE('2025-12-01', 'YYYY-MM-DD'), NULL, 915);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (23, 516, 216, TO_DATE('2025-12-05', 'YYYY-MM-DD'), TO_DATE('2025-12-06', 'YYYY-MM-DD'), 916);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (26, 503, 211, TO_DATE('2025-10-16', 'YYYY-MM-DD'), TO_DATE('2025-10-17', 'YYYY-MM-DD'), 911);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (28, 505, 213, TO_DATE('2025-11-16', 'YYYY-MM-DD'), TO_DATE('2025-11-18', 'YYYY-MM-DD'), 913);
INSERT INTO Assignment (AssignmentID, VolunteerID, ShelterID, StartDate, EndDate, DisasterID) VALUES (29, 506, 214, TO_DATE('2025-11-26', 'YYYY-MM-DD'), TO_DATE('2025-11-28', 'YYYY-MM-DD'), 914);

-- Shelter_Inventory
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (1, 1, 201, 500, TO_DATE('2026-06-01', 'YYYY-MM-DD'), 'Section A, Shelf 1');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (2, 2, 201, 200, TO_DATE('2026-12-01', 'YYYY-MM-DD'), 'Section A, Shelf 2');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (3, 3, 201, 300, NULL, 'Section B, Shelf 1');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (4, 1, 202, 300, TO_DATE('2026-07-01', 'YYYY-MM-DD'), 'Storage Room 1');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (5, 4, 202, 100, TO_DATE('2025-12-01', 'YYYY-MM-DD'), 'Medical Cabinet');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (6, 1, 206, 1000, TO_DATE('2026-08-01', 'YYYY-MM-DD'), 'Main Storage');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (7, 5, 206, 800, TO_DATE('2027-01-01', 'YYYY-MM-DD'), 'Section C, Shelf 3');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (8, 7, 207, 150, NULL, 'Tool Shed');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (9, 9, 209, 400, TO_DATE('2026-03-01', 'YYYY-MM-DD'), 'Nursery Area');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (10, 1, 210, 100, TO_DATE('2026-05-01', 'YYYY-MM-DD'), 'Pantry');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (11, 13, 211, 50, NULL, 'Outdoor Storage');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (12, 12, 212, 200, NULL, 'Safety Equipment Room');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (13, 10, 213, 600, TO_DATE('2028-01-01', 'YYYY-MM-DD'), 'Utility Room');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (14, 14, 214, 150, TO_DATE('2027-06-01', 'YYYY-MM-DD'), 'Emergency Supplies');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (15, 15, 215, 300, TO_DATE('2026-09-01', 'YYYY-MM-DD'), 'Food Storage');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (16, 16, 216, 400, NULL, 'Medical Supplies');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (17, 4, 201, 50, TO_DATE('2026-01-01', 'YYYY-MM-DD'), 'First Aid Station');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (18, 6, 201, 100, TO_DATE('2027-02-01', 'YYYY-MM-DD'), 'Sanitation Area');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (19, 8, 202, 30, TO_DATE('2025-11-01', 'YYYY-MM-DD'), 'Nursery');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (20, 3, 206, 200, NULL, 'Section B');
INSERT INTO Shelter_Inventory (InventoryID, ItemID, ShelterID, Quantity, ExpiryDate, StorageLocation) VALUES (21, 11, 207, 20, NULL, 'Tool Shed');
-- Victims
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (1, 901, 201, 'Betty', 'White', 'F', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (2, 901, 201, 'George', 'Clooney', 'M', 'Injured');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (3, 901, 201, 'Brad', 'Pitt', 'M', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (4, 902, 202, 'Angelina', 'Jolie', 'F', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (5, 902, 202, 'Tom', 'Cruise', 'M', 'Displaced');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (6, 905, 206, 'Jennifer', 'Aniston', 'F', 'Dehydrated');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (7, 905, 206, 'Leonardo', 'DiCaprio', 'M', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (8, 907, 207, 'Scarlett', 'Johansson', 'F', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (9, 909, 209, 'Chris', 'Evans', 'M', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (10, 910, 210, 'Julia', 'Roberts', 'F', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (11, 911, 211, 'Morgan', 'Freeman', 'M', 'Displaced');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (12, 912, 212, 'Halle', 'Berry', 'F', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (13, 913, 213, 'Tom', 'Hanks', 'M', 'Injured');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (14, 914, 214, 'Cate', 'Blanchett', 'F', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (15, 915, 215, 'Denzel', 'Washington', 'M', 'Stable');
INSERT INTO Victim (VictimID, DisasterID, ShelterID, FirstName, LastName, Gender, Status) VALUES (16, 916, 216, 'Nicole', 'Kidman', 'F', 'Stable');

-- Distribution
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (1, 1, 1, 5, TO_DATE('2025-01-11', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (2, 2, 1, 5, TO_DATE('2025-01-11', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (3, 1, 2, 2, TO_DATE('2025-01-11', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (4, 3, 3, 1, TO_DATE('2025-01-12', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (5, 4, 4, 10, TO_DATE('2025-02-16', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (6, 5, 5, 1, TO_DATE('2025-02-16', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (7, 6, 6, 20, TO_DATE('2025-06-02', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (8, 7, 6, 20, TO_DATE('2025-06-02', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (9, 6, 7, 5, TO_DATE('2025-06-03', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (10, 8, 8, 1, TO_DATE('2025-08-11', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (11, 2, 17, 1, TO_DATE('2025-01-13', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (12, 4, 5, 1, TO_DATE('2025-02-17', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (13, 7, 7, 5, TO_DATE('2025-06-03', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (14, 3, 1, 5, TO_DATE('2025-01-12', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (15, 5, 4, 5, TO_DATE('2025-02-17', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (16, 9, 9, 1, TO_DATE('2025-09-20', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (17, 9, 9, 5, TO_DATE('2025-09-20', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (18, 9, 9, 1, TO_DATE('2025-09-21', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (19, 9, 9, 1, TO_DATE('2025-09-22', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (20, 9, 9, 2, TO_DATE('2025-09-25', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (21, 9, 9, 3, TO_DATE('2025-09-25', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (22, 12, 12, 3, TO_DATE('2025-11-02', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (23, 12, 12, 5, TO_DATE('2025-11-02', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (24, 12, 12, 2, TO_DATE('2025-11-03', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (25, 12, 12, 5, TO_DATE('2025-11-04', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (26, 10, 10, 1, TO_DATE('2025-10-02', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (27, 13, 13, 1, TO_DATE('2025-11-16', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (28, 14, 14, 2, TO_DATE('2025-11-26', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (29, 15, 15, 5, TO_DATE('2025-12-02', 'YYYY-MM-DD'));
INSERT INTO Distribution_Record (DistID, VictimID, InventoryID, Quantity_Distributed, Dist_Date) VALUES (30, 16, 16, 1, TO_DATE('2025-12-06', 'YYYY-MM-DD'));

-- Alerts
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (1, 901, 'Flash Flood Warning for Downtown. Evacuate immediately.', 'SMS', 5, 1);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (2, 902, 'Fire reported in North Hills. Stay clear of sector 4.', 'APP', 5, 2);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (3, 903, 'River levels rising. Prepare for potential evacuation.', 'SMS', 3, 5);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (4, 904, 'Chemical spill in Industrial Zone. Do not inhale fumes.', 'APP', 5, 3);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (5, 905, 'Extreme Heat Warning. Stay hydrated.', 'SMS', 2, 6);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (6, 906, 'Severe Storm Approaching Westside.', 'APP', 3, 4);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (7, 907, 'Oil spill containment in Harbor. Water access restricted.', 'SMS', 4, 7);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (8, 908, 'Minor tremor detected. No action needed.', 'APP', 1, 8);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (9, 909, 'Tsunami threat cleared. Return to area.', 'SMS', 3, 9);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (10, 910, 'Extreme Drought: Conserve water immediately.', 'APP', 4, 10);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (11, 911, 'Wildfire contained. Smoke health warning.', 'SMS', 5, 11);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (12, 912, 'Severe Avalanche risk. Avoid mountain passes.', 'APP', 5, 12);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (13, 913, 'Ashfall warning. Secure air intakes.', 'SMS', 3, 13);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (14, 914, 'Blizzard conditions in South Flats. Shelter in place.', 'APP', 4, 14);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (15, 915, 'Biohazard contamination confirmed. Full lockdown.', 'SMS', 5, 15);
INSERT INTO Alert (AlertID, DisasterID, Message_Body, Delivery_Method, Severity, AreaAffected) VALUES (16, 916, 'Heavy fog advisory. Drive with extreme caution.', 'APP', 1, 16);


SELECT * FROM Distribution_Record;
SELECT * FROM Item_Catalog;
SELECT * FROM Assignment;
SELECT * FROM Incident_Report;
SELECT * FROM Alert;
SELECT * FROM Victim;
SELECT * FROM Vehicle;
SELECT * FROM Personnel;
SELECT * FROM Roles;
SELECT * FROM Disaster;
SELECT * FROM Station;
SELECT * FROM Shelter;
SELECT * FROM Area;
SELECT * FROM Shelter_Inventory;
SELECT * FROM Caller;
SELECT * FROM Disaster_Type;
SELECT * FROM Deployment;
SELECT * FROM Volunteer;

/* Part 2 Q3 */
-- Question a.
/* List the name of each disaster type and the number of disasters 
   of that type. Include types with no disasters. */

SELECT 
    dt.Name AS "Disaster Type Name", 
    COUNT(d.DisasterID) AS "Number of Disasters"
FROM 
    Disaster_Type dt
LEFT JOIN 
    Disaster d ON dt.Type = d.DisasterType
GROUP BY 
    dt.Name
ORDER BY 
    "Number of Disasters" DESC;
    
-- Question b.
-- Track personnel information (Station,Area,Role) and deployment frequency across the organization
SELECT p.PersonnelID AS "Personnel ID", p.FirstName AS "First Name", r.RoleName AS "Role", 
s.name AS "Stationed At", a.areaname AS "Area", COUNT(d.deploymentid) AS "Number Of Deployments"
FROM personnel p
LEFT JOIN roles r
ON p.RoleID = r.RoleID
LEFT JOIN Station s
ON p.StationID = s.StationID
LEFT JOIN area a
ON s.AreaID = a.areaID
LEFT JOIN deployment d
ON p.PersonnelID = d.PersonnelID
GROUP BY p.PersonnelID , p.FirstName , r.RoleName, s.name, a.areaname 
ORDER BY p.PersonnelID ASC

-- Question c.
-- Lists all personnel with the role of Search and Rescue Lead who have been deployed to disasters
SELECT p.PersonnelID AS "Personnel ID", p.FirstName AS "First Name", r.RoleName AS "Role", ds.DisasterID AS "Disaster ID", ds.DisasterName AS "Disaster Name"
FROM Personnel p
LEFT JOIN Roles r
ON p.roleID = r.roleID
LEFT JOIN Deployment d
ON p.personnelID = d.personnelID
LEFT JOIN Disaster ds
ON d.disasterID = ds.disasterID
WHERE r.RoleName LIKE 'Search%'

--Question d.
-- List all critical active disasters AND resolved major flood OR fire incidents
SELECT 
    d.DisasterID,
    d.DisasterName,
    d.DisasterType,
    d.Severity_Level,
    d.Status,
    d.Start_Date,
    d.End_Date,
    a.AreaName,
    a.AreaCode,
    dt.Name AS Disaster_Type_Name,
    dt.Description
FROM 
    Disaster d
    JOIN Area a ON d.AreaID = a.AreaID
    JOIN Disaster_Type dt ON d.DisasterType = dt.Type
WHERE 
    (d.Status = 'Active' AND d.Severity_Level >= 4)
    OR 
    (d.Status = 'Resolved' AND (d.DisasterType = 'FLOOD' OR d.DisasterType = 'FIRE') AND d.Severity_Level >= 3)
ORDER BY 
    d.Status DESC,
    d.Severity_Level DESC, 
    d.Start_Date DESC;
    
-- Question f.
/*
List the relief centers that have handled the highest number of aid distributions within
the past three months, along with the volunteers most frequently assigned to those
centers.*/
SELECT q2.shelterid,q2.sheltername,q2."Number of Aid",q1.firstname,q1.lastname,q1."Number of Assignments" FROM (SELECT s.shelterid,v.firstname,v.lastname,count(v.volunteerid) AS "Number of Assignments"
FROM shelter s 
JOIN assignment a ON a.shelterid = s.shelterid
JOIN volunteer v ON a.volunteerid = v.volunteerid
GROUP BY s.shelterid,v.firstname,v.lastname) q1 
JOIN 
(SELECT s.shelterid,s.ShelterName,count(s.shelterid) AS "Number of Aid" 
FROM shelter s 
JOIN distribution ds ON s.shelterid = ds.shelterid 
WHERE ds.Dist_date >= ADD_MONTHS(SYSDATE,-3)
GROUP BY s.shelterid,ShelterName) q2 
ON q1.shelterid = q2.shelterid 
ORDER BY q2."Number of Aid" DESC,q1."Number of Assignments" DESC 
FETCH NEXT 5 ROWS ONLY;
