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


CREATE TABLE IMAGE
(
    ID number(10) NOT NULL,
    ProductID number(10) NOT NULL,
    Name varchar2(200) NOT NULL,
    Type varchar2(4) NOT NULL,
    Image ORDimage,
    CONSTRAINT Image_PK PRIMARY KEY (ID),
    CONSTRAINT FK_ProductImage
        FOREIGN KEY (ProductID)
        REFERENCES PRODUCT (ID)
);

DECLARE
    file bfile;
    bl BLOB:=empty_blob();
    fileSize number;
    id number(10);
BEGIN
    file:=bfilename('IMAGES','SamsungGalaxyS8.jpg');
    IF(dbms_lob.fileexists(file)=1) THEN
        fileSize:=dbms_lob.getlength(file);
        insert into IMAGE(PRODUCTID,NAME,TYPE,IMAGE) VALUES(1,'Samsung Galaxy S8','jpg',bl);
        dbms_lob.open(file,dbms_lob.lob_readonly);
        dbms_lob.open(bl,dbms_lob.lob_readwrite);
        dbms_lob.loadfromfile(bl,file, fileSize);
        dbms_lob.close(bl);
        dbms_lob.close(file);
        COMMIT;
        dbms_output.put_line('plik znalazl siê w tabeli pod numerem '||id||', zajmuje '||fileSize||' bajtow');
        ELSE 
            dbms_output.put_line('nie znalazlem takiego pliku...');  
        END IF;
END;
/