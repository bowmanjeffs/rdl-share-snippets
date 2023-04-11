@echo off

set day=7
echo >"%temp%\%~n0.vbs" s=DateAdd("d",%day%,now) : d=weekday(s)
echo>>"%temp%\%~n0.vbs" WScript.Echo year(s)^& right(100+month(s),2)^& right(100+day(s),2)
for /f %%a in ('cscript /nologo "%temp%\%~n0.vbs"') do set "result=%%a"
del "%temp%\%~n0.vbs"
set "YYYY=%result:~0,4%"
set "MM=%result:~4,2%"
set "DD=%result:~6,2%"
set "expiredate=%yyyy%-%mm%-%dd%"

echo %d%"

set apitoken=youneedatoken
set endpoint=https://rdl-share.ucsd.edu/attachments

echo %apitoken%

if "%~1"=="" goto blank

echo %1%
for %%F in (%1) do set filename=%%~nxF
echo %filename%

for /f "tokens=* delims=" %%i in ('C:\programdata\chocolatey\bin\curl.exe -X POST --user "%apitoken%:x" -H "Accept: application/json" -H "Content-Type: application/json" --data-binary @%1 "https://rdl-share.ucsd.edu/attachments/binary_upload?filename=%filename%"') do set attachmentjson=%%i

echo %attachmentjson%
for /f "tokens=3 delims=:" %%a in ("%attachmentjson%") do set iditem=%%a
echo %iditem%
for /f "tokens=1 delims=," %%b in ("%iditem%") do set attachmentid=%%b
set attachmentid=%attachmentid:"=%
echo %attachmentid%

del message.json

echo {"message":> message.json
echo  {>> message.json
echo   "recipients":["someemail@ucsd.edu"],>> message.json
echo   "subject":"File Upload",>> message.json
echo   "message":"File Upload",>> message.json
echo   "expires_at":"%expiredate%",>> message.json
echo   "send_email":false,>> message.json
echo   "authorization":3,>> message.json
echo   "attachments":["%attachmentid%"]>> message.json
echo  }>> message.json
echo }>> message.json

for /f "tokens=* delims=" %%i in ('C:\programdata\chocolatey\bin\curl.exe --insecure -X POST --user "%apitoken%:x" -H "Accept: application/json" -H "Content-Type: application/json" --data @message.json "https://rdl-share.ucsd.edu/message"') do set messageid=%%i

echo %messageid%

del message.json

goto done

:blank

echo "Please supply a filename or path."

:done
