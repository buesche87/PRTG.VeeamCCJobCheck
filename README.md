# PRTG.VeeamCCJobCheck

This is a PRTG Sensor that checks all acive Tenants in Veeam Cloud Connect

The XML part is meant to be scheduled on the host where executed the script creates a PRTG formatted XML-file in ```C:\Temp\VeeamResults```

## Scheduled task

Execute

```powerhsell.exe```

Parameter

```-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Script\VeeamCCJobCheck-XML.ps1"```

## PRTG-Sensor

This script opens a PS-Drive, retrieves the content of the xml and imports it to PRTG.

The PRTG-Part is copied to the EXEXML folder in the PRTG installation directory under Custom Sensors. 

On the PRTG Webinterface create a new exe/script advanced sensor with the following parameters

```-HostName '%host' -JobName 'Jobname' -UserName '%windowsdomain\%windowsuser' -Password '%windowspassword'```
