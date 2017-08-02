
@echo off
cd /d %~dp0
setlocal ENABLEDELAYEDEXPANSION

REM =================================================================================
REM　引数（一括呼び出し時に指定されるもの）
REM　　%1： エンコード対象とする動画ファイル名。
REM　　%2： 実行モード。AUTOで自動モード(最後のpauseをしないだけ)
REM　　%3： 結果を格納するファイル名。テキストファイル(*.txt)のみ指定可。
REM =================================================================================

REM =================================================================================
REM ★注意
REM　●NVEncに対応している環境と、rigaya氏のNVEncCが必要です。
REM　　　http://rigaya34589.blog135.fc2.com/
REM　　からNVEncをダウンロードし、その中のNVEncCフォルダを
REM　　このバッチのある場所のbinフォルダの下に置いて下さい。
REM　●エンコード対象として指定できるのは、
REM　　NVEncC.exe --avcuvidでハードウェアデコードできる動画ファイルのみです。
REM =================================================================================

REM ベンチマークのタイトル
set benchname=NVEncC H.264 VBRHQ

REM 出力ファイル名の冒頭
set outname=NVEncC_H264_VBRHQ

@echo.
@echo %benchname%のベンチマークを実行します...


REM =================================================================
REM　一時ファイルやエンコードファイルを置くディレクトリ
REM =================================================================
set tempdir=.\temp
mkdir %tempdir% 2> nul

set encdir=.\encode
mkdir %encdir% 2> nul

REM =================================================================
REM　いくつかのパラメータ設定
REM =================================================================

REM 終了コード
set exitCode=0

REM colorEchoによるエラー出力時の文字色指定。colorコマンド参照。Eは明るい黄色。
set strcolor=E

REM =================================================================
REM　結果を格納するファイル名(このファイルに追記する)
REM =================================================================

REM デフォルトの結果格納ファイル名
set encresultlog=".\ベンチマークの結果.txt"

REM 引数%3が指定されていた場合、その拡張子が.txtの場合だけ指定を許容する。
IF NOT "%~3"=="" (
 IF "%~x3"==".txt" (
  set encresultlog="%~3"
 ) ELSE (
  @echo.
  call :colorEcho "結果を追記するファイルとして指定できるのはテキストファイルのみです。"
  call :colorEcho "何もせず終了します。"
  @echo.
  set exitCode=1
  goto eof
 )
)

REM =================================================================
REM　エンコード対象の動画ファイル名
REM =================================================================

REM デフォルトのエンコード対象
set inputfile="test-1080p.mkv"
set inputfilename=test-1080p.mkv

REM 引数で指定されていた場合はそれをエンコード対象とする
IF NOT "%~1"=="" (
 set inputfile="%~1"
 set inputfilename=%~nx1
)

REM =================================================================================
REM　使用バイナリとオプション設定
REM =================================================================================

set bindir=.\bin
set encoder=%bindir%\NVEncC\x64\NVEncC64.exe
IF NOT "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
 set encoder=%bindir%\NVEncC\x86\NVEncC.exe
)

REM　VBRで指定するビットレートはデフォルト4000kbpsとしておくが、
REM　bin\vbr.ini が存在している場合はそこから読み込む。

set bitrate=4000

set initvbr=%bindir%\vbr.ini
IF EXIST "%initvbr%" (
 set /p bitrate=<%initvbr%
)

set encopt=--avcuvid --vbrhq %bitrate%

REM =================================================================================
REM　バイナリやエンコード対象の存在チェック
REM =================================================================================

IF NOT EXIST %encoder% (
 @echo.
 call :colorEcho "以下のエンコーダが見つかりません。終了します。"
 @echo 　　%encoder%
 @echo.
 set exitCode=1
 goto eof
)

IF NOT EXIST %inputfile% (
 @echo.
 call :colorEcho "以下の入力動画が見つかりません。終了します。"
 @echo 　　%inputfile%
 @echo.
 set exitCode=1
 goto eof
)

REM =================================================================================
REM　バージョンチェックとエンコード
REM =================================================================================

call :checkencver

(@echo.) >> %encresultlog%
(@echo 【!benchname!】!encver!) >> %encresultlog%

@echo.
@echo 　入力ファイルは以下のファイルです。
@echo 　　%inputfile%

REM エンコードの実行
REM 厳密には呼び出しの度にエラー判定した方が良いと思うけど
REM わかりにくくなるし、ここではスルーする。

call :encode quality "【Quality】" FIRST


:eof

@echo.
@echo %benchname%のベンチマークが終了しました。


IF NOT "%2"=="AUTO" (
 @echo.
 @echo 結果は %encresultlog% に追記されています。
 @echo また「%encdir%」にはエンコードした動画やログ、
 @echo 「%tempdir%」には一時出力ファイル等があります。
 @echo 特に必要ないなら、これらは削除して下さい。
 @echo.
 pause
)

exit /b %exitCode%

REM =======================================================
REM　↑メイン処理の終わり
REM =======================================================


REM ↓　ここから下はサブルーチン　↓


REM ==============================================================================
REM　↓ :checkencverの始まり。
REM ==============================================================================

:checkencver

set vertemp=%tempdir%\vertemp.txt
set encver=不明

%encoder% --version > %vertemp%
set /p encver=<%vertemp%

exit /b

REM ==============================================================================
REM　↑ :checkencverの終わり。
REM ==============================================================================


REM ==============================================================================
REM　↓ :encodeの始まり。
REM　　　　引数%1：プリセット名。
REM　　　　引数%2：出力用のプリセット文字列。
REM　　　　引数%3：FIRST と指定するとエンコードオプションと入力ファイル情報を出力
REM ==============================================================================

:encode

@echo.
@echo 　%benchname% --preset %1 %encopt% のエンコード中です...

set outfile=%encdir%\%outname%_%1.mp4
set outlog=%encdir%\%outname%_%1.log

(@echo ================================================================) > %outlog%
(@echo　↓ 指定オプション) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo !encopt!) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo　↓ 入力ファイル) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo !inputfile!) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo　↓ バージョン情報) >> %outlog%
(@echo ================================================================) >> %outlog%
(!encoder! --version) >> %outlog%
(@echo ================================================================) >> %outlog%
(@echo　↓ エンコードログ) >> %outlog%
(@echo ================================================================) >> %outlog%
call worktime.bat START
%encoder% -i %inputfile% --preset %1 %encopt% -o %outfile% >> %outlog% 2>&1
call worktime.bat STOP

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "　エンコードがうまくいかなかったようです。"
 call :colorEcho "　原因はencodeフォルダのログを参照して下さい。"
 set exitCode=%ERRORLEVEL%
 exit /b !exitCode!
)
IF NOT EXIST %outfile% (
 call :colorEcho "　出力ファイルが見つかりません。エンコードに失敗したようです。"
 call :colorEcho "　原因はencodeフォルダのログを参照して下さい。"
 set exitCode=1
 exit /b !exitCode!
)

@echo 　　　%DPS_STAMP%(%DPS2%秒)でエンコードしました。

REM FIRST指定がある時だけ、オプションと入力ファイル情報を出力する
IF "%3"=="FIRST" (
 (@echo 　【オプション】!encopt!) >> %encresultlog%
 FOR /F "tokens=2" %%a in ('findstr /B /C:"encoded" %outlog%') DO (
  (@echo %%a) > %tempdir%\frames.txt
 )
 set /p frames=<%tempdir%\frames.txt
 FOR /F "tokens=3*" %%a in ('findstr /B /C:"Input Info" %outlog%') DO (
  (@echo 　【入力ファイル情報】!inputfilename! %%b !frames!frames) >> %encresultlog%
 )
)

REM 結果の出力
FOR /F "tokens=3*" %%a in ('findstr /B /C:"encoded" %outlog%') DO (
 (@echo 　%~2 %%b) >> %encresultlog%
)

exit /b %exitCode%

REM =======================================================
REM　↑ :encodeの終わり
REM =======================================================

REM ========================================
REM colorEcho
REM　引数%1：出力する文字列("で囲む)
REM
REM　strcolorで指定された色で文字を出力する。
REM　tempdirに文字列をファイル名としたファイルを作るので
REM　ファイル名に使えない文字は指定できない。
REM
REM　参考にさせていただいたサイト
REM　　http://scripting.cocolog-nifty.com/blog/2009/08/echo-447c.html
REM ========================================

:colorEcho

IF NOT EXIST %tempdir% (
 mkdir %tempdir% 2> nul
)

REM strcolorによる色指定がないなら白で。
IF NOT DEFINED strcolor set strcolor=7

pushd %tempdir%

<nul >"%~1" cmd /k prompt $h
findstr /a:%strcolor% "." "%~1" nul
@echo.

popd

exit /b

REM ========================================
REM　↑:colorEchoの終わり
REM ========================================
