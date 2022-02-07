CREATE DATABASE Nashville_housing
USE Nashville_housing
-- CLEANING THE DATA IN SQL QUERIES

SELECT *
FROM nashville
---------------------------------------------------------------------------

-- STANDARIZE THE DATE FORMAT

SELECT Sale_Date_Converted as Sale_Date,CONVERT(DATE,saledate) as Sale_Date
FROM nashville

ALTER TABLE Nashville
ADD Sale_Date_Converted date

UPDATE nashville
SET Sale_Date_Converted = CONVERT(DATE,saledate)

---------------------------------------------------------------------------

-- POPULATING THE PROPERTY ADDRESS

SELECT propertyaddress
FROM Nashville
WHERE propertyaddress is null

SELECT a.parcelID,a.PropertyAddress,b.ParcelID, b.PropertyAddress , ISNULL(a.propertyAddress,b.propertyaddress)
FROM Nashville a
JOIN Nashville b
ON a.parcelID = b.parcelID
AND a.UniqueID <> b.UniqueID
WHERE a.propertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress,b.propertyaddress) 
FROM Nashville a
JOIN Nashville b
ON a.parcelID = b.parcelID
AND a.UniqueID <> b.UniqueID
WHERE a.propertyAddress is null

-------------------------------------------------------------------------------

--SEPERTATING THE ADDRESS INTO INDIVIDUAL COLUMNS i.e.(ADDRESS,CITY,STATE)

SELECT propertyaddress
FROM Nashville

SELECT 
SUBSTRING(Propertyaddress,1,CHARINDEX(',',Propertyaddress)-1) as Address
,SUBSTRING(Propertyaddress,CHARINDEX(',',Propertyaddress)+1,len(propertyaddress)) as Address
FROM Nashville

ALTER TABLE Nashville
ADD Property_Split_Address Nvarchar(300)

UPDATE nashville
SET Property_Split_Address = SUBSTRING(Propertyaddress,1,CHARINDEX(',',Propertyaddress)-1) 


ALTER TABLE Nashville
ADD Property_Split_city Nvarchar(300)

UPDATE nashville
SET Property_Split_city = SUBSTRING(Propertyaddress,CHARINDEX(',',Propertyaddress)+1,len(propertyaddress)) 

SELECT owneraddress
FROM Nashville

SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM Nashville

ALTER TABLE Nashville
ADD OWNER_Split_Address Nvarchar(300)

UPDATE nashville
SET OWNER_Split_Address = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE Nashville
ADD OWNER_Split_city Nvarchar(300)

UPDATE nashville
SET OWNER_Split_city = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE Nashville
ADD OWNER_Split_state Nvarchar(300)

UPDATE nashville
SET OWNER_Split_state = PARSENAME(REPLACE(owneraddress,',','.'),1)

------------------------------------------------------------------------------

-- CHANGING Y and N TO YES and NO in "Sold as Vacant" FEILD.

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT
SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-------------------------------------------------------------------------
-- REMOVE DUPLICATES.
-- create a cte table

WITH row_num_cte AS (
SELECT *,
         ROW_NUMBER() OVER(
		 PARTITION BY ParcelID, 
		                        propertyAddress,
								saleprice,
								saledate,
								legalreference
								ORDER BY 
								uniqueID) row_num
	FROM Nashville
	--ORDER BY ParcelID
)
--DELETE 
SELECT *
FROM row_num_cte
WHERE row_num > 1
ORDER BY propertyaddress 

SELECT *
FROM Nashville

------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS 

SELECT * FROM Nashville

ALTER TABLE Nashville
DROP COLUMN owneraddress,taxdistrict,propertyaddress,saledate