
@echo off
cd /d %~dp0
setlocal ENABLEDELAYEDEXPANSION

REM =================================================================================
REM�@�����i�ꊇ�Ăяo�����Ɏw�肳�����́j
REM�@�@%1�F �G���R�[�h�ΏۂƂ��铮��t�@�C�����B
REM�@�@%2�F ���s���[�h�BAUTO�Ŏ������[�h(�Ō��pause�����Ȃ�����)
REM�@�@%3�F ���ʂ��i�[����t�@�C�����B�e�L�X�g�t�@�C��(*.txt)�̂ݎw��B
REM =================================================================================

REM =================================================================================
REM ������
REM�@��NVEnc�ɑΉ����Ă�����ƁArigaya����NVEncC���K�v�ł��B
REM�@�@�@http://rigaya34589.blog135.fc2.com/
REM�@�@����NVEnc���_�E�����[�h���A���̒���NVEncC�t�H���_��
REM�@�@���̃o�b�`�̂���ꏊ��bin�t�H���_�̉��ɒu���ĉ������B
REM�@���G���R�[�h�ΏۂƂ��Ďw��ł���̂́A
REM�@�@NVEncC.exe --avcuvid�Ńn�[�h�E�F�A�f�R�[�h�ł��铮��t�@�C���݂̂ł��B
REM =================================================================================

REM �x���`�}�[�N�̃^�C�g��
set benchname=NVEncC H.264 VBRHQ

REM �o�̓t�@�C�����̖`��
set outname=NVEncC_H264_VBRHQ

@echo.
@echo %benchname%�̃x���`�}�[�N�����s���܂�...


REM =================================================================
REM�@�ꎞ�t�@�C����G���R�[�h�t�@�C����u���f�B���N�g��
REM =================================================================
set tempdir=.\temp
mkdir %tempdir% 2> nul

set encdir=.\encode
mkdir %encdir% 2> nul

REM =================================================================
REM�@�������̃p�����[�^�ݒ�
REM =================================================================

REM �I���R�[�h
set exitCode=0

REM colorEcho�ɂ��G���[�o�͎��̕����F�w��Bcolor�R�}���h�Q�ƁBE�͖��邢���F�B
set strcolor=E

REM =================================================================
REM�@���ʂ��i�[����t�@�C����(���̃t�@�C���ɒǋL����)
REM =================================================================

REM �f�t�H���g�̌��ʊi�[�t�@�C����
set encresultlog=".\�x���`�}�[�N�̌���.txt"

REM ����%3���w�肳��Ă����ꍇ�A���̊g���q��.txt�̏ꍇ�����w������e����B
IF NOT "%~3"=="" (
 IF "%~x3"==".txt" (
  set encresultlog="%~3"
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
REM�@�G���R�[�h�Ώۂ̓���t�@�C����
REM =================================================================

REM �f�t�H���g�̃G���R�[�h�Ώ�
set inputfile="test-1080p.mkv"
set inputfilename=test-1080p.mkv

REM �����Ŏw�肳��Ă����ꍇ�͂�����G���R�[�h�ΏۂƂ���
IF NOT "%~1"=="" (
 set inputfile="%~1"
 set inputfilename=%~nx1
)

REM =================================================================================
REM�@�g�p�o�C�i���ƃI�v�V�����ݒ�
REM =================================================================================

set bindir=.\bin
set encoder=%bindir%\NVEncC\x64\NVEncC64.exe
IF NOT "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
 set encoder=%bindir%\NVEncC\x86\NVEncC.exe
)

REM�@VBR�Ŏw�肷��r�b�g���[�g�̓f�t�H���g4000kbps�Ƃ��Ă������A
REM�@bin\vbr.ini �����݂��Ă���ꍇ�͂�������ǂݍ��ށB

set bitrate=4000

set initvbr=%bindir%\vbr.ini
IF EXIST "%initvbr%" (
 set /p bitrate=<%initvbr%
)

set encopt=--avcuvid --vbrhq %bitrate%

REM =================================================================================
REM�@�o�C�i����G���R�[�h�Ώۂ̑��݃`�F�b�N
REM =================================================================================

IF NOT EXIST %encoder% (
 @echo.
 call :colorEcho "�ȉ��̃G���R�[�_��������܂���B�I�����܂��B"
 @echo �@�@%encoder%
 @echo.
 set exitCode=1
 goto eof
)

IF NOT EXIST %inputfile% (
 @echo.
 call :colorEcho "�ȉ��̓��͓��悪������܂���B�I�����܂��B"
 @echo �@�@%inputfile%
 @echo.
 set exitCode=1
 goto eof
)

REM =================================================================================
REM�@�o�[�W�����`�F�b�N�ƃG���R�[�h
REM =================================================================================

call :checkencver

(@echo.) >> %encresultlog%
(@echo �y!benchname!�z!encver!) >> %encresultlog%

@echo.
@echo �@���̓t�@�C���͈ȉ��̃t�@�C���ł��B
@echo �@�@%inputfile%

REM �G���R�[�h�̎��s
REM �����ɂ͌Ăяo���̓x�ɃG���[���肵�������ǂ��Ǝv������
REM �킩��ɂ����Ȃ邵�A�����ł̓X���[����B

call :encode quality "�yQuality�z" FIRST


:eof

@echo.
@echo %benchname%�̃x���`�}�[�N���I�����܂����B


IF NOT "%2"=="AUTO" (
 @echo.
 @echo ���ʂ� %encresultlog% �ɒǋL����Ă��܂��B
 @echo �܂��u%encdir%�v�ɂ̓G���R�[�h��������⃍�O�A
 @echo �u%tempdir%�v�ɂ͈ꎞ�o�̓t�@�C����������܂��B
 @echo ���ɕK�v�Ȃ��Ȃ�A�����͍폜���ĉ������B
 @echo.
 pause
)

exit /b %exitCode%

REM =======================================================
REM�@�����C�������̏I���
REM =======================================================


REM ���@�������牺�̓T�u���[�`���@��


REM ==============================================================================
REM�@�� :checkencver�̎n�܂�B
REM ==============================================================================

:checkencver

set vertemp=%tempdir%\vertemp.txt
set encver=�s��

%encoder% --version > %vertemp%
set /p encver=<%vertemp%

exit /b

REM ==============================================================================
REM�@�� :checkencver�̏I���B
REM ==============================================================================


REM ==============================================================================
REM�@�� :encode�̎n�܂�B
REM�@�@�@�@����%1�F�v���Z�b�g���B
REM�@�@�@�@����%2�F�o�͗p�̃v���Z�b�g������B
REM�@�@�@�@����%3�FFIRST �Ǝw�肷��ƃG���R�[�h�I�v�V�����Ɠ��̓t�@�C�������o��
REM ==============================================================================

:encode

@echo.
@echo �@%benchname% --preset %1 %encopt% �̃G���R�[�h���ł�...

set outfile=%encdir%\%outname%_%1.mp4
set outlog=%encdir%\%outname%_%1.log

(@echo ================================================================) > %outlog%
(@echo�@�� �w��I�v�V����) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo !encopt!) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo�@�� ���̓t�@�C��) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo !inputfile!) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo�@�� �o�[�W�������) >> %outlog%
(@echo ================================================================) >> %outlog%
(!encoder! --version) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo�@�� �G���R�[�h���O) >> %outlog%
(@echo ================================================================) >> %outlog%
call worktime.bat START
%encoder% -i %inputfile% --preset %1 %encopt% -o %outfile% >> %outlog% 2>&1
call worktime.bat STOP

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "�@�G���R�[�h�����܂������Ȃ������悤�ł��B"
 call :colorEcho "�@������encode�t�H���_�̃��O���Q�Ƃ��ĉ������B"
 set exitCode=%ERRORLEVEL%
 exit /b !exitCode!
)
IF NOT EXIST %outfile% (
 call :colorEcho "�@�o�̓t�@�C����������܂���B�G���R�[�h�Ɏ��s�����悤�ł��B"
 call :colorEcho "�@������encode�t�H���_�̃��O���Q�Ƃ��ĉ������B"
 set exitCode=1
 exit /b !exitCode!
)

@echo �@�@�@%DPS_STAMP%(%DPS2%�b)�ŃG���R�[�h���܂����B

REM FIRST�w�肪���鎞�����A�I�v�V�����Ɠ��̓t�@�C�������o�͂���
IF "%3"=="FIRST" (
 (@echo �@�y�I�v�V�����z!encopt!) >> %encresultlog%
 FOR /F "tokens=2" %%a in ('findstr /B /C:"encoded" %outlog%') DO (
  (@echo %%a) > %tempdir%\frames.txt
 )
 set /p frames=<%tempdir%\frames.txt
 FOR /F "tokens=3*" %%a in ('findstr /B /C:"Input Info" %outlog%') DO (
  (@echo �@�y���̓t�@�C�����z!inputfilename! %%b !frames!frames) >> %encresultlog%
 )
)

REM ���ʂ̏o��
FOR /F "tokens=3*" %%a in ('findstr /B /C:"encoded" %outlog%') DO (
 (@echo �@%~2 %%b) >> %encresultlog%
)

exit /b %exitCode%

REM =======================================================
REM�@�� :encode�̏I���
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
