/**************************************************************************************
 USE project_1;
 
**************************************************************************************/

-- Create New Table
DROP TABLE if exists Nashville_Housing;
CREATE TABLE Nashville_Housing
     (unique_id INT,
	  parcel_id VARCHAR(55),
      land_use CHAR (55),
      property_address VARCHAR(255),
      sale_date DATE,
      sale_price BIGINT,
      legal_reference VARCHAR(255),
      sold_as_vacant CHAR(50),
      owner_name VARCHAR(255),
      owner_address VARCHAR(255),
      acreage DECIMAL,
      tax_district CHAR(55),
      land_value INT,
      building_value INT,
      total_value INT,
      year_built INT,
      bedrooms INT,
      full_bath INT,
      half_bath INT);
      

      
-- Load CSV file
set global sql_mode='';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Projects\\Nashville Housing Data For Data Cleaning.csv'
INTO TABLE Nashville_Housing
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE Nashville_Housing CHANGE acreage acreage DECIMAL(10,0) NULL;

----- Cleaning Data in SQL Queries
SELECT *
FROM Nashville_Housing;

----- Populate Property Address Data

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, IFNULL(a.property_address,b.property_address)
FROM Nashville_Housing a
JOIN Nashville_Housing b
On a.parcel_id = b.parcel_id
AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL;

UPDATE Nashville_Housing a
JOIN Nashville_Housing b
On a.parcel_id = b.parcel_id
AND a.unique_id <> b.unique_id
SET a.property_address = b.property_address
WHERE a.property_address IS NULL;

-- -- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT property_address
FROM Nashville_Housing;

SELECT
SUBSTRING(property_address, 1, LOCATE(',', property_address)-1) AS address,
SUBSTRING(property_address, LOCATE(',', property_address)+1, LENGTH(property_address)) AS address
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD property_address_split VARCHAR(255);

UPDATE Nashville_Housing
SET property_address_split = SUBSTRING(property_address, 1, LOCATE(',', property_address)-1);

ALTER TABLE Nashville_Housing
ADD property_split_city VARCHAR(255);

UPDATE Nashville_Housing
SET property_split_city = SUBSTRING(property_address, LOCATE(',', property_address)+1, LENGTH(property_address));

SELECT *
FROM Nashville_Housing;

SELECT owner_address
FROM Nashville_Housing;

SELECT 
SUBSTRING_INDEX(owner_address, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(owner_name, ',', 2), ',', -1),
SUBSTRING_INDEX(owner_address, ',', -1)
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD owner_split_address VARCHAR(255);

UPDATE Nashville_Housing
SET owner_split_address = SUBSTRING_INDEX(owner_address, ',', 1);

ALTER TABLE Nashville_Housing
ADD owner_split_city VARCHAR(255);

UPDATE Nashville_Housing
SET owner_split_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owner_name, ',', 2), ',', -1);

ALTER TABLE Nashville_Housing
ADD owner_split_state VARCHAR(255);

UPDATE Nashville_Housing
SET owner_split_state = SUBSTRING_INDEX(owner_address, ',', -1);

-- Change Y And N to Yes And No in 'Sold As Vacant' Field

SELECT DISTINCT sold_as_vacant, COUNT(sold_as_vacant)
FROM Nashville_Housing
GROUP BY sold_as_vacant
ORDER BY 2;

SELECT sold_as_vacant,
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
     WHEN sold_as_vacant = 'N' THEN 'No'
     ELSE sold_as_vacant
     END
FROM Nashville_Housing;

UPDATE Nashville_Housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
     WHEN sold_as_vacant = 'N' THEN 'No'
     ELSE sold_as_vacant
     END;
     
-- Delete Unused Columns

ALTER TABLE Nashville_Housing
DROP COLUMN owner_address, 
DROP COLUMN tax_district, 
DROP COLUMN property_address;

SELECT *
FROM Nashville_Housing;






