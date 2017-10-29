create or replace 
FUNCTION fileExists(fileName varchar2, filePath varchar2)
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
---------------------------------

create or replace 
FUNCTION productExists(productID number)
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
---------------------------------

create or replace 
PROCEDURE addImage(imageName varchar2, imageType varchar2, path varchar2, productID number)
IS
  img ORDImage;
  ctx RAW(64) := NULL;
  row_id urowid;
  no_file_exception EXCEPTION;
  to_long_string_exception EXCEPTION;
BEGIN
  IF fileExists(imageName, path)=FALSE THEN
    RAISE no_file_exception;
  END IF;
  IF LENGTH(imageName)>200 THEN
    RAISE to_long_string_exception;
  END IF;
  
  INSERT INTO IMAGE (PRODUCTID, NAME, TYPE, IMAGEFILE)
    VALUES(productID, imageName, imageType, ORDImage.init('FILE', path,imageName))
              RETURNING IMAGEFILE,rowid INTO img, row_id;
  img.import(ctx);
  UPDATE IMAGE SET IMAGEFILE = img WHERE rowid = row_id;
  COMMIT;
  EXCEPTION
  WHEN no_file_exception THEN 
    raise_application_error (-20001, 'File dont exists, please check path parameter in procedure execution');
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID'); 
  WHEN to_long_string_exception THEN
    raise_application_error (-20001, 'image name is to long!');
END;
---------------------------------

create or replace 
PROCEDURE exportImage(imageID number, newImageName varchar)
IS 
  obr1 ORDSYS.ORDIMAGE;
  ctx raw(64) :=null;
BEGIN
  SELECT imagefile INTO obr1 FROM image WHERE ID = imageID;
  obr1.export(ctx, 'FILE', 'IMAGES', newImageName);
  COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID'); 
END;
---------------------------------

create or replace 
FUNCTION imageTypeExists(imageType varchar2)
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
---------------------------------

create or replace 
PROCEDURE changeFormat(imageID number, format varchar2)
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
 
 UPDATE IMAGE SET IMAGEFILE = obj WHERE ID = imageID;
 
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

create or replace 
PROCEDURE showImageFormat(imageID number)
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
---------------------------------

create or replace 
PROCEDURE setImageSize(imageID number, height number, width number)
IS
  obj ORDImage;
  invalid exception;
  PRAGMA EXCEPTION_INIT(invalid, -6502);
BEGIN
  SELECT IMAGEFILE INTO obj FROM IMAGE
  WHERE ID = imageID FOR UPDATE;
  obj.process('fixedScale=' || width || ' ' || height);
 
  UPDATE IMAGE SET IMAGEFILE = obj WHERE ID = imageID;
  COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Image of specified ID does not exist, please check image ID');
  WHEN others THEN
    raise_application_error (-20001, 'Invalid number, please check passed parameters');
END;
---------------------------------

create or replace 
PROCEDURE showImageSize(imageID number)
IS
    image ORDSYS.ORDImage;
    width number;
    height number;
BEGIN
    SELECT IMAGEFILE INTO image FROM IMAGE WHERE ID = imageID;
    width := image.getWidth();
    height := image.getHeight();
    DBMS_OUTPUT.PUT_LINE('wysokosc: ' || height);
    DBMS_OUTPUT.PUT_LINE('szerokosc: ' || width);
    COMMIT;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN 
      raise_application_error (-20001, 'Image of specified ID does not exist, please check image ID'); 
END;
---------------------------------

create or replace 
function GetVariableType
(
    p_object_name varchar2,
    p_name varchar2
) return varchar2 is
    v_type_name varchar2(4000);
begin
    select reference.name into v_type_name
    from user_identifiers declaration
    join user_identifiers reference
        on declaration.usage_id = reference.usage_context_id
        and declaration.object_name = reference.object_name
    where
        declaration.object_name = p_object_name
        and declaration.usage = 'DECLARATION'
        and reference.usage = 'REFERENCE'
        and declaration.name = p_name;

    return v_type_name;
end;
---------------------------------

create or replace 
procedure updateImageMetaData(imageId number)
is
  img ORDSYS.ORDImage;
  metav XMLSequenceType;
  meta_root VARCHAR2(40);
  xmlORD XMLType;
  xmlXMP XMLType;
  xmlEXIF XMLType;
  xmlIPTC XMLType;
begin
  select imagefile into img from IMAGE where ID = imageId;
  metav := img.getMetadata('ALL');
  
  FOR i IN 1..metav.count() LOOP
    meta_root := metav(i).getRootElement();
    CASE meta_root
      WHEN 'ordImageAttributes' THEN xmlORD := metav(i);
      WHEN 'xmpMetadata' THEN xmlXMP := metav(i);
      WHEN 'iptcMetadata' THEN xmlIPTC := metav(i);
      WHEN 'exifMetadata' THEN xmlEXIF := metav(i);
      ELSE NULL;
    END CASE;
  END LOOP;
  
  xmlORD:=fixmetadataxml(xmlORD);
  
  UPDATE image
  SET metaORDImage = xmlORD,
      metaEXIF = xmlEXIF,
      metaIPTC = xmlIPTC,
      metaXMP = xmlXMP
  WHERE id = imageId;
  
  commit;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID');
END;
---------------------------------

create or replace 
procedure updateImageMetaData(imageId number)
is
  img ORDSYS.ORDImage;
  metav XMLSequenceType;
  meta_root VARCHAR2(40);
  xmlORD XMLType;
  xmlXMP XMLType;
  xmlEXIF XMLType;
  xmlIPTC XMLType;
begin
  select imagefile into img from IMAGE where ID = imageId;
  metav := img.getMetadata('ALL');
  
  FOR i IN 1..metav.count() LOOP
    meta_root := metav(i).getRootElement();
    CASE meta_root
      WHEN 'ordImageAttributes' THEN xmlORD := metav(i);
      WHEN 'xmpMetadata' THEN xmlXMP := metav(i);
      WHEN 'iptcMetadata' THEN xmlIPTC := metav(i);
      WHEN 'exifMetadata' THEN xmlEXIF := metav(i);
      ELSE NULL;
    END CASE;
  END LOOP;
  
  xmlORD:=fixmetadataxml(xmlORD);
  
  UPDATE image
  SET metaORDImage = xmlORD,
      metaEXIF = xmlEXIF,
      metaIPTC = xmlIPTC,
      metaXMP = xmlXMP
  WHERE id = imageId;
  
  commit;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID');
END;
---------------------------------


create or replace 
function fixMetadataXML(imageXml XMLType)
return XMLType
is
  x varchar2(30000);
  NEW_XML xmltype;
begin
  x:=imageXml.getStringVal();
  
  x:=REPLACE(x, 'xmlns="http://xmlns.oracle.com/ord/meta/ordimage"');
  
  NEW_XML:=XMLTYPE.CREATEXML(x);

  return NEW_XML;
end;
---------------------------------


create or replace 
procedure compareImages(image1Id number, image2Id number)
is
  image1OrdXML xmltype;
  image2OrdXML xmltype;
  image1Height varchar2(100);
  image1Width varchar2(100);
  image1Type varchar2(100);
  image2Height varchar2(100);
  image2Width varchar2(100);
  image2Type varchar2(100);
begin
  
  select metaordimage into image1OrdXML from image where id=image1Id;
  select metaordimage into image2OrdXML from image where id=image2Id;
  
  SELECT ExtractValue(Value(xml),'*/height/text()') into image1Height
  FROM TABLE(XMLSequence(Extract(image1OrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/width/text()') into image1Width
  FROM TABLE(XMLSequence(Extract(image1OrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/fileFormat/text()') into image1Type
  FROM TABLE(XMLSequence(Extract(image1OrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/height/text()') into image2Height
  FROM TABLE(XMLSequence(Extract(image2OrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/width/text()') into image2Width
  FROM TABLE(XMLSequence(Extract(image2OrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/fileFormat/text()') into image2Type
  FROM TABLE(XMLSequence(Extract(image2OrdXML,'/ordImageAttributes'))) xml;

  if image1Height = image2Height then
    dbms_output.put_line('Obrazy maja te same wysokosci');
  else 
    dbms_output.put_line('Obrazy maja rozna wysokosc');
  end if;
  
  if image1Width = image2Width then
    dbms_output.put_line('Obrazy maja te same szerokosci');
  else 
    dbms_output.put_line('Obrazy maja rozna szerokosc');
  end if;
  
  if image1Type = image2Type then
    dbms_output.put_line('Obrazy maja ten sam format');
  else 
    dbms_output.put_line('Obrazy maja rozny format');
  end if;
  
  if (image1Height = image2Height) and (image1Width = image2Width) and (image1Type = image2Type) then
    dbms_output.put_line('Obrazy sa jednakowe pod wzgleden rozmiaru i typu');
  else
    dbms_output.put_line('Obrazy sa rozne pod wzgleden rozmiaru i typu');
  end if;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'Product of specified ID does not exist, please check product ID'); 
  
end;
---------------------------------

create or replace 
procedure findSimilarImage(imageId number)
is
  imageOrdXML xmltype;
  imageHeight varchar2(100);
  imageWidth varchar2(100);
  imageType varchar2(100);
  tempxml xmltype;
  tempheight varchar2(100);
  tempwidth varchar2(100);
  temptype varchar2(100);
  numberOfRows number;
begin
  numberOfRows := 0;
  select metaordimage into imageOrdXML from image where id=imageId;
  
  SELECT ExtractValue(Value(xml),'*/height/text()') into imageHeight
  FROM TABLE(XMLSequence(Extract(imageOrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/width/text()') into imageWidth
  FROM TABLE(XMLSequence(Extract(imageOrdXML,'/ordImageAttributes'))) xml;
  
  SELECT ExtractValue(Value(xml),'*/fileFormat/text()') into imageType
  FROM TABLE(XMLSequence(Extract(imageOrdXML,'/ordImageAttributes'))) xml;
  
  for i in (select * from image img where img.id <> imageId)
  loop
    tempxml:=i.metaordimage;
    
    SELECT ExtractValue(Value(xml),'*/height/text()') into tempheight
    FROM TABLE(XMLSequence(Extract(tempxml,'/ordImageAttributes'))) xml;
    
    SELECT ExtractValue(Value(xml),'*/width/text()') into tempwidth
    FROM TABLE(XMLSequence(Extract(tempxml,'/ordImageAttributes'))) xml;
    
    SELECT ExtractValue(Value(xml),'*/fileFormat/text()') into temptype
    FROM TABLE(XMLSequence(Extract(tempxml,'/ordImageAttributes'))) xml;
    
    if (tempheight = imageHeight) AND (tempwidth = imageWidth) AND (temptype = imageType) then
      --numberOfRows:=numberOfRows+1;
      dbms_output.put_line('');
      dbms_output.put_line('ID: ' || i.id);
      dbms_output.put_line('Name: ' || i.name);
      dbms_output.put_line('');
    end if;

  end loop;
      
    --dbms_output.put_line(TO_CHAR(numberOfRows));
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    raise_application_error (-20001, 'image of specified ID does not exist, please check image ID');
  
end;
---------------------------------

