#Skrypt zbierający dane z serwerów i tworzący plik html (stronę internetową) wyświetlającą informacje o serwerach.W pliku config znajdującym się w tym samym folderze powinny być umieszczane adresy gdzie znajdują się pliki json z informacjami o serwerze ( zużycie CPU,Ramu,dysku itp)
$head = " 
<meta http-equiv=`"refresh`" content=`"30`"/>
<style>
th,td{
  border: 1px solid black ;

}
table{

    border-collapse: collapse;
    width: 100%;
}

    </style>"
     Clear-Variable -Name lokalizacja
$info_adress
$lokalizacja = @{
'CPU' = $CPU
'Memory' = $Memory
'FreeRam' = $FreeRam
'disk_info' =$disk_info

}
   $x = @()
$PathToHtml = "C:\testy\index.html"

$ile_linii = (Get-Content .\config).Length


$adresy = @();
 $json_contents = @();
$zmienna = @();

for($i=1;$i -le $ile_linii;$i++){
if ($i -eq 1 ) {

$adresy +=Get-Content -Path ".\config" | Select-Object  -First $i 

}
else {

$adresy +=Get-Content -Path ".\config" | Select-Object -Skip ($i-1) -First 1


}
}
$uriTable = @();
$Header= "<meta http-equiv=`"refresh`" content=`"30`"/>"
$disk_info = @();
$indeks = 0
     $dlugosc_dysk_info = @();
     $x = @();
     $index1 = 1 
      $info_adress = ' '
     foreach($adres in $adresy){
   
     try{

$jsoneq = Invoke-WebRequest -URI $adres


}
catch{
     
     $info_adress += $adres.ToString() + "  niedostepny . To " + $index1 + " wiersz w tabeli i jest on błędny ,Tabela moze wyswietlac nieprawidłowe informację"

     
     
     
     
     }
       $index1++

     }
