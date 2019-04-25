--DROP table ALLFILENAMES
CREATE TABLE ALLFILENAMES(WHICHPATH VARCHAR(255) DEFAULT 'C:\DS6050\Processed\',WHICHFILE varchar(255));
--truncate tAble ALLFILENAMES;
declare @filename varchar(255),
            @path     varchar(255),
            @sql      varchar(8000),
            @cmd      varchar(1000)


    --get the list of files to process:
    SET @path = 'C:\DS6050\Processed\'
    SET @cmd = 'dir ' + @path + '* /b'
    INSERT INTO  ALLFILENAMES(WHICHFILE)
    EXEC Master..xp_cmdShell @cmd
--select * from ALLFILENAMES

    --cursor loop
	declare @filename1 varchar(255),
            @path1     varchar(255),
            @sql1      varchar(8000),
            @cmd1      varchar(1000)



    declare c1 cursor for SELECT WHICHPATH,WHICHFILE FROM ALLFILENAMES
    open c1
    fetch next from c1 into @path1,@filename1
    While @@fetch_status <> -1
      begin
	  print(@filename1)
      --bulk insert won't take a variable name, so make a sql and execute it instead:
       set @sql1 = 'BULK INSERT raw_data FROM ''' + @path1 + @filename1 + ''' '
           + '     WITH ( 
                   
                   FIELDTERMINATOR = '','', 
                   ROWTERMINATOR = ''0x0a'',
				   MAXERRORS = 1000000,
				   ERRORFILE = ''C:\DS6050\'+@filename1+'_error.list''
                ) '
    print @sql1
    exec (@sql1)

      fetch next from c1 into @path1,@filename1
      end
    close c1
    deallocate c1