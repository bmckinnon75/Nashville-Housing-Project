/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM dbo.NashvilleHousing;




--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted
FROM dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate =CONVERT(date,SaleDate);

--If didn't update

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted =CONVERT(date,SaleDate);


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID= b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;










--------------------------------------------------------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State)

--Updating Property Address

SELECT PropertyAddress
FROM dbo.NashvilleHousing;

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) AS address
,SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) AS address
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAdress =SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity =SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress));


SELECT *
FROM NashvilleHousing;

--Updating owner address

SELECT owneraddress
FROM NashvilleHousing


SELECT PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(owneraddress,',','.'),2)
,PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(owneraddress,',','.'),3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(owneraddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState =PARSENAME(REPLACE(owneraddress,',','.'),1);

SELECT*
FROM NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
FROM NashvilleHousing
Group BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET SoldASVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(


SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
				 Propertyaddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

					
FROM NashvilleHousing)
--ORDER BY ParcelID
SELECT* 
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM NashvilleHousing;



ALTER TABLE NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress;

ALTER TABLE NashvilleHousing
DROP COLUMN saledate;










-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------