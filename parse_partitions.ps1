$path = 'C:\Users\Lucas Alves\Downloads\RKDevTool_Release_v2.86\RKDevTool_Release_v2.86\Output\ExportImage.img'
$bytes = [System.IO.File]::ReadAllBytes($path)

# 1. Search for 'PARM' or 'mtdparts' or 'CMDLINE'
$ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
$match = [regex]::Match($ascii, 'CMDLINE:.*?(?=\x00|$)')
if ($match.Success) {
    Write-Output "=== FOUND PARAMETER CMDLINE ==="
    Write-Output $match.Value
} else {
    Write-Output "No CMDLINE found in ASCII. Checking for GPT..."
}

# 2. Check GPT Header at offset 512
$sig = [System.Text.Encoding]::ASCII.GetString($bytes[512..519])
Write-Output ("LBA 1 Signature: " + $sig)
if ($sig -eq 'EFI PART') {
    Write-Output "=== FOUND GPT PARTITION TABLE! ==="
    $partEntryLBA = [BitConverter]::ToUInt64($bytes, 512 + 72)
    $numEntries = [BitConverter]::ToUInt32($bytes, 512 + 80)
    $entrySize = [BitConverter]::ToUInt32($bytes, 512 + 84)
    Write-Output ("Partitions: $numEntries (Entry size: $entrySize bytes at LBA $partEntryLBA)")
    
    $offset = [int]($partEntryLBA * 512)
    for ($i = 0; $i -lt $numEntries; $i++) {
        $entryOffset = $offset + ($i * $entrySize)
        $firstLBA = [BitConverter]::ToUInt64($bytes, $entryOffset + 32)
        $lastLBA = [BitConverter]::ToUInt64($bytes, $entryOffset + 40)
        if ($firstLBA -eq 0 -and $lastLBA -eq 0) { continue }
        
        $sectors = ($lastLBA - $firstLBA) + 1
        $sizeMB = ($sectors * 512) / 1024 / 1024
        
        $nameBytes = $bytes[($entryOffset + 56)..($entryOffset + 127)]
        $name = [System.Text.Encoding]::Unicode.GetString($nameBytes).Trim([char]0)
        
        $startHex = "0x" + $firstLBA.ToString("X8")
        $countHex = "0x" + $sectors.ToString("X8")
        Write-Output ("Partition $($i.ToString('D2')): Name=$($name.PadRight(15)) | Start=$($firstLBA.ToString().PadLeft(10)) ($startHex) | Count=$($sectors.ToString().PadLeft(10)) ($countHex) | Size=$([math]::Round($sizeMB, 2)) MB")
    }
}
