# Nashville Housing Data Cleaning Project

## Overview
This project demonstrates the process of cleaning and preparing a dataset using SQL, specifically focusing on a Nashville housing dataset. The goal of this project is to clean and standardize the data, handle missing values, split columns for better data structure, and perform essential transformations to enhance the dataset's usability for future analysis.

## Dataset
The dataset used in this project contains various attributes related to properties in Nashville, including sale date, property address, and owner information. The dataset was imported into Microsoft SQL Server (MSSQL) for cleaning and manipulation.

## Steps Involved

### 1. **Standardizing Date Formats**
   - The `SaleDate` column was converted into a consistent `DATE` format for uniformity in data analysis.
   ```sql
   ALTER TABLE Nashville
   ADD Sale_Date_Converted DATE;

   UPDATE Nashville
   SET Sale_Date_Converted = CONVERT(DATE, saledate);
```

### 2.**Populating Missing Property Addresses**
Missing property addresses were filled by matching parcel IDs and leveraging existing records.

```sql
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL;
```
### 3.Splitting Address into Individual Columns
The property and owner addresses were split into separate columns for Address, City, and State, improving the granularity of the dataset.

```sql
ALTER TABLE Nashville
ADD Property_Split_Address NVARCHAR(300);

UPDATE Nashville
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);
```
### 4. Converting Y/N to Yes/No in “Sold as Vacant” Field
The values in the `SoldAsVacant` field were standardized by converting `Y` to `Yes` and `N` to `No`.

```sql
UPDATE Nashville
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;
```
### 5. Removing Duplicate Records
A Common Table Expression (CTE) was used to identify and remove duplicate records based on ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference.

```sql
WITH row_num_cte AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID) AS row_num
    FROM Nashville
)
DELETE FROM row_num_cte
WHERE row_num > 1;
```
### 6. Dropping Unused Columns
Columns such as `OwnerAddress`, `TaxDistrict`, `PropertyAddress`, and `SaleDate` were removed as they were either redundant or replaced by newly cleaned columns.

```sql
ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
```
## Technologies Used
- **SQL**: Used for data cleaning and transformation.
- **Microsoft SQL Server (MSSQL)**: The database platform used for this project.

## Key Features
- **Date Standardization**: Ensuring consistency in date formats for analysis.
- **Address Cleaning**: Splitting addresses into separate columns for better granularity.
- **Data Standardization**: Converting binary values (Y/N) into more interpretable values (Yes/No).
- **Duplicate Removal**: Efficiently identifying and removing duplicate records using CTE.
- **Unused Column Cleanup**: Dropping columns that are no longer necessary after cleaning.

## Conclusion
This project showcases a systematic approach to cleaning a housing dataset using SQL. The transformations applied ensure that the data is well-structured, consistent, and ready for analysis or further processing.
