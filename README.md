PDE
===

CMS Prescription Drug Event file processing<br />
<i>Developed in MS SQL</i>

<b>ImportPDE</b><br />
Imports the detail records from the PDE submission file into a SQL table. (<i>requires function nCobol2Int</i>)

<b>fnCobol2Int</b><br />
Converts the PDE amount format (olde COBOL format!) to integer

<b>SQLCreate_tbl_PDE_Edit</b><br />
Creates and populates the PDE edit table

<b>ImportPDE_Reject</b><br />
Imports a PDE reject file, updates the PDE reject flag in tbl_PDE and sends an email containing a spreadsheet with the reject errors
