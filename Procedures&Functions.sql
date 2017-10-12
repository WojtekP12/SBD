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
  no_product_exception EXCEPTION;
  
BEGIN
  IF fileExists(imageName, path)=FALSE THEN
    RAISE no_file_exception;
  END IF;
  if productExists(productID)=FALSE THEN
    RAISE no_product_exception;
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
  WHEN no_product_exception THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID'); 
END;


execute ADDIMAGE ('galaxys8.png', 'IMAGES', 1);