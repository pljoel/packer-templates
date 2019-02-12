@REM https://docs.microsoft.com/en-us/windows/desktop/msi/command-line-options
@REM https://docs.vmware.com/en/VMware-Tools/10.3.0/com.vmware.vsphere.vmwaretools.doc/GUID-E45C572D-6448-410F-BFA2-F729F2CDA8AC.html
@REM setup64.exe /S /v "/qn REBOOT=R ADDLOCAL=ALL REMOVE=Hgfs,Sync,Audio,Unity,PerfMon,WYSE,BootCamp,Debug,ThinPrint"
@REM /l <logfile> - Where to output the logfile
@REM /S – Silent, non-GUI installation
@REM /v  – pass parameters directly to MSI
@REM REBOOT=R – ReallySuppress the server reboot. Note The installer may indicate if a reboot is necessary by exiting with ERROR_SUCCESS_REBOOT_REQUIRED.
@REM ADDLOCAL=ALL – Install all components locally
@REM REMOVE=component(s) – Component or components (separated by comma) that will NOT be installed / excluded
e:\setup64 /s /v "/qn REBOOT=R"
