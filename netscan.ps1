$ip = $(ipconfig | where {$_ -match 'IPv4.+\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' } | out-null; $Matches[1])

$oct0=([ipaddress] $ip).GetAddressBytes()[0]
$oct1=([ipaddress] $ip).GetAddressBytes()[1]
$oct2=([ipaddress] $ip).GetAddressBytes()[2]
$oct3=([ipaddress] $ip).GetAddressBytes()[3]

$ipcutup="$oct0 $oct1 $oct2 $oct3"
$ipcut="$oct0.$oct1.$oct2"
$ipaddresscut= "$oc0 $oc1 $oc2"
$sNet = 1..50
$all = $sNet.Count
$i = 1

$hosts = @()
$ips = @()

$sNet | ForEach-Object {
    if ((ping "$ipcut.$_" -n 1 -w 200 |Select-String 'ms'|Out-String).Trim() -gt 10) {
        $ips += "$ipcut.$_"
        $discoveredhost = (((arp -a).Trim() | Select-String "$ipcut.$_ ") | Out-String).Replace('dynamic','').Replace('-',':').Replace('           ', ' - ').Replace('          ', ' - ').Replace('         ', ' - ').Trim()        
        Write-Host "[+]" $discoveredhost "is up!"
        $hosts += $discoveredhost
    }
    if ($i -eq 50) {
        Write-Host "[*] Scanned 50 hosts."
    }
    elseif ($i -eq 100) {
        Write-Host "[*] Scanned 100 hosts."
    }
    elseif ($i -eq 150) {
        Write-Host "[*] Scanned 150 hosts."
    }
    elseif ($i -eq 200) {
        Write-Host "[*] Scanned 200 hosts."
    }
   $i++
}

$j = 0

Write-Host "[*] Scanned 255 hosts."
Write-Host "[*] Discovered hosts: "

$hosts | ForEach-Object {
    Write-Host " - " $hosts[$j]
    $j++
}

Write-Host "[*] Running portscan for discovered hosts..."

$ips | ForEach-Object {
    Write-Host "[*] Scanning open ports for $_..."
    for ($port = 1 ; $port -le 1024 ; $port++){    
        $TCPClient = New-Object Net.Sockets.TCPClient
        $isopen = $TCPClient.ConnectAsync("$_",$port).Wait(150)
        if ($isopen) {
            Write-Host "[+]Port $port is open on $_!"
        }
        $TCPClient.Dispose()
    }
}
