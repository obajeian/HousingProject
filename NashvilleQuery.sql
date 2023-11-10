--In this project we are going to use the Nashville housing dataset
-- The aim of this project is to look into Data Cleaning strategies

Select *
From HousingProject..Nashville

----------------------------------------------------------------------

-- Standardize the date format

Select SaleDateConverted, CONVERT(date, SaleDate)
From HousingProject..Nashville

Update Nashville
Set SaleDate = CONVERT(date, SaleDate)

Alter table Nashville
Add SaleDateConverted Date;

Update Nashville
Set SaleDateConverted = CONVERT(date, SaleDate)

---------------------------------------------------------------------------------
-- Populate Property Address data
-- We look at the null values in this column

Select * 
From HousingProject..Nashville
--Where PropertyAddress is null

	-- We are going to populate based on duplicates from the Parcel ID column
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject..Nashville a
Join HousingProject..Nashville b
	On a.ParcelID = b.ParcelID --Same parcelID
	And a.[UniqueID ] <> b.[UniqueID ] -- not the same row
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject..Nashville a
Join HousingProject..Nashville b
	On a.ParcelID = b.ParcelID --Same parcelID
	And a.[UniqueID ] <> b.[UniqueID ] -- not the same row
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------
-- Breaking out Address into individual columns regarding address, city & state

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address --looks at the property address column, looks into the 1st value, until it gets to the comma the -1 get's rid of the comma at the end
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From HousingProject..Nashville

Alter table Nashville
Add PropertySplitAddress nvarchar(255);

Update Nashville
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table Nashville
Add PropertySplitCity nvarchar(255);

Update Nashville
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


Select*
From HousingProject..Nashville

-- Doing the same for the owner address column
-- Using parse name

Select OwnerAddress
From HousingProject..Nashville

Select 
PARSENAME (Replace(OwnerAddress,',','.'), 3) -- we replace the comma witha period for the parsename to work
, PARSENAME (Replace(OwnerAddress,',','.'), 2) 
, PARSENAME (Replace(OwnerAddress,',','.'), 1) 
From HousingProject..Nashville

Alter table Nashville
Add OwnerSplitAddress nvarchar(255);

Update Nashville
Set OwnerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.'), 3)

Alter table Nashville
Add OwnerSplitCity nvarchar(255);

Update Nashville
Set OwnerSplitCity = PARSENAME (Replace(OwnerAddress,',','.'), 2) 

Alter table Nashville
Add OwnerSplitState nvarchar(255);

Update Nashville
Set OwnerSplitState = PARSENAME (Replace(OwnerAddress,',','.'), 1) 


Select *
From HousingProject..Nashville

------------------------------------------------------------------------------------------------
-- Change Y & N to Yes and No in the "Sold as Vacant" field (Standadization)
Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From HousingProject..Nashville
Group by SoldAsVacant
Order by 2

-- we are going to use a case statement
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From HousingProject..Nashville

Update Nashville
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

-----------------------------------------------------------------------------------------------
--Remove Duplicates
-- using row number

WITH RowNumCTE AS( 
Select*,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
				 	 UniqueID
					 ) row_num

From HousingProject..Nashville
--Order by ParcelID
)

Select*
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-------------------------------------------------------------------------------------
-- Deleting unused columns (Do not do this for raw data you might need)

Select*
From HousingProject..Nashville

Alter table HousingProject..Nashville
Drop Column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate