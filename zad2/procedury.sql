
-- PROCEDURA OBS�UGI PRZECHWYTYWANIA WYJ�TKOW
---------------------------------------------------------------------------------------------------------
CREATE PROCEDURE catchError
AS
BEGIN
	SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage;
END


-- PROCEDURA KT�RA UMO�LIWIA KORZYSTANIE Z CMDSHELL DO ZAPYTAN DYNAMICZNYCH
---------------------------------------------------------------------------------------------------------
create procedure setUpConfiguration
as 
begin
	begin try
		-- To allow advanced options to be changed.
		EXEC sp_configure 'show advanced options', 1
		-- To enable the feature.
		EXEC sp_configure 'xp_cmdshell', 1
		-- To update the currently configured value for this feature.
		RECONFIGURE
	end try
	begin catch
		exec catchError
	end catch
end


-- PROCEDURY POMOCNICZE DO USUWANIA LEKOW
---------------------------------------------------------------------------------------------------------
create procedure deleteAllDataFromMedicines
as
begin
	begin try
		delete from Orders
		delete from Medicines
	end try
	begin catch
		exec catchError
	end catch
end

create procedure deleteMedicine
@medicine_id int
as
begin
	begin try
		delete from Orders where med_id=@medicine_id
		delete from Medicines where id=@medicine_id
	end try
	begin catch
		exec catchError
	end catch
end


-- PROCEDURA DO WSTAWIANIA DANYCH Z XML DO TABELI
---------------------------------------------------------------------------------------------------------
-- BULK - umo�liwia czytanie z pliku bez konieczno�ci �adowania go do tabeli.
-- SINGLE_BLOB - parametr dla BULK, czytanie pliku jako pojedynczej linii (BLOC - jako ASCII)
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='insertXMLData')
drop procedure insertXMLData
GO
CREATE PROCEDURE insertXMLData
@table_name VARCHAR(32), @xmlPath VARCHAR(255)
AS
BEGIN
	BEGIN TRY 
		DECLARE @query VARCHAR(3000)
		SET @query = 'INSERT INTO ' + @table_name + ' SELECT * FROM OPENROWSET (BULK ''' + @xmlPath + ''', SINGLE_BLOB) AS DATA'
		exec (@query)
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
GO
delete from Manufacturers
go
Select * from Manufacturers;
GO
exec insertXMLData 'Manufacturers', 'C:\Users\nero1\Desktop\bazy\producenci.xml';
go
Select * from Manufacturers;


-- PROCEDURA DO WYCI�GANIA DANYCH Z KOLUMNY TYPU XML
---------------------------------------------------------------------------------------------------------
-- CROSS APPLY - Polecenie to umo�liwia wykonanie dowolnego zapytania dla ka�dego wiersza tabeli i z��czenie otrzymanego wyniku z tym wierszem
-- Tutaj jest to o tyle przydatne, ze mamy do czynienia z tabel�, w kt�rej ka�dy wiersz jest r�wnierz jak�� kolekcja danych, kt�ra zn�w zawiera wiecej niz 1 element producent
-- @ - odczyt atrybutu
-- nodes(node) - alias. samo nodes bez () odwo�uwa�oby do Producenci.dane_producentow.nodes natomiast z () odwo�uje do node'a xmla producent
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='getAllManufacturersInfo')
drop procedure getAllManufacturersInfo
GO
CREATE PROCEDURE getAllManufacturersInfo
AS
BEGIN
DECLARE @query VARCHAR(1000)
SET @query = 'SELECT
				node.value(''@id[1]'',''VARCHAR(5)'') AS [id],
				node.value(''name[1]'',''VARCHAR(30)'') AS ''name'',
				node.value(''city_id[1]'',''VARCHAR(10)'') AS ''city'',
				node.value(''country[1]'',''VARCHAR(30)'') AS ''country''
				FROM Manufacturers
				CROSS APPLY Manufacturers.manufacturers_data.nodes(''//manufacturer'') AS nodes(node)';
	BEGIN TRY
		EXEC (@query);
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
GO
exec getAllManufacturersInfo

-- PROCEDURA DO WYCI�GANIA DANYCH Z TABELI XML NA PODSTAWIE W�Z�A XML
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='getInfoFromManufacturerNode')
drop procedure getInfoFromManufacturerNode
GO
CREATE PROCEDURE getInfoFromManufacturerNode @node_name varchar(32)
AS
BEGIN
DECLARE @query VARCHAR(1000)
SET @query = 'SELECT
				node.value(''' + @node_name + '[1]'',''VARCHAR(30)'') AS '''+@node_name+'''
				FROM Manufacturers
				CROSS APPLY Manufacturers.manufacturers_data.nodes(''//manufacturer'') AS nodes(node)';
	BEGIN TRY
		EXEC (@query);
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
GO
exec getInfoFromManufacturerNode 'name'

-- PROCEDURA DO WYCI�GANIA DANYCH Z TABELI XML NA PODSTAWIE ATRYBUTU
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='getManufacturerInfoByAttribute')
drop procedure getManufacturerInfoByAttribute
GO
CREATE PROCEDURE getManufacturerInfoByAttribute @man_id VARCHAR(5)
AS
BEGIN
DECLARE @query VARCHAR(1000)
SET @query = 'SELECT
				node.value(''@id[1]'',''VARCHAR(5)'') AS [id],
				node.value(''name[1]'',''VARCHAR(30)'') AS ''name'',
				node.value(''city_id[1]'',''VARCHAR(10)'') AS ''city_id'',
				node.value(''country[1]'',''VARCHAR(30)'') AS ''country''
				FROM Manufacturers
				CROSS APPLY Manufacturers.manufacturers_data.nodes(''//manufacturer'') AS nodes(node)
				WHERE node.value(''@id[1]'',''VARCHAR(5)'') = ''' + @man_id + '''';
	BEGIN TRY
		EXEC (@query);
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
GO
exec getManufacturerInfoByAttribute 'P02'


-- PROCEDYRA DO EKSPORTOWANIA DANYCH Z TABELI DO PLIKU XML
---------------------------------------------------------------------------------------------------------
-- AUTO - postac xml jest generowana autoamczynie w zaleznosci od struktury tabeli
-- ELEMENTS - kazda kolumna w select jest mapowana na pod elementy w xml
-- -c - format pliku plain text -T bcp komunikuje si� z sql serverem bezpiecznym po��czeniem
if exists( select 1 from sys.objects where TYPE='P' and name='exportDataToXML')
drop procedure exportDataToXML
GO
CREATE PROCEDURE exportDataToXML
@table_name VARCHAR(32), @file_path VARCHAR(3000)
AS
BEGIN
	DECLARE @query VARCHAR(3000)
	exec setUpConfiguration
	SET @query = 'bcp "SELECT * FROM Apteka.dbo."' + @table_name + '" FOR XML AUTO, ELEMENTS" queryout "' + @file_path + '" -c -T'

	BEGIN TRY
		EXEC xp_cmdshell @query
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
GO
exec exportDataToXML 'Manufacturers', 'D:\manufacturers.xml'


-- PROCEDURA DO WSTAWIANIA DANYCH XML DO WIELU WIERSZY
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='insertManufacturersToManyRows')
drop procedure insertManufacturersToManyRows
GO
delete from Manufacturers
GO
CREATE PROCEDURE insertManufacturersToManyRows
@table_name VARCHAR(32), @xmlPath VARCHAR(255)
AS
BEGIN
	DECLARE @query VARCHAR(3000)
	BEGIN TRY
		SET @query ='INSERT INTO ' + @table_name + ' SELECT X.manufacturer.query(''.'')
					 FROM ( 
						SELECT CAST(x AS XML)
						FROM OPENROWSET(BULK '''+ @xmlPath +''', SINGLE_BLOB) AS T(x)) AS T(x)
					 CROSS APPLY x.nodes(''manufacturers/manufacturer'') AS X(manufacturer)';
		EXEC (@query);
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH

END
GO
delete from Manufacturers
go
select * from Manufacturers
go
exec insertManufacturersToManyRows 'Manufacturers', 'C:\Users\nero1\Desktop\bazy\producenci.xml';
go
select * from Manufacturers


-- PROCEDURA DO POBIERANIA DANYCH O PRODUCENCIE NA PODSTAWIE NAZWY LEKU
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='getManufacturerByMedicineName')
drop procedure getManufacturerByMedicineName
GO
CREATE PROCEDURE getManufacturerByMedicineName
@medicine_name VARCHAR(100)
AS
BEGIN 
	DECLARE @manufakturer_id VARCHAR(10)
	BEGIN TRY
		SELECT @manufakturer_id = m.manufacturer FROM Medicines m WHERE m.name = @medicine_name
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
	
	exec getManufacturerInfoByAttribute @manufakturer_id
END
go
delete from Manufacturers
go 
exec insertXMLData 'Manufacturers', 'C:\Users\nero1\Desktop\bazy\producenci.xml';
go
select * from Manufacturers
go
exec getManufacturerByMedicineName 'Apap'


-- PROCEDURA DO MAPOWANIA DANYCH Z PLIKU XML NA TABELE
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='mapXMLDataToMedicinesTable')
drop procedure mapXMLDataToMedicinesTable
GO
CREATE PROCEDURE mapXMLDataToMedicinesTable
AS
BEGIN
Declare @xml XML
	BEGIN TRY
		Select  @xml = CONVERT(XML,bulkcolumn,2) FROM OPENROWSET(BULK 'C:\Users\nero1\Desktop\bazy\leki.xml',SINGLE_BLOB) AS X;
		print 'xml: ' + cast(@xml as varchar(max))

		INSERT INTO Medicines(id, name, type_id, action, side_effects, recipe, expiration_date, price, manufacturer, quantity)

			Select
				node.value('@id', 'int') AS id,
				node.value('(name)[1]', 'varchar(30)') AS name,
				T.type_id AS type_id,
				node.value('(action)[1]', 'varchar(30)') AS action,
				node.value('(side_effects)[1]', 'varchar(50)') AS side_effects,
				r.bit_value AS recipe,
				node.value('(expiration_date)[1]', 'date') AS expiration_date,
				node.value('(price)[1]', 'decimal(5,2)') AS price,
				node.value('(manufacturer)[1]', 'varchar(5)') AS manufacturer,
				node.value('(quantity)[1]', 'int') AS quantity

			From @xml.nodes('/medicines/medicine') nodes(node)
			join Apteka.dbo.Types T 
			ON T.name = node.value('(type_id)[1]', 'varchar(200)')
			join Apteka.dbo.recipe_value_subsidiary_table r
			ON r.long_name = node.value('(recipe)[1]', 'varchar(3)')
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
go
delete from Medicines
go
select * from Medicines
go
exec mapXMLDataToMedicinesTable
GO
select * from Medicines

-- PROCEDURA DO MAPOWANIA TABELI NA PLIK XML
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='exportMadicinesData')
drop procedure exportMadicinesData
go
CREATE PROCEDURE exportMadicinesData
AS
BEGIN
	exec setUpConfiguration

	BEGIN TRY
			EXEC xp_cmdshell 'bcp "SELECT id AS ''@id'', M.name, T.name as type_id, M.action, M.side_effects, r.long_name as recipe, M.expiration_date, M.price, M.manufacturer, M.quantity FROM Apteka.dbo.Medicines M join Apteka.dbo.Types T ON T.type_id = M.type_id join Apteka.dbo.recipe_value_subsidiary_table r ON r.bit_value = M.recipe FOR XML PATH (''medicine''), ROOT (''medicines'')" queryout "D:\leki1.xml" -c -T'
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END
go
exec exportMadicinesData


-- PROCEDURA DO ZNAJDOWANIA WSZYSTKICH LEKOW W TABELI DANEGO PRODUCENTA
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='findMedicinesByManufacturerName')
drop procedure findMedicinesByManufacturerName
go
create procedure findMedicinesByManufacturerName
@manufacturer_name varchar(30)
as
begin
	Declare @xml XML
	Declare @manufacturer_id varchar(5)
	begin try
		Select  @xml = CONVERT(XML,bulkcolumn,2) FROM OPENROWSET(BULK 'C:\Users\nero1\Desktop\bazy\producenci.xml',SINGLE_BLOB) AS X;
		select @manufacturer_id = node.value('@id', 'VARCHAR(5)')
		From @xml.nodes('/manufacturers/manufacturer') nodes(node)
		where node.value('(name)[1]', 'varchar(30)') = @manufacturer_name

		Select * from Medicines as M where M.manufacturer = @manufacturer_id
	end try
	begin catch
		exec catchError
	end catch
end
go
exec findMedicinesByManufacturerName 'BAYER'


-- PROCEDURA DO AKTUALIZACJI PRODUCENT�W Z PLIKU XML
---------------------------------------------------------------------------------------------------------
if exists( select 1 from sys.objects where TYPE='P' and name='updateManufacturers')
drop procedure updateManufacturers
go
create procedure updateManufacturers
as
begin
	Declare @xml XML
	BEGIN TRY
		Select  @xml = CONVERT(XML,bulkcolumn,2) FROM OPENROWSET(BULK 'C:\Users\nero1\Desktop\bazy\producenci.xml',SINGLE_BLOB) AS X

		SELECT X1.id as '@id', X1.name, X1.city, X1.country
		FROM (Select node.value('@id[1]','VARCHAR(5)') AS id, 
			 node.value('name[1]','VARCHAR(30)') AS name,
			 node.value('city_id[1]','VARCHAR(10)') AS city, 
			 node.value('country[1]','VARCHAR(30)') AS country From @xml.nodes('/manufacturers/manufacturer') AS nodes(node) 
			 EXCEPT 
			SELECT node.value('@id[1]','VARCHAR(5)') AS id, 
			 node.value('name[1]','VARCHAR(30)') AS name, 
			 node.value('city_id[1]','VARCHAR(10)') AS city_id, 
			 node.value('country[1]','VARCHAR(30)') AS country 
			 FROM Apteka.dbo.Manufacturers 
			 CROSS APPLY Manufacturers.manufacturers_data.nodes('//manufacturer') AS nodes(node)) as X1

	DECLARE @query VARCHAR(3000)
	exec setUpConfiguration
	SET @query = 'bcp "SET QUOTED_IDENTIFIER ON Declare @xml XML Select  @xml = CONVERT(XML,bulkcolumn,2) FROM OPENROWSET(BULK ''D:\producenci.xml'',SINGLE_BLOB) AS X SELECT X1.id as ''@id'', X1.name, X1.city, X1.country FROM (Select node.value(''@id[1]'',''VARCHAR(5)'') AS id, node.value(''name[1]'',''VARCHAR(30)'') AS name, node.value(''city_id[1]'',''VARCHAR(10)'') AS city, node.value(''country[1]'',''VARCHAR(30)'') AS country From @xml.nodes(''/manufacturers/manufacturer'') AS nodes(node) EXCEPT SELECT node.value(''@id[1]'',''VARCHAR(5)'') AS id, node.value(''name[1]'',''VARCHAR(30)'') AS name, node.value(''city_id[1]'',''VARCHAR(10)'') AS city_id, node.value(''country[1]'',''VARCHAR(30)'') AS country FROM Apteka.dbo.Manufacturers CROSS APPLY Manufacturers.manufacturers_data.nodes(''//manufacturer'') AS nodes(node)) as X1 FOR XML PATH (''manufacturer''), ROOT (''manufacturers'')" queryout "D:\temp.xml" -c -T'

	EXEC xp_cmdshell @query

	--exec insertXMLData 'Manufacturers', 'D:\temp.xml';
	exec insertManufacturersToManyRows 'Manufacturers', 'D:\temp.xml'

	EXEC xp_cmdshell 'del D:\temp.xml'

	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
end
go
delete from Manufacturers
go
exec insertManufacturersToManyRows 'Manufacturers', 'C:\Users\nero1\Desktop\bazy\producenci.xml';
go
Select * FROM Manufacturers
go
exec updateManufacturers
go
Select * FROM Manufacturers