foreach($adres in $adresy){

$Procesy  = ' '

$PolaczonyString2 = ' '

$uriObject = New-Object PSObject
$json = Invoke-WebRequest -URI $adres
$json_contents = $json.Content | ConvertFrom-Json

$zmienna += $json.Content | ConvertFrom-Json


$dlugosc = $json_contents.Process.ProcessName.Length;
$dlugosc_dysk_info += $json_contents.DiskProperties.Length

$Polaczony_String2 = ' '
$Procesy  = ' '


for ($j = 0; $j -lt $dlugosc; $j++) { 
  $Polaczony_String2 +='<span>' + $json_contents.Process.ProcessName[$j] + '<span>'

  $Procesy += $Polaczony_String2
  }

if($json_contents.DiskProperties.Length -gt 1){

$PolaczonyString = ' '



for($i=0;$i -lt $json_contents.DiskProperties.Length ;$i++){


$PolaczonyString += '<span> '
$PolaczonyString += $json_contents.DiskProperties.DriveLetter[$i] + " ;   "
$PolaczonyString +=   $json_contents.DiskProperties.FileSystem[$i] + " ;   "
$PolaczonyString += $json_contents.DiskProperties.DriveType[$i]  + " ;  "
         $PolaczonyString += $json_contents.DiskProperties.HealthStatus[$i]  + " ;  "
          $PolaczonyString += $json_contents.DiskProperties.OperationalStatus[$i] + " ;   "
            $PolaczonyString += ($json_contents.DiskProperties.SizeRemaining[$i].ToString() +  " Remaining[GB]   ; ")
             $PolaczonyString +=($json_contents.DiskProperties.Size[$i].ToString()  + " Size[GB]  ;")
       $PolaczonyString += $json_contents.DiskProperties.Free[$i].ToString()  + " Free[%]  "
                         $PolaczonyString += "<br> "
                           

$PolaczonyString += '<span> '
}







}
else {
$PolaczonyString = ' '
$PolaczonyString += $json_contents.DiskProperties.DriveLetter + " ;   "
$PolaczonyString +=   $json_contents.DiskProperties.FileSystem + " ;   "
$PolaczonyString += $json_contents.DiskProperties.DriveType  + " ;  "
         $PolaczonyString += $json_contents.DiskProperties.HealthStatus  + " ;  "
          $PolaczonyString += $json_contents.DiskProperties.OperationalStatus + " ;   "
            $PolaczonyString += ($json_contents.DiskProperties.SizeRemaining.ToString() +  " Remaining[GB]   ; ")
             $PolaczonyString +=($json_contents.DiskProperties.Size.ToString()  + " Size[GB]  ;")
       $PolaczonyString += $json_contents.DiskProperties.Free.ToString()  + " Free[%]  "
                         $PolaczonyString +=  "<br> "
                             
} 

try{


      $uriObject | Add-Member  -MemberType NoteProperty -Name "ServerName" -Value  $json_contents.ServerName
   $uriObject | Add-Member  -MemberType NoteProperty -Name "Timestamp" -Value $json_contents.Timestamp 
$uriObject | Add-Member  -MemberType NoteProperty -Name "UpTime" -Value ($json_contents.UpTime +  " since " +  $json_contents.LastBootTime)
$uriObject | Add-Member  -MemberType NoteProperty -Name "CPUUsage" -Value  $json_contents.CPUUsageP
$uriObject | Add-Member  -MemberType NoteProperty -Name "Memory%" -Value  $json_contents.Memory
$uriObject | Add-Member  -MemberType NoteProperty -Name "FreeRam%" -Value  $json_contents.FreeramP
$uriObject | Add-Member  -MemberType NoteProperty -Name "FreeRamMb" -Value  $json_contents.FreeramMb
$uriObject | Add-Member  -MemberType NoteProperty -Name "TotalRam" -Value  $json_contents.TotalRam 
$uriObject | Add-Member  -MemberType NoteProperty -Name "Procesy" -Value  $Polaczony_String2
$uriObject | Add-Member  -MemberType NoteProperty -Name "Dysk" -Value  $indeks
$uriTable += $uriObject

  $disk_info += $PolaczonyString






$lokalizacja[$indeks] = @{

'CPU'= ("<td>" + $uriTable[$indeks].'CPUUsage'+ "</td>")
'Memory' = ("<td>" + $uriTable[$indeks].'Memory%'+ "</td>")
'FreeRam' =  ("<td>" + $uriTable[$indeks].'FreeRam%'+ "</td>")
'DiskInfo' =  ("<td>" + $uriTable[$indeks]."DiskInfo"+ "</td>")

}






}


catch{

Write-Host "Unable to reach " -ForegroundColor Red 
 }

 Clear-Variable -Name uriObject
 Clear-Variable -Name PolaczonyString
  Clear-Variable -Name PolaczonyString2
   
  $indeks++
} 



  function funkcja {
    param ($PSItem) 
     $yz = '&#39;&lt;br&gt;&#39;'
 $PSItem = $PSItem -replace $yz , '<br>'




 
   for($i = 0 ; $i -lt  $ile_linii;$i++) {
     
   $lok_dysk = "<td>$($i)</td>"
  

 if($null -eq $zmienna[$i].DiskProperties.Length){
 if(  ($zmienna[$i].DiskProperties.HealthStatus -ne 'Healthy') -or ($zmienna[$i].DiskProperties.OperationalStatus -ne 'OK') -or ($zmienna[$i].DiskProperties.SizeRemaining -lt 10) -or
($zmienna[$i].DiskProperties.Free -lt 5) ) {

$PSItem = $PSItem -replace $lok_dysk, "<td style='color:red  ; font-weight: bold; '>$($disk_info[$i])</td>"
}
else{


$PSItem = $PSItem -replace $lok_dysk, "<td >$($disk_info[$i])</td>"


}
 

}

else{
$allHealthy = $true
for($k=0;$k -lt $zmienna[$k].DiskProperties.Length;$k++){

if(  ($zmienna[$i].DiskProperties[$k].HealthStatus -ne 'Healthy') -or ($zmienna[$i].DiskProperties[$k].OperationalStatus -ne 'OK') -or ($zmienna[$i].DiskProperties[$k].SizeRemaining -lt 2) -or
($zmienna[$i].DiskProperties[$k].Free -lt 5) ) {

$allHealthy = $false

}


}

if(-not $allHealthy){
$PSItem = $PSItem -replace $lok_dysk, "<td style='color:red  ; font-weight: bold; '>$($disk_info[$i])</td>" 
}
else {
$PSItem = $PSItem -replace $lok_dysk, "<td >$($disk_info[$i])</td>"
}
}
 
  if( $uriTable[$i].'CPUUsage' -gt 90 ){
   
  $PSItem = $PSItem -replace $lokalizacja[$i].CPU, "<td style='color:red  ; font-weight: bold; '>$($uriTable[$i].'CPUUsage')</td>"}
 
         if( $uriTable[$i].'Memory%' -gt 90 ){$PSItem = $PSItem -replace $lokalizacja[$i].'Memory', "<td style='color:red  ; font-weight: bold; '>$($uriTable[$i].'Memory%')</td>"}
             
                  if( $uriTable[$i].'FreeRam%' -lt 10 ){$PSItem = $PSItem -replace $lokalizacja[$i].FreeRam, "<td style='color:red  ; font-weight: bold; '>$($uriTable[$i].'FreeRam%')</td>"}
                    for($j = 0 ;$j -lt $dlugosc_dysk_info[$i];$j++) {
                 
                 if(  ($zmienna[$i].DiskProperties[$j].HealthStatus -ne 'Healthy') -or ($zmienna[$i].DiskProperties[$j].OperationalStatus -ne 'OK') -or ($zmienna[$i].DiskProperties[$j].SizeRemaining[$j] ) -or
($zmienna[$i].DiskProperties[$j].Free -lt 5) )
{
$PSItem = $PSItem -replace $lok_dysk, "<td style='color:red  ; font-weight: bold; '>$($disk_info[$i])</td>"

}
else{ 
$PSItem = $PSItem -replace $lok_dysk, "<td>$($disk_info[$i])</td>"}
                  
            }
            
      
             
            $dlugosc = $zmienna[$i].Process.ProcessName.Length
           

            for ($j = 0; $j -lt $dlugosc; $j++) {
      $yz = '&lt;span&gt;'+ $($zmienna[$i].Process[$j].ProcessName) +'&lt;span&gt;';

  
                   if( $zmienna[$i].Process[$j].Status -eq 'Running' ){
        
     
         
         $PSItem = $PSItem -replace "<td>$($x[$i])</td>", "<td style='color:red  ; font-weight: bold; '>$($disk_info[$i])</td>"
                                     
         $PSItem = $PSItem -replace $yz, "<span style='color:green  ; font-weight: bold; '>$($zmienna[$i].Process[$j].ProcessName) </span>"
      

                      }
                   else{   
    

                          $PSItem = $PSItem -replace $yz, "<span style='color:red  ; font-weight: bold; '>$($zmienna[$i].Process[$j].ProcessName) </span>"
                   }
                    
                    
                     }      
                  

    
                
                }
    return $PSItem

}


$uriTable | ConvertTo-Html -Head $Head  -PostContent "<p>$($info_adress)<p><p>Data odświeżenia: $(Get-Date)<p> " |  ForEach-Object { funkcja $_ } |Out-File index.html
