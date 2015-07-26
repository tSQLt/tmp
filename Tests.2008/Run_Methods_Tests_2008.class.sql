EXEC tSQLt.NewTestClass 'Run_Methods_Tests_2008';
GO
--Valid JUnit XML Schema
--Source:https://raw.githubusercontent.com/windyroad/JUnit-Schema/master/JUnit.xsd
DECLARE @cmd NVARCHAR(MAX);SET @cmd = 
'<?xml version="1.0" encoding="UTF-8"?>

<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
	 elementFormDefault="qualified"
	 attributeFormDefault="unqualified">
	<xs:annotation>
		<xs:documentation xml:lang="en">JUnit test result schema for the Apache Ant JUnit and JUnitReport tasks
Copyright � 2011, Windy Road Technology Pty. Limited
The Apache Ant JUnit XML Schema is distributed under the terms of the Apache License Version 2.0 http://www.apache.org/licenses/
Permission to waive conditions of this license may be requested from Windy Road Support (http://windyroad.org/support).</xs:documentation>
	</xs:annotation>
	<xs:element name="testsuite" type="testsuite"/>
	<xs:simpleType name="ISO8601_DATETIME_PATTERN">
		<xs:restriction base="xs:dateTime">
			<xs:pattern value="[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}"/>
		</xs:restriction>
	</xs:simpleType>
	<xs:element name="testsuites">
		<xs:annotation>
			<xs:documentation xml:lang="en">Contains an aggregation of testsuite results</xs:documentation>
		</xs:annotation>
		<xs:complexType>
			<xs:sequence>
				<xs:element name="testsuite" minOccurs="0" maxOccurs="unbounded">
					<xs:complexType>
						<xs:complexContent>
							<xs:extension base="testsuite">
								<xs:attribute name="package" type="xs:token" use="required">
									<xs:annotation>
										<xs:documentation xml:lang="en">Derived from testsuite/@name in the non-aggregated documents</xs:documentation>
									</xs:annotation>
								</xs:attribute>
								<xs:attribute name="id" type="xs:int" use="required">
									<xs:annotation>
										<xs:documentation xml:lang="en">Starts at ''0'' for the first testsuite and is incremented by 1 for each following testsuite</xs:documentation>
									</xs:annotation>
								</xs:attribute>
							</xs:extension>
						</xs:complexContent>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
	<xs:complexType name="testsuite">
		<xs:annotation>
			<xs:documentation xml:lang="en">Contains the results of exexuting a testsuite</xs:documentation>
		</xs:annotation>
		<xs:sequence>
			<xs:element name="properties">
				<xs:annotation>
					<xs:documentation xml:lang="en">Properties (e.g., environment settings) set during test execution</xs:documentation>
				</xs:annotation>
				<xs:complexType>
					<xs:sequence>
						<xs:element name="property" minOccurs="0" maxOccurs="unbounded">
							<xs:complexType>
								<xs:attribute name="name" use="required">
									<xs:simpleType>
										<xs:restriction base="xs:token">
											<xs:minLength value="1"/>
										</xs:restriction>
									</xs:simpleType>
								</xs:attribute>
								<xs:attribute name="value" type="xs:string" use="required"/>
							</xs:complexType>
						</xs:element>
					</xs:sequence>
				</xs:complexType>
			</xs:element>
			<xs:element name="testcase" minOccurs="0" maxOccurs="unbounded">
				<xs:complexType>
					<xs:choice minOccurs="0">
						<xs:element name="error">
			<xs:annotation>
				<xs:documentation xml:lang="en">Indicates that the test errored.  An errored test is one that had an unanticipated problem. e.g., an unchecked throwable; or a problem with the implementation of the test. Contains as a text node relevant data for the error, e.g., a stack trace</xs:documentation>
			</xs:annotation>
							<xs:complexType>
								<xs:simpleContent>
									<xs:extension base="pre-string">
										<xs:attribute name="message" type="xs:string">
											<xs:annotation>
												<xs:documentation xml:lang="en">The error message. e.g., if a java exception is thrown, the return value of getMessage()</xs:documentation>
											</xs:annotation>
										</xs:attribute>
										<xs:attribute name="type" type="xs:string" use="required">
											<xs:annotation>
												<xs:documentation xml:lang="en">The type of error that occured. e.g., if a java execption is thrown the full class name of the exception.</xs:documentation>
											</xs:annotation>
										</xs:attribute>
									</xs:extension>
								</xs:simpleContent>
							</xs:complexType>
						</xs:element>
						<xs:element name="failure">
			<xs:annotation>
				<xs:documentation xml:lang="en">Indicates that the test failed. A failure is a test which the code has explicitly failed by using the mechanisms for that purpose. e.g., via an assertEquals. Contains as a text node relevant data for the failure, e.g., a stack trace</xs:documentation>
			</xs:annotation>
							<xs:complexType>
								<xs:simpleContent>
									<xs:extension base="pre-string">
										<xs:attribute name="message" type="xs:string">
											<xs:annotation>
												<xs:documentation xml:lang="en">The message specified in the assert</xs:documentation>
											</xs:annotation>
										</xs:attribute>
										<xs:attribute name="type" type="xs:string" use="required">
											<xs:annotation>
												<xs:documentation xml:lang="en">The type of the assert.</xs:documentation>
											</xs:annotation>
										</xs:attribute>
									</xs:extension>
								</xs:simpleContent>
							</xs:complexType>
						</xs:element>
					</xs:choice>
					<xs:attribute name="name" type="xs:token" use="required">
						<xs:annotation>
							<xs:documentation xml:lang="en">Name of the test method</xs:documentation>
						</xs:annotation>
					</xs:attribute>
					<xs:attribute name="classname" type="xs:token" use="required">
						<xs:annotation>
							<xs:documentation xml:lang="en">Full class name for the class the test method is in.</xs:documentation>
						</xs:annotation>
					</xs:attribute>
					<xs:attribute name="time" type="xs:decimal" use="required">
						<xs:annotation>
							<xs:documentation xml:lang="en">Time taken (in seconds) to execute the test</xs:documentation>
						</xs:annotation>
					</xs:attribute>
				</xs:complexType>
			</xs:element>
			<xs:element name="system-out">
				<xs:annotation>
					<xs:documentation xml:lang="en">Data that was written to standard out while the test was executed</xs:documentation>
				</xs:annotation>
				<xs:simpleType>
					<xs:restriction base="pre-string">
						<xs:whiteSpace value="preserve"/>
					</xs:restriction>
				</xs:simpleType>
			</xs:element>
			<xs:element name="system-err">
				<xs:annotation>
					<xs:documentation xml:lang="en">Data that was written to standard error while the test was executed</xs:documentation>
				</xs:annotation>
				<xs:simpleType>
					<xs:restriction base="pre-string">
						<xs:whiteSpace value="preserve"/>
					</xs:restriction>
				</xs:simpleType>
			</xs:element>
		</xs:sequence>
		<xs:attribute name="name" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">Full class name of the test for non-aggregated testsuite documents. Class name without the package for aggregated testsuites documents</xs:documentation>
			</xs:annotation>
			<xs:simpleType>
				<xs:restriction base="xs:token">
					<xs:minLength value="1"/>
				</xs:restriction>
			</xs:simpleType>
		</xs:attribute>
		<xs:attribute name="timestamp" type="ISO8601_DATETIME_PATTERN" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">when the test was executed. Timezone may not be specified.</xs:documentation>
			</xs:annotation>
		</xs:attribute>
		<xs:attribute name="hostname" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">Host on which the tests were executed. ''localhost'' should be used if the hostname cannot be determined.</xs:documentation>
			</xs:annotation>
			<xs:simpleType>
				<xs:restriction base="xs:token">
					<xs:minLength value="1"/>
				</xs:restriction>
			</xs:simpleType>
		</xs:attribute>
		<xs:attribute name="tests" type="xs:int" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">The total number of tests in the suite</xs:documentation>
			</xs:annotation>
		</xs:attribute>
		<xs:attribute name="failures" type="xs:int" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">The total number of tests in the suite that failed. A failure is a test which the code has explicitly failed by using the mechanisms for that purpose. e.g., via an assertEquals</xs:documentation>
			</xs:annotation>
		</xs:attribute>
		<xs:attribute name="errors" type="xs:int" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">The total number of tests in the suite that errorrd. An errored test is one that had an unanticipated problem. e.g., an unchecked throwable; or a problem with the implementation of the test.</xs:documentation>
			</xs:annotation>
		</xs:attribute>
		<xs:attribute name="time" type="xs:decimal" use="required">
			<xs:annotation>
				<xs:documentation xml:lang="en">Time taken (in seconds) to execute the tests in the suite</xs:documentation>
			</xs:annotation>
		</xs:attribute>
	</xs:complexType>
	<xs:simpleType name="pre-string">
		<xs:restriction base="xs:string">
			<xs:whiteSpace value="preserve"/>
		</xs:restriction>
	</xs:simpleType>
</xs:schema>';
SET @cmd = 'CREATE XML SCHEMA COLLECTION Run_Methods_Tests_2008.ValidJUnitXML AS '''+REPLACE(REPLACE(@cmd,'''',''''''),'�','(c)')+''';';
--EXEC(@cmd);
EXEC tSQLt.CaptureOutput @cmd;
GO
CREATE PROC Run_Methods_Tests_2008.[test XmlResultFormatter returns XML that validates against the JUnit specification]
AS
BEGIN
    EXEC tSQLt.FakeTable @TableName = 'tSQLt.TestResult';
    EXEC tSQLt.SpyProcedure 'tSQLt.Private_PrintXML';

    DELETE FROM tSQLt.TestResult;
    INSERT INTO tSQLt.TestResult (Class, TestCase, Result, TestStartTime, TestEndTime)
    VALUES ('MyTestClass1', 'testA', 'Failure', '2015-07-24T00:00:01.000', '2015-07-24T00:00:01.138');
    INSERT INTO tSQLt.TestResult (Class, TestCase, Result, TestStartTime, TestEndTime)
    VALUES ('MyTestClass1', 'testB', 'Success', '2015-07-24T00:00:02.000', '2015-07-24T00:00:02.633');
    INSERT INTO tSQLt.TestResult (Class, TestCase, Result, TestStartTime, TestEndTime)
    VALUES ('MyTestClass2', 'testC', 'Failure', '2015-07-24T00:00:01.111', '2015-07-24T20:31:24.758');
    INSERT INTO tSQLt.TestResult (Class, TestCase, Result, TestStartTime, TestEndTime)
    VALUES ('MyTestClass2', 'testD', 'Error', '2015-07-24T00:00:00.667', '2015-07-24T00:00:01.055');
    
    EXEC tSQLt.XmlResultFormatter;

    EXEC tSQLt.ExpectNoException;
    DECLARE @XML XML(Run_Methods_Tests_2008.ValidJUnitXML);
    SELECT @XML = CAST(Message AS XML) FROM tSQLt.Private_PrintXML_SpyProcedureLog;
   
END;
GO
CREATE PROCEDURE Run_Methods_Tests_2008.[test tSQLt.Private_InputBuffer does not produce output]
AS
BEGIN
  DECLARE @Actual NVARCHAR(MAX);SET @Actual = '<Something went wrong!>';

  EXEC tSQLt.CaptureOutput 'DECLARE @r NVARCHAR(MAX);EXEC tSQLt.Private_InputBuffer @r OUT;';

  SELECT @Actual  = COL.OutputText FROM tSQLt.CaptureOutputLog AS COL;
  
  EXEC tSQLt.AssertEqualsString @Expected = NULL, @Actual = @Actual;
END
GO
