@echo off
rem Compiles and runs all UVM environments with the Vivado simulator (xsim).
rem Logs go to _sim_logs\ next to this script; build files go to %TEMP%\uvm_xsim.
setlocal enabledelayedexpansion
set "ROOT=%~dp0"
set "LOGS=%ROOT%_sim_logs"
if not exist "%LOGS%" mkdir "%LOGS%"
set "SUM=%LOGS%\summary.txt"
echo xsim run %DATE% %TIME% > "%SUM%"

rem ---- locate Vivado ----
set "XBIN="
for %%P in (xvlog.bat) do if not "%%~$PATH:P"=="" set "XBIN=%%~dp$PATH:P"
if not defined XBIN for /d %%D in ("C:\Xilinx\Vivado\*" "C:\Xilinx\*\Vivado" "C:\AMDDesignTools\*\Vivado" "D:\Xilinx\Vivado\*" "D:\Xilinx\*\Vivado" "D:\AMDDesignTools\*\Vivado") do if exist "%%~D\bin\xvlog.bat" set "XBIN=%%~D\bin\"
if not defined XBIN (
  echo VIVADO NOT FOUND >> "%SUM%"
  dir /b C:\Xilinx C:\AMDDesignTools D:\Xilinx >> "%SUM%" 2>&1
  goto :end
)
echo Vivado bin: %XBIN% >> "%SUM%"

set "WORK=%TEMP%\uvm_xsim"
if not exist "%WORK%" mkdir "%WORK%"

rem ---- eda_2 ----
set "D=%ROOT%eda_2"
set "W=%WORK%\eda_2"
if not exist "%W%" mkdir "%W%"
pushd "%W%"
> h.sv echo `include "uvm_macros.svh"
>>h.sv echo import uvm_pkg::*;
for %%F in (actuator_interface button_interface sensor_interface_dut test_ambient_base test_limit_values test_temperature_regulation test_humidity_regulation test_light_intensity_values test_sensor_functionality test_multiple_button_presses test_fast_button_presses test_ambient_full test_frequent_button_presses testbench) do >>h.sv echo `include "%%F.sv"
call :build eda_2 "%D%" "%D%\design.sv" h.sv
if !BUILD_OK!==1 for %%T in (test_ambient_base test_limit_values test_temperature_regulation test_humidity_regulation test_light_intensity_values test_sensor_functionality test_multiple_button_presses test_fast_button_presses test_ambient_full test_frequent_button_presses) do call :sim eda_2 %%T
popd

rem ---- lab5 ----
set "D=%ROOT%lab5"
set "W=%WORK%\lab5"
if not exist "%W%" mkdir "%W%"
pushd "%W%"
call :build lab5 "%D%" "%D%\testbench.sv"
if !BUILD_OK!==1 call :sim lab5 test_example
popd

rem ---- template_with_checker ----
set "D=%ROOT%template_with_checker"
set "W=%WORK%\template"
if not exist "%W%" mkdir "%W%"
pushd "%W%"
call :build template_with_checker "%D%" "%D%\testbench.sv"
if !BUILD_OK!==1 call :sim template_with_checker test_example
popd
goto :end

:build
rem %1=name %2=incdir %3.. = files
set "BUILD_OK=0"
set "N=%~1"
set "INC=%~2"
set "F1=%~3"
set "F2=%~4"
call "%XBIN%xvlog.bat" -sv -L uvm -i "%INC%" "%F1%" %F2% > "%LOGS%\%N%_xvlog.log" 2>&1
if errorlevel 1 ( echo %N%: XVLOG FAILED >> "%SUM%" & goto :eof )
call "%XBIN%xelab.bat" top -L uvm -timescale 1ns/1ns -s top_sim > "%LOGS%\%N%_xelab.log" 2>&1
if errorlevel 1 ( echo %N%: XELAB FAILED >> "%SUM%" & goto :eof )
echo %N%: compile+elab OK >> "%SUM%"
set "BUILD_OK=1"
goto :eof

:sim
rem %1=name %2=test
call "%XBIN%xsim.bat" top_sim -R -testplusarg UVM_TESTNAME=%2 > "%LOGS%\%1_%2.log" 2>&1
echo ---- %1 / %2 >> "%SUM%"
findstr /c:"UVM_ERROR :" /c:"UVM_FATAL :" /c:"TEST PASS" /c:"TEST FAIL" /c:"ERROR:" "%LOGS%\%1_%2.log" >> "%SUM%"
goto :eof

:end
echo DONE >> "%SUM%"
endlocal
