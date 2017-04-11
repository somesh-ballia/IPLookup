IPLOOKUP STORAGE AUTOMATION UTILITY

;******************************************************************************;
Installation Information
;******************************************************************************;
No installer needed. Copy and paste the Folder to any desired place.

;******************************************************************************;
Prerequisites
;******************************************************************************;
Following prerequisites are required to run this utility

0) Utility is designed for windows server 2003 ONLY (ver. "5.2.3790")
1) Usernames and passwords for all the CPS should be same and should be entered in config file beforehand
2) Firewall on all cps should be OFF
3) IIS should be already installed on machine where this script is to be executed
4) I386 folder of Windows 2K3 should be directly accessible from the machine where script will be executed
5) HOST NAME of all the machines should be known
6) IP address of the FTP server machine should be known
7) Any FTP site should not be running on the machine
8) There should be NO spaces in any directory path or DUMP Folder name
9) Domain user names should not be used
10) Any other folder should not be shared on any one the machine with the name same as DUMP_FOLDER_NAME's value
11) FTP_BASE_PATH directory should not be present, script will create it by itself along with the folders requited for virtual directory.


;******************************************************************************;
Configuration Information
;******************************************************************************;

Location of Config.ini file should be in the script folder only
Details of the configuration file is described bellow

; [GENERAL]															
;ENABLE_SETUP_INSTALL = 1				= To enable or disable FTP server installation
;ENABLE_USER_FOLDER_CREATION=1				= To enable or disable dump folder creation and sharing
;ENABLE_FTP_SITE = 1					= To enable or disable FTP site creation
;USER_NAME = iplookup					= Common user name present on all machine(CPS)
;PASSWORD = iplookup					= Common password present on all machine(CPS)
;DUMP_FOLDER_NAME = CPS					= Common name of dump folder also the share name of dump folder
;I386_PATH = \\192.168.50.228\WS2K3\			= Shared Windows 2K3 I386 folder for FTP server installation

;[FTP_SITE]								
;CPS_NAME = CT-N0060					= HOST name of CPS where FTP server will be installed
;DUMP_FOLDER_PATH = D:\CPS0				= Dump folder path on this particular machine
;FTP_BASE_PATH = D:\IPLOOKUP\FTPBase			= FTP site base path, It will be base directory of FTP server
;FTP_SITE_NAME = IPLOOKUP_FTP				= Name of FTP site
;IPADDRESS = 192.168.129.136				= IP address of CPS where FTP server will be hosted
;OVERWRITE_DEFAULT_SITE = 1				= IF default site is already present then setting the value as 1 will delete the default site

;[CPS_INFO]
;NUMBER_OF_CPS = 2					= Number of CPS's other than the one where ftp server will be installed

;[CPS_0]						= Nomenclature should be like [CPS_<cps count from 0>]
;CPS_NAME = CT-D063					= HOST NAME of CPS
;DUMP_FOLDER_PATH = E:\CPS0				= Dump folder path on this particular machine

;[CPS_1]
;CPS_NAME = CT-D012
;DUMP_FOLDER_PATH = F:\CPS1

;******************************************************************************;
Execution Information
;******************************************************************************;
Make changes in the Config.ini file and execute IPLOOKUP_Master.vbs for complete installation
Or execute individual scripts for iis installation, folder creation, and ftp site creation

NOTE:- In some cases while installing FTP server you might get prompted for address of I386 folder. 
       Select the default choice to continue in that case and even after selecting the default choice 
       the wizard doesn’t continue then verify the accessibility of I386 folder from the machine where 
       this script is executed.


;******************************************************************************;
Logging Information
;******************************************************************************;
Error logs will be generated in the same folder where script is present
There are 2 log files
1) Log.txt contains all debug logs and notification logs
2) ProgressLog.txt contains the progress information of the script

;******************************************************************************;
Limitation
;******************************************************************************;

1) Creation of virtual directory is not supported in this script it has to be done manually
2) Any of the path names shall not contain spaces in between (paths with spaces is not supported by the api provided by Microsoft)
3) IIS server creation by command line provides access level to ftp site as logs only, the access level has to be modified to read write manually.
