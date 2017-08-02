
@echo off
cd /d %~dp0
setlocal ENABLEDELAYEDEXPANSION

REM =================================================================================
REM�@�����i�ꊇ�Ăяo�����Ɏw�肳�����́j
REM�@�@%1�F ���s���[�h�BAUTO�Ŏ������[�h(���C�������I�����̃��b�Z�[�W�o�͂�pause�����Ȃ�����)
REM�@�@%2�F ���ʂ��i�[����t�@�C�����B�e�L�X�g�t�@�C��(*.txt)�̂ݎw��B
REM�@�@%3�F �o�̓��[�h�BFULL,NORMAL,SIMPLE,CPUZ_BENCH,X264BENCH�̂����ꂩ�B
REM�@�@%4�F ���O�擾���[�h�BRECYCLE�̏ꍇ��CPU-Z�ɂ��V�K���O�擾�͍s�킸�������O�𗘗p����B
REM =================================================================================

REM =================================================================
REM�@���̃V�X�e�������W�o�b�`�̖���
REM =================================================================

set infobatchname=CPUZtoText_20170730


REM =================================================================
REM�@�ꎞ�o�̓t�@�C��
REM =================================================================
set tempdir=.\temp
mkdir %tempdir% 2> nul

REM �ꎞ�I�Ɍ��ʂ��i�[���Ă����t�@�C��
set tempResultLog=%tempdir%\tempResultLog.txt

REM �ėp�I�Ɏg���񂷈ꎞ�o�̓t�@�C��
set tempLog=%tempdir%\tempLog.txt
set tempLog2=%tempdir%\tempLog2.txt

@echo.
set strcolor=A0
call :colorEcho "�ySystemInfo�z!infobatchname!"

REM =================================================================
REM�@�������̃p�����[�^�ݒ�
REM =================================================================

REM �I���R�[�h
set exitCode=0

REM colorEcho�ɂ��G���[�o�͎��̕����F�w��Bcolor�R�}���h�Q�ƁBE�͖��邢���F�B
set strcolor=E

REM CPU-Z�̃��O�ɐ�Ώo�Ă��Ȃ��ł��낤������(��s�܂߂čs�ԍ������������ȂǂɎg��)
set nonExtString=ThisIsNonExistentCharacterStringInCpuzLog

REM =================================================================
REM�@���ʂ��i�[����t�@�C�����i�w�肵���t�@�C���Ɂy�ǋL�z���܂��j
REM =================================================================

REM �f�t�H���g�̌��ʊi�[�t�@�C����
set infoResultLog=.\�V�X�e�����̎擾�����s��������.txt

REM ����%2���w�肳��Ă����ꍇ�A���̊g���q��.txt�̏ꍇ�����w������e����B
IF NOT "%~2"=="" (
 IF "%~x2"==".txt" (
  set infoResultLog=%2
 ) ELSE (
  @echo.
  call :colorEcho "���ʂ�ǋL����t�@�C���Ƃ��Ďw��ł���̂̓e�L�X�g�t�@�C���݂̂ł��B"
  call :colorEcho "���������I�����܂��B"
  @echo.
  set exitCode=1
  goto eof
 )
)

REM =================================================================
REM�@����%3�̏o�̓��[�h�̐ݒ�
REM�@�@�o�͍��ڂ���������ƍ��邱�Ƃ�����̂ŁA
REM�@�@�������̍��ڂ̏o�͂�}����w�肪�ł���悤�ɂ���B
REM =================================================================

set outputMode=FULL
IF NOT "%~3"=="" (
 set outputMode=%~3
)

REM --------------------------------------------------
REM�@�o�͐��䍀��
REM --------------------------------------------------
set show_cpuz=0
set show_cpu_simpleName=0
set show_cpuFreq=1
set show_cpuCoreSpeedNow=1
set show_cpuTurbo=1
set show_cpuSocket=1
set show_cpuCache=1
set show_instructionSet=1
set show_MB=1
set show_MB_vendor=1
set show_MB_bridge=1
set show_graphicIF=1
set show_mem_timing=1
set show_memspec=1
set show_allMemspec=1
set show_bios=1
set show_gpu_details=1
set show_storage=1
set show_removableStorage=1
set show_monitor=1

REM --------------------------------------------------
REM�@FULL2�F FULL���班����������
REM --------------------------------------------------
IF "%outputMode%"=="FULL2" (
 set show_allMemspec=0
 set show_removableStorage=0
)

REM --------------------------------------------------
REM�@NORMAL�F �V�X�e�����S�ʂ��r�I�V���v���Ɏ�肽���ꍇ
REM --------------------------------------------------
IF "%outputMode%"=="NORMAL" (
 set show_cpu_simpleName=1
 set show_cpuCoreSpeedNow=0
 set show_cpuSocket=0
 set show_cpuCache=0
 set show_instructionSet=0
 set show_MB_vendor=0
 set show_MB_bridge=0
 set show_mem_timing=0
 set show_allMemspec=0
 set show_gpu_details=0
 set show_removableStorage=0
)

REM --------------------------------------------------
REM�@SIMPLE�F �V���v���ɃV�X�e��������肽���ꍇ
REM --------------------------------------------------
IF "%outputMode%"=="SIMPLE" (
 set show_cpu_simpleName=1
 set show_cpuCoreSpeedNow=0
 set show_cpuSocket=0
 set show_cpuCache=0
 set show_instructionSet=0
 set show_MB_vendor=0
 set show_MB_bridge=0
 set show_graphicIF=0
 set show_mem_timing=0
 set show_allMemspec=0
 set show_gpu_details=0
 set show_bios=0
 set show_storage=0
 set show_monitor=0
)

REM --------------------------------------------------
REM�@CPUZ_BENCH�F CPU-Z�x���`�}�[�N�p
REM --------------------------------------------------
IF "%outputMode%"=="CPUZ_BENCH" (
 set show_cpuz=1
 set show_cpu_simpleName=1
 set show_cpuCoreSpeedNow=0
 set show_cpuSocket=0
 set show_cpuCache=0
 set show_instructionSet=0
 set show_MB_vendor=0
 set show_MB_bridge=0
 set show_graphicIF=0
 set show_allMemspec=0
 set show_bios=0
 set show_gpu_details=0
 set show_storage=0
 set show_monitor=0
)

REM --------------------------------------------------
REM�@X264BENCH�F x264/x265�x���`�}�[�N�p
REM --------------------------------------------------
IF "%outputMode%"=="X264BENCH" (
 set show_cpuSocket=0
 set show_cpuCache=0
 set show_instructionSet=0
 set show_MB_vendor=0
 set show_MB_bridge=0
 set show_graphicIF=0
 set show_allMemspec=0
 set show_bios=0
 set show_gpu_details=0
 set show_storage=0
 set show_monitor=0
)


REM =================================================================
REM�@�o�C�i���̐ݒ�
REM =================================================================
set bindir=.\bin
set cpuz=%bindir%\cpuz_x32.exe
set cpuzArch=

REM cpuzArch�̓o�C�i����ʂ���ʂ��邽�߂̂��́B
REM CPU-Z 1.80.0��GUI����e�L�X�g���O��������ꍇ�A
REM x64�Ȃ�CPU-Z�̃��O��CPU-Z version�̖�����.x64�Ƃ����\�L�����̂���
REM CLI��-txt�I�v�V�����Ń��O��������ꍇ�͉��̂����̕\�L���Ȃ��B
REM �����o�O�Ȃ̂��낤���A�d���Ȃ��̂œ��ʂ͓Ǝ��ɕ\�L��ǉ�����B

IF "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
 IF EXIST %bindir%\cpuz_x64.exe (
  set cpuz=%bindir%\cpuz_x64.exe
  set cpuzArch=.x64
 )
)

REM =================================================================================
REM�@�o�C�i���̑��݃`�F�b�N
REM =================================================================================

IF NOT EXIST %cpuz% (
 @echo.
 call :colorEcho "�ȉ���CPU-Z��������܂���B�I�����܂��B"
 @echo �@�@%cpuz%
 @echo.
 set exitCode=1
 goto eof
)

REM =================================================================
REM�@�����J�n���b�Z�[�W
REM =================================================================

@echo.
@echo �V�X�e�����̎擾���y%outputMode%�z���[�h�ŊJ�n���܂�...

REM =================================================================
REM�@CPU-Z�̃��O�t�@�C����
REM =================================================================
set cpuzlogname=cpu-z-log
set cpuzlog=%bindir%\%cpuzlogname%.txt

REM =================================================================
REM�@CPU-Z�̃��O���Ƃ�
REM =================================================================

REM %4��RECYCLE�̏ꍇ��CPU-Z�͋N�������A�������O���g���B

IF NOT "%~4"=="RECYCLE" (
 @echo.
 @echo CPU-Z�ŃV�X�e�����𒲂ׂĂ��܂�...
 call :colorEcho "�@�i���[�U�[�A�J�E���g����̃_�C�A���O�ŋN���������ĉ������j"

 %cpuz% -txt=%cpuzlogname%
)

REM =================================================================
REM�@�e�o�C�i���̃`�F�b�N
REM =================================================================
@echo.
@echo �o�C�i���̃o�[�W�����𒲂ׂĂ��܂�...

call :checkbinary

(@echo �ySystemInfo�z!infobatchname! ^(CPU-Z !cpuzVer!!cpuzArch!^)) > %tempResultLog%

IF !show_cpuz!==1 (
 (@echo �yCPU-Z�z!cpuzVer!!cpuzArch!) >> %tempResultLog%
)

REM =================================================================
REM�@CPU-Z�̃��O����K�v�ȃV�X�e�����𒲂ׂ�
REM =================================================================
@echo.
@echo CPU-Z�̃��O����K�v�ȃV�X�e�����𒊏o���Ă��܂�...

call :checksystem

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "�V�X�e�����̒��o�����܂������Ȃ������悤�ł��B"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto eof
)


@echo.
@echo ���o�������𐮌`���Ă��܂�...

call :replaceTabSpace

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "���o�������̐��`�����܂������Ȃ������悤�ł��B"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto eof
)


:eof

@echo.
@echo �V�X�e�����̎擾���������܂����B

IF NOT "%1"=="AUTO" (
 @echo.
 @echo ���ʂ� �u%infoResultLog%�v �Ɂy�ǋL�z����Ă��܂��B
 @echo �܂� %tempdir% �ɂ͈ꎞ�o�̓t�@�C����������܂��B
 @echo ���ɕK�v�Ȃ��Ȃ�A�����͍폜���ĉ������B
 @echo.
 @echo ������
 @echo �@CPU-Z�̃��O�`���̓s����A������GPU������ꍇ�A
 @echo �@GPU�̃h���C�o���̑Ή��t�����s�m���ɂȂ邱�Ƃ�����܂��B
 @echo �@GPU�̃h���C�o���̉E���ɋ^�╄�����Ă���ꍇ�́A
 @echo �@�Ή��t���������Ŋm�F���A�Ԉ���Ă�����C�����ĉ������B
 @echo.
 @echo ������
 @echo �@�I�[�o�[�N���b�N^(OC^)�̐ݒ��ԂȂǂ͒��ׂ邱�Ƃ��ł��܂���B
 @echo �@�����̓_�ɂ��Ă͕⑫������Y���ď���񎦂���Ɨǂ��ł��傤�B
 @echo.
 pause
)

exit /b %exitCode%

REM =======================================================
REM�@�����C�������̏I���
REM =======================================================



REM ���@�������牺�̓T�u���[�`���@��



REM =======================================================
REM�@�� :checkbinary�̎n�܂�
REM =======================================================

:checkbinary

REM -----------------------------------------------------------------
REM�@�o�C�i���̃o�[�W�����𒲂ׂ�
REM -----------------------------------------------------------------

set cpuzVer=�s��
FOR /F "tokens=2*" %%a in ('findstr /B /C:"CPU-Z version" %cpuzlog%') DO (
 set cpuzVer=%%b
)


exit /b

REM =======================================================
REM�@�� :checkbinary�̏I���
REM =======================================================


REM =======================================================
REM�@�� :checksystem�̎n�܂�
REM =======================================================

:checksystem

REM -----------------------------------------------------------------
REM�@CPU-Z�̃��O����V�X�e���̏��𒊏o����
REM -----------------------------------------------------------------

REM �܂��͒��o�p�ɍs�ԍ��t���̃��O�t�@�C���𐶐����Ă���
set nlog=%tempdir%\%cpuzlogname%_n.txt
findstr /V /N /C:"%nonExtString%" %cpuzlog% > %nlog%


REM -----------------------------------------------
REM�@CPU
REM -----------------------------------------------

call :cpu

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "CPU�̏��̒��o�����܂������Ȃ������悤�ł��B"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto checksystemEOF
)


REM -----------------------------------------------
REM�@MotherBoard, Memory
REM -----------------------------------------------

call :chipset

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "MotherBoard��Memory�̏��̒��o�����܂������Ȃ������悤�ł��B"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto checksystemEOF
)


REM -----------------------------------------------
REM�@MemSpec
REM -----------------------------------------------

IF !show_memspec!==1 (

 call :memspec

 REM -------------------------------------------------------
 REM �Ȃ�IF������q�ɂȂ��Ă��ERRORLEVEL��x���W�J���Ă�
 REM ������IF�̒��ł͂��܂��W�J����Ȃ��悤�Ȃ̂�
 REM ��x�ʂ̕ϐ��Ɋi�[���Ď󂯓n���悤�ɂ����B
 REM -------------------------------------------------------
 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "MemSpec�̏��̒��o�����܂������Ȃ������悤�ł��B"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)

REM -----------------------------------------------
REM�@BIOS
REM -----------------------------------------------

IF !show_bios!==1 (

 call :bios

 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "BIOS�̏��̒��o�����܂������Ȃ������悤�ł��B"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)


REM -----------------------------------------------
REM�@GPU
REM -----------------------------------------------

call :gpu

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "GPU�̏��̒��o�����܂������Ȃ������悤�ł��B"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto checksystemEOF
)


REM -----------------------------------------------
REM�@Storage
REM -----------------------------------------------

IF !show_storage!==1 (

 call :storage

 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "Storage�̏��̒��o�����܂������Ȃ������悤�ł��B"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)

REM -----------------------------------------------
REM�@Monitor
REM -----------------------------------------------

IF !show_monitor!==1 (

 call :monitor

 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "Monitor�̏��̒��o�����܂������Ȃ������悤�ł��B"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)

REM -----------------------------------------------
REM�@OS, DirectX
REM -----------------------------------------------
set osname=-
set dxVer=-
FOR /F "tokens=2*" %%a in ('findstr /B /C:"Windows Version" %cpuzlog%') DO (
 set osname=%%b
)
FOR /F "tokens=2*" %%a in ('findstr /B /C:"DirectX Version" %cpuzlog%') DO (
 set dxVer=%%b
)
(@echo �yOS�z!osname! �yDirectX�z!dxVer!) >> %tempResultLog%

:checksystemEOF

exit /b %exitCode%

REM =======================================================
REM�@�� :checksystem�̏I���
REM =======================================================


REM =======================================================
REM�@�� :cpu�̎n�܂�B
REM =======================================================

:cpu

REM ---------------------------------------------------------------------
REM�@�Ƃ肠�����uDMI Processor�v����
REM�@�@�Eclock speed
REM�@�@�EFSB speed
REM�@�@�Emultiplier
REM�@���擾���Ă����B
REM�@�}���`�v���Z�b�T�[�̏ꍇ�A�����́uDMI Processor�v������񂾂낤���E�E�E
REM�@�������悭�킩��Ȃ��̂ŁA�Ƃ肠�����������P���璊�o�������̂��g���B
REM�@FOR���̊֌W��A��������ꍇ�͌�̕����g����B
REM ---------------------------------------------------------------------
set DMIProcessorCol=0
FOR /F "tokens=1 delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:DMI Processor" %nlog%') DO (
 set DMIProcessorCol=%%a
)

IF %DMIProcessorCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDMI Processor�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

set /a "p3 = DMIProcessorCol + 3"
set /a "p4 = DMIProcessorCol + 4"
set /a "p5 = DMIProcessorCol + 5"
set /a "p6 = DMIProcessorCol + 6"
set dmiproclog=%tempdir%\dmiproclog.txt
type nul > %dmiproclog%
FOR /F "tokens=1* delims=:	 " %%a in ('findstr /B "%p3%: %p4%: %p5%: %p6%:" %nlog%') DO (
 IF NOT "%%b"=="" (
  (@echo %%b) >> %dmiproclog%
 )
)
set clkspd=�s��
set fsb=�s��
set mul=�s��
FOR /F "tokens=3-4" %%a in ('findstr /B /C:"clock speed" %dmiproclog%') DO (
 set clkspd=%%a%%b
)
FOR /F "tokens=3-4" %%a in ('findstr /B /C:"FSB speed" %dmiproclog%') DO (
 set fsb=%%a%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"multiplier" %dmiproclog%') DO (
 set mul=%%b
)


REM ---------------------------------------------------------------------
REM�@������Socket�ɂ��āA���ꂼ�ꏈ�����s���B
REM�@�@�L�[���[�h Socket N\t\t\tID
REM�@�@���ɂ���L�[���[�h Thread dumps
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM�@�uSocket N ID�v�̍s��nlog���璊�o���A�V���ɍs�ԍ�������cpuListLog�֕ۑ��B
REM�@cpuListLog�̍s����numOfCPUs�Ɋi�[�B
REM ---------------------------------------------------------------------
set cpuListLog=%tempdir%\cpuListLog.txt
set numOfCPUs=0

findstr /B /R /C:"[0-9]*:Socket [0-9]			ID" %nlog% | findstr /V /N /C:"%nonExtString%" > %cpuListLog%
FOR /F "" %%a in ('type %cpuListLog% ^| find /V /C ""') DO (
 set numOfCPUs=%%a
)

IF %numOfCPUs%==0 (
 call :colorEcho "CPU-Z�̃��O��CPU�������uSocket N�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM�@�eCPU�ɂ��Ă̏��������s�B
REM�@�@�E�ʂ̃��O�𒊏o���AtempLog�ɕۑ��B
REM�@�@�EtempLog����K�v�ȏ��𒊏o����B
REM�@�@�E���o���������yCPU�z�`�`���ŏo�́B
REM ---------------------------------------------------------------------

REM ���̗v�f�ł���uThread dumps�v�̍s�𒊏o���A�s�ԍ��𒲂ׂĂ����B
REM �Ō�̗v�f�ł͂��̍s�܂Ŏ擾���邱�ƂɂȂ�B
set threadDumpsCol=0
findstr /B /R /C:"[0-9]*:Thread dumps" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set threadDumpsCol=%%a
)

IF %threadDumpsCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuThread dumps�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM cpuListLog�̊e�s�ɂ��ď������s���B
REM ---------------------------------------------------------------------

FOR /F "tokens=1,2 delims=:" %%a in (%cpuListLog%) DO (

 set startCol=%%b

 IF %%a==%numOfCPUs% (
  set /a "endCol = %threadDumpsCol% -1"
 ) ELSE (
  set /a "nextCol = %%a + 1"
  FOR /F "tokens=1,2 delims=:" %%e in ('findStr /B /C:"!nextCol!:" %cpuListLog%') DO (
   set /a "endCol = %%f -1"
  )
 )

 IF NOT DEFINED endCol (
  call :colorEcho "CPU-Z�̃��O��CPU���̗̈�����ł��܂���ł����B"
  @echo.
  set exitCode=1
  exit /b !exitCode!
 )

 REM �Ή�����s��nlog���甲���o����tempLog�ɕۑ��B
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM ---------------------------------------------------------------------
 REM tempLog����K�v�v�f�𒊏o����B
 REM ---------------------------------------------------------------------
 set cores=�s��
 set threads=�s��
 set codename=�s��
 set cpuname=�s��
 set cpuSimpleName=�s��
 set socket=�s��
 set cpuID=�s��
 set exCpuId=�s��
 set coreStep=�s��
 set tech=�s��
 set tdplimit=�s��
 set instSet=�s��
 set L1DataCache=
 set L1InstCache=
 set L2Cache=
 set L3Cache=
 set L4Cache=
 set maxRatioNT=?
 set maxRatioT=?
 set maxRatioE=?
 set volt0=�s��

 set coreSpeed=�s��
 set mulBusSpeed=�s��
 set coreSpeedNow=�s��
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Core Speed" %tempLog%') DO (
  set coreSpeed=%%n
 )
 FOR /F "tokens=5* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Multiplier x Bus Speed" %tempLog%') DO (
  set mulBusSpeed=%%n
 )
 type nul > %tempLog2%
 call :eraseSpace "!coreSpeed!^(!mulBusSpeed!^)" %tempLog2%
 set /p coreSpeedNow=<%tempLog2%


 FOR /F "tokens=5 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Number of cores" %tempLog%') DO (
  set cores=%%m
 )
 FOR /F "tokens=5 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Number of threads" %tempLog%') DO (
  set threads=%%m
 )
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Codename" %tempLog%') DO (
  set codename=%%n
 )
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Specification" %tempLog%') DO (
  set cpuname=%%n
 )
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Name" %tempLog%') DO (
  set cpuSimpleName=%%n
 )

 REM ---------------------------------------------------------------------
 REM Socket(Package)�ɂ��ẮA
 REM�@�@�EPackage (platform ID)�@��Intel�n�H
 REM�@�@�EPackage�@��AMD�n�H
 REM �̂Q�p�^�[���̗v�f��������炵���̂ŁA����ɑΉ��B
 REM Package�ł̌����͑��̗v�f�Ɣ���đʖڂȂ̂ŁASocket�Ō�������B
 REM Socket�G���g���̍s������������Ȃ��悤�A�f�[�^�̕��������u\tSocket�v�Ō����B
 REM ---------------------------------------------------------------------

 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /C:"	Socket" %tempLog%') DO (
  set socket=%%n
 )
 FOR /F "tokens=1,2,3*" %%m in ('@echo !socket!') DO (
  IF NOT "%%m"=="Socket" (
    set socket=%%o %%p
  )
 )

 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	CPUID" %tempLog%') DO (
  set cpuId=%%n
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Extended CPUID" %tempLog%') DO (
  set exCpuId=%%n
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Core Stepping" %tempLog%') DO (
  set coreStep=%%n
 )


 FOR /F "tokens=3-4 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Technology" %tempLog%') DO (
  set tech=%%m%%n
 )
 FOR /F "tokens=4 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	TDP Limit" %tempLog%') DO (
  set tdplimit=%%m
 )

 FOR /F "tokens=4 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Voltage 0" %tempLog%') DO (
  set volt0=%%m
 )

 type nul > %tempLog2%
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Instructions sets" %tempLog%') DO (
  call :eraseSpace "%%n" %tempLog2%
  set /p instSet=<%tempLog2%
 )


 FOR /F "tokens=5-9 delims=:,	 " %%m in ('findstr /B /R /C:"[0-9]*:	L1 Data cache" %tempLog%') DO (
  IF NOT "%%n"=="x" (
   set L1DataCache=L1Data:^(%%m%%n,%%o^)
  ) ELSE (
   set L1DataCache=L1Data:^(%%m%%n%%o%%p,%%q^)
  )
 )
 FOR /F "tokens=5-9 delims=:,	 " %%m in ('findstr /B /R /C:"[0-9]*:	L1 Instruction cache" %tempLog%') DO (
  IF NOT "%%n"=="x" (
   set L1InstCache=L1Inst:^(%%m%%n,%%o^)
  ) ELSE (
   set L1InstCache=L1Inst:^(%%m%%n%%o%%p,%%q^)
  )
 )
 FOR /F "tokens=4-8 delims=:,	 " %%m in ('findstr /B /R /C:"[0-9]*:	L2 cache" %tempLog%') DO (
  IF NOT "%%n"=="x" (
   set L2Cache=L2:^(%%m%%n,%%o^)
  ) ELSE (
   set L2Cache=L2:^(%%m%%n%%o%%p,%%q^)
  )
 )
 FOR /F "tokens=4-8 delims=:,	 " %%m in ('findstr /B /R /C:"[0-9]*:	L3 cache" %tempLog%') DO (
  IF NOT "%%n"=="x" (
   set L3Cache=L3:^(%%m%%n,%%o^)
  ) ELSE (
   set L3Cache=L3:^(%%m%%n%%o%%p,%%q^)
  )
 )
 FOR /F "tokens=4-8 delims=:,	 " %%m in ('findstr /B /R /C:"[0-9]*:	L4 cache" %tempLog%') DO (
  IF NOT "%%n"=="x" (
   set L4Cache=L4:^(%%m%%n,%%o^)
  ) ELSE (
   set L4Cache=L4:^(%%m%%n%%o%%p,%%q^)
  )
 )


 REM --------------------------------------------
 REM�@�^�[�{�u�[�X�g�֘A
 REM --------------------------------------------

 REM �^�[�{�u�[�X�g�֘A�̏�񂪂P�ł���ꂽ��1�ɂ���
 set turboFlag=0

 FOR /F "tokens=4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Max non-turbo ratio" %tempLog%') DO (
  set maxRatioNT=%%n
  set turboFlag=1
 )
 FOR /F "tokens=4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Max turbo ratio" %tempLog%') DO (
  set maxRatioT=%%n
  set turboFlag=1
 )
 FOR /F "tokens=4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Max efficiency ratio" %tempLog%') DO (
  set maxRatioE=%%n
  set turboFlag=1
 )

 REM --------------------------------------------
 REM �uRatio N core(s)�v�̎擾
 REM --------------------------------------------
 set coresRatioLog=%tempdir%\coresRatioLog.txt
 set coresRatio=
 findstr /B /R /C:"[0-9]*:	Ratio [0-9]* core" %tempLog% > !coresRatioLog!
 FOR /F "tokens=3,4*" %%m in (!coresRatioLog!) DO (
  IF "!coresRatio!"=="" (
   set coresRatio=!coresRatio!^(%%m^)%%o
  ) ELSE (
   set coresRatio=!coresRatio!-^(%%m^)%%o
  )
 )
 IF NOT "!coresRatio!"=="" (
  set turboFlag=1
 )

 REM --------------------------------------------
 REM ���ʃt�@�C���ւ̏o��
 REM --------------------------------------------

 IF !show_cpu_simpleName!==1 (
  (@echo �yCPU�z!cpuSimpleName! ^(!codename!^)^(!cores!cores/!threads!threads^)^(!tech!^)) >> %tempResultLog%
 ) ELSE (
  (@echo �yCPU�z!cpuname! ^(!codename!^)^(!cores!Cores/!threads!Threads^)^(!tech!^)) >> %tempResultLog%
 )

 IF !show_cpuFreq!==1 (
  (@echo �@�@!clkspd!^(!mul!!fsb!^)^(!tdplimit!W^)^(!volt0!V^)) >> %tempResultLog%
 )

 IF !show_cpuCoreSpeedNow!==1 (
  (@echo �@�@���擾���̓�����g���� !coreSpeedNow!) >> %tempResultLog%
 )

 IF !show_cpuTurbo!==1 (
  IF !turboFlag!==1 (
   (@echo �@�@^(!maxRatioE!-!maxRatioNT!-!maxRatioT!^) !coresRatio!) >> %tempResultLog%
  )
 )

 IF !show_cpuSocket!==1 (
  (@echo �@�@^(!socket!^)^(!cpuId!, !exCpuId!, !coreStep!^)) >> %tempResultLog%
 )

 IF !show_cpuCache!==1 (
  (@echo �@�@!L1DataCache! !L1InstCache! !L2Cache! !L3Cache! !L4Cache!) >> %tempResultLog%
 )

 IF !show_instructionSet!==1 (
  (@echo �@�@!instSet!) >> %tempResultLog%
 )

)


exit /b %exitCode%

REM =======================================================
REM�@�� :cpu�̏I���B
REM =======================================================

REM =======================================================
REM�@�� :chipset�̎n�܂�B
REM =======================================================

:chipset

REM ---------------------------------------------------------------------
REM�@MotherBoard�AGraphicIF�AMemory�̏��𒊏o����
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM�@�Ƃ肠�����uDMI Baseboard�v����
REM�@�@�Evendor
REM�@�@�Emodel
REM�@���擾���Ă����B
REM ---------------------------------------------------------------------
set DMIBaseBoardCol=0
FOR /F "tokens=1 delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:DMI Baseboard" %nlog%') DO (
 set DMIBaseBoardCol=%%a
)

IF %DMIBaseBoardCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDMI Baseboard�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

set /a "p1 = DMIBaseBoardCol + 1"
set /a "p2 = DMIBaseBoardCol + 2"
set /a "p3 = DMIBaseBoardCol + 3"
set dmiboardlog=%tempdir%\dmiboardlog.txt
type nul > %dmiboardlog%
FOR /F "tokens=1* delims=:	 " %%a in ('findstr /B "%p1%: %p2%: %p3%:" %nlog%') DO (
 IF NOT "%%b"=="" (
  (@echo %%b) >> %dmiboardlog%
 )
)
set bdVendor=�s��
set bdModel=�s��
FOR /F "tokens=1*" %%a in ('findstr /B /C:"vendor" %dmiboardlog%') DO (
 set bdVendor=%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"model" %dmiboardlog%') DO (
 set bdModel=%%b
)


REM ---------------------------------------------------------------------
REM�@Chipset�ɂ��āA�������s���B
REM�@�@�L�[���[�h Chipset
REM�@�@���ɂ���L�[���[�h Memory SPD
REM ---------------------------------------------------------------------

REM �܂��́uChipset�v�̍s�𒊏o���A�s�ԍ��𒲂ׂĂ����B
set chipsetCol=0
findstr /B /R /C:"[0-9]*:Chipset" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set chipsetCol=%%a
)

IF %chipsetCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuChipset�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ���̗v�f�ł���uMemory SPD�v�̍s�𒊏o���A�s�ԍ��𒲂ׂ�B
set memSPDCol=0
findstr /B /R /C:"[0-9]*:Memory SPD" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set /a "memSPDCol = %%a - 1"
)

IF %memSPDCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuMemory SPD�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM -----------------------------------------------
REM �K�v���𒊏o���Ă����B
REM -----------------------------------------------

REM �Ή�����s��nlog���甲���o����tempLog�ɕۑ��B
type nul > %tempLog%
FOR /L %%i in (!chipsetCol!, 1, !memSPDCol!) DO (
 findstr /B /C:"%%i:" %nlog% >> %tempLog%
)

REM -----------------------------------------------
REM tempLog����K�v�v�f�𒊏o�B
REM -----------------------------------------------
set nBridge=�s��
set sBridge=�s��
set graphicIF=-
set pcieLinkWidth=-
set pcieMaxLinkWidth=-
set memType=�s��
set memSize=�s��
set memChannel=�s��
set memFreq=�s��

REM tRC��tRFC�͂ǂ��炩�����o�Ȃ�(�H)�悤�Ȃ̂ŋ󏉊���
set CL=?^(CL^)
set tRCD=?^(tRCD^)
set tRP=?^(tRP^)
set tRAS=?^(tRAS^)
set tRC=
set tRFC=
set CR=?^(CR^)

FOR /F "tokens=2* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Northbridge" %tempLog%') DO (
 set nBridge=%%b
)
FOR /F "tokens=2* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Southbridge" %tempLog%') DO (
 set sBridge=%%b
)

FOR /F "tokens=3* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Graphic Interface" %tempLog%') DO (
 set graphicIF=%%b
)
FOR /F "tokens=4* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:PCI-E Link Width" %tempLog%') DO (
 set pcieLinkWidth=%%b
)
FOR /F "tokens=5* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:PCI-E Max Link Width" %tempLog%') DO (
 set pcieMaxLinkWidth=%%b
)

FOR /F "tokens=3* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Memory Type" %tempLog%') DO (
 set memType=%%b
)
FOR /F "tokens=4,5* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Memory Size" %tempLog%') DO (
 set memSize=%%a%%b%%c
)
FOR /F "tokens=2* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Channels" %tempLog%') DO (
 set memChannel=%%b
)
FOR /F "tokens=4,5* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Memory Frequency" %tempLog%') DO (
 set memFreq=%%a%%b%%c
)

FOR /F "tokens=4* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:CAS# latency (CL)" %tempLog%') DO (
 set CL=%%b^(CL^)
)
FOR /F "tokens=6* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:RAS# to CAS# delay (tRCD)" %tempLog%') DO (
 set tRCD=%%b^(tRCD^)
)
FOR /F "tokens=4* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:RAS# Precharge (tRP)" %tempLog%') DO (
 set tRP=%%b^(tRP^)
)
FOR /F "tokens=4* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Cycle Time (tRAS)" %tempLog%') DO (
 set tRAS=%%b^(tRAS^)
)
FOR /F "tokens=5* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Bank Cycle Time (tRC)" %tempLog%') DO (
 set tRC=-%%b^(tRC^)
)
FOR /F "tokens=6* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Row Refresh Cycle Time (tRFC)" %tempLog%') DO (
 set tRFC=-%%b^(tRFC^)
)
FOR /F "tokens=4* delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:Command Rate (CR)" %tempLog%') DO (
 set CR=%%b^(CR^)
)


REM -----------------------------------------------
REM ���ʃt�@�C���ւ̏o��
REM -----------------------------------------------

IF !show_MB!==1 (

 IF !show_MB_vendor!==1 (
  (@echo �yMotherBoard�z!bdModel! ^(!bdVendor!^)) >> %tempResultLog%
 ) ELSE (
  (@echo �yMotherBoard�z!bdModel!) >> %tempResultLog%
 )

 IF !show_MB_bridge!==1 (
  (@echo �@�@North:^(!nBridge!^), South:^(!sBridge!^)) >> %tempResultLog%
 )

)

IF !show_graphicIF!==1 (
 (@echo �yGraphic I/F�z!graphicIF!^(!pcieLinkWidth!,max:!pcieMaxLinkWidth!^)) >> %tempResultLog%
)

IF !show_mem_timing!==1 (
 (@echo �yMemory�z!memType!,!memSize!,!memChannel!,!memFreq!,!CL!-!tRCD!-!tRP!-!tRAS!!tRC!!tRFC!-!CR!) >> %tempResultLog%
) ELSE (
 (@echo �yMemory�z!memType!,!memSize!,!memChannel!,!memFreq!) >> %tempResultLog%
)


exit /b %exitCode%

REM =======================================================
REM�@�� :chipset�̏I���
REM =======================================================

REM =======================================================
REM�@�� :memspec�̎n�܂�B
REM =======================================================

:memspec

REM ---------------------------------------------------------------------
REM�@�@�L�[���[�h SMBus address
REM�@�@���ɂ���L�[���[�h Monitoring
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM�@�uSMBus address�v�̍s��nlog���璊�o���A�V���ɍs�ԍ�������memoryListLog�֕ۑ��B
REM�@memoryListLog�̍s����numOfMemories�Ɋi�[�B
REM ---------------------------------------------------------------------
set memoryListLog=%tempdir%\memoryListLog.txt
set numOfMemories=0

findstr /B /R /C:"[0-9]*:	SMBus address" %nlog% | findstr /V /N /C:"%nonExtString%" > %memoryListLog%
FOR /F "" %%a in ('type %memoryListLog% ^| find /V /C ""') DO (
 set numOfMemories=%%a
)

IF %numOfMemories%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuSMBus address�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM ���̗v�f�ł���uSPD registers�v�̍ŏ��̍s�𒊏o���A�s�ԍ��𒲂ׂĂ����B
REM �Ō�̗v�f�ł͂��̍s�܂Ŏ擾���邱�ƂɂȂ�B
REM ---------------------------------------------------------------------
set spdRegCol=0
findstr /B /R /C:"[0-9]*:SPD registers" %nlog% > %tempLog%
set /p spdRegFirst=<%tempLog%
FOR /F "tokens=1 delims=:" %%a in ('@echo !spdRegFirst!') DO (
 set spdRegCol=%%a
)

IF %spdRegCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuSPD registers�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM�@�e�������ɂ��Ă̏��������s�B
REM�@�@�E�ʂ̃��O�𒊏o���AtempLog�ɕۑ��B
REM�@�@�EtempLog����K�v�ȏ��𒊏o����B
REM�@�@�E���o���������yMemSpec�z�`�`����memspecListLog�ɕۑ��B
REM ---------------------------------------------------------------------

set memspecListLog=%tempdir%\memspecListLog.txt
type nul > %memspecListLog%

FOR /F "tokens=1,2 delims=:" %%a in (%memoryListLog%) DO (

 set startCol=%%b
 IF %%a==%numOfMemories% (
  set /a "endCol = %spdRegCol% - 1"
 ) ELSE (
  set /a "nextCol = %%a + 1"
  FOR /F "tokens=1,2 delims=:" %%e in ('findStr /B /C:"!nextCol!:" %memoryListLog%') DO (
   set /a "endCol = %%f -1"
  )
 )

 REM -----------------------------------------------
 REM �Ή�����s��nlog���甲���o����tempLog�ɕۑ��B
 REM -----------------------------------------------
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM -----------------------------------------------
 REM tempLog����K�v�v�f�𒊏o����memspecListLog�ɕۑ��B
 REM -----------------------------------------------
 set memtype=�s��
 set modfmt=�s��
 set manuid=�s��
 set memsize=�s��
 set maxband=�s��
 set part=�s��
 set EPP=
 set XMP=
 set XMPrev=
 set AMP=

 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Memory type" %tempLog%') DO (
  set memtype=%%n
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Module format" %tempLog%') DO (
  set modfmt=%%n
 )
 FOR /F "tokens=4 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Manufacturer (ID)" %tempLog%') DO (
  set manuid=%%m
 )
 FOR /F "tokens=3,4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Size" %tempLog%') DO (
  set memsize=%%m%%n%%o
 )
 FOR /F "tokens=4,5,6* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Max bandwidth" %tempLog%') DO (
  set maxband=%%m%%n%%o%%p
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Part number" %tempLog%') DO (
  set part=%%n
 )

 set memEx=^(
 FOR /F "tokens=3 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	EPP		" %tempLog%') DO (
  IF "%%m"=="yes" (
   set memEx=!memEx!EPP
  )
 )
 FOR /F "tokens=3 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	XMP		" %tempLog%') DO (
  set XMP=%%m
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	XMP revision" %tempLog%') DO (
  set XMPrev=%%n
 )
 FOR /F "tokens=3 delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	AMP		" %tempLog%') DO (
  set AMP=%%m
 )
 IF "!XMP!"=="yes" (
  IF "!memEx!"=="(" (
   set memEx=!memEx!XMP!XMPrev!
  ) ELSE (
   set memEx=!memEx!,XMP!XMPrev!
  )
 )
 IF "!AMP!"=="yes" (
  IF "!memEx!"=="(" (
   set memEx=!memEx!AMP
  ) ELSE (
   set memEx=!memEx!,AMP
  )
 )
 IF "!memEx!"=="(" (
  set memEx=!memEx!-^)
 ) ELSE (
  set memEx=!memEx!^)
 )

 (@echo �yMemSpec�z!memtype!,!maxband!,!memsize!,!modfmt!,!memEx!,!manuid!,!part!) >> %memspecListLog%

)

REM ---------------------------------------------------------------------
REM�@���ʃt�@�C���ւ̏o��
REM ---------------------------------------------------------------------

IF !show_allMemspec!==1 (

 type %memspecListLog% >> %tempResultLog%

) ELSE (

 REM ---------------------------------------------------------------------
 REM�@���e������̍s�͂P�s���������ʃt�@�C���ɏo�͂���B
 REM�@�@�EmemspecListLog��tempLog�Ƃ��ăR�s�[�B
 REM�@�@�EtempLog����ŏ��̍s�����o���A���ʃt�@�C���ɏo�́B
 REM�@�@�Efindstr /V /C:"�ŏ��̍s" �ōŏ��̍s�ƈ�v���Ȃ����̂����𒊏o���AtempLog�ɕۑ��B
 REM�@�@�EtempLog ����ɂȂ�܂ő�����B
 REM ---------------------------------------------------------------------

 copy /Y %memspecListLog% %tempLog% > nul
 set count=0

:memspecLoop
REM �Ȃ�IF�̒��Ƀ��x����u���ƃV���^�b�N�X�G���[���N���邪
REM ���x�������ɃR�����g������Ɖ���ł���炵���̂ł���Ƃ��B

 REM ---------------------------------------------------------------------
 REM�@�P�s�ڂ����o���Č��ʃt�@�C���֏o��
 REM ---------------------------------------------------------------------
 set /p lineData=<%tempLog%
 IF "!lineData!"=="" (
  goto memspecLoopOut
 )

 (@echo !lineData!) >> %tempResultLog%

 REM ---------------------------------------------------------------------
 REM�@�d�����Ă���s����菜���A�܂��s���c���Ă���Ȃ�ă��[�v�B
 REM�@�s�������Ȃ�܂ő�����B
 REM ---------------------------------------------------------------------

 FOR /F "tokens=1" %%a in ('findstr /V /C:"!lineData!" %tempLog% ^| find /V /C ""') DO (
  set count=%%a
 )
 IF NOT !count!==0 (
  findstr /V /C:"!lineData!" %tempLog% > %tempLog2%
  move /Y %tempLog2% %tempLog% > nul
  goto memspecLoop
 )

)

:memspecLoopOut
REM �ꉞ�R�����g�������Ă������E�E�E

exit /b %exitCode%

REM =======================================================
REM�@�� :memspec�̏I���
REM =======================================================

REM =======================================================
REM�@�� :bios�̎n�܂�B
REM =======================================================

:bios

REM ---------------------------------------------------------------------
REM�@�uDMI BIOS�v����
REM�@�@�Evendor
REM�@�@�Eversion
REM�@�@�Edate
REM�@���擾���Ă����B
REM ---------------------------------------------------------------------
set DMIBIOSCol=0
FOR /F "tokens=1 delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:DMI BIOS" %nlog%') DO (
 set DMIBIOSCol=%%a
)

IF %DMIBIOSCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDMI BIOS�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

set /a "p1 = DMIBIOSCol + 1"
set /a "p2 = DMIBIOSCol + 2"
set /a "p3 = DMIBIOSCol + 3"
set /a "p4 = DMIBIOSCol + 4"
set dmibioslog=%tempdir%\dmibioslog.txt
type nul > %dmibioslog%
FOR /F "tokens=1* delims=:	 " %%a in ('findstr /B "%p1%: %p2%: %p3%: %p4%:" %nlog%') DO (
 (@echo %%b) >> %dmibioslog%
)
set biosVendor=�s��
set biosVer=�s��
set biosDate=�s��
FOR /F "tokens=1*" %%a in ('findstr /B /C:"vendor" %dmibioslog%') DO (
 set biosVendor=%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"version" %dmibioslog%') DO (
 set biosVer=%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"date" %dmibioslog%') DO (
 set biosDate=%%b
)

(@echo �yBIOS�z!biosVendor!^(!biosVer!^)^(!biosDate!^)) >> %tempResultLog%

exit /b %exitCode%

REM =======================================================
REM�@�� :bios�̏I���
REM =======================================================

REM =======================================================
REM�@�� :gpu�̎n�܂�B
REM =======================================================

:gpu

REM ---------------------------------------------------------------------
REM�@DriverVersion�̃��X�g�̍쐬�B
REM�@DriverVersion��Display adapter�Ƃ͕ʂ̂Ƃ���ňꗗ�\������Ă���A
REM�@������Display adapter���������ꍇ�A
REM�@Display adapter��DriverVersion�Ƃ𖾊m�ɕR�Â��邱�Ƃ͂ł��Ȃ��B
REM�@�����A
REM�@�@�EiGPU��Display adapter�͈�ԍŏ��ɂ�����̂Ǝv����
REM�@�@�EDriverVersion��AdapterRAM�̒l�ƕR�Â��邱�Ƃ��\�ł���A
REM�@�@�@�܂��AiGPU�̏ꍇ�AAdapterRAM�̒l�͔�r�I�������Ȃ��Ă���Ǝv����B
REM�@�Ƃ������Ƃ���AAdapterRAM�̒l���ł�������DriverVersion��
REM�@�ŏ���Display adapter�ƌ��ѕt����΁AiGPU��DriverVersion��
REM�@�قڊm���ɕR�Â�����ƍl������B
REM�@�����DriverVersion�́AAdapterRAM�̐��l�ŏ��������Ƀ\�[�g������̂Ƃ���B
REM�@�\�[�g�ς݂̃��X�g�̌`���͈ȉ��̂悤�ɂ���
REM�@�@�@�s�ԍ�:16�i����AdapterRAM�l:DriverVersion:DriverDate
REM ---------------------------------------------------------------------

set adapterRAMList=%tempdir%\adapterRAMList.txt
set numOfAdapters=0
findstr /B /C:"Win32_VideoController		AdapterRAM" %cpuzlog% > %tempLog%
findstr /V /N /C:"%nonExtString%" %tempLog% > %adapterRAMList%
FOR /F "" %%a in ('type %adapterRAMList% ^| find /V /C ""') DO (
 set numOfAdapters=%%a
)

IF %numOfAdapters%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuAdapterRAM�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

set driverVersionList=%tempdir%\driverVersionList.txt
set numOfDrivers=0
findstr /B /C:"Win32_VideoController		DriverVersion" %cpuzlog% > %tempLog%
findstr /V /N /C:"%nonExtString%" %tempLog% > %driverVersionList%
FOR /F "" %%a in ('type %driverVersionList% ^| find /V /C ""') DO (
 set numOfDrivers=%%a
)

IF %numOfDrivers%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDriverVersion�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

set driverDateList=%tempdir%\driverDateList.txt
set numOfDriverDates=0
findstr /B /C:"Win32_VideoController		DriverDate" %cpuzlog% > %tempLog%
findstr /V /N /C:"%nonExtString%" %tempLog% > %driverDateList%
FOR /F "" %%a in ('type %driverDateList% ^| find /V /C ""') DO (
 set numOfDriverDates=%%a
)

IF %numOfDriverDates%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDriverDate�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM AdapterRAM��DriverVersion��DriverDate�����т���
REM ---------------------------------------------------------------------
type nul > %tempLog%
FOR /L %%i in (1, 1, %numOfAdapters%) DO (

 set adapterRAM=
 set driverVersion=
 set driverDate=

 REM AdapterRAM��16�i���l�̎��o��
 FOR /F "tokens=5 delims=:	 " %%a in ('findstr /B /C:"%%i:" %adapterRAMList%') DO (
  set adapterRAM=%%a
 )

 REM DriverVersion�̎��o��
 FOR /F "tokens=5 delims=:	 " %%a in ('findstr /B /C:"%%i:" %driverVersionList%') DO (
  set driverVersion=%%a
 )

 REM DriverDate�̎��o��
 FOR /F "tokens=5 delims=:	 " %%a in ('findstr /B /C:"%%i:" %driverDateList%') DO (
  set driverDate=%%a
 )

 (@echo !adapterRAM!:!driverVersion!:!driverDate!) >> %tempLog%
)

REM ---------------------------------------------------------------------
REM ���e��adapterRAM�̒l�Ń\�[�g������ōs�ԍ�������driverList�ɕۑ��B
REM ---------------------------------------------------------------------
sort %tempLog% > %tempLog2%
set driverList=%tempdir%\driverList.txt
findstr /V /N /C:"%nonExtString%" %tempLog2% > %driverList%


REM ---------------------------------------------------------------------
REM�@������Display adapter�ɂ��āA���ꂼ�ꏈ�����s���B
REM�@�@�L�[���[�h Display adapter N
REM�@�@���ɂ���L�[���[�h Win32_VideoController
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM�@�uDisplay adapter N�v�̍s��nlog���璊�o���A�V���ɍs�ԍ�������gpuListLog�֕ۑ��B
REM�@gpuListLog�̍s����numOfGPUs�Ɋi�[�B
REM ---------------------------------------------------------------------
set gpuListLog=%tempdir%\gpuListLog.txt
set numOfGPUs=0
set iGPU=0

findstr /B /R /C:"[0-9]*:Display adapter [0-9]" %nlog% | findstr /V /N /C:"%nonExtString%" > %gpuListLog%
FOR /F "" %%a in ('type %gpuListLog% ^| find /V /C ""') DO (
 set numOfGPUs=%%a
)

IF %numOfGPUs%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDisplay adapter N�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM�@�eGPU�ɂ��Ă̏��������s�B
REM�@�@�E�ʂ̃��O�𒊏o���AtempLog�ɕۑ��B
REM�@�@�EtempLog����K�v�ȏ��𒊏o����B
REM�@�@�E���o���������yGPU�z�`�`���Ō��ʃt�@�C���֏o�́B
REM ---------------------------------------------------------------------

REM ���̗v�f�ł���uWin32_VideoController�v�̍s�𒊏o���A�s�ԍ��𒲂ׂĂ����B
REM �Ō�̗v�f�ł͂��̍s�܂Ŏ擾���邱�ƂɂȂ�B
set winVidCtrlCol=0
findstr /B /R /C:"[0-9]*:Win32_VideoController" %nlog% > %tempLog%
set /p firstWinVidCtrl=<%tempLog%
FOR /F "tokens=1 delims=:" %%a in ('@echo !firstWinVidCtrl!') DO (
 set winVidCtrlCol=%%a
)

IF %winVidCtrlCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuWin32_VideoController�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM gpuListLog�̊e�s�ɂ��ď������s���B
REM ---------------------------------------------------------------------

FOR /F "tokens=1,2 delims=:" %%a in (%gpuListLog%) DO (

 set startCol=%%b

 IF %%a==%numOfGPUs% (
  set /a "endCol = %winVidCtrlCol% -1"
 ) ELSE (
  set /a "nextCol = %%a + 1"
  FOR /F "tokens=1,2 delims=:" %%e in ('findStr /B /C:"!nextCol!:" %gpuListLog%') DO (
   set /a "endCol = %%f -1"
  )
 )

 REM ---------------------------------------------------------------------
 REM �Ή�����s��nlog���甲���o����tempLog�ɕۑ��B
 REM ---------------------------------------------------------------------
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM ---------------------------------------------------------------------
 REM tempLog����K�v�v�f�𒊏o���Č��ʃt�@�C���ɏo�́B
 REM ---------------------------------------------------------------------
 set gname=�s��
 set gmanu=�s��
 set gcodename=-
 set gtech=-
 set gmemsize=-
 set gmemtype=-

 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Name" %tempLog%') DO (
  set gname=%%n
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Board Manufacturer" %tempLog%') DO (
  set gmanu=%%n
 )
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Codename" %tempLog%') DO (
  set gcodename=%%n
 )
 FOR /F "tokens=3,4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Technology" %tempLog%') DO (
  set gtech=%%m%%n%%o
 )
 FOR /F "tokens=4,5* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Memory size" %tempLog%') DO (
  set gmemsize=%%m%%n%%o
 )
 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Memory type" %tempLog%') DO (
  set gmemtype=%%n
 )

 REM ----------------------------------------------
 REM DriverVersion,DriverDate�̕R�Â�����
 REM ----------------------------------------------

 set driverNum=0
 set driverVersion=�s��
 set driverDate=�s��

 REM ----------------------------------------------
 REM DriverVersion���̕R�Â��͕s�m���Ȃ̂ŁA������GPU�����݂���ꍇ��?������
 REM DriverVersion�̊m�F�𑣂��B
 REM ----------------------------------------------
 set dverAccuracy=?
 IF !numOfGPUs!==1 (
  set dverAccuracy=
 )

 REM driverList�̐擪�s�����
 set /p driverInfo=<%driverList%
 FOR /F "tokens=1-4 delims=:" %%m in ('@echo !driverInfo!') DO (
�@set driverNum=%%m
  set driverVersion=%%o
  set driverDate=%%p
 )

 REM driverList�̐擪�s���폜����
 findstr /V /B /C:"!driverNum!:" %driverList% > %tempLog2%
 move /Y %tempLog2% %driverList% > nul

 REM ----------------------------------------------
 REM tempLog����iGPU�����������񂪌���������iGPU���Ƃ݂Ȃ��A
 REM ����Ȃ�܂�DriverVersion�̕R�Â��̊m���x���������낤�Ƃ݂Ȃ��B
 REM ----------------------------------------------

 REM ----------------------------------------------
 REM gname��Intel�Ƃ��������񂪂���ꍇ
 REM ----------------------------------------------
 @echo !gname! | findstr /C:"Intel" > %tempLog2%
 FOR /F "" %%m in (%tempLog2%) DO (
  set dverAccuracy=
  set iGPU=1
 )

 REM ----------------------------------------------
 REM gcodename��AMD APU��\�������񂪂���ꍇ
 REM ----------------------------------------------
 @echo !gcodename! | findstr /C:"Llano" /C:"Trinity" /C:"Richland" /C:"Kaveri" /C:"Carrizo" /C:"Bristol Ridge" /C:"Raven Ridge" > %tempLog2%
 FOR /F "" %%m in (%tempLog2%) DO (
  set dverAccuracy=
  set iGPU=1
 )

 REM ----------------------------------------------
 REM�@iGPU���������Ă���A�Ȃ�����numOfGPUs==2�Ȃ�
 REM�@����͂��Ȃ킿dGPU�̐��͂P�Ƃ������ƂȂ̂ŁA
 REM�@�R�Â����m�����낤�Ƃ݂Ȃ��B
 REM ----------------------------------------------
 IF !iGPU!==1 (
  IF !numOfGPUs!==2 (
   set dverAccuracy=
  )
 )

 IF !show_gpu_details!==1 (
  (@echo �yGPU�z!gname! ^(!driverVersion!, !driverDate!^)!dverAccuracy! ^(!gcodename!^)^(!gmemtype!,!gmemsize!,!gtech!^)^(!gmanu!^)) >> %tempResultLog%
 ) ELSE (
  (@echo �yGPU�z!gname! ^(!driverVersion!, !driverDate!^)!dverAccuracy! ^(!gcodename!^)) >> %tempResultLog%
 )

)


exit /b %exitCode%

REM =======================================================
REM�@�� :gpu�̏I���
REM =======================================================

REM =======================================================
REM�@�� :storage�̎n�܂�B
REM =======================================================

:storage

REM ---------------------------------------------------------------------
REM�@������Storage�ɂ��āA���ꂼ�ꏈ�����s���B
REM�@�@�L�[���[�h Drive
REM�@�@���ɂ���L�[���[�h USB Devices
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM�@�uDrive�v�̍s��nlog���璊�o���A�V���ɍs�ԍ�������storageListLog�֕ۑ��B
REM�@storageListLog�̍s����numOfStorages�Ɋi�[�B
REM ---------------------------------------------------------------------
set storageListLog=%tempdir%\storageListLog.txt
set numOfStorages=0

findstr /B /R /C:"[0-9]*:Drive" %nlog% | findstr /V /N /C:"%nonExtString%" > %storageListLog%
FOR /F "" %%a in ('type %storageListLog% ^| find /V /C ""') DO (
 set numOfStorages=%%a
)

IF %numOfStorages%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuDrive�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM�@�eStorage�ɂ��Ă̏��������s�B
REM�@�@�E�ʂ̃��O�𒊏o���AtempLog�ɕۑ��B
REM�@�@�EtempLog����K�v�ȏ��𒊏o����B
REM�@�@�E���o���������yStorage�z�`�`���Ō��ʃt�@�C���ɏo�́B
REM ---------------------------------------------------------------------

REM ���̗v�f�ł���uUSB Devices�v�̍s�𒊏o���A�s�ԍ��𒲂ׂĂ����B
REM �Ō�̗v�f�ł͂��̍s�܂Ŏ擾���邱�ƂɂȂ�B
set USBDevicesCol=0
findstr /B /R /C:"[0-9]*:USB Devices" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set USBDevicesCol=%%a
)

IF %USBDevicesCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuUSB Devices�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM storageListLog�̊e�s�ɂ��ď������s���B
REM ---------------------------------------------------------------------

FOR /F "tokens=1,2 delims=:" %%a in (%storageListLog%) DO (

 set startCol=%%b

 IF %%a==%numOfStorages% (
  set /a "endCol = %USBDevicesCol% -1"
 ) ELSE (
  set /a "nextCol = %%a + 1"
  FOR /F "tokens=1,2 delims=:" %%e in ('findStr /B /C:"!nextCol!:" %storageListLog%') DO (
   set /a "endCol = %%f - 1"
  )
 )

 REM �Ή�����s��nlog���甲���o����tempLog�ɕۑ��B
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM ---------------------------------------------------------------------
 REM tempLog����K�v�v�f�𒊏o���Č��ʃt�@�C���ɏo�́B
 REM ---------------------------------------------------------------------

 set sname=�s��
 set stype=�s��
 set scapa=-
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Type" %tempLog%') DO (
  set stype=%%n
 )
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Name" %tempLog%') DO (
  set sname=%%n
 )
 FOR /F "tokens=3,4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Capacity" %tempLog%') DO (
  set scapa=%%m%%n%%o
 )

 REM ---------------------------------------------------------------------
 REM �uBus Type�v�ɂ́u11 x3�v�̂悤�ɐ��������łȂ����ɕ\�L�������Ƃ�����B
 REM�@���̂��ߕϊ������O�ɕ����������K�v�B
 REM ---------------------------------------------------------------------

 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Bus Type" %tempLog%') DO (
  (@echo %%n) > %tempLog2%
 )
 set bustype=�s��
 set bustypeex=
 FOR /F "tokens=1*" %%m in (%tempLog2%) DO (
  set bustype=%%m
  set bustypeex=%%n
 )

 REM ---------------------------------------------------------------------
 REM �uBus Type�v�̕ϊ�����
 REM�@�@�Q�l�F https://msdn.microsoft.com/en-us/library/windows/desktop/hh830493(v=vs.85).aspx
 REM ---------------------------------------------------------------------

 IF "!bustype!"=="0" set bustype=Unknown
 IF "!bustype!"=="1" set bustype=SCSI
 IF "!bustype!"=="2" set bustype=ATAPI
 IF "!bustype!"=="3" set bustype=ATA
 IF "!bustype!"=="4" set bustype=IEEE1394
 IF "!bustype!"=="5" set bustype=SSA
 IF "!bustype!"=="6" set bustype=FibreChannel
 IF "!bustype!"=="7" set bustype=USB
 IF "!bustype!"=="8" set bustype=RAID
 IF "!bustype!"=="9" set bustype=iSCSI
 IF "!bustype!"=="10" set bustype=SAS
 IF "!bustype!"=="11" set bustype=SATA
 IF "!bustype!"=="12" set bustype=SecureDigital
 IF "!bustype!"=="13" set bustype=MMC
 IF "!bustype!"=="14" set bustype=Virtual
 IF "!bustype!"=="15" set bustype=FileBackedVirtual
 IF "!bustype!"=="16" set bustype=StorageSpaces
 IF "!bustype!"=="17" set bustype=NVMe


 REM ---------------------------------------------------------------------
 REM Volume�̒���
 REM Volume�s�̓[���܂��͕����̉\��������B
 REM ---------------------------------------------------------------------
 set volumeList=^(
 FOR /F "tokens=3,4,5,6 delims=:,	 " %%m in ('findstr /B /R /C:"[0-9]*:	Volume" %tempLog%') DO (
  IF "!volumeList!"=="(" (
   set volumeList=!volumeList!%%m:\[%%o%%p]
  ) ELSE (
   set volumeList=!volumeList!, %%m:\[%%o%%p]
  )
 )
 IF "!volumeList!"=="(" (
  set volumeList=!volumeList!-^)
 ) ELSE (
  set volumeList=!volumeList!^)
 )


 REM ---------------------------------------------------------------------
 REM�@���ʃt�@�C���ւ̏o��
 REM ---------------------------------------------------------------------
 IF "!stype!"=="Removable" (
  IF !show_removableStorage!==1 (
   (@echo �yStorage�z!sname!,!scapa!!volumeList!,!bustype! !bustypeex!) >> %tempResultLog%
  )
 ) ELSE (
  (@echo �yStorage�z!sname!,!scapa!!volumeList!,!bustype! !bustypeex!) >> %tempResultLog%
 )

)


exit /b %exitCode%

REM =======================================================
REM�@�� :storage�̏I���
REM =======================================================

REM =======================================================
REM�@�� :monitor�̎n�܂�B
REM =======================================================

:monitor

REM ---------------------------------------------------------------------
REM�@������Monitor�ɂ��āA���ꂼ�ꏈ�����s���B
REM�@�@�L�[���[�h Monitor N
REM�@�@���ɂ���L�[���[�h Software
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM�@�uMonitor N�v�̍s��nlog���璊�o���A�V���ɍs�ԍ�������monitorListLog�֕ۑ��B
REM�@monitorListLog�̍s����numOfMonitors�Ɋi�[�B
REM ---------------------------------------------------------------------
set monitorListLog=%tempdir%\monitorListLog.txt
set numOfMonitors=0

findstr /B /R /C:"[0-9]*:Monitor [0-9]" %nlog% | findstr /V /N /C:"%nonExtString%" > %monitorListLog%
FOR /F "" %%a in ('type %monitorListLog% ^| find /V /C ""') DO (
 set numOfMonitors=%%a
)

IF %numOfMonitors%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuMonitor N�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM�@�eMonitor�ɂ��Ă̏��������s�B
REM�@�@�E�ʂ̃��O�𒊏o���AtempLog�ɕۑ��B
REM�@�@�EtempLog����K�v�ȏ��𒊏o����B
REM�@�@�E���o���������yMonitor�z�`�`���Ō��ʃt�@�C���ɏo�́B
REM ---------------------------------------------------------------------

REM ���̗v�f�ł���uSoftware�v�̍s�𒊏o���A�s�ԍ��𒲂ׂĂ����B
REM �Ō�̗v�f�ł͂��̍s�܂Ŏ擾���邱�ƂɂȂ�B
set SoftwareCol=0
findstr /B /R /C:"[0-9]*:Software" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set SoftwareCol=%%a
)

IF %SoftwareCol%==0 (
 call :colorEcho "CPU-Z�̃��O�ŁuSoftware�v��������܂���ł����B"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM monitorListLog�̊e�s�ɂ��ď������s���B
REM ---------------------------------------------------------------------

FOR /F "tokens=1,2 delims=:" %%a in (%monitorListLog%) DO (

 set startCol=%%b

 IF %%a==%numOfMonitors% (
  set /a "endCol = %SoftwareCol% - 1"
 ) ELSE (
  set /a "nextCol = %%a + 1"
  FOR /F "tokens=1,2 delims=:" %%e in ('findStr /B /C:"!nextCol!:" %monitorListLog%') DO (
   set /a "endCol = %%f - 1"
  )
 )

 REM �Ή�����s��nlog���甲���o����tempLog�ɕۑ��B
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM tempLog����K�v�v�f�𒊏o���Č��ʃt�@�C���ɏo�́B
 set monModel=�s��
 set monId=�s��
 set monSize=�s��
 set monRes=�s��
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Model" %tempLog%') DO (
  set monModel=%%n
 )
 FOR /F "tokens=2* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	ID" %tempLog%') DO (
  set monId=%%n
 )
 FOR /F "tokens=3,4* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Size" %tempLog%') DO (
  set monSize=%%m%%n%%o
 )
 FOR /F "tokens=4,5,6,7,8,9* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Max Resolution" %tempLog%') DO (
  set monRes=%%m%%n%%o%%p%%q%%r%%s
 )

 REM ---------------------------------------------------------------------
 REM�@���ʃt�@�C���ւ̏o��
 REM ---------------------------------------------------------------------
 (@echo �yMonitor�z!monModel!, !monId!, !monSize!, !monRes!) >> %tempResultLog%

)


exit /b %exitCode%

REM =======================================================
REM�@�� :monitor�̏I���
REM =======================================================

REM =======================================================
REM�@�� :replaceTabSpace�̎n�܂�
REM =======================================================

:replaceTabSpace

REM ---------------------------------------------
REM�@tempResultLog��
REM�@�@�E�^�u���X�y�[�X�ɒu��������
REM�@�@�E2�ȏ�A�����Ă���X�y�[�X��1�ɂ܂Ƃ߂�
REM�@�@�E�s���ɂ���X�y�[�X�͍폜����
REM�@�Ƃ����������s������ŁA�ŏI�I�Ȍ��ʃt�@�C���ւƏo�͂���B
REM ---------------------------------------------

REM more��/S(�����̋󔒍s��1�s�ɂ܂Ƃ߂�)�͔O�̂��߂ɂ��Ă邾��
REM /T1�Ń^�u���P�̃X�y�[�X�ɒu��
more /S /T1 %tempResultLog% > %tempLog%

REM �e�s���Ƃɕ����A�������X�y�[�X��s���̃X�y�[�X���폜����tempLog2�ɓ����
type nul > %tempLog2%
FOR /F "tokens=1 delims=" %%a in (%tempLog%) DO (
 call :replaceTabSpaceLine "%%a" %tempLog2%
)

REM tempLog2�����ʃt�@�C���ɏo�͂���
(echo.) >> %infoResultLog%
type %tempLog2% >> %infoResultLog%

exit /b %exitCode%

REM =======================================================
REM�@�� :replaceTabSpace�̏I���
REM =======================================================

REM =======================================================
REM�@�� :replaceTabSpaceLine�̎n�܂�
REM�@�@�@����%1�F �P�s���̕�����B""�ł������Ă���
REM�@�@�@����%2�F ���ʂ�ǋL����t�@�C����
REM
REM�@�@�@�����A���������p�X�y�[�X�͂P�̔��p�X�y�[�X�ɂ܂Ƃ߁A
REM�@�@�@�s���̔��p�X�y�[�X�͍폜���ăt�@�C���ɒǋL����
REM =======================================================

:replaceTabSpaceLine

set a=%~1%
IF NOT DEFINED a (
 @echo replaceTabSpaceLine: �����ɕ����񂪎w�肳��Ă��܂���
 set exitCode=1
 goto endReplaceTabSpaceLine
)

set resfile=%2
IF NOT DEFINED resfile (
 @echo replaceTabSpaceLine: �����ɏo�̓t�@�C�����w�肳��Ă��܂���
 set exitCode=1
 goto endReplaceTabSpaceLine
)

set count=0
set resultStr=

:strLoop

set /a "p1 = count + 1"
set c0=!a:~%count%,1!
set c1=!a:~%p1%,1!

IF NOT DEFINED c0 goto strLoopOut

IF "!c0!"==" " (
 IF DEFINED c1 (
  IF NOT "!c1!"==" " (
   set resultStr=!resultStr!!c0!
  )
 )
) ELSE (
 set resultStr=!resultStr!!c0!
)

set /a "count += 1"
goto strLoop

:strLoopOut

(@echo !resultStr!) >> %resfile%

:endReplaceTabSpaceLine

exit /b %exitCode%

REM =======================================================
REM�@�� :replaceTabSpaceLine�̏I���
REM =======================================================

REM =======================================================
REM�@�� :eraseSpace�̎n�܂�
REM�@�@�@����%1�F �P�s���̕�����B""�ł������Ă���
REM�@�@�@����%2�F ���ʂ�ǋL����t�@�C����
REM
REM�@�@�@�s���̔��p�X�y�[�X���폜���ăt�@�C���ɒǋL����
REM =======================================================

:eraseSpace

set a=%~1%
IF NOT DEFINED a (
 @echo eraseSpace: �����ɕ����񂪎w�肳��Ă��܂���
 set exitCode=1
 goto endEraseSpace
)

set resfile=%2
IF NOT DEFINED resfile (
 @echo eraseSpace: �����ɏo�̓t�@�C�����w�肳��Ă��܂���
 set exitCode=1
 goto endEraseSpace
)

set count=0
set resultStr=

:strLoop2

set /a "p1 = count + 1"
set c0=!a:~%count%,1!

IF NOT DEFINED c0 goto strLoopOut2

IF NOT "!c0!"==" " (
 set resultStr=!resultStr!!c0!
)

set /a "count += 1"
goto strLoop2

:strLoopOut2

(@echo !resultStr!) >> %resfile%

:endEraseSpace

exit /b %exitCode%

REM =======================================================
REM�@�� :eraseSpace�̏I���
REM =======================================================


REM ========================================
REM colorEcho
REM�@����%1�F�o�͂��镶����("�ň͂�)
REM
REM�@strcolor�Ŏw�肳�ꂽ�F�ŕ������o�͂���B
REM�@tempdir�ɕ�������t�@�C�����Ƃ����t�@�C�������̂�
REM�@�t�@�C�����Ɏg���Ȃ������͎w��ł��Ȃ��B
REM
REM�@�Q�l�ɂ����Ă����������T�C�g
REM�@�@http://scripting.cocolog-nifty.com/blog/2009/08/echo-447c.html
REM ========================================

:colorEcho

IF NOT EXIST %tempdir% (
 mkdir %tempdir% 2> nul
)

REM strcolor�ɂ��F�w�肪�Ȃ��Ȃ甒�ŁB
IF NOT DEFINED strcolor set strcolor=7

pushd %tempdir%

<nul >"%~1" cmd /k prompt $h
findstr /a:%strcolor% "." "%~1" nul
@echo.

popd

exit /b

REM ========================================
REM�@��:colorEcho�̏I���
REM ========================================
