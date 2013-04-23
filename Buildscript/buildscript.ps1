$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)

if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 

properties {
    $distributivePath = "C:\Sitecore 6.6.0 rev. 130404.zip"
    $localStorage = "C:\LocalStorage"
    $distributiveName = [System.IO.Path]::GetFileNameWithoutExtension($distributivePath)
    $zipFile = "$localStorage\$distributiveName.zip"
    $buildFolder = Resolve-Path .. 
    $revision = "12345"
    $buildNumber = "15"
    $tag_dir = "$localStorage\LiveSite"  
}

task Package -depends Init, Compile, Courier, Zip

task Init {
    if (-not (Test-Path $localStorage)) {
        New-Item $localStorage -type directory  -Verbose
    }

    if (-not (Test-Path $zipFile)) {
        Copy-Item $distributivePath $zipFile -Verbose
    }
    
    if (-not (Test-Path $localStorage\$distributiveName)) {
        sz x -y  "-o$localStorage" $zipFile "$distributiveName/Website"
        sz x -y  "-o$localStorage" $zipFile "$distributiveName/Data"
    }

    if (Test-Path "$buildFolder\output") {
        Remove-Item -Recurse -Force "$buildFolder\Output"         
    }
    
    New-Item "$buildFolder\Output" -type directory    
    robocopy $localStorage\$distributiveName $buildFolder /E /XC /XN /XO
}

task Compile { 
  exec { msbuild $buildFolder\Website\LaunchSitecore.sln /p:Configuration=Release /t:Clean } 

  exec { msbuild $buildFolder\Website\LaunchSitecore.sln /p:Configuration=Release /t:Build } 

}

task Courier { 
  New-Item $buildFolder\Data\serialization_empty -type directory -force
  & "$buildFolder\Buildscript\Tools\Courier\Sitecore.Courier.Runner.exe" /source:$buildFolder\Data\serialization_empty /target:$buildFolder\Data\serialization /output:$buildFolder\Website\sitecore\admin\Packages\LaunchSitecoreItems.update
}

task Zip {
    $outputPath = "$buildFolder\output\LaunchSitecore.Build.$buildNumber.zip"

    sz a $outputPath "$buildFolder\data" -xr!?serialization_TAG\* -xr!serialization* -mx1
    sz a $outputPath "$buildFolder\website" -mx1
    sz a $outputPath "$buildFolder\setSecurity.bat" -mx1
}
