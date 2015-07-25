EXEC tSQLt.NewTestClass 'Private_ScriptIndexTests';
GO
CREATE PROCEDURE Private_ScriptIndexTests.[assert index is scripted correctly]
  @setup1 NVARCHAR(MAX) = 'CREATE TABLE Private_ScriptIndexTests.T1(C1 INT, C2 INT, C3 INT, C4 INT);',
  @index_create_cmd NVARCHAR(MAX),
  @setup2 NVARCHAR(MAX) = NULL,
  @object_name NVARCHAR(MAX) = '[Private_ScriptIndexTests].[T1]',
  @index_name NVARCHAR(MAX) = 'Private_ScriptIndexTests.T1 - IDX1'
AS
BEGIN
  EXEC(@setup1);
  EXEC(@index_create_cmd);
  EXEC(@setup2);

  DECLARE @ScriptedCmd NVARCHAR(MAX);
  SELECT @ScriptedCmd = create_cmd
    FROM tSQLt.Private_ScriptIndex(OBJECT_ID(@object_name),(SELECT index_id FROM sys.indexes AS I WHERE I.name = @index_name AND I.object_id = OBJECT_ID(@object_name)));

  EXEC tSQLt.AssertEqualsString @Expected = @index_create_cmd, @Actual = @ScriptedCmd;
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test scripts simple index]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test scripts simple multi column index]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC,[C2]ASC,[C3]ASC);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test handles ASC and DESC specifiers]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC,[C2]DESC,[C3]DESC);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test scripts correct index]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @setup1 = 'CREATE TABLE Private_ScriptIndexTests.T1(C1 INT, C2 INT, C3 INT, C4 INT);CREATE CLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC);',
    @index_create_cmd = 'CREATE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX2] ON [Private_ScriptIndexTests].[T1]([C2]DESC,[C3]DESC);',
    @setup2 = 'CREATE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX3] ON [Private_ScriptIndexTests].[T1]([C4]ASC);',
    @index_name = 'Private_ScriptIndexTests.T1 - IDX2';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test scripts index on correct table]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @setup1 = 'CREATE TABLE Private_ScriptIndexTests.T2(C2 INT);
               CREATE TABLE Private_ScriptIndexTests.T1(C1 INT);
               CREATE NONCLUSTERED INDEX [IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC);',
    @index_create_cmd = 'CREATE NONCLUSTERED INDEX [IDX1] ON [Private_ScriptIndexTests].[T2]([C2]ASC);',
    @object_name = 'Private_ScriptIndexTests.T2',
    @index_name = 'IDX1';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test handles odd names]
AS
BEGIN
  EXEC('CREATE SCHEMA [some space!];');
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @setup1 = 'CREATE TABLE [some space!].[a table]([a column]INT);',
    @index_create_cmd = 'CREATE NONCLUSTERED INDEX [some space! = a table - a column] ON [some space!].[a table]([a column]ASC);',
    @object_name = '[some space!].[a table]',
    @index_name = 'some space! = a table - a column';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test handles CLUSTERED indexes]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE CLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC,[C2]DESC);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test handles UNIQUE indexes]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE UNIQUE CLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC,[C2]DESC);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test uses key_ordinal for column order]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE UNIQUE CLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C3]ASC,[C1]ASC,[C2]DESC);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test handles included columns]
AS
BEGIN
  EXEC Private_ScriptIndexTests.[assert index is scripted correctly]
    @index_create_cmd = 'CREATE UNIQUE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC,[C3]DESC)INCLUDE([C4],[C2]);';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test scripts all indexes on (@index_id IS NULL)]
AS
BEGIN
  CREATE TABLE Private_ScriptIndexTests.T1(C1 INT, C2 INT, C3 INT, C4 INT);

  CREATE TABLE Private_ScriptIndexTests.Expected(create_cmd NVARCHAR(MAX));
  INSERT INTO Private_ScriptIndexTests.Expected
  VALUES('CREATE CLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX1] ON [Private_ScriptIndexTests].[T1]([C1]ASC,[C2]DESC);');
  INSERT INTO Private_ScriptIndexTests.Expected
  VALUES('CREATE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX2] ON [Private_ScriptIndexTests].[T1]([C2]ASC,[C3]DESC)INCLUDE([C4]);');
  INSERT INTO Private_ScriptIndexTests.Expected
  VALUES('CREATE UNIQUE NONCLUSTERED INDEX [Private_ScriptIndexTests.T1 - IDX3] ON [Private_ScriptIndexTests].[T1]([C3]ASC,[C1]DESC);');

  DECLARE @cmd NVARCHAR(MAX);
  SET @cmd = (SELECT create_cmd FROM Private_ScriptIndexTests.Expected FOR XML PATH(''),TYPE).value('.','NVARCHAR(MAX)');
  EXEC(@cmd);

  SELECT create_cmd
    INTO Private_ScriptIndexTests.Actual
    FROM tSQLt.Private_ScriptIndex(OBJECT_ID('[Private_ScriptIndexTests].[T1]'),NULL);

  EXEC tSQLt.AssertEqualsTable 'Private_ScriptIndexTests.Expected','Private_ScriptIndexTests.Actual';
END;
GO
CREATE PROCEDURE Private_ScriptIndexTests.[test exposes other important columns]
AS
BEGIN
  CREATE TABLE Private_ScriptIndexTests.T1
  (
    C1 INT,
    C2 INT,
    CONSTRAINT [Private_ScriptIndexTests.T1 - PK] PRIMARY KEY CLUSTERED (C1),
    CONSTRAINT [Private_ScriptIndexTests.T1 - UC1] UNIQUE NONCLUSTERED (C2)
  );
  CREATE INDEX [Private_ScriptIndexTests.T1 - IX1] ON Private_ScriptIndexTests.T1(C2,C1);
  ALTER INDEX [Private_ScriptIndexTests.T1 - IX1] ON Private_ScriptIndexTests.T1 DISABLE;
  
  SELECT PRSN.index_id, PRSN.index_name, PRSN.is_primary_key, PRSN.is_unique, PRSN.is_disabled
    INTO Private_ScriptIndexTests.Actual
    FROM tSQLt.Private_ScriptIndex(OBJECT_ID('Private_ScriptIndexTests.T1'),NULL) AS PRSN;

    SELECT TOP(0) *
    INTO Private_ScriptIndexTests.Expected
    FROM Private_ScriptIndexTests.Actual;
    
    INSERT INTO Private_ScriptIndexTests.Expected
    VALUES(1,'Private_ScriptIndexTests.T1 - PK',1,1,0);
    INSERT INTO Private_ScriptIndexTests.Expected
    VALUES(2,'Private_ScriptIndexTests.T1 - UC1',0,1,0);
    INSERT INTO Private_ScriptIndexTests.Expected
    VALUES(3,'Private_ScriptIndexTests.T1 - IX1',0,0,1);

    EXEC tSQLt.AssertEqualsTable 'Private_ScriptIndexTests.Expected','Private_ScriptIndexTests.Actual';
    
END;
GO
