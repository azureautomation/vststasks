/*****************************************************************************************************
DROP STANDARD LOGGING STORED PROCEDURES

The following set of commands will DROP existing versions of the following Stored Procedures:

	sp_STANDARD_LOGGING_Insert
	sp_STANDARD_LOGGING_Update
	sp_STANDARD_LOGGING_Select

INPUT:	N/A

USAGE:	EXECUTE File Contents (within or MSSQL)

OUTPUT: N/A

HISTORY

	Revision	Created By	Date		Comments
	--------------------------------------------------------
	0.1		Charles Joy	04/23/2009	Created.
	0.2		Charles Joy	06/01/2009	OIS_LOGGING to STANDARD_OIS_LOGGING
	0.3		Charles Joy	11/01/2011	STANDARD_OIS_LOGGING to STANDARD_LOGGING

*****************************************************************************************************/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_STANDARD_LOGGING_Insert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_STANDARD_LOGGING_Insert]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_STANDARD_LOGGING_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_STANDARD_LOGGING_Update]

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_STANDARD_LOGGING_Select]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_STANDARD_LOGGING_Select]