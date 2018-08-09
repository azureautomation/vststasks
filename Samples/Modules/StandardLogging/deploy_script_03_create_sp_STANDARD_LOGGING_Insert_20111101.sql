CREATE PROCEDURE [dbo].[sp_STANDARD_LOGGING_Insert]
	@Status nvarchar(50) = null,
	@Stage nvarchar(10) = null,
	@RunbookName nvarchar(200) = null,
	@JobID nvarchar(400) = null,
	@CustomField01 nvarchar(400) = null,
	@CustomField02 nvarchar(400) = null,
	@CustomField03 nvarchar(400) = null,
	@CustomField04 nvarchar(400) = null

AS

/*****************************************************************************************************
STANDARD_LOGGING INSERT

The following set of commands will INSERT Log Data into the STANDARD_LOGGING Table

INPUT:	STAGE, RUNBOOKNAME, JOBID, CUSTOMFIELD01, CUSTOMFIELD02, CUSTOMFIELD03, CUSTOMFIELD04

	NOTE: ALL VALUES: '<From QIK Object User Input>' 

USAGE:	EXEC sp_STANDARD_LOGGING_Insert '0 - Start', '0.1', '0.1 Runbook Name', 'Job ID', 'Custom Data 01', 'Custom Data 02', 'Custom Data 03', 'Custom Data 04'

OUTPUT: [LoggingID];[Requires_Restart];[Start_DateTime];[LastUpdate_DateTime];[End_DateTime];[Status];[Stage],
	[Runbook_Name];[JobID];[Custom_Field_01];[Custom_Field_02];[Custom_Field_03];[Custom_Field_04]

HISTORY

	Revision	Created By	Date		Comments
	--------------------------------------------------------
	0.1		Charles Joy	04/23/2009	Created.
	0.2		Charles Joy	06/01/2009	OIS_LOGGING to STANDARD_OIS_LOGGING
	0.3		Charles Joy	11/01/2011	STANDARD_OIS_LOGGING to STANDARD_LOGGING
							OISLoggingID to LoggingID
							Policy to Runbook

*****************************************************************************************************/

BEGIN

SET NOCOUNT ON

DECLARE @ID int

INSERT INTO [STANDARD_LOGGING]
	(
		[Requires_Restart],
		[Start_DateTime],
		[LastUpdate_DateTime],
		[Status],
		[Stage],
		[Runbook_Name],
		[JobID],
		[Custom_Field_01],
		[Custom_Field_02],
		[Custom_Field_03],
		[Custom_Field_04]
	)
VALUES
	(
		0,
		current_timestamp,
		current_timestamp,
		@Status,
		@Stage,
		@RunbookName,
		@JobID,
		@CustomField01,
		@CustomField02,
		@CustomField03,
		@CustomField04
	)

SET @ID = SCOPE_IDENTITY()

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
	[Custom_Field_04]  as [LogData]

FROM 
	[STANDARD_LOGGING]

WHERE
	[LoggingID] = @ID

END