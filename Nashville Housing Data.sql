


-- Cleaning Data in SQL queries

Select * from Nashville

-- Standardise the Date format

Select saledateconverted, CONVERT(date, saledate) from nashville

Update Nashville
Set Saledate = CONVERT(date, saledate)

Alter table Nashville
Add Saledateconverted Date; 

Update Nashville
Set Saledateconverted = CONVERT(date, saledate)


--POPULATE THE PROPERTY ADDRESS DATA

Select * from nashville 
Where propertyaddress is null
Order by ParcelID

Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL (a.propertyaddress, b.propertyaddress) 
from Nashville a
Join Nashville b
on a.parcelID = b.parcelID
and a.[uniqueID]<>b.[uniqueID]
where a.propertyaddress is null

Update a
SET propertyaddress = ISNULL (a.propertyaddress, b.propertyaddress)
from Nashville a
Join Nashville b
on a.parcelID = b.parcelID
and a.[uniqueID]<>b.[uniqueID]
where a.propertyaddress is null

--Breaking out address into individual columns

Select 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1) as Address,
SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) +1, LEN(Propertyaddress)) as Address
from nashville 

Alter table Nashville
Add PropertySplitaddress nvarchar(255); 

Update Nashville
Set PropertySplitaddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1)

Alter table Nashville
Add PropertySplitcity nvarchar(255); 

Update Nashville
Set PropertySplitcity = SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) +1, LEN(Propertyaddress))



Select *
from Nashville

--- Breaking the 'owneraddress' into individual columns

Select owneraddress
from Nashville

Select Parsename(REPLACE(owneraddress,',','.'), 3),
Parsename(REPLACE(owneraddress,',','.'), 2),
Parsename(REPLACE(owneraddress,',','.'), 1)
from Nashville


Alter table Nashville
Add Ownersplitaddress nvarchar(255); 

Alter table Nashville
Add ownerSplitcity nvarchar(255); 

Alter table Nashville
Add ownerSplitstate nvarchar(255); 

Update Nashville
Set Ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'), 3)

Update Nashville
Set ownerSplitcity = PARSENAME(REPLACE(owneraddress,',','.'), 2)

Update Nashville
Set ownerSplitstate = PARSENAME(REPLACE(owneraddress,',','.'), 1)


--change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (SoldAsVacant), count(soldasvacant)
from Nashville
Group by SoldAsVacant
Order by 2

Select SoldasVacant, 
CASE when SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From Nashville

Update Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 End



--Removing Duplicates (Not Standard practice to be deleting Data)

WITH RownumCTE AS(
Select *, 
     ROW_NUMBER()OVER (
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  Legalreference
				  ORDER BY UniqueID
				  )row_num
From Nashville
)

Select * 
from RownumCTE
Where row_num > 1
order by PropertyAddress

-- Deleting unused columns

Select *
From Nashville

Alter table Nashville
Drop column saledate, taxdistrict, propertyaddress, owneraddress