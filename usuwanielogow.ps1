#Skrypt usuwający logi starsze niż
$directory = pwd

$dni = '7' # Tutaj wpisujemy liczbe  dni,tzn jak stare pliki maja… byc usuwane domyslna wartosc 7

#tutaj sa podawane sciezki z jakich katalogów maja byc usuwane pliki
$array_path = @(
   #przykladowe sciezki
   'C:\xyz\c'
'C:\Company\Logs'
'C:\Company\Messages\Logs'
)



New-Item -Path $directory -Name "usuwanielogow.ps1" -ItemType "file" 
foreach($sciezka in $array_path){
Add-Content -Path .\usuwanielogow.ps1 -Value ( 'Get-Childitem '+ "'" + $sciezka + "'"+' | Where-Object {$_.LastWriteTime -lt   (Get-Date).AddDays(-' + $dni  +')} | Remove-Item -Include *.log,*txt -Verbose ')
}
 $trigger = New-JobTrigger -Daily -At "11:50 PM" 
$action = New-ScheduledTaskAction -Execute "PowerShell" -Argument " -ExecutionPolicy Bypass $directory\usuwanielogow.ps1   "
 Register-ScheduledTask  'usuwanielogow3'  -Trigger $trigger -Action $action -User "$env:USERDOMAIN\$env:USERNAME" -Password "test123"
 