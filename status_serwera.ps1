cd C:\inetpub\wwwroot\healthcheck




#& "$PSScriptRoot/check-health.ps1"
function TimeSpanAsString([TimeSpan]$uptime)
{
	[int]$days = $uptime.Days
	[int]$hours = $days * 24 + $uptime.Hours
	if ($days -gt 2) {
		return "$days days"
	} elseif ($hours -gt 1) {
		return "$hours hours"
	} else {
		return "$($uptime.Minutes)min"
	}
}

	[system.threading.thread]::currentthread.currentculture = [system.globalization.cultureinfo]"en-US"
	if ($IsLinux) {
		$lastBootTime = (Get-Uptime -since)
		$uptime = (Get-Uptime)
	} else {
		$lastBootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime 
		$uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)
	}
#$uptime_info = " $(hostname) is up for $(TimeSpanAsString $uptime) since $($lastBootTime.ToShortDateString())"

$free_ram = (Get-WmiObject -Class Win32_OperatingSystem | % FreePhysicalMemory)/1024

$ram_total = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1mb

$cputotal =  Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Processor |Where-Object { $_.Name -eq "_Total" } |  Select-Object -ExpandProperty PercentProcessorTime

$cpu_total_other = Get-CimInstance win32_processor | Measure-Object -Property LoadPercentage -Average |Select-Object Average;Start-Sleep -Seconds 4
 
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss";
  
  $memory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property @{Name = "MemoryUsage(%)"; Expression = { [math]::Round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize * 100, 2) } }
     
     $processes = (Get-Process -Name "IpcService","IpcStatusService","Intelix.ApplicationPack.IxMetaService","IpcReservationService")
    
    $processesData = foreach ($process in $processes) {
        
        $processName = $process.Name
        
        $cpuUsage = $process.CPU
        
        $memoryUsage = (($process.WorkingSet)/1Mb)
        
        $virtualMemory = (($process.VirtualMemorySize)/1Mb)
        
        $handles = $process.Handles

        [PSCustomObject]@{
             
           
             ProcessName = $processName
            CPUUsage = $cpuUsage
            'MemoryUsage[Mb]' = $memoryUsage
            'VirtualMemory[Mb]' = $virtualMemory
            Handles = $handles }
            }
         
    $usageData = @(
     [pscustomobject]@{'Timestamp[%]'=$timestamp; 
     'CpuUsageTotalOther'=$cputotal;
     'CPUUsageTotal[%]'=
     $cpu_total_other.Average;
        'MemoryUsage[%]'=$memory.'MemoryUsage(%)';
        'TotalRam[Mb]'=$ram_total;
        'FreeRam[Mb]'=$free_ram;
            }
            )
   
  

       $dyski = (Get-Volume  |  Where-Object {  $_.DriveType -eq 'Fixed' -and $_.DriveLetter -notlike "" })
       #$dyski = (Get-Volume  | Where-Object { $_.DriveLetter -notlike "" })
$drive_data = foreach ($dysk in $dyski) {

$drive_letter= $dysk.DriveLetter
$system_plikow = $dysk.FileSystem
$typ_dysku = $dysk.DriveType
$stan_dysku = $dysk.HealthStatus
$operacyjny_status = $dysk.OperationalStatus
$Size_remaining = $dysk.SizeRemaining/1Gb
$Size  = $dysk.Size/1Gb

$Free = $Size_remaining/$Size 


 [PSCustomObject]@{
          'DriveLetter' = $drive_letter;
'FileSystem' = $system_plikow;
'DriveType' = $typ_dysku;
'HealthStatus' = $stan_dysku;
'OperationalStatus' = $operacyjny_status;
'SizeReamining' = $Size_remaining.ToString('F2')
'Size'=$Size.ToString('F2')
'Free' = $Free.ToString('P');
           
                     }
}

$info = @{
	
		 'ServerName' = $(hostname)
'UpTime' = $(TimeSpanAsString $uptime)
'LastBootTime' =$($lastBootTime.ToShortDateString())
	'CPU Usage[%]' = "$cpu_total_other"
	'CPU Usage[Other]' = "$cputotal"
	'Free ram  [%]' =  $memory
'Free ram  [Mb]' =  $free_ram
		'Total Ram' = "$ram_total"
		'Process'= $processesData
		
         'DiskProperties' = $drive_data
	
	
}

$info_other = @{
	
	 'ServerName' = $(hostname)
'UpTime' = $(TimeSpanAsString $uptime)
'Last Boot Time' =$($lastBootTime.ToShortDateString())
	'CPU Usage[%]' = $cpu_total_other
	'CPU Usage[Other]' = $cputotal
	'Free ram  [%]' =  $memory
'Free ram  [Mb]' =  $free_ram
		'Total Ram' = $ram_total
		'Process'= $processesData
		'DiskProperties' = $drive_data
	
	
}


#& "$PSScriptRoot/check-health.ps1"
function TimeSpanAsString([TimeSpan]$uptime)
{
	[int]$days = $uptime.Days
	[int]$hours = $days * 24 + $uptime.Hours
	if ($days -gt 2) {
		return "$days days"
	} elseif ($hours -gt 1) {
		return "$hours hours"
	} else {
		return "$($uptime.Minutes)min"
	}
}

	[system.threading.thread]::currentthread.currentculture = [system.globalization.cultureinfo]"en-US"
	if ($IsLinux) {
		$lastBootTime = (Get-Uptime -since)
		$uptime = (Get-Uptime)
	} else {
		$lastBootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime 
		$uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)
	}
#$uptime_info = " $(hostname) is up for $(TimeSpanAsString $uptime) since $($lastBootTime.ToShortDateString())"

$free_ram = (Get-WmiObject -Class Win32_OperatingSystem | % FreePhysicalMemory)/1024

$ram_total = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1mb

$cputotal =  Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Processor |Where-Object { $_.Name -eq "_Total" } |  Select-Object -ExpandProperty PercentProcessorTime

$cpu_total_other = Get-CimInstance win32_processor | Measure-Object -Property LoadPercentage -Average |Select-Object Average;Start-Sleep -Seconds 4
 
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss";
  
  $memory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property @{Name = "MemoryUsage(%)"; Expression = { [math]::Round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize * 100, 2) } }
     
     $processes = (Get-Process -Name "IpcService","IpcStatusService","Intelix.ApplicationPack.IxMetaService","IpcReservationService")
    
    $processesData = foreach ($process in $processes) {

    $Id_procesu = $process.Id
        

        $servicename = (Get-WmiObject Win32_Service | Where-Object { $_.ProcessId -eq $Id_procesu }).Name
$info_process = get-service -Name $servicename




$processName = $servicename
        
       


        #$processName = $process.Name
        
        #$cpuUsage = $process.CPU
        
        $memoryUsage = (($process.WorkingSet)/1Mb)
        
        $virtualMemory = (($process.VirtualMemorySize)/1Mb)
        
        $handles = $process.Handles

        [PSCustomObject]@{
             
           
             ProcessName = $servicename 
        Status =  $info_process.Status.ToString()
            CPUUsage = $cpuUsage
            'MemoryUsage[Mb]' = $memoryUsage
            'VirtualMemory[Mb]' = $virtualMemory
            Handles = $handles }
            }
         
    $usageData = @(
     [pscustomobject]@{'Timestamp[%]'=$timestamp; 
     'CpuUsageTotalOther'=$cputotal;
     'CPUUsageTotal[%]'=
     $cpu_total_other.Average;
        'MemoryUsage[%]'=$memory.'MemoryUsage(%)';
        'TotalRam[Mb]'=$ram_total;
        'FreeRam[Mb]'=[Math]::Round($free_ram,2);
            }
            )
   
  

       $dyski = (Get-Volume  | Where-Object {  $_.DriveType -eq 'Fixed' -and $_.DriveLetter -notlike "" })
       #$dyski = (Get-Volume  | Where-Object { $_.DriveLetter -notlike "" })
$drive_data = foreach ($dysk in $dyski) {

$drive_letter= $dysk.DriveLetter
$system_plikow = $dysk.FileSystem
$typ_dysku = $dysk.DriveType
$stan_dysku = $dysk.HealthStatus
$operacyjny_status = $dysk.OperationalStatus
$Size_remaining = $dysk.SizeRemaining/1Gb
$Size  = $dysk.Size/1Gb

$Free = $Size_remaining/$Size 


 [PSCustomObject]@{
          'DriveLetter' = $drive_letter;
'FileSystem' = $system_plikow;
'DriveType' = $typ_dysku;
'HealthStatus' = $stan_dysku;
'OperationalStatus' = $operacyjny_status;
'SizeRemaining' = ([Math]::Round($Size_remaining, 2));
'Size'=[Math]::Round($Size, 2);
'Free' =[Math]::Round(($Free*100), 2);
           
                     }
}

$info = @{
	
		 'ServerName' = $(hostname)
'UpTime' = $(TimeSpanAsString $uptime)
'LastBootTime' =$($lastBootTime.ToShortDateString())
	'CPU Usage[%]' = "$cpu_total_other"
	'CPU Usage[Other]' = "$cputotal"
	'Free ram  [%]' =  $memory
'Free ram  [Mb]' =  [Math]::Round($free_ram, 2)
		'Total Ram' = "$ram_total"
		'Process'= $processesData
		
         'DiskProperties' = $drive_data
	
	
}
$freeramMb =  [Math]::Round($free_ram, 2)
  $memory = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -Property @{Name = "MemoryUsage(%)"; Expression = { [math]::Round(($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize * 100, 2) } }
$info_other = [PSCustomObject]@{
	
	'Timestamp' = $timestamp
	 'ServerName' = $(hostname)
'UpTime' = $(TimeSpanAsString $uptime)
'LastBootTime' =$($lastBootTime.ToShortDateString())
	'CPUUsageP' = [Math]::Round($cpu_total_other.Average, 2)
#	'CPUUsageOther' = $cputotal
	'Memory' =  $memory.'MemoryUsage(%)'
	'FreeramP' =  ([Math]::Round(($freeramMb)/$ram_total, 2)*100)
'FreeramMb' =  $freeramMb
		'TotalRam' = $ram_total
		'Process'= $processesData
		'DiskProperties' = $drive_data
	
	
}
$pliknazwa = $(hostname) + '.json'


ConvertTo-Json -InputObject $info_other -Depth 3 | Out-File $pliknazwa -Encoding Ascii
