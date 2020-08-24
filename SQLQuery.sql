CREATE TABLE emptb (					-- Table creation
	empid INT PRIMARY KEY NOT NULL,
	empname VARCHAR(30) NOT NULL,
	designation VARCHAR(25) NOT NULL,
	manid INT NOT NULL
);


SELECT * FROM emptb; -- Display the entire table 

-- Display hierarchy using recursion
CREATE PROCEDURE TraverseRecursive
@empid INTEGER
AS
   /* to change action on each vertex, change these lines */
   DECLARE @empname VARCHAR(30)
   SELECT @empname=(SELECT empname 
                    FROM emptb WHERE empid=@empid) 
   PRINT SPACE(@NESTLEVEL*2)+STR(@empid)+' '+@empname
   /* ****** */

   DECLARE subprojects CURSOR LOCAL FOR
      SELECT empid FROM emptb WHERE manid=@empid     

   OPEN subprojects
      FETCH NEXT FROM subprojects INTO @empid
      WHILE @@FETCH_STATUS=0 BEGIN
         EXEC TraverseRecursive @empid
         FETCH NEXT FROM subprojects INTO @empid
      END
   CLOSE subprojects
   DEALLOCATE subprojects

TraverseRecursive 1

--INSERT INTO TABLE IF GIVEN MANAGER ID EXISTS IN EMP ID COLUMN
PRINT 'Enter EMPLOYEE details in format EMPID, EMPNAME, DESIGNATION, MANAGERID in the EXEC statement below';

EXEC insert_empdup 100,emp100,'BU HEAD',41;

CREATE PROCEDURE insert_empdup @empid int, @empname nvarchar(30), @designation nvarchar(25), @manid int
AS
IF (SELECT empid FROM emptb WHERE empid=@manid) IS NOT NULL
INSERT INTO emptb VALUES (@empid,@empname,@designation,@manid)
ELSE
PRINT 'ERROR : EMP ID NOT EXISTS'


--Modify the employee name
PRINT 'ENTER EMPID ALONG WITH THE UPDATED EMPLOYEE NAME';
CREATE PROC mod_emp @empid int, @empupdate nvarchar(30)
AS
DECLARE @temp int
SET @temp=(SELECT COUNT (empname) FROM emptb WHERE empname=@empupdate)
IF @temp=0
BEGIN
UPDATE emptb
SET empname = @empupdate
WHERE empid = @empid;
END
ELSE
PRINT 'DUPLICATE NAME FOUND'


EXEC mod_emp 13,John;



--Move employee from one level to another
PRINT 'ENTER THE EMPLOYEE ID WHOSE LEVEL NEEDS TO BE CHANGED IN FORMAT empid, new managerid';
CREATE PROCEDURE mov_emp @empid int, @newmanid int
AS
UPDATE emptb
SET manid=@newmanid
WHERE empid=@empid;

EXEC mov_emp 9,6;

--Remove an employee at any level
PRINT 'ENTER THE EMPLOYEE ID to be deleted along with the EmpID under which descendants needs to be attached';
PRINT 'ENTER newmanid as 0 for default';
CREATE PROCEDURE del_emp_2 @empiddel int, @newmanid int
AS
IF @newmanid=0
GOTO defau;
ELSE
BEGIN
EXEC mov_emp @empiddel, @newmanid;		-- Moving the employee and its descendants 

defau:	DECLARE @temp int
		SET @temp = (SELECT manid FROM emptb WHERE empid=@empiddel);
		UPDATE emptb
		SET manid=@temp
		WHERE manid=@empiddel;

		DELETE FROM emptb WHERE empid=@empiddel;
END

EXEC del_emp_2 6,2;




