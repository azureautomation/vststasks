CREATE PROCEDURE [dbo].[sp_STANDARD_LOGGING_Select]
	@RequiresRestart bit = 0
AS

/*****************************************************************************************************
STANDARD_LOGGING SELECT

The following set of commands will SELECT Log Data from the STANDARD_LOGGING Table

INPUT:	REQUIRES RESTART
	Hardcoded in QIK Object Code

USAGE:	EXEC sp_STANDARD_LOGGING_Select 0

	OR

	EXEC sp_STANDARD_LOGGING_Select 1

OUTPUT: [LoggingID];[Requires_Restart];[Start_DateTime];[LastUpdate_DateTime];[End_DateTime];[Status];[Stage],
	[Runbook_Name];[JobID];[Custom_Field_01];[Custom_Field_02];[Custom_Field_03];[Custom_Field_04]

HISTORY

	Revision	Created By	Date		Comments
	--------------------------------------------------------
	0.1		Charles Joy	04/23/2009	Created.
	0.2		Charles Joy	04/27/2009	Updated - Added Get All Data Functionality.
	0.3		Charles Joy	06/01/2009	Updated - OIS_LOGGING to STANDARD_OIS_LOGGING 
	0.4		Charles Joy	11/01/2011	STANDARD_OIS_LOGGING to STANDARD_LOGGING
							OISLoggingID to LoggingID
							Policy to Runbook

*****************************************************************************************************/

BEGIN

SET NOCOUNT ON

IF @RequiresRestart = 1

SELECT
	convert(nvarchar(100),[LoggingID]) + ';' +
	convert(nvarchar(100),[Requires_Restart]) + ';' +
	convert(nchar(19),isnull([Start_DateTime],0),120) + ';' +
	convert(nchar(19),isnull([LastUpdate_DateTime],0),120) + ';' +
	convert(nchar(19),isnull([End_DateTime],0),120) + ';' +
	[Status] + ';' +
	[Stage] + ';' +
	[Runbook_Name] + ';' +
	[JobID] + ';' +
	[Custom_Field_01] + ';' +
	[Custom_Field_02] + ';' +
	[Custom_Field_03] + ';' +
	[Custom_Field_04]

FROM 
	[STANDARD_LOGGING]

WHERE
	[Requires_Restart] = @RequiresRestart

ELSE


SELECT
	convert(nvarchar(100),[LoggingID]) + ';' +
	convert(nvarchar(100),[Requires_Restart]) + ';' +
	convert(nchar(19),isnull([Start_DateTime],0),120) + ';' +
	convert(nchar(19),isnull([LastUpdate_DateTime],0),120) + ';' +
	convert(nchar(19),isnull([End_DateTime],0),120) + ';' +
	[Status] + ';' +
	[Stage] + ';' +
	[Runbook_Name] + ';' +
	[JobID] + ';' +
	[Custom_Field_01] + ';' +
	[Custom_Field_02] + ';' +
	[Custom_Field_03] + ';' +
	[Custom_Field_04]

FROM 
	[STANDARD_LOGGING]

END