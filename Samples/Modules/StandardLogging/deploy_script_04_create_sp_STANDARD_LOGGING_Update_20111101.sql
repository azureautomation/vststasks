CREATE PROCEDURE [dbo].[sp_STANDARD_LOGGING_Update]
	@LoggingID int = 0,
	@Status nvarchar(50) = null,
	@Stage nvarchar(10) = null,
	@RunbookName nvarchar(200) = null,
	@JobID nvarchar(400) = null,
	@CustomField01 nvarchar(400) = null,
	@CustomField02 nvarchar(400) = null,
	@CustomField03 nvarchar(400) = null,
	@CustomField04 nvarchar(400) = null,
	@RequiresRestart bit = 0,
	@End bit = 0

AS

/*****************************************************************************************************
STANDARD_LOGGING UPDATE

The following set of commands will UPDATE Log Data in the STANDARD_LOGGING Table

INPUT:	ID, STAGE, RUNBOOKNAME, JOBID, CUSTOMFIELD01, CUSTOMFIELD02, CUSTOMFIELD03, CUSTOMFIELD04
	NOTE: ALL VALUES: '<From QIK Object User Input>'

	STATUS, END, REQUIRESRESTART
	Hardcoded in QIK Object Code

USAGE:	EXEC sp_STANDARD_LOGGING_Update 1, '1 - Success', '0.1', '0.1 Runbook Name', 'Job ID', 'Custom Data 01', 'Custom Data 02', 'Custom Data 03', 'Custom Data 04', 0, 0

	OR

	EXEC sp_STANDARD_LOGGING_Update 1, '1 - Warning', '0.1', '0.1 Runbook Name', 'Job ID', 'Custom Data 01', 'Custom Data 02', 'Custom Data 03', 'Custom Data 04', 0, 0

	OR
	
	EXEC sp_STANDARD_LOGGING_Update 1, '1 - Failure', '0.1', '0.1 Runbook Name', 'Job ID', 'Custom Data 01', 'Custom Data 02', 'Custom Data 03', 'Custom Data 04', 1, 0
	
	OR

	EXEC sp_STANDARD_LOGGING_Update 1, '1 - Completed', '0.1', '0.1 Runbook Name', 'Job ID', 'Custom Data 01', 'Custom Data 02', 'Custom Data 03', 'Custom Data 04', 0, 1

OUTPUT: [LoggingID];[Requires_Restart];[Start_DateTime];[LastUpdate_DateTime];[End_DateTime];[Status];[Stage],
	[Runbook_Name];[JobID];[Custom_Field_01];[Custom_Field_02];[Custom_Field_03];[Custom_Field_04]

HISTORY

	Revision	Created By	Date		Comments
	--------------------------------------------------------
	0.1		Charles Joy	04/23/2009	Created.
	0.2		Charles Joy	04/27/2009	Updated - Added '' Handling.
	0.3		Charles Joy	06/01/2008	Updated - @ID to @OISLoggingID
							Updated - OIS_LOGGING to STANDARD_OIS_LOGGING 
	0.4		Charles Joy	11/01/2011	STANDARD_OIS_LOGGING to STANDARD_LOGGING
							OISLoggingID to LoggingID
							Policy to Runbook

*****************************************************************************************************/

BEGIN

SET NOCOUNT ON

DECLARE @ExistingStage nvarchar(10),
	@ExistingRunbookName nvarchar(200),
	@ExistingJobID nvarchar(400),
	@ExistingCustomField01 nvarchar(400),
	@ExistingCustomField02 nvarchar(400),
	@ExistingCustomField03 nvarchar(400),
	@ExistingCustomField04 nvarchar(400),
	@BlankTest nvarchar(400)

SELECT @ExistingStage = [Stage] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID
SELECT @ExistingRunbookName = [Runbook_Name] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID
SELECT @ExistingJobID = [JobID] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID
SELECT @ExistingCustomField01 = [Custom_Field_01] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID
SELECT @ExistingCustomField02 = [Custom_Field_02] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID
SELECT @ExistingCustomField03 = [Custom_Field_03] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID
SELECT @ExistingCustomField04 = [Custom_Field_04] FROM [STANDARD_LOGGING] WHERE [LoggingID] = @LoggingID

IF @End = 0
BEGIN

UPDATE [STANDARD_LOGGING]

SET
	[Requires_Restart]	 = @RequiresRestart,
	[LastUpdate_DateTime]	 = current_timestamp,
	[Status]		 = @Status,
	[Stage]			 = CASE WHEN @Stage = '' THEN @ExistingStage ELSE ISNULL(@Stage,@ExistingStage) END,
	[Runbook_Name]		 = CASE WHEN @RunbookName = '' THEN @ExistingRunbookName ELSE ISNULL(@RunbookName,@ExistingRunbookName) END,
	[JobID]			 = CASE WHEN @JobID = '' THEN @ExistingJobID ELSE ISNULL(@JobID,@ExistingJobID) END,
	[Custom_Field_01]	 = CASE WHEN @CustomField01 = '' THEN @ExistingCustomField01 ELSE ISNULL(@CustomField01,@ExistingCustomField01) END,
	[Custom_Field_02]	 = CASE WHEN @CustomField02 = '' THEN @ExistingCustomField02 ELSE ISNULL(@CustomField02,@ExistingCustomField02) END,
	[Custom_Field_03]	 = CASE WHEN @CustomField03 = '' THEN @ExistingCustomField03 ELSE ISNULL(@CustomField03,@ExistingCustomField03) END,
	[Custom_Field_04]	 = CASE WHEN @CustomField04 = '' THEN @ExistingCustomField04 ELSE ISNULL(@CustomField04,@ExistingCustomField04) END

WHERE
	[LoggingID] = @LoggingID

END
ELSE IF @End = 1
BEGIN

UPDATE [STANDARD_LOGGING]

SET
	[Requires_Restart]	 = @RequiresRestart,
	[LastUpdate_DateTime]	 = current_timestamp,
	[End_DateTime]		 = current_timestamp,
	[Status]		 = @Status,
	[Stage]			 = CASE WHEN @Stage = '' THEN @ExistingStage ELSE ISNULL(@Stage,@ExistingStage) END,
	[Runbook_Name]		 = CASE WHEN @RunbookName = '' THEN @ExistingRunbookName ELSE ISNULL(@RunbookName,@ExistingRunbookName) END,
	[JobID]			 = CASE WHEN @JobID = '' THEN @ExistingJobID ELSE ISNULL(@JobID,@ExistingJobID) END,
	[Custom_Field_01]	 = CASE WHEN @CustomField01 = '' THEN @ExistingCustomField01 ELSE ISNULL(@CustomField01,@ExistingCustomField01) END,
	[Custom_Field_02]	 = CASE WHEN @CustomField02 = '' THEN @ExistingCustomField02 ELSE ISNULL(@CustomField02,@ExistingCustomField02) END,
	[Custom_Field_03]	 = CASE WHEN @CustomField03 = '' THEN @ExistingCustomField03 ELSE ISNULL(@CustomField03,@ExistingCustomField03) END,
	[Custom_Field_04]	 = CASE WHEN @CustomField04 = '' THEN @ExistingCustomField04 ELSE ISNULL(@CustomField04,@ExistingCustomField04) END


WHERE
	[LoggingID] = @LoggingID

END

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
	[LoggingID] = @LoggingID

END