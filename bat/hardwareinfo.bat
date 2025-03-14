@echo off
echo Hardware Information Report
echo ===========================

echo CPU Information:
wmic cpu get name, manufacturer, numberofcores, numberoflogicalprocessors 

echo Memory Information:
wmic memorychip get Manufacturer, SerialNumber, PartNumber,banklabel, capacity, speed, memorytype 

echo Disk Drive Information:
wmic diskdrive get model, size, mediatype, interfacetype, status 

echo NIC Information:
wmic NIC get name, Manufacturer, ProductName, Speed 

echo Network Adapter Information:
wmic path win32_networkadapter where "physicaladapter=true" get name, product, manufacturer, macaddress, status 

echo Graphics Card Information:
wmic path win32_videocontroller get name, driverversion, videomodeDescription, status 

echo Motherboard Information:
wmic baseboard get product, manufacturer, version, SerialNumber, status 

echo BIOS Information:
wmic bios get smbiosbiosversion, manufacturer, name, version, SerialNumber, status 

echo Sound Device Information:
wmic sounddev get name, manufacturer, StatusInfo
