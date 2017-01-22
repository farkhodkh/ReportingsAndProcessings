IF OBJECT_ID (N'dbo.SysValueTempExcude') IS NOT NULL  
DROP PROCEDURE dbo.SysValueTempExcude
GO
Create PROCEDURE SysValueTempExcude
AS BEGIN
IF OBJECT_ID (N'dbo.TempSysXMLTable') IS NOT NULL  
DROP TABLE dbo.TempSysXMLTable;

DECLARE @DateBegin datetime = dateadd(YEAR, 2000, dateadd(day,-3,getdate()));
DECLARE @TestXML XML; 
set @TestXML =  (
SELECT
		RefPartners.[_Description] Description
		,RefPartnersDetailAddres.[_Fld2188] RegDate
		,RefPartnersDetailPhone.[_Fld2195] Adress
		,RefPartnersDetailEMail.[_Fld2193] Phone
		,RefPartners._Fld2151 EMAIL
  FROM [newbase2015].[dbo].[_Reference104] AS RefPartners
  Inner Join [newbase2015].[dbo].[_Reference104_VT2184] AS RefPartnersDetailAddres
  ON RefPartners._IDRRef = RefPartnersDetailAddres.[_Reference104_IDRRef]
  AND RefPartnersDetailAddres.[_Fld2186RRef] = 0xAE8167157822C4B643D29FDC57B31A5D
  
  Inner Join [newbase2015].[dbo].[_Reference104_VT2184] AS RefPartnersDetailPhone  
  ON RefPartnersDetailPhone.[_Reference104_IDRRef] = RefPartners._IDRRef
  AND RefPartnersDetailPhone.[_Fld2186RRef] =0xA873CB4AD71D17B2459F9A70D4E2DA66
  
  Inner Join [newbase2015].[dbo].[_Reference104_VT2184] AS RefPartnersDetailEMail
  ON RefPartnersDetailEMail.[_Reference104_IDRRef] = RefPartners._IDRRef
  AND RefPartnersDetailEMail.[_Fld2186RRef] =0x82E6D573EE35D0904BF4D326A84A91D2
  
  WHERE [_Description] <> ''
  AND RefPartners._Fld2151 >= @DateBegin
                FOR XML AUTO)

CREATE TABLE TempSysXMLTable
     (
       xCol XML
     ) ;
 
 INSERT  INTO TempSysXMLTable ( xCol )
         SELECT  @testXML
 
DECLARE @Command VARCHAR(255)
DECLARE @Filename VARCHAR(100)
 
SELECT  @Filename = 'D:\TEMP\SysXMLRoutine'
SELECT  @Command = 'bcp "select xCol from ' + DB_NAME() + '..TempSysyXMLTable" queryout ' + @Filename + ' -w -T -S' + @@servername
EXECUTE master..xp_cmdshell @command

EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = null,  
    @recipients = 'dangerdigger@yandex.ru',  
    @body = "System update info",  
    @body_format = 'HTML',
	@file_attachments =  @Filename,
    @subject = 'Automated Success Message';
END 