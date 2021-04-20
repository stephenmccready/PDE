SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

Create procedure [dbo].[ImportPDE] @path As varChar(128), @filename As varChar(128), @emailRecipient As varChar(128)
As

Begin

If OBJECT_ID('dbo.tbl_PDE_In') Is Not Null
	Drop Table [dbo].[tbl_PDE_In]

Create Table [dbo].[tbl_PDE_In] (col001 varchar(max))

Declare @BulkCmd As nvarChar(4000)
Set		@BulkCmd = "BULK INSERT tbl_PDE_In FROM '"+@path+@filename+"' WITH (ROWTERMINATOR = '0x0a')"

Exec	(@BulkCmd)

Insert	Into [dbo].[tbl_PDE]
Select	Distinct
		SubString(col001,1,3) As [RECORD ID]
,		SubString(col001,4,7) As [SEQUENCE NO]
,		SubString(col001,11,40) As [CLAIM CONTROL NUMBER]
,		SubString(col001,51,20) As [HEALTH INSURANCE CLAIM NUMBER (HICN)]
,		SubString(col001,71,20) As [CARDHOLDER ID]
,		SubString(col001,91,8) As [PATIENT DATE OF BIRTH (DOB)]
,		SubString(col001,99,1) As [PATIENT GENDER CODE]
,		SubString(col001,100,8) As [DATE OF SERVICE (DOS)]
,		SubString(col001,108,8) As [PAID DATE]
,		SubString(col001,116,12) As [PRESCRIPTION SERVICE REFERENCE NO]
,		SubString(col001,128,2) As [FILLER]
,		SubString(col001,130,19) As [PRODUCT SERVICE ID]
,		SubString(col001,149,2) As [SERVICE PROVIDER ID QUALIFIER]
,		SubString(col001,151,15) As [SERVICE PROVIDER ID]
,		SubString(col001,166,2) As [FILL NUMBER]
,		SubString(col001,168,1) As [DISPENSING STATUS]
,		SubString(col001,169,1) As [COMPOUND CODE]
,		SubString(col001,170,1) As [DISPENSE AS WRITTEN (DAW) PRODUCT SELECTION CODE]
,		Cast(SubString(col001,171,10)As INT)/1000 As [QUANTITY DISPENSED]
,		SubString(col001,181,2) As [FILLER01]
,		Cast(SubString(col001,183,3)As INT) As [DAYS SUPPLY]
,		SubString(col001,186,2) As [PRESCRIBER ID QUALIFIER]
,		SubString(col001,188,15) As [PRESCRIBER ID]
,		SubString(col001,203,1) As [DRUG COVERAGE STATUS CODE]
,		SubString(col001,204,1) As [ADJUSTMENT DELETION CODE]
,		SubString(col001,205,1) As [NON- STANDARD FORMAT CODE]
,		SubString(col001,206,1) As [PRICING EXCEPTION  CODE]
,		SubString(col001,207,1) As [CATASTROPHIC COVERAGE CODE]
,		fnCobol2Int(SubString(col001,208,8)) As [INGREDIENT COST PAID]
,		fnCobol2Int(SubString(col001,216,8)) As [DISPENSING FEE PAID]
,		fnCobol2Int(SubString(col001,224,8)) As [TOTAL AMOUNT ATTRIBUTED TO SALES TAX]
,		fnCobol2Int(SubString(col001,232,8)) As [GROSS DRUG COST BELOW OUT- OF-POCKET THRESHOLD (GDCB)]
,		fnCobol2Int(SubString(col001,240,8)) As [GROSS DRUG COST ABOVE OUT-OF-POCKET THRESHOLD (GDCA)]
,		fnCobol2Int(SubString(col001,248,8)) As [PATIENT PAY AMOUNT]
,		fnCobol2Int(SubString(col001,256,8)) As [OTHER TROOP AMOUNT]
,		fnCobol2Int(SubString(col001,264,8)) As [LOW INCOME COST SHARING SUBSIDYAMOUNT (LICS)]
,		fnCobol2Int(SubString(col001,272,8)) As [PATIENT LIABILITY REDUCTION DUE TO OTHER PAYER AMOUNT (PLRO)]
,		fnCobol2Int(SubString(col001,280,8)) As [COVERED D PLAN PAID AMOUNT (CPP)]
,		fnCobol2Int(SubString(col001,288,8)) As [NON COVERED PLAN PAID AMOUNT (NPP)]
,		fnCobol2Int(SubString(col001,296,8)) As [ESTIMATED REBATE AT POS]
,		fnCobol2Int(SubString(col001,304,8)) As [VACCINE ADMINISTRATION FEE]
,		SubString(col001,312,1) As [PRESCRIPTION ORIGIN CODE]
,		SubString(col001,313,8) As [DATE ORIGINAL CLAIM RECEIVED]
,		SubString(col001,321,26) As [CLAIM ADJUDICATION BEGAN TIMESTAMP]
,		fnCobol2Int(SubString(col001,347,9)) As [TOTAL GROSS COVERED DRUG COST ACCUMULATOR]
,		fnCobol2Int(SubString(col001,356,8)) As [TRUE OUT-OF-POCKET ACCUMULATOR]
,		SubString(col001,364,1) As [BRAND/GENERIC CODE]
,		SubString(col001,365,1) As [BEGINNING BENEFIT PHASE]
,		SubString(col001,366,1) As [ENDING BENEFIT PHASE]
,		fnCobol2Int(SubString(col001,367,8)) As [REPORTED GAP DISCOUNT]
,		SubString(col001,375,1) As [TIER]
,		SubString(col001,376,1) As [FORMULARY CODE]
,		SubString(col001,377,1) As [GAP DISCOUNT PLAN OVERRIDE CODE]
,		SubString(col001,378,2) As [Pharmacy Service Type]
,		SubString(col001,380,2) As [Patient Residence]
,		SubString(col001,382,2) As [Submission Clarification Code]
,		SubString(col001,384,1) As [Adjustment Reason Code Qualifier]
,		SubString(col001,385,12) As [Adjustment Reason Code]
,		SubString(col001,384,116) As [FILLER02]
,		@filename As PDE_FileName
,		GETDATE() As dateImported
,		' ' As RejectFlag
,		Null As RejectDate
From	[tbl_PDE_In]
Where	SubString(col001,1,3)='DET'	-- Detail Records Only

Declare @body As varChar(max), @kount As int
Set @kount=(Select COUNT(*) From [tbl_PDE_In])

	Set	@body='<style>table{font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;width:100%;border-collapse:collapse;}</style>'
	+Cast(@kount As varchar(10))+' records added to dbo.tbl_PDE<br /><br /> From file: '+@filename
	+'<br /><br /><br /><small>SQL Job: JobName [ImportPDE]</small>'

	-- Email the excel file
	EXEC msdb..sp_send_dbmail 
	@profile_name='YourMailProfile',
	@recipients=@emailRecipient,
	@subject='PDE File Import Completed',
	@body=@body,
	@body_format='HTML'

End
