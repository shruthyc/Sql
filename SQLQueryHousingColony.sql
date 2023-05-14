Select * from ProjectPortfolio.dbo.HousingColony

-----Date format Standardised

Select UpdatedSaleDate, CONVERT(Date,SaleDate)
From ProjectPortfolio.dbo.HousingColony

Update HousingColony
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table HousingColony
Add UpdatedSaleDate Date;

Update HousingColony
SET UpdatedSaleDate = CONVERT(Date,SaleDate)

-----Populate Property Address

Select * 
From ProjectPortfolio.dbo.HousingColony
----where PropertyAddress is Null
Order By ParcelID

Select x.ParcelID, x.PropertyAddress,y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress,y.PropertyAddress)
From ProjectPortfolio.dbo.HousingColony x
Join ProjectPortfolio.dbo.HousingColony y
on x.ParcelID = y.ParcelID
AND x.[UniqueID ]<>y.[UniqueID ]
Where x.PropertyAddress is null

Update x
Set PropertyAddress= ISNULL(x.PropertyAddress,y.PropertyAddress)
From ProjectPortfolio.dbo.HousingColony x
Join ProjectPortfolio.dbo.HousingColony y
on x.ParcelID = y.ParcelID
AND x.[UniqueID ]<>y.[UniqueID ]
Where x.PropertyAddress is null

---Breaking address into address and city

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From ProjectPortfolio.dbo.HousingColony 

Alter Table HousingColony
Add PropertySplitAddress NVarChar(255);

Update HousingColony
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table HousingColony
Add PropertySplitCiti NVarChar(255);

Update HousingColony
SET PropertySplitCiti = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From ProjectPortfolio.dbo.HousingColony 

ALTER TABLE HousingColony
DROP COLUMN PropertySplitCity;

Select *
From ProjectPortfolio.dbo.HousingColony 

Select OwnerAddress
From ProjectPortfolio.dbo.HousingColony

Select PARSENAME(Replace(OwnerAddress, ',' , '.'), 3),
PARSENAME(Replace(OwnerAddress, ',' , '.'), 2),
PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)
From ProjectPortfolio.dbo.HousingColony

Alter Table HousingColony
Add OwnerAddressSplitted NVarChar(255);

Update HousingColony
SET OwnerAddressSplitted = PARSENAME(Replace(OwnerAddress, ',' , '.'), 3)

Alter Table HousingColony
Add OwnerCitySplitted NVarChar(255);

Update HousingColony
SET OwnerCitySplitted = PARSENAME(Replace(OwnerAddress, ',' , '.'), 2)

Alter Table HousingColony
Add OwnerStateSplitted NVarChar(255);

Update HousingColony
SET OwnerStateSplitted = PARSENAME(Replace(OwnerAddress, ',' , '.'), 1)

Select *
From ProjectPortfolio.dbo.HousingColony 

-------Change the Yes and No to Y and N in "Sold as Vacant " field

Select Distinct(SoldasVacant), count(SoldasVacant)
From ProjectPortfolio.dbo.HousingColony
GROUP BY SoldAsVacant
Order by 2

Select SoldasVacant,
	CASE when SoldasVacant='Y' THEN 'YES'
	when SoldasVacant='N' THEN 'NO'
	ELSE SoldAsVacant
	END
From ProjectPortfolio.dbo.HousingColony

Update HousingColony
SET SoldasVacant = CASE when SoldasVacant='Y' THEN 'YES'
	when SoldasVacant='N' THEN 'NO'
	ELSE SoldAsVacant
	END
From ProjectPortfolio.dbo.HousingColony


----Remove Duplicates
with RowNumCTE AS(
Select *, 
	Row_Number() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By UniqueID)
				row_num
From ProjectPortfolio.dbo.HousingColony
----Order By ParcelID
)
Delete from RowNumCTE
Where row_num>1
----order by PropertyAddress

------Delete Unused columns

Select *
From ProjectPortfolio.dbo.HousingColony

Alter table ProjectPortfolio.dbo.HousingColony
Drop Column OwnerAddress, PropertyAddress, TaxDistrict,SaleDate











