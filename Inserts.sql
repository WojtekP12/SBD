-- przed wrzuceniem obrazka do tabeli nalezy polaczyc folder na dysku z folderem w oracle sql : 
-- 1. sciagnij folder ze zdjeciami z repo
-- 3. po³¹cz folder na dysku z folderem oracle sql
-- 		3.1 - zaloguj sie jako sysdba : sqlplus / as sysdba
--		3.2 - CREATE OR REPLACE DIRECTORY IMAGES as 'sciezka_do_folderu';
-- 4. Wykonaj skrypt ponizej


INSERT INTO BRAND (NAME) VALUES('Samsung');
INSERT INTO CATHEGORY (NAME) VALUES('Smartphone');
INSERT INTO PRODUCT (BRANDID,CATHEGORYID,NAME,COLOR,PRICE,GRADE) VALUES(1,1,'Galaxy S8', 'black', 3298.00, 5);
INSERT INTO LOCALIZATION (PRODUCTID,CITY,STREET,AVAIL,QUANTITY) VALUES(1,'Lodz','Kolumny 6/36', 1, 10);

INSERT INTO PARAMS_TYPES (NAME) VALUES('Screen');
INSERT INTO PARAMS_TYPES (NAME) VALUES('Camera');
INSERT INTO PARAMS_TYPES (NAME) VALUES('Memory');
INSERT INTO PARAMS_TYPES (NAME) VALUES('Battery');

INSERT INTO PARAMS (PRODUCTID,PARAMSTYPESID, VALUE) VALUES(1,1,'5.8, HD+, Proporcje: 18.5:9');
INSERT INTO PARAMS (PRODUCTID,PARAMSTYPESID, VALUE) VALUES(1,2,'Rear: 12MP, FRONT: 8MP');
INSERT INTO PARAMS (PRODUCTID,PARAMSTYPESID, VALUE) VALUES(1,3,'Internal: 64GB');
INSERT INTO PARAMS (PRODUCTID,PARAMSTYPESID, VALUE) VALUES(1,3,'3000 mAh');

INSERT INTO PARAMS_CATHEGORY (CATHEGORYID, PARAMSTYPESID) VALUES(1,1);
INSERT INTO PARAMS_CATHEGORY (CATHEGORYID, PARAMSTYPESID) VALUES(1,2);
INSERT INTO PARAMS_CATHEGORY (CATHEGORYID, PARAMSTYPESID) VALUES(1,3);
INSERT INTO PARAMS_CATHEGORY (CATHEGORYID, PARAMSTYPESID) VALUES(1,4);

DECLARE
    img ORDImage;
    ctx RAW(64) := NULL;
    row_id urowid;
BEGIN
    INSERT INTO IMAGE (PRODUCTID, NAME, TYPE, IMAGEFILE)
             VALUES (1,'galaxys8','png', ORDImage.init('FILE', 'IMAGES','galaxys8.png'))
                                   RETURNING IMAGEFILE,rowid INTO img, row_id;
    img.import(ctx); -- ORDImage.import wywo³uje ORDImage.setProperties;
    UPDATE IMAGE SET IMAGEFILE = img WHERE rowid = row_id;  --aktualizacja tabeli o atrybuty obrazów
    COMMIT;
END;
/