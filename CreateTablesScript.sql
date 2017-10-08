CREATE TABLE BRAND
(
    ID number(10) NOT NULL,
    Name varchar2(50) NOT NULL,
    CONSTRAINT Brand_PK PRIMARY KEY (ID)
);

CREATE TABLE CATHEGORY
(
    ID number(10) NOT NULL,
    Name varchar2(50) NOT NULL,
    CONSTRAINT Cathegory_PK PRIMARY KEY (ID)
);

CREATE TABLE PRODUCT
(
    ID number(10) NOT NULL,
    BrandID number(10) NOT NULL,
    CathegoryID number(10) NOT NULL,
    Name varchar2(50) NOT NULL,
    Color varchar2(20) NOT NULL,
    Price number(8,2) NOT NULL,
    Grade number NOT NULL,
    CONSTRAINT Product_PK PRIMARY KEY (ID),
    CONSTRAINT FK_BrandProduct
        FOREIGN KEY (BrandID)
        REFERENCES BRAND (ID),
    CONSTRAINT FK_CathegoryProduct
        FOREIGN KEY (CathegoryID)
        REFERENCES CATHEGORY (ID)
);

CREATE TABLE IMAGE
(
    ID number(10) NOT NULL,
    ProductID number(10) NOT NULL,
    Name varchar2(200) NOT NULL,
    Type varchar2(4) NOT NULL,
    ImageFile ORDImage,
    CONSTRAINT Image_PK PRIMARY KEY (ID),
    CONSTRAINT FK_ProductImage
        FOREIGN KEY (ProductID)
        REFERENCES PRODUCT (ID)
);

CREATE TABLE LOCALIZATION
(
    ID number(10) NOT NULL,
    ProductID number(10) NOT NULL,
    City varchar2(100) NOT NULL,
    Street varchar(100) NOT NULL,
    Avail number(1) NOT NULL,
    Quantity number NOT NULL, 
    CONSTRAINT Localization_PK PRIMARY KEY (ID),
    CONSTRAINT FK_ProductLocalization
        FOREIGN KEY (ProductID)
        REFERENCES PRODUCT (ID)
);

CREATE TABLE PARAMS_TYPES
(
    ID number(10) NOT NULL,
    Name varchar2(50) NOT NULL,
    CONSTRAINT Params_Types_PK PRIMARY KEY (ID)
);

CREATE TABLE PARAMS
(
    ID number(10) NOT NULL,
    ProductID number(10) NOT NULL,
    ParamsTypesID number(10) NOT NULL,
	ParamValue varchar2(200),
    CONSTRAINT Params_PK PRIMARY KEY (ID),
    CONSTRAINT FK_ParamsTypesParams
        FOREIGN KEY (ParamsTypesID)
        REFERENCES PARAMS_TYPES (ID),
    CONSTRAINT FK_ProductParams
        FOREIGN KEY (ProductID)
        REFERENCES PRODUCT (ID)
);

CREATE TABLE PARAMS_CATHEGORY
(
    CathegoryID number(10) NOT NULL,
    ParamsID number(10) NOT NULL,
    CONSTRAINT FK_CathegoryParamsCathegory
        FOREIGN KEY (CathegoryID)
        REFERENCES CATHEGORY (ID),
    CONSTRAINT FK_ParamsTypesParamsCathegory
        FOREIGN KEY (ParamsID)
        REFERENCES PARAMS (ID)
);