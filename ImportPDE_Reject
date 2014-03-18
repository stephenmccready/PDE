SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

Create procedure [dbo].[ImportPDE_Reject] @filename As varChar(128), @emailRecipient As varChar(128)
As

Begin
	
Declare @body As varChar(max), @kount As int
Set @kount=(Select COUNT(*) From [dbo].[tbl_PDE_Reject])

Declare @lastRow As Int

Declare @xp_cmd As Varchar(128)
Set @xp_cmd='type '+@filename

create table ##tempfile (line varchar(255) null)
insert ##tempfile exec master..xp_cmdshell @xp_cmd
Set @lastRow=(select count(*) as NumLines from ##tempfile)-16

Drop Table ##tempfile

Declare @BulkCmd As nvarChar(4000)
Set @BulkCmd = "BULK INSERT tbl_PDE_Reject FROM '"+@filename+"' WITH (FIRSTROW=2,LASTROW="+CAST(@lastRow As varchar(11))+",FIELDTERMINATOR=',',ROWTERMINATOR='"+CHAR(10)+"')"

Exec	(@BulkCmd)

Declare	@today As Datetime
Set @today=getdate()

Update	P
Set RejectFlag='R',RejectDate=@today
From	dbo.tbl_PDE As P
Join	dbo.tbl_PDE_Reject As X
		On P.[CLAIM CONTROL NUMBER]=X.[Claim #]
Where	P.RejectFlag=' '
And		P.DateImported > @today-4

Set @kount=(Select COUNT(*) From [dbo].[tbl_PDE_Reject])-@kount

	Set	@body='<style>table{font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;width:100%;border-collapse:collapse;}</style>'
	+Cast(@kount As varchar(10))+' records added to tbl_PDE_Reject<br /><br /> From file: '+@filename
	+'<br /><br /><br /><small>SQL Job: PDE_Reject_File_Import [ImportPDE_Reject]</small>'

	-- Email the excel file
	EXEC msdb..sp_send_dbmail 
	@profile_name='YourMailProfile',
	@recipients=@emailRecipient,
	@subject='PDE Reject File Import Completed',
	@body=@body,
	@body_format='HTML'

End
