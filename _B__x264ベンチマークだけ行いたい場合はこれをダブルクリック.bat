
@echo off
cd /d %~dp0
setlocal ENABLEDELAYEDEXPANSION

REM =================================================================================
REM�@�����i�ꊇ�Ăяo�����Ɏw�肳�����́j
REM�@�@%1�F �G���R�[�h�ΏۂƂ��铮��t�@�C�����B
REM�@�@%2�F ���s���[�h�BAUTO�Ŏ������[�h(�Ō��pause�����Ȃ�����)
REM�@�@%3�F ���ʂ��i�[����t�@�C�����B�e�L�X�g�t�@�C��(*.txt)�̂ݎw��B
REM =================================================================================

REM �x���`�}�[�N�̃^�C�g��
set benchname=x264

REM �o�̓t�@�C�����̖`��
set outname=x264

@echo.
@echo %benchname%�̃x���`�}�[�N�����s���܂�...


REM =================================================================
REM�@�ꎞ�t�@�C����G���R�[�h�t�@�C����u���f�B���N�g��
REM =================================================================
set tempdir=.\temp
mkdir %tempdir% 2> nul

set encdir=.\encode
mkdir %encdir% 2> nul

REM -----------------------------------------------------------------------
REM x264�x���`�}�[�N�o�b�`���I��������ɍ쐬����t�@�C���B
REM ���̃t�@�C���̑��݃`�F�b�N�����邱�ƂŌĂяo�����ŏI���҂�������B
REM -----------------------------------------------------------------------
set x264BenchFinished=%tempdir%\x264BenchFinished.txt
del %x264BenchFinished% > nul 2>&1

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
set ffmpeg=%bindir%\ffmpeg.exe
set encoder=%bindir%\x264.exe

set encopt=--crf 20

REM =================================================================================
REM�@�o�C�i����G���R�[�h�Ώۂ̑��݃`�F�b�N
REM =================================================================================

IF NOT EXIST %ffmpeg% (
 @echo.
 call :colorEcho "�ȉ���ffmpeg��������܂���B�I�����܂��B"
 @echo �@�@%ffmpeg%
 @echo.
 set exitCode=1
 goto eof
)

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
(@echo �y!benchname!�z!encver! ^(!encdepth!bit^)) >> %encresultlog%

@echo.
@echo �@���̓t�@�C���͈ȉ��̃t�@�C���ł��B
@echo �@�@%inputfile%

REM �G���R�[�h�̎��s
REM �����ɂ͌Ăяo���̓x�ɃG���[���肵�������ǂ��Ǝv������
REM �킩��ɂ����Ȃ邵�A�����ł̓X���[����B

call :encode slower "�y.�@Slower�z" FIRST
call :encode slow "�y�@ �@Slow�z"
call :encode medium "�y. Medium�z"
call :encode veryfast "�yVeryfast�z"


:eof

REM -------------------------------------
REM �I���t�@�C���̍쐬
REM -------------------------------------
(@echo Finished!) > %x264BenchFinished%

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
set vertemp2=%tempdir%\vertemp2.txt
set encver=�s��
set encdepth=�s��

%encoder% --version > %vertemp%
more < %vertemp% > %vertemp2%
set /p encver=<%vertemp2%

FOR /F "tokens=4 delims==	 " %%a in ('findstr /B /C:"x264 configuration:" %vertemp2%') DO (
 set encdepth=%%a
)

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

set outfile=%encdir%\%outname%_%1.mkv
set outlog=%encdir%\%outname%_%1.log
set ffoutlog=%encdir%\%outname%_%1_ffmpeg.log

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
%ffmpeg% -i %inputfile% -strict -1 -f yuv4mpegpipe - 2> %ffoutlog% | %encoder% --demuxer y4m - --preset %1 %encopt% -o %outfile% >> %outlog% 2>&1
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
 FOR /F "tokens=2*" %%a in ('findstr /B /C:"y4m [info]:" %outlog%') DO (
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
