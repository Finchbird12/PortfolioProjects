CREATE TABLE housing (
    UniqueID INT,
    ParcelID VARCHAR(255),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255),
    SaleDate TIMESTAMP,
    SalePrice INT, 
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(255),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage FLOAT,
    TaxDistrict VARCHAR(255),
    LandValue INT,
    BuildingValue INT,
    TotalValue INT,
    YearBuilt INT, 
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

--- Cleaning Data in SQL Queries ----

SELECT *
FROM housing

-- Standardize Date Format---

SELECT saledate
FROM housing

SELECT saledate::date
FROM housing

ALTER TABLE housing
ALTER COLUMN saledate TYPE date

SELECT *
FROM housing

--Populate Property Address Data ---

SELECT propertyaddress
FROM housing
WHERE propertyaddress is null

SELECT *
FROM housing
WHERE propertyaddress is null

SELECT *
FROM housing
--WHERE propertyaddress is null
ORDER BY parcelID

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
FROM housing a
JOIN housing b
	on a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
WHERE a.propertyaddress is null

UPDATE housing a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM housing b
WHERE a.parcelID = b.parcelID
	AND a.uniqueID <> b.uniqueID
	AND a.propertyaddress is null

SELECT * 
FROM housing
WHERE propertyaddress is NULL

--BREAKING out Address into Individual Columns (address, city, state)

SELECT propertyaddress
FROM housing


SELECT split_part(propertyaddress,',',1) as Address, split_part(propertyaddress, ',', 2) as City
FROM housing

ALTER TABLE housing
ADD propertysplitaddress VARCHAR(255)

UPDATE housing
SET propertysplitaddress = split_part(propertyaddress,',',1)

ALTER TABLE housing
ADD propertysplitcity VARCHAR (255)

UPDATE housing
SET propertysplitcity = split_part(propertyaddress, ',', 2)

SELECT *
FROM housing

SELECT owneraddress
FROM housing

SELECT split_part(owneraddress, ',', 1), split_part(owneraddress, ',', 2), split_part(owneraddress, ',', 3)
FROM housing

ALTER TABLE housing
Add ownersplitaddress VARCHAR (255),
Add ownersplitcity VARCHAR (255),
Add ownersplitstate VARCHAR (255)

UPDATE housing
SET ownersplitaddress = split_part(owneraddress, ',', 1)

UPDATE housing
SET ownersplitcity = split_part(owneraddress, ',', 2)

UPDATE housing
SET ownersplitstate = split_part(owneraddress, ',', 3)

SELECT *
FROM housing

-- CHANGE Y and N to Yes and No in "Sold as Vacant" field --

SELECT Distinct (soldasvacant), COUNT(soldasvacant)
FROM housing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant
, Case 
	WHEN soldasvacant = 'Y' Then 'Yes'
	WHen soldasvacant = 'N' Then 'No'
	ELSE soldasvacant
	END
FROM housing

UPDATE housing
SET soldasvacant = Case 
	WHEN soldasvacant = 'Y' Then 'Yes'
	WHen soldasvacant = 'N' Then 'No'
	ELSE soldasvacant
	END

-- REMOVE Duplicates --

WITH RowNumCTE as(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 	ParcelID, 
					propertyaddress, 
					saleprice, 
					saledate, 
					legalreference
					ORDER BY
						uniqueID
						) row_num
FROM housing
--ORDER BY parcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY propertyaddress


--postgres can not delete from CTE soo---

DELETE FROM housing
WHERE uniqueID IN (
    SELECT uniqueID
    FROM (
        SELECT uniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, 
                                propertyaddress, 
                                saleprice, 
                                saledate, 
                                legalreference
                   ORDER BY uniqueID
               ) AS row_num
        FROM housing
    ) AS subquery
    WHERE row_num > 1
);

--Delete Unused Columns--

SELECT *
FROM housing

ALTER TABLE housing
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict


