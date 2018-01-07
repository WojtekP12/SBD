


---------------------------------------------------------------------------------------------------------
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

exec sp_configure "remote access", 1          -- 0 on, 1 off
exec sp_configure "remote query timeout", 600 -- seconds
exec sp_configure "remote proc trans", 0      -- 0 on, 1 off


-- BULK - umo¿liwia czytanie z pliku bez koniecznoœci ³adowania go do tabeli.
-- SINGLE_BLOB - parametr dla BULK, czytanie pliku jako pojedynczej linii (BLOC - jako ASCII)
---------------------------------------------------------------------------------------------------------

drop procedure catchError
GO
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

delete from Manufacturers
exec insertXMLData 'Manufacturers', 'C:\Users\nero1\Desktop\bazy\producenci.xml';
Select * from Manufacturers;

---------------------------------------------------------------------------------------------------------
-- CROSS APPLY - Polecenie to umo¿liwia wykonanie dowolnego zapytania dla ka¿dego wiersza tabeli i z³¹czenie otrzymanego wyniku z tym wierszem
-- Tutaj jest to o tyle przydatne, ze mamy do czynienia z tabel¹, w której ka¿dy wiersz jest równierz jak¹œ kolekcja danych, która znów zawiera wiecej niz 1 element producent
-- @ - odczyt atrybutu
-- nodes(node) - alias. samo nodes bez () odwo³uwa³oby do Producenci.dane_producentow.nodes natomiast z () odwo³uje do node'a xmla producent
drop procedure getAllProducersInfo
GO
CREATE PROCEDURE getAllProducersInfo
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

exec getAllProducersInfo

---------------------------------------------------------------------------------------------------------
drop procedure getInfoFromProducerNode
GO
CREATE PROCEDURE getInfoFromProducerNode @node_name varchar(32)
AS
BEGIN
DECLARE @query VARCHAR(1000)
SET @query = 'SELECT
				node.value(''' + @node_name + '[1]'',''VARCHAR(30)'') AS ''Node info''
				FROM Manufacturers
				CROSS APPLY Manufacturers.manufacturers_data.nodes(''//manufacturer'') AS nodes(node)';
	BEGIN TRY
		EXEC (@query);
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END

exec getInfoFromProducerNode 'name'

---------------------------------------------------------------------------------------------------------
-- AUTO - postac xml jest generowana autoamczynie w zaleznosci od struktury tabeli
-- ELEMENTS - kazda kolumna w select jest mapowana na pod elementy w xml
-- -c - format pliku plain text -T bcp komunikuje siê z sql serverem bezpiecznym po³¹czeniem
drop procedure exportDataToXML
GO
CREATE PROCEDURE exportDataToXML
@table_name VARCHAR(32)
AS
BEGIN
	DECLARE @query VARCHAR(3000)
	SET @query = 'bcp "SELECT * FROM Apteka.dbo."' + @table_name + '" FOR XML AUTO, ELEMENTS" queryout "D:\table.xml" -c -T'

	BEGIN TRY
		EXEC xp_cmdshell @query
	END TRY
	BEGIN CATCH
		exec catchError
	END CATCH
END

exec exportDataToXML 'Medicines'