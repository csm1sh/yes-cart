--
--  Copyright 2009 Denys Pavlov, Igor Azarnyi
--
--     Licensed under the Apache License, Version 2.0 (the "License");
--     you may not use this file except in compliance with the License.
--     You may obtain a copy of the License at
--
--         http://www.apache.org/licenses/LICENSE-2.0
--
--     Unless required by applicable law or agreed to in writing, software
--     distributed under the License is distributed on an "AS IS" BASIS,
--     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--     See the License for the specific language governing permissions and
--     limitations under the License.
--

--
-- This script is for MySQL only with some Derby hints inline with comments
-- We highly recommend you seek YC's support help when upgrading your system
-- for detailed analysis of your code.
--
-- Upgrades organised in blocks representing JIRA tasks for which they are
-- necessary - potentially you may hand pick the upgrades you required but
-- to keep upgrade process as easy as possible for future we recommend full
-- upgrades
--

--
-- YC-870 Request for price prices
--

alter table TSKUPRICE add column PRICE_UPON_REQUEST bit not null default 0;
-- alter table TSKUPRICE add column PRICE_UPON_REQUEST smallint not null default 0;

--
-- YC-871 Calculated B2B prices
--

alter table TSKUPRICE add column AUTO_GENERATED bit not null default 0;
-- alter table TSKUPRICE add column AUTO_GENERATED smallint not null default 0;



    create table TSKUPRICERULE (
        SKUPRICERULE_ID bigint not null auto_increment,
        VERSION bigint not null default 0,
        CODE varchar(255) not null unique,
        RANK integer default 500,
        SHOP_CODE varchar(255) not null,
        CURRENCY varchar(5) not null,
        RULE_ACTION varchar(1) not null,
        ELIGIBILITY_CONDITION longtext not null,
        MARGIN_PERCENT decimal(9,2),
        MARGIN_AMOUNT decimal(9,2),
        ADD_DEFAULT_TAX bit not null,
        ROUNDING_UNIT decimal(9,2),
        PRICE_TAG varchar(255),
        PRICE_REF varchar(255),
        PRICE_POLICY varchar(255),
        NAME varchar(255) not null,
        DESCRIPTION varchar(1000),
        TAG varchar(255),
        ENABLED bit not null,
        ENABLED_FROM datetime,
        ENABLED_TO datetime,
        CREATED_TIMESTAMP datetime,
        UPDATED_TIMESTAMP datetime,
        CREATED_BY varchar(64),
        UPDATED_BY varchar(64),
        GUID varchar(36) not null unique,
        primary key (SKUPRICERULE_ID)
    );

    create index SKUPRICERULE_SHOP_CODE on TSKUPRICERULE (SHOP_CODE);
    create index SKUPRICERULE_CURRENCY on TSKUPRICERULE (CURRENCY);
    create index SKUPRICERULE_ENABLED on TSKUPRICERULE (ENABLED);

--     create table TSKUPRICERULE (
--         SKUPRICERULE_ID bigint not null GENERATED BY DEFAULT AS IDENTITY,
--         VERSION bigint not null default 0,
--         CODE varchar(255) not null unique,
--         RANK integer default 500,
--         SHOP_CODE varchar(255) not null,
--         CURRENCY varchar(5) not null,
--         RULE_ACTION varchar(1) not null,
--         ELIGIBILITY_CONDITION varchar(4000) not null,
--         MARGIN_PERCENT numeric(9,2),
--         MARGIN_AMOUNT numeric(9,2),
--         ADD_DEFAULT_TAX smallint not null,
--         ROUNDING_UNIT numeric(9,2),
--         PRICE_TAG varchar(255),
--         PRICE_REF varchar(255),
--         PRICE_POLICY varchar(255),
--         NAME varchar(255) not null,
--         DESCRIPTION varchar(1000),
--         TAG varchar(255),
--         ENABLED smallint not null,
--         ENABLED_FROM timestamp,
--         ENABLED_TO timestamp,
--         CREATED_TIMESTAMP timestamp,
--         UPDATED_TIMESTAMP timestamp,
--         CREATED_BY varchar(64),
--         UPDATED_BY varchar(64),
--         GUID varchar(36) not null unique,
--         primary key (SKUPRICERULE_ID)
--     );
--
--     create index SKUPRICERULE_SHOP_CODE on TSKUPRICERULE (SHOP_CODE);
--     create index SKUPRICERULE_CURRENCY on TSKUPRICERULE (CURRENCY);
--     create index SKUPRICERULE_ENABLED on TSKUPRICERULE (ENABLED);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  10886,  'SHOP_B2B_STRICT_PRICE_RULES', 'SHOP_B2B_STRICT_PRICE_RULES',  0,  NULL,  'Shop: B2B strict price rules mode enable',
   'Disable master shop price rules and use only sub shop rules',  1008, 1001, 0, 0, 0, 0);

--
-- YC-888 Ensure SYSTEM_PANEL_LABEL is consistent with environment build
--

delete from TSYSTEMATTRVALUE where CODE like 'SYSTEM_PANEL_LABEL';
delete from TATTRIBUTE where CODE like 'SYSTEM_PANEL_LABEL';

--
-- YC-896 Automatically filter out empty product categories from menu
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  5001,  'SHOP_CATEGORY_REMOVE_EMPTY', 'SHOP_CATEGORY_REMOVE_EMPTY',  0,  NULL,  'Shop: remove empty categories from menu',
  'Remove empty categories from menus. Default is false',  1008, 1001, 0, 0, 0, 0);

--
-- YC-897 B2B sub shops must be allowed own promotions
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  10887,  'SHOP_B2B_STRICT_PROMOTIONS', 'SHOP_B2B_STRICT_PROMOTIONS',  0,  NULL,  'Shop: B2B strict promotions mode enable',
   'Disable master shop promotions and use only sub shop promotions',  1008, 1001, 0, 0, 0, 0);

--
-- YC-891 Expose various system configurations as preferences
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11230,  'JOB_EXPIRE_GUESTS_BATCH_SIZE', 'JOB_EXPIRE_GUESTS_BATCH_SIZE',  0,  NULL,  'Job\\Expired Guest Accounts Clean Up: batch size',
    'Guest accounts deletion batch size (default is 500)',  1006, 1000, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11231,  'JOB_CUSTOMER_TAG_BATCH_SIZE', 'JOB_CUSTOMER_TAG_BATCH_SIZE',  0,  NULL,  'Job\\Customer Tagging: batch size',
    'Customer tagging batch size (default is 500)',  1006, 1000, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11232,  'JOB_ABANDONED_CARTS_BATCH_SIZE', 'JOB_ABANDONED_CARTS_BATCH_SIZE',  0,  NULL,  'Job\\Abandoned Shopping Cart State Clean Up: batch size',
    'Abandoned cart clean up batch size (default is 500)',  1006, 1000, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11233,  'JOB_EMPTY_CARTS_BATCH_SIZE', 'JOB_EMPTY_CARTS_BATCH_SIZE',  0,  NULL,  'Job\\Empty Anonymous Shopping Cart State Clean Up: batch size',
    'Empty cart clean up batch size (default is 500)',  1008, 1000, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11234,  'SHOP_COUPON_CODE_LENGTH', 'SHOP_COUPON_CODE_LENGTH',  0,  NULL,  'Promotion: size of the coupon code',
   'Size of the auto generated coupon code (min is 5 char not including shop code prefix)',  1006, 1001, 0, 0, 0, 0);

--
-- YC-894 Manual export trigger flow in JAM
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  8020,  'ORDER_EXPORTER_MANUAL_STATE_PROXY', 'ORDER_EXPORTER_MANUAL_STATE_PROXY',  0,  NULL,  'Export Orders\\Manual state transition',
    'Property mapping for supplier codes and corresponding transition states. Use NOBLOCK or BLOCK after next eligibility to denote if this is a blocking change to enable manual mode.
E.g. INITPAID=MANUALXML,BLOCK
DELIVERY=EMAILNOTIFY,NOBLOCK',  1012, 1001, 0, 0, 0, 0);

--
-- YC-905 Improved registration and validation process
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  10888,  'SHOP_CREGATTRS_EMAIL', 'SHOP_CREGATTRS_EMAIL',  0,  NULL,  'Customer (Email validation): login, contact, newsletter etc',
    'Customer attribute used to validate the emails',  1000, 1001, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV, SECURE_ATTRIBUTE, REXP, DISPLAYNAME, V_FAILED_MSG)
  VALUES (  11163,  'password', 'password',  1,  'password',  'Password',  'Password', 1017,  1006, 0, 0, 0, 0, 1,
  '^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{8,}$',
  'en#~#Password#~#uk#~#Пароль#~#ru#~#Пароль#~#de#~#Passwort',
  'en#~#Password must have at least 8 symbols: 1 upper case letter (A-Z), 1 lower case letter (a-z), 1 digit (0-9) and 1 special character (@#$%^&+=)#~#uk#~#Пароль має містити принаймні 8 символів: 1 велику літеру (A-Z), 1 маленьку літеру (a-z), 1 цифру (0-9) та 1 спеціальний символ (@#$%^&+=)#~#ru#~#Пароль должен содержать 8 символов: 1 большую букву (A-Z), 1 маленькую букву (a-z), 1 цифру (0-9) и 1 специальный символ (@#$%^&+=)#~#de#~#Das Passwort muss mindestens 8 Symbole enthalten: 1 Großbuchstabe (A-Z), 1 Kleinbuchstabe (a-z), 1 Ziffer (0-9) und 1 Sonderzeichen (@#$%^&+=)');

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV, SECURE_ATTRIBUTE, DISPLAYNAME)
  VALUES (  11164,  'confirmPassword', 'confirmPassword',  1,  'confirmPassword',  'Confirm Password',  'Confirm Password', 1017,  1006, 0, 0, 0, 0, 1,
  'en#~#Confirm Password#~#uk#~#Підтвердження пароля#~#ru#~#Подтверждения пароля#~#de#~#Bestätigungspasswort');

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV, REXP, DISPLAYNAME, V_FAILED_MSG)
  VALUES (  11165,  'email', 'email',  1,  'email',  'Customer Email',  'Email', 1010,  1006, 0, 0, 0, 0,
  '^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*((\\.[A-Za-z]{2,}){1}$)',
  'en#~#E-mail#~#uk#~#E-mail#~#ru#~#E-mail#~#de#~#E-mail',
  'en#~#''${input}'' is not a valid email address#~#uk#~#''${input}'' не є коректною електронною поштою#~#ru#~#''${input}'' не является корректной электронной почтой#~#de#~#''${input}'' ist keine gültige E-Mail Adresse');

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV, SECURE_ATTRIBUTE, V_FAILED_MSG)
  VALUES (  11166,  'MANAGER_PASSWORD_REGEX', 'MANAGER_PASSWORD_REGEX',  1,  NULL,  'Manager Password RegEx',  'Manager Password RegEx', 1017,  1000, 0, 0, 0, 0, 1,
  'en#~#Password must have at least 8 symbols: 1 upper case letter (A-Z), 1 lower case letter (a-z), 1 digit (0-9) and 1 special character (@#$%^&+=)#~#uk#~#Пароль має містити принаймні 8 символів: 1 велику літеру (A-Z), 1 маленьку літеру (a-z), 1 цифру (0-9) та 1 спеціальний символ (@#$%^&+=)#~#ru#~#Пароль должен содержать 8 символов: 1 большую букву (A-Z), 1 маленькую букву (a-z), 1 цифру (0-9) и 1 специальный символ (@#$%^&+=)#~#de#~#Das Passwort muss mindestens 8 Symbole enthalten: 1 Großbuchstabe (A-Z), 1 Kleinbuchstabe (a-z), 1 Ziffer (0-9) und 1 Sonderzeichen (@#$%^&+=)');


UPDATE TSHOPATTRVALUE SET VAL = 'email,salutation,firstname,middlename,lastname,CUSTOMER_PHONE,MARKETING_OPT_IN,password,confirmPassword' WHERE GUID = 'SHOP_CUSTOMER_REGISTRATION_10';
UPDATE TSHOPATTRVALUE SET VAL = 'email,firstname,lastname' WHERE GUID = 'SHOP_CUSTOMER_REGGUEST_10';
INSERT INTO TSHOPATTRVALUE(ATTRVALUE_ID,VAL,CODE,SHOP_ID, GUID)  VALUES (26, 'email','SHOP_CREGATTRS_EMAIL', 10, 'SHOP_CUSTOMER_EMAIL_10');


alter table TMANAGER add column PASSWORDEXPIRY datetime;
-- alter table TMANAGER add column PASSWORDEXPIRY timestamp;
alter table TCUSTOMER add column PASSWORDEXPIRY datetime;
-- alter table TCUSTOMER add column PASSWORDEXPIRY timestamp;

--
-- YC-908 Improve plug ability of widgets
--

alter table TMANAGER add column DASHBOARDWIDGETS varchar(4000);

INSERT INTO TATTRIBUTEGROUP (ATTRIBUTEGROUP_ID, GUID, CODE, NAME, DESCRIPTION) VALUES (1010, 'WIDGET',   'WIDGET', 'Dashboard widgets settings.', 'Dashboard widgets settings');

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6200,  'WIDGET_Alerts', 'WIDGET_Alerts',  0,  NULL,  'Alerts',  'Alerts: displays system messages', 1000,  1010, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6201,  'WIDGET_OrdersInShop', 'WIDGET_OrdersInShop',  0,  NULL,  'Orders Overview',  'Orders Overview: count of orders for today, this week and this month', 1000,  1010, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6202,  'WIDGET_UnprocessedPgCallbacks', 'WIDGET_UnprocessedPgCallbacks',  0,  NULL,  'Unprocessed Callbacks (YCE)',  'Unprocessed Callbacks: count of failed payment callbacks', 1000,  1010, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6203,  'WIDGET_CustomersInShop', 'WIDGET_CustomersInShop',  0,  NULL,  'Customers Overview',  'Customers Overview: count of customers for today, this week and this month', 1000,  1010, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6204,  'WIDGET_CacheOverview', 'WIDGET_CacheOverview',  0,  NULL,  'Cache Alerts',  'Cache Alerts: count of full of nearly full caches', 1000,  1010, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6205,  'WIDGET_ReindexOverview', 'WIDGET_ReindexOverview',  0,  NULL,  'Search Index',  'Search Index: count of products in FT, DB', 1000,  1010, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  6206,  'WIDGET_UiSettings', 'WIDGET_UiSettings',  0,  NULL,  'UI Settings',  'UI Settings: Admin UI preferences', 1000,  1010, 0, 0, 0, 0);

--
-- YC-865 Review clustered tasks API
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11167,  'JOB_CACHE_EVICT_PAUSE', 'JOB_CACHE_EVICT_PAUSE',  0,  NULL,  'Job\\Evict frontend cache: pause image vault scanning',
    'Pause frontend cache eviction (if paused updates in admin will not take effect unless manual cache evict is triggered)',  1008, 1000, 0, 0, 0, 0);

--
-- YC-889 Products, Categories and Content available flag
--

alter table TPRODUCT add column DISABLED bit default 0;
-- alter table TPRODUCT add column DISABLED smallint DEFAULT 0;
create index PRODUCT_DISABLED on TPRODUCT (DISABLED);

alter table TCATEGORY add column DISABLED bit default 0;
-- alter table TCATEGORY add column DISABLED smallint DEFAULT 0;
create index CAT_DISABLED on TCATEGORY (DISABLED);


--
-- YC-868 Customer registration improvements
--

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11168,  'regAddressForm', 'regAddressForm',  1,  'regAddressForm',  'Address form for registration marker',  'Address form for registration marker', 1000,  1006, 0, 0, 0, 0);

--
-- YC-916 Create a product image vault clean up job
--


INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11122,  'JOB_LOCAL_PRODIMAGECLEAN_SCAN_PAUSE', 'JOB_LOCAL_PRODIMAGECLEAN_SCAN_PAUSE',  0,  NULL,  'Job\\Product image vault clean up: pause product image vault clean up',
    'Pause local file system product image vault clean up',  1008, 1000, 0, 0, 0, 0);

INSERT INTO TATTRIBUTE (ATTRIBUTE_ID, GUID, CODE, MANDATORY, VAL, NAME, DESCRIPTION, ETYPE_ID, ATTRIBUTEGROUP_ID, STORE, SEARCH, SEARCHPRIMARY, NAV)
  VALUES (  11123,  'JOB_LOCAL_PRODIMAGEVAULT_CLEAN_MODE', 'JOB_LOCAL_PRODIMAGEVAULT_CLEAN_MODE',  0,  NULL,  'Job\\Product image vault clean up: mode',
    'Mode can be SCAN (logging only) or DELETE (removes the orphan image files)',  1000, 1000, 0, 0, 0, 0);
