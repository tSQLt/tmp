IF OBJECT_ID('tSQLt.Private_SqlVersion') IS NOT NULL DROP FUNCTION tSQLt.Private_SqlVersion;
GO
---Build+
GO
CREATE FUNCTION tSQLt.Private_SqlVersion()
RETURNS TABLE
AS
RETURN
  SELECT CAST(SERVERPROPERTY('ProductVersion')AS NVARCHAR(128)) ProductVersion;
GO
---Build-
GO
