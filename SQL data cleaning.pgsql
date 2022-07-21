-- Replace null values in propertyaddress with values
SELECT t1.uniqueid , t1.parcelid, t1.propertyaddress , t2.uniqueid , t2.parcelid, t2.propertyaddress, COALESCE (t1.propertyaddress,t2.propertyaddress) as new
FROM house t1
join house t2
ON t1.parcelid = t2.parcelid
and t1.uniqueid != t2.uniqueid



UPDATE house
SET propertyaddress = COALESCE (t1.propertyaddress,t2.propertyaddress)
FROM house t1
join house t2
on t1.parcelid = t2.parcelid
and t1.uniqueid != t2.uniqueid

-----------------------------------------------------

-- spliting propertyaddress into two columns
SELECT propertyaddress,
       split_part(propertyaddress, ',' ,1) as col1,
       split_part(propertyaddress, ',' ,2) as col2 
FROM house 

-- Add two new columns type TEXT 
ALTER TABLE house
ADD COLUMN state text,
ADD COLUMN street text

-- Putting data in the new two columns
UPDATE house
SET state = split_part(h.propertyaddress, ',' ,1)
from house as h
where house.uniqueid = h.uniqueid

UPDATE house
SET street = split_part(h.propertyaddress, ',' ,2)
from house as h
where house.uniqueid = h.uniqueid

-----------------------------------------------------
-- uniform the data
SELECT Case when soldasvacant = 'Y' then  'Yes'
            when soldasvacant = 'N' then  'No'
            else soldasvacant
            END
FROM house


Update house 
set soldasvacant = Case when h1.soldasvacant = 'Y' then  'Yes'
            when h1.soldasvacant = 'N' then  'No'
            else h1.soldasvacant
            END
FROM house as h1
where house.uniqueid = h1.uniqueid


SELECT DISTINCT soldasvacant
from house
------------------------------------------------------
-- Deleting duplicated values
DELETE FROM house 
where house.uniqueid in (SELECT uniqueid FROM (SELECT uniqueid , parcelid , propertyaddress , saleprice,saledate ,
row_number() OVER(PARTITION BY parcelid ORDER BY propertyaddress , saleprice,saledate) as row_number
FROM house) as t1
where row_number > 1)

