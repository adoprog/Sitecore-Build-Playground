Clear-Host

remove-module [p]sake
import-module .\Tools\psake\psake.psm1

$psake.use_exit_on_error = $true 
Invoke-psake .\buildscript.ps1 Package -parameters @{ buildNumber = '12345';<#isDevEnvironmentFlag = '1'#> }