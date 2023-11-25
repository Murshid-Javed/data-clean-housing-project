----------- showing the whole table ---------

select * from Sheet1$

------------ converting the date into standard format ---------
select SaleDate,convert(date,SaleDate) as standard_date from Sheet1$
alter table Sheet1$
add standard_date date;
update Sheet1$
set standard_date  = convert(date,SaleDate)

--------drop the existing date and that date is converted --------
alter table Sheet1$
drop column  SaleDate;

---------populate the property address -----------

select a.UniqueID , a.PropertyAddress,a.ParcelID ,b.UniqueID,b.PropertyAddress, b.ParcelID
from Sheet1$ a
join Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is not null

--------- now updating the table -------------
update a
set a.PropertyAddress = isnull(a.PropertyAddress ,b.PropertyAddress)
from Sheet1$ a
join Sheet1$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is not null

----------- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS ---------------(Address,city,state)

select PropertyAddress from Sheet1$
select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 )as address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as last_address
from Sheet1$


alter table Sheet1$
add property_split_address nvarchar(250);

update Sheet1$
set property_split_address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1 )


alter table Sheet1$
add property_split_city nvarchar(250);


update Sheet1$
set property_split_city = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

select *from Sheet1$

----------------BREAKING THE OWNER ADDRESS ---------- INTO INDIVIDUALS COLUMN ----------------
select OwnerAddress from Sheet1$

select 
PARSENAME(replace(OwnerAddress,',','.'),1),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),3)
from Sheet1$

alter table Sheet1$
add Owner_split_address nvarchar(250);
update Sheet1$
set Owner_split_address = PARSENAME(replace(OwnerAddress,',','.'),3);



alter table Sheet1$
add Owner_split_city nvarchar(250);
update Sheet1$
set Owner_split_city = PARSENAME(replace(OwnerAddress,',','.'),2)



alter table Sheet1$
add Owner_split_state nvarchar(250);
update Sheet1$
set Owner_split_state = PARSENAME(replace(OwnerAddress,',','.'),1)

select *from Sheet1$



-----------change 'y' and 'n' in exchange of the yes and no in soldvsvacant column-------------------



select distinct(SoldAsVacant),count((SoldAsVacant))as anique
from Sheet1$
group by SoldAsVacant
order by 2

select SoldAsVacant,
   case 
        when SoldAsVacant = 'y' then 'yes'
		when SoldAsVacant ='N' THEN 'N0'
	 else SoldAsVacant
end 
from Sheet1$


alter table Sheet1$
add Sold_As_Vacant varchar(50);
update Sheet1$
set  Sold_As_Vacant= case 
        when SoldAsVacant = 'y' then 'yes'
		when SoldAsVacant ='N' THEN 'N0'
	 else SoldAsVacant
end 
from Sheet1$
select * from Sheet1$


-----------------  remove duplicates   --------------

select * from Sheet1$;

with AQIB  AS (
select * ,
ROW_NUMBER() over (
                 PARTITION BY  ParcelID,PropertyAddress,SalePrice,LegalReference
                 ORDER BY UniqueID
			) AS new_row
from Sheet1$
)
select * from AQIB 
where new_row >1
order by PropertyAddress;



-------deleting these rows 
with AQIB  AS (
select * ,
ROW_NUMBER() over (
                 PARTITION BY  ParcelID,PropertyAddress,SalePrice,LegalReference
                 ORDER BY UniqueID
			) AS new_row
from Sheet1$
)
delete  from AQIB 
where new_row >1;


---- deleting unused column -------
select * from Sheet1$
alter table Sheet1$
drop column PropertyAddress,OwnerAddress,SoldAsVacant,TaxDistrict;



---------------  NEVER LEAVE THAT TILL TOMORROW WHICH YOU CAN DO TODAY -------------


















