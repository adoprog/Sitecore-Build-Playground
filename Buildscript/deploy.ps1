Clear-Host

# Framework initialization
$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
$env:PSModulePath = $env:PSModulePath + ";$scriptRoot\Tools\PowerCore\Framework"

Import-Module WebUtils
Import-Module ConfigUtils
Import-Module DBUtils
Import-Module IISUtils
Import-Module FileUtils

# Main variables
$siteName = "LaunchSitecore"
$licensePath = "C:\license.xml"
$sourcePath = "Z:\GitHub\Sitecore-Build-Playground\Output\LaunchSitecore.Build.15.zip"
$targetFolder = "E:\inetpub\wwwroot\LaunchSitecore"

New-Item $targetFolder -type directory -Force -Verbose

# Additional variables
$packageFileName = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
$dataFolder = "$targetFolder\Data"
$websiteFolder = "$targetFolder\Website"
$serverName = $env:COMPUTERNAME
$sqlServerName = "$serverName\SQLEXPRESS"

# Main Script
Unzip-Archive $sourcePath $targetFolder

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $sqlServerName
$databases = "core", "master", "web"
foreach ($db in $databases)
{
    Attach-Database $server "$siteName.$db" "$targetFolder\Databases\Sitecore.$db.mdf" "$targetFolder\Databases\Sitecore.$db.ldf"
	Set-ConnectionString "$websiteFolder\App_Config\ConnectionStrings.config" "$db" "Trusted_Connection=Yes;Data Source=$sqlServerName;Database=$siteName.$db"
}

Set-ConfigAttribute "$websiteFolder\web.config" "sitecore/sc.variable[@name='dataFolder']" "value" $dataFolder   

Copy-Item $licensePath $dataFolder
Create-AppPool $siteName "v4.0"
Create-Site $siteName "$siteName.local"  "$destination"
Add-HostFileContent "127.0.0.1" "$siteName.local"
