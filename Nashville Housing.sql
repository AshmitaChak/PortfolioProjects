/*

Cleaning Data in SQL queries

*/

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

-- Changing the date to YYYY-MM-DD format

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Adding a new date column now

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property address data for values where null is present 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
 where a.PropertyAddress is NULL

 UPDATE a
 SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID] 
 where a.PropertyAddress is NULL



 -- Breaking out address into individual columns (address, city, state)
 
 -- With Property address

 SELECT Address, City
 FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address nvarchar(255);

Update NashvilleHousing
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) 

ALTER TABLE NashvilleHousing
ADD City nvarchar(255);

Update NashvilleHousing
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1,LEN(PropertyAddress))


-- With owner address

Select  OwnerAddress1, OwnerAddressCity, OwnerAddressState
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddress1 nvarchar(255);

Update NashvilleHousing
SET OwnerAddress1  = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerAddressCity nvarchar(255);

Update NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerAddressState nvarchar(255);

Update NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change to Yes and No from Y and N in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UNIQUEID
				 ) row_num
FROM PortfolioProject..NashvilleHousing
-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete unused columns

Select  *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
