/*****************************************************************************************************
DROP/CREATE STANDARD_LOGGING TABLE

The following set of commands will DROP then CREATE existing versions of the following Table:

	STANDARD_LOGGING

INPUT:	N/A

USAGE:	EXECUTE File Contents (within Orchestrator or MSSQL)

OUTPUT: N/A

HISTORY

	Revision	Created By	Date		Comments
	--------------------------------------------------------
	0.1		Charles Joy	04/23/2009	Created.
	0.2		Charles Joy	06/01/2009	Updated - OIS_LOGGING to STANDARD_OIS_LOGGING 
	0.3		Charles Joy	11/01/2011	STANDARD_OIS_LOGGING to STANDARD_LOGGING
							OISLoggingID to LoggingID
							Policy to Runbook

*****************************************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[STANDARD_LOGGING]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [STANDARD_LOGGING]


CREATE TABLE [STANDARD_LOGGING] (
	[LoggingID] [int] IDENTITY (1, 1) NOT NULL ,
	[Requires_Restart] [bit] NULL ,
	[Start_DateTime] [datetime] NULL ,
	[LastUpdate_DateTime] [datetime] NULL ,
	[End_DateTime] [datetime] NULL ,
	[Status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Stage] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Runbook_Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[JobID] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Custom_Field_01] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Custom_Field_02] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Custom_Field_03] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[Custom_Field_04] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]


