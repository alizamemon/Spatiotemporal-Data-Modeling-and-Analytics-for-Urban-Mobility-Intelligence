USE UrbanMobilityDB;
GO

SELECT COUNT(*) FROM [202502-citibike-tripdata_1];
SELECT TOP 5 * FROM [202502-citibike-tripdata_1];

-- to see the table names
SELECT name FROM sys.tables;

CREATE TABLE [202502-citibike-tripdata_2] (
    ride_id NVARCHAR(50),
    rideable_type NVARCHAR(50),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name NVARCHAR(255),
    start_station_id NVARCHAR(50),
    end_station_name NVARCHAR(255),
    end_station_id NVARCHAR(50),
    start_lat FLOAT,
    start_lng FLOAT,
    end_lat FLOAT,
    end_lng FLOAT,
    member_casual NVARCHAR(20)
);

BULK INSERT [202502-citibike-tripdata_2]
FROM 'F:\Data\Urban Mobility\202502-citibike-tripdata\202502-citibike-tripdata_2.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,          
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a', 
    TABLOCK                
);

SELECT COUNT(*) FROM [202502-citibike-tripdata_2];
SELECT TOP 5 * FROM [202502-citibike-tripdata_2];


SELECT COUNT(*) FROM [202502-citibike-tripdata_3];
SELECT TOP 5 * FROM [202502-citibike-tripdata_3];

-- Merging all three tables 
--1NF Atomicity & No Repeating Groups
CREATE TABLE Staging_Trips (
    ride_id NVARCHAR(50),
    rideable_type NVARCHAR(50),
    started_at DATETIME2,
    ended_at DATETIME2,
    start_station_name NVARCHAR(255),
    start_station_id NVARCHAR(50),
    end_station_name NVARCHAR(255),
    end_station_id NVARCHAR(50),
    start_lat FLOAT,
    start_lng FLOAT,
    end_lat FLOAT,
    end_lng FLOAT,
    member_casual NVARCHAR(20)
);

INSERT INTO Staging_Trips
SELECT * FROM [202502-citibike-tripdata_1]
UNION ALL
SELECT * FROM [202502-citibike-tripdata_2]
UNION ALL
SELECT * FROM [202502-citibike-tripdata_3];

SELECT COUNT(*) FROM Staging_Trips;

SELECT COUNT(*) FROM Staging_Trips WHERE ride_id IS NULL;

SELECT COUNT(*) FROM Staging_Trips WHERE ended_at <= started_at;

CREATE TABLE Trips_Cleaned (
    ride_id NVARCHAR(50) PRIMARY KEY,
    rideable_type NVARCHAR(50),
    started_at DATETIME2,
    ended_at DATETIME2,
    ride_duration_minutes INT,
    start_station_name NVARCHAR(255),
    end_station_name NVARCHAR(255),
    member_casual NVARCHAR(20)
);

INSERT INTO Trips_Cleaned
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    DATEDIFF(MINUTE, started_at, ended_at) AS ride_duration_minutes,
    start_station_name,
    end_station_name,
    member_casual
FROM Staging_Trips
WHERE ended_at > started_at AND ride_id IS NOT NULL;


--Star Schema Modeling
-- 2NF No Partial Dependencies
CREATE TABLE Dim_Stations (
    Station_ID_Key INT IDENTITY(1,1) PRIMARY KEY,
    Station_Name NVARCHAR(255),
    Latitude FLOAT,
    Longitude FLOAT
);

-- Stations fill karein (Unique stations only)
INSERT INTO Dim_Stations (Station_Name, Latitude, Longitude)
SELECT start_station_name, AVG(start_lat), AVG(start_lng)
FROM Staging_Trips
WHERE start_station_name IS NOT NULL
GROUP BY start_station_name;

-- 2. Ride Type Table
CREATE TABLE Dim_Rideable (
    Rideable_ID INT IDENTITY(1,1) PRIMARY KEY,
    Rideable_Type NVARCHAR(50)
);

INSERT INTO Dim_Rideable (Rideable_Type)
SELECT DISTINCT rideable_type 
FROM Trips_Cleaned;

-- 3. The Main Fact Table (Jo sabko joregi)
CREATE TABLE Fact_Trips (
    Trip_ID NVARCHAR(50) PRIMARY KEY,
    Rideable_ID INT,
    Start_Station_Key INT,
    Started_At DATETIME2,
    Ended_At DATETIME2,
    Duration_Minutes INT,
    Member_Type NVARCHAR(20),
    -- Linking to Dimensions
    FOREIGN KEY (Start_Station_Key) REFERENCES Dim_Stations(Station_ID_Key),
    FOREIGN KEY (Rideable_ID) REFERENCES Dim_Rideable(Rideable_ID)
);

-- Fact table fill karein (Joining with Dimensions)
-- 3NF No Transitive Dependencies
INSERT INTO Fact_Trips (Trip_ID, Started_At, Ended_At, Duration_Minutes, Member_Type, Start_Station_Key, Rideable_ID)
SELECT 
    c.ride_id, 
    c.started_at, 
    c.ended_at, 
    c.ride_duration_minutes, 
    c.member_casual,
    s.Station_ID_Key,
    r.Rideable_ID
FROM Trips_Cleaned c
JOIN Dim_Stations s ON c.start_station_name = s.Station_Name
JOIN Dim_Rideable r ON c.rideable_type = r.Rideable_Type;

SELECT COUNT(*) FROM Fact_Trips;

SELECT TOP 5 f.Trip_ID, s.Station_Name, r.Rideable_Type FROM Fact_Trips f JOIN Dim_Stations s ON f.Start_Station_Key = s.Station_ID_Key JOIN Dim_Rideable r ON f.Rideable_ID = r.Rideable_ID;

--Analytics
SELECT 
    r.Rideable_Type, 
    f.Member_Type, 
    AVG(f.Duration_Minutes) AS Avg_Duration,
    COUNT(*) AS Total_Trips
FROM Fact_Trips f
JOIN Dim_Rideable r ON f.Rideable_ID = r.Rideable_ID
GROUP BY r.Rideable_Type, f.Member_Type
ORDER BY Avg_Duration DESC;

--Member vs Casual KPI View
CREATE VIEW vw_member_summary AS
SELECT
    Member_Type,
    COUNT(*) AS Total_Trips,
    AVG(Duration_Minutes) AS Avg_Duration_Minutes
FROM Fact_Trips
GROUP BY Member_Type;

--Peak hour demand
CREATE VIEW vw_peak_hours AS
SELECT
    DATEPART(HOUR, Started_At) AS Ride_Hour,
    COUNT(*) AS Total_Trips
FROM Fact_Trips
GROUP BY DATEPART(HOUR, Started_At);

SELECT * FROM vw_peak_hours ORDER BY Total_Trips DESC;

-- Station Load
CREATE VIEW vw_station_load AS
SELECT
    s.Station_Name,
    COUNT(*) AS Total_Trips
FROM Fact_Trips f
JOIN Dim_Stations s 
    ON f.Start_Station_Key = s.Station_ID_Key
GROUP BY s.Station_Name;

SELECT * FROM vw_station_load ORDER BY Total_Trips DESC;


-- Adding an index to speed up peak hour analysis
CREATE INDEX idx_started_at ON Fact_Trips(Started_At);

SELECT s.Station_Name, s.Latitude, s.Longitude, v.Total_Trips
FROM Dim_Stations s
JOIN vw_station_load v ON s.Station_Name = v.Station_Name;
