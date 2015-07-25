
--> New Direction: Drop schema bound objects and offer option to recreate as needed.

EXEC tSQLt.NewTestClass 'Private_RemoveSchemaBindingTests_2008';
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
  @CreateViewStatement NVARCHAR(MAX)
AS
BEGIN
  CREATE TABLE Private_RemoveSchemaBindingTests_2008.T1(C1 INT);
  INSERT INTO Private_RemoveSchemaBindingTests_2008.T1(C1)
  VALUES(CHECKSUM(NEWID()));
  INSERT INTO Private_RemoveSchemaBindingTests_2008.T1(C1)
  VALUES(CHECKSUM(NEWID()));
  INSERT INTO Private_RemoveSchemaBindingTests_2008.T1(C1)
  VALUES(CHECKSUM(NEWID()));

  EXEC(@CreateViewStatement);
 
  DECLARE @object_id INT;SET @object_id = OBJECT_ID('Private_RemoveSchemaBindingTests_2008.V1');
  EXEC tSQLt.Private_RemoveSchemaBinding @object_id = @object_id;

  SELECT QUOTENAME(OBJECT_SCHEMA_NAME(SED.referencing_id))+'.'+QUOTENAME(OBJECT_NAME(SED.referencing_id)) AS schema_bound_object_name,SED.referencing_id,SED.referencing_class_desc
    INTO #SchemaBoundObjects
    FROM sys.sql_expression_dependencies AS SED 
   WHERE SED.is_schema_bound_reference = 1
     AND SED.referenced_id = OBJECT_ID('Private_RemoveSchemaBindingTests_2008.T1');

  EXEC tSQLt.AssertEmptyTable @TableName = '#SchemaBoundObjects';

  SELECT * 
    INTO Private_RemoveSchemaBindingTests_2008.Actual
    FROM Private_RemoveSchemaBindingTests_2008.V1;

  EXEC tSQLt.AssertEqualsTable 'Private_RemoveSchemaBindingTests_2008.T1','Private_RemoveSchemaBindingTests_2008.Actual';  
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test SB property on view is removed and view is still working]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    'CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test does not remove second W/SB statement]
AS
BEGIN
  CREATE TABLE Private_RemoveSchemaBindingTests_2008.T1(C1 INT);
  EXEC('CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1,''CREATE VIEW dbo.test WITH SCHEMABINDING'' AS C2 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;');
  INSERT INTO Private_RemoveSchemaBindingTests_2008.T1(C1)
  VALUES(42);
 
  DECLARE @object_id INT;SET @object_id = OBJECT_ID('Private_RemoveSchemaBindingTests_2008.V1');
  EXEC tSQLt.Private_RemoveSchemaBinding @object_id = @object_id;

  SELECT C1,C2
    INTO #Actual
    FROM Private_RemoveSchemaBindingTests_2008.V1;

  SELECT TOP(0) *
  INTO #Expected
  FROM #Actual;

  INSERT INTO #Expected
  VALUES(42,'CREATE VIEW dbo.test WITH SCHEMABINDING');
  
  EXEC tSQLt.AssertEqualsTable '#Expected','#Actual';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles leading spaces]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '   CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles newlines]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '
  CREATE 
  VIEW 
  Private_RemoveSchemaBindingTests_2008.V1 
  WITH 
  SCHEMABINDING 
  AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles leading one line comments]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '-- test 
        CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles leading one line comments with CREATE VIEW statement]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '-- test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        -- test2: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        --
        CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles leading multi-line comments with CREATE VIEW statement]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '/* test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        -- test2: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        */CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles leading double nested multi-line comments]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '/* test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        /* test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        */ test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        */CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test handles leading nested multi-line comments and other niceties with CREATE VIEW statement]
AS
BEGIN
  EXEC Private_RemoveSchemaBindingTests_2008.[Assert SB property on view is removed and view is still working]
    '/* /test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        /* /test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        /* /test: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        -- *test2: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        */-- *test2: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        */-- *test2: CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS 
        */--/*
        CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;';
END;
GO
CREATE PROCEDURE Private_RemoveSchemaBindingTests_2008.[test works on indexed view]
AS
BEGIN
  CREATE TABLE Private_RemoveSchemaBindingTests_2008.T1(C1 INT);
  EXEC('CREATE VIEW Private_RemoveSchemaBindingTests_2008.V1 WITH SCHEMABINDING AS SELECT T.C1,''A Constant'' AS C2 FROM Private_RemoveSchemaBindingTests_2008.T1 AS T;');
  EXEC('CREATE UNIQUE CLUSTERED INDEX [CI:V1] ON Private_RemoveSchemaBindingTests_2008.V1(C1);');
  EXEC('CREATE NONCLUSTERED INDEX [NCI:V1] ON Private_RemoveSchemaBindingTests_2008.V1(C2);');
  INSERT INTO Private_RemoveSchemaBindingTests_2008.T1(C1)
  VALUES(42);
 
  DECLARE @object_id INT;SET @object_id = OBJECT_ID('Private_RemoveSchemaBindingTests_2008.V1');
  EXEC tSQLt.Private_RemoveSchemaBinding @object_id = @object_id;

  SELECT C1,C2
    INTO #Actual
    FROM Private_RemoveSchemaBindingTests_2008.V1;

  SELECT TOP(0) *
  INTO #Expected
  FROM #Actual;

  INSERT INTO #Expected
  VALUES(42,'A Constant');
  
  EXEC tSQLt.AssertEqualsTable '#Expected','#Actual';
END;
GO


/*
-- Comments before create view including 
-- superflous whitespace (CREATE VIEW as well as WITH SCHEMABINDING)
-- indexed views
-- computed columns
-- indexed computed columns
-- other object types: (see remarks) http://msdn.microsoft.com/en-us/library/bb677315.aspx 


  SELECT * FROM sys.sql_expression_dependencies AS SED 
  JOIN sys.sql_modules AS SM
  ON SED.referencing_id = SM.object_id
  WHERE SED.referenced_id = OBJECT_ID('Private_RemoveSchemaBindingTests_2008.T1');


-- /*
-- PRINT 1;
-- --/*
-- PRINT 1;
-- /*
-- PRINT 1;
-- --*/
-- PRINT 1;
-- --*/
-- PRINT 1;
-- --*/
-- PRINT 1;





--*/