CREATE OR REPLACE FUNCTION fileExists(fileName varchar2, filePath varchar2)
RETURN BOOLEAN
IS
v_exists BOOLEAN;
v_length NUMBER;
v_blocksize NUMBER;
BEGIN
  UTL_FILE.fgetattr (filePath, fileName, v_exists, v_length, v_blocksize);
  IF v_exists
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;

CREATE OR REPLACE FUNCTION productExists(productID number)
RETURN BOOLEAN
IS
  productCount number;
BEGIN
  SELECT COUNT(*) INTO productCount FROM product WHERE ID=productID;
  IF productCount<1 THEN
    RETURN FALSE;
  ELSE 
    RETURN TRUE;
  END IF;
END;

CREATE OR REPLACE PROCEDURE addImage(imageName varchar2, path varchar2, productID number)
IS
  img ORDImage;
  ctx RAW(64) := NULL;
  row_id urowid;
  no_file_exception EXCEPTION; 
BEGIN
  IF fileExists(imageName, path)=FALSE THEN
    RAISE no_file_exception;
  END IF;
  INSERT INTO IMAGE (PRODUCTID, NAME, TYPE, IMAGEFILE)
    VALUES(productID, imageName, 'png', ORDImage.init('FILE', path,imageName))
              RETURNING IMAGEFILE,rowid INTO img, row_id;
  img.import(ctx);
  UPDATE IMAGE SET IMAGEFILE = img WHERE rowid = row_id;
  COMMIT;
  EXCEPTION
  WHEN no_file_exception THEN 
    raise_application_error (-20001, 'File dont exists, please check path parameter in procedure execution');
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID'); 
END;

CREATE OR REPLACE PROCEDURE exportImage(imageID number, newImageName varchar)
IS 
  obr1 ORDSYS.ORDIMAGE;
  ctx raw(64) :=null;
BEGIN
    SELECT imagefile INTO obr1 FROM image WHERE ID = imageID;
    obr1.export(ctx, 'FILE', 'IMAGES', newImageName);
END;

CREATE OR REPLACE FUNCTION imageTypeExists(imageType varchar2)
RETURN BOOLEAN
IS
  t varchar2(10);
BEGIN
  t := imageType;
  IF(imageType = 'BMPF') OR 
    (imageType = 'CALS') OR 
    (imageType = 'GIFF') OR
    (imageType = 'JFIF') OR 
    (imageType = 'PBMF') OR 
    (imageType = 'PICT') OR 
    (imageType = 'PNGF') OR 
    (imageType = 'PNMF') OR 
    (imageType = 'PPMF') OR
    (imageType = 'RASF') OR 
    (imageType = 'RPIX') OR 
    (imageType = 'TGAF') OR 
    (imageType = 'TIFF') OR 
    (imageType = 'WBMP') 
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
END;

CREATE OR REPLACE PROCEDURE changeFormat(imageID number, format varchar2)
IS
  obj ORDImage;
  no_image_exception EXCEPTION;
  wrong_format_exception EXCEPTION;
BEGIN
  IF imageExists(imageID)=FALSE THEN
      RAISE no_image_exception;
  END IF;
  
  IF imageTypeExists(format)=FALSE THEN
    RAISE wrong_format_exception;
  END IF;

  SELECT IMAGEFILE INTO obj FROM IMAGE
  WHERE ID = imageID FOR UPDATE;
  obj.process('fileFormat=' || format);
 
 -- Update 
 UPDATE IMAGE SET IMAGEFILE = obj WHERE ID = imageID;
 
 -- Roll back to keep original format of image:
 COMMIT;
 
 EXCEPTION
  WHEN ORDSYS.ORDImageExceptions.DATA_NOT_LOCAL THEN
   DBMS_OUTPUT.PUT_LINE('Data is not local');
  WHEN no_image_exception THEN 
    raise_application_error (-20001, 'Image of specified ID does not exist, please check image ID');
  WHEN wrong_format_exception THEN 
    raise_application_error (-20001, 'Wrong image format');
   
END;
---------------------------------

CREATE OR REPLACE PROCEDURE showImageFormat(imageID number)
IS
    image ORDSYS.ORDImage;
    format varchar(4000);
BEGIN
    SELECT IMAGEFILE INTO image FROM IMAGE WHERE ID = imageID;
    format := image.getFileFormat();
    DBMS_OUTPUT.PUT_LINE('format obrazka: ' || format);
    COMMIT;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN 
      raise_application_error (-20001, 'Image of specified ID does not exist, please check image ID'); 
END;
---------------------------------

create or replace 
FUNCTION imageExists(imageID number)
RETURN BOOLEAN
IS
  imageCount number;
BEGIN
  SELECT COUNT(*) INTO imageCount FROM IMAGE WHERE ID=imageID;
  IF imageCount<1 THEN
    RETURN FALSE;
  ELSE 
    RETURN TRUE;
  END IF;
END;

--execute ADDIMAGE ('galaxys8.png', 'IMAGES', 1);
--execute exportImage(21,'nowy.png');
--execute changeFormat(21,'JFIF');

--set serveroutput on;
--execute showImageFormat(123);

