

#pobieranie pliku
$url ='https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLEXPR_x64_ENU.exe'
Invoke-WebRequest  -Uri $url -OutFile mssql.exe
#Wypakowanie pliku
./mssql.exe /q  
#poczekaj az sie wypakuje
Start-Sleep -Seconds 1
#przejście do folderu z plikiem instalacyjnym
cd mssql
#instalacja
./setup.exe /Q /IACCEPTSQLSERVERLICENSETERMS='true' /ACTION="install" /ADDCURRENTUSERASSQLADMIN='true' /FEATURES=SQL /INSTANCENAME=MSSQLSERVER2019 /SAPWD="Test123!" /SECURITYMODE=SQL   /TCPENABLED=1   /SQLSYSADMINACCOUNTS="BUILTIN\ADMINISTRATORS" /SQLCOLLATION="Polish_CI_AS" /BROWSERSVCSTARTUPTYPE=DISABLED 
