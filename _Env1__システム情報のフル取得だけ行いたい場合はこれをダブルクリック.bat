
@echo off
cd /d %~dp0
setlocal ENABLEDELAYEDEXPANSION

REM =================================================================================
REM　引数（一括呼び出し時に指定されるもの）
REM　　%1： 実行モード。AUTOで自動モード(メイン処理終了時のメッセージ出力とpauseをしないだけ)
REM　　%2： 結果を格納するファイル名。テキストファイル(*.txt)のみ指定可。
REM　　%3： 出力モード。FULL,NORMAL,SIMPLE,CPUZ_BENCH,X264BENCHのいずれか。
REM　　%4： ログ取得モード。RECYCLEの場合はCPU-Zによる新規ログ取得は行わず既得ログを利用する。
REM =================================================================================

REM =================================================================
REM　このシステム情報収集バッチの名称
REM =================================================================

set infobatchname=CPUZtoText_20170730


REM =================================================================
REM　一時出力ファイル
REM =================================================================
set tempdir=.\temp
mkdir %tempdir% 2> nul

REM 一時的に結果を格納しておくファイル
set tempResultLog=%tempdir%\tempResultLog.txt

REM 汎用的に使い回す一時出力ファイル
set tempLog=%tempdir%\tempLog.txt
set tempLog2=%tempdir%\tempLog2.txt

@echo.
set strcolor=A0
call :colorEcho "【SystemInfo】!infobatchname!"

REM =================================================================
REM　いくつかのパラメータ設定
REM =================================================================

REM 終了コード
set exitCode=0

REM colorEchoによるエラー出力時の文字色指定。colorコマンド参照。Eは明るい黄色。
set strcolor=E

REM CPU-Zのログに絶対出てこないであろう文字列(空行含めて行番号をつけたい時などに使う)
set nonExtString=ThisIsNonExistentCharacterStringInCpuzLog

REM =================================================================
REM　結果を格納するファイル名（指定したファイルに【追記】します）
REM =================================================================

REM デフォルトの結果格納ファイル名
set infoResultLog=.\システム情報の取得だけ行った結果.txt

REM 引数%2が指定されていた場合、その拡張子が.txtの場合だけ指定を許容する。
IF NOT "%~2"=="" (
 IF "%~x2"==".txt" (
  set infoResultLog=%2
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
REM　引数%3の出力モードの設定
REM　　出力項目が多すぎると困ることもあるので、
REM　　いくつかの項目の出力を抑える指定ができるようにする。
REM =================================================================

set outputMode=FULL
IF NOT "%~3"=="" (
 set outputMode=%~3
)

REM --------------------------------------------------
REM　出力制御項目
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
REM　FULL2： FULLから少しだけ制限
REM --------------------------------------------------
IF "%outputMode%"=="FULL2" (
 set show_allMemspec=0
 set show_removableStorage=0
)

REM --------------------------------------------------
REM　NORMAL： システム情報全般を比較的シンプルに取りたい場合
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
REM　SIMPLE： シンプルにシステム情報を取りたい場合
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
REM　CPUZ_BENCH： CPU-Zベンチマーク用
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
REM　X264BENCH： x264/x265ベンチマーク用
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
REM　バイナリの設定
REM =================================================================
set bindir=.\bin
set cpuz=%bindir%\cpuz_x32.exe
set cpuzArch=

REM cpuzArchはバイナリ種別を区別するためのもの。
REM CPU-Z 1.80.0でGUIからテキストログを取った場合、
REM x64ならCPU-ZのログのCPU-Z versionの末尾に.x64という表記がつくのだが
REM CLIで-txtオプションでログを取った場合は何故かその表記がない。
REM 多分バグなのだろうが、仕方ないので当面は独自に表記を追加する。

IF "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
 IF EXIST %bindir%\cpuz_x64.exe (
  set cpuz=%bindir%\cpuz_x64.exe
  set cpuzArch=.x64
 )
)

REM =================================================================================
REM　バイナリの存在チェック
REM =================================================================================

IF NOT EXIST %cpuz% (
 @echo.
 call :colorEcho "以下のCPU-Zが見つかりません。終了します。"
 @echo 　　%cpuz%
 @echo.
 set exitCode=1
 goto eof
)

REM =================================================================
REM　処理開始メッセージ
REM =================================================================

@echo.
@echo システム情報の取得を【%outputMode%】モードで開始します...

REM =================================================================
REM　CPU-Zのログファイル名
REM =================================================================
set cpuzlogname=cpu-z-log
set cpuzlog=%bindir%\%cpuzlogname%.txt

REM =================================================================
REM　CPU-Zのログをとる
REM =================================================================

REM %4がRECYCLEの場合はCPU-Zは起動せず、既得ログを使う。

IF NOT "%~4"=="RECYCLE" (
 @echo.
 @echo CPU-Zでシステム情報を調べています...
 call :colorEcho "　（ユーザーアカウント制御のダイアログで起動を許可して下さい）"

 %cpuz% -txt=%cpuzlogname%
)

REM =================================================================
REM　各バイナリのチェック
REM =================================================================
@echo.
@echo バイナリのバージョンを調べています...

call :checkbinary

(@echo 【SystemInfo】!infobatchname! ^(CPU-Z !cpuzVer!!cpuzArch!^)) > %tempResultLog%

IF !show_cpuz!==1 (
 (@echo 【CPU-Z】!cpuzVer!!cpuzArch!) >> %tempResultLog%
)

REM =================================================================
REM　CPU-Zのログから必要なシステム情報を調べる
REM =================================================================
@echo.
@echo CPU-Zのログから必要なシステム情報を抽出しています...

call :checksystem

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "システム情報の抽出がうまくいかなかったようです。"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto eof
)


@echo.
@echo 抽出した情報を整形しています...

call :replaceTabSpace

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "抽出した情報の整形がうまくいかなかったようです。"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto eof
)


:eof

@echo.
@echo システム情報の取得が完了しました。

IF NOT "%1"=="AUTO" (
 @echo.
 @echo 結果は 「%infoResultLog%」 に【追記】されています。
 @echo また %tempdir% には一時出力ファイル等があります。
 @echo 特に必要ないなら、これらは削除して下さい。
 @echo.
 @echo ※注意
 @echo 　CPU-Zのログ形式の都合上、複数のGPUがある場合、
 @echo 　GPUのドライバ情報の対応付けが不確実になることがあります。
 @echo 　GPUのドライバ情報の右側に疑問符がついている場合は、
 @echo 　対応付けを自分で確認し、間違っていたら修正して下さい。
 @echo.
 @echo ※注意
 @echo 　オーバークロック^(OC^)の設定状態などは調べることができません。
 @echo 　それらの点については補足説明を添えて情報を提示すると良いでしょう。
 @echo.
 pause
)

exit /b %exitCode%

REM =======================================================
REM　↑メイン処理の終わり
REM =======================================================



REM ↓　ここから下はサブルーチン　↓



REM =======================================================
REM　↓ :checkbinaryの始まり
REM =======================================================

:checkbinary

REM -----------------------------------------------------------------
REM　バイナリのバージョンを調べる
REM -----------------------------------------------------------------

set cpuzVer=不明
FOR /F "tokens=2*" %%a in ('findstr /B /C:"CPU-Z version" %cpuzlog%') DO (
 set cpuzVer=%%b
)


exit /b

REM =======================================================
REM　↑ :checkbinaryの終わり
REM =======================================================


REM =======================================================
REM　↓ :checksystemの始まり
REM =======================================================

:checksystem

REM -----------------------------------------------------------------
REM　CPU-Zのログからシステムの情報を抽出する
REM -----------------------------------------------------------------

REM まずは抽出用に行番号付きのログファイルを生成しておく
set nlog=%tempdir%\%cpuzlogname%_n.txt
findstr /V /N /C:"%nonExtString%" %cpuzlog% > %nlog%


REM -----------------------------------------------
REM　CPU
REM -----------------------------------------------

call :cpu

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "CPUの情報の抽出がうまくいかなかったようです。"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto checksystemEOF
)


REM -----------------------------------------------
REM　MotherBoard, Memory
REM -----------------------------------------------

call :chipset

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "MotherBoardやMemoryの情報の抽出がうまくいかなかったようです。"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto checksystemEOF
)


REM -----------------------------------------------
REM　MemSpec
REM -----------------------------------------------

IF !show_memspec!==1 (

 call :memspec

 REM -------------------------------------------------------
 REM なんかIFが入れ子になってるとERRORLEVELを遅延展開しても
 REM 内側のIFの中ではうまく展開されないようなので
 REM 一度別の変数に格納して受け渡すようにした。
 REM -------------------------------------------------------
 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "MemSpecの情報の抽出がうまくいかなかったようです。"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)

REM -----------------------------------------------
REM　BIOS
REM -----------------------------------------------

IF !show_bios!==1 (

 call :bios

 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "BIOSの情報の抽出がうまくいかなかったようです。"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)


REM -----------------------------------------------
REM　GPU
REM -----------------------------------------------

call :gpu

IF NOT %ERRORLEVEL%==0 (
 call :colorEcho "GPUの情報の抽出がうまくいかなかったようです。"
 @echo.
 set exitCode=%ERRORLEVEL%
 goto checksystemEOF
)


REM -----------------------------------------------
REM　Storage
REM -----------------------------------------------

IF !show_storage!==1 (

 call :storage

 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "Storageの情報の抽出がうまくいかなかったようです。"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)

REM -----------------------------------------------
REM　Monitor
REM -----------------------------------------------

IF !show_monitor!==1 (

 call :monitor

 set myErrorLevel=!ERRORLEVEL!

 IF NOT !myErrorLevel!==0 (
  call :colorEcho "Monitorの情報の抽出がうまくいかなかったようです。"
  @echo.
  set exitCode=!myErrorLevel!
  goto checksystemEOF
 )

)

REM -----------------------------------------------
REM　OS, DirectX
REM -----------------------------------------------
set osname=-
set dxVer=-
FOR /F "tokens=2*" %%a in ('findstr /B /C:"Windows Version" %cpuzlog%') DO (
 set osname=%%b
)
FOR /F "tokens=2*" %%a in ('findstr /B /C:"DirectX Version" %cpuzlog%') DO (
 set dxVer=%%b
)
(@echo 【OS】!osname! 【DirectX】!dxVer!) >> %tempResultLog%

:checksystemEOF

exit /b %exitCode%

REM =======================================================
REM　↑ :checksystemの終わり
REM =======================================================


REM =======================================================
REM　↓ :cpuの始まり。
REM =======================================================

:cpu

REM ---------------------------------------------------------------------
REM　とりあえず「DMI Processor」から
REM　　・clock speed
REM　　・FSB speed
REM　　・multiplier
REM　を取得しておく。
REM　マルチプロセッサーの場合、複数の「DMI Processor」があるんだろうか・・・
REM　そこがよくわからないので、とりあえず見つけた１つから抽出したものを使う。
REM　FOR文の関係上、複数ある場合は後の方が使われる。
REM ---------------------------------------------------------------------
set DMIProcessorCol=0
FOR /F "tokens=1 delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:DMI Processor" %nlog%') DO (
 set DMIProcessorCol=%%a
)

IF %DMIProcessorCol%==0 (
 call :colorEcho "CPU-Zのログで「DMI Processor」が見つかりませんでした。"
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
set clkspd=不明
set fsb=不明
set mul=不明
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
REM　複数のSocketについて、それぞれ処理を行う。
REM　　キーワード Socket N\t\t\tID
REM　　次にくるキーワード Thread dumps
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM　「Socket N ID」の行をnlogから抽出し、新たに行番号をつけてcpuListLogへ保存。
REM　cpuListLogの行数をnumOfCPUsに格納。
REM ---------------------------------------------------------------------
set cpuListLog=%tempdir%\cpuListLog.txt
set numOfCPUs=0

findstr /B /R /C:"[0-9]*:Socket [0-9]			ID" %nlog% | findstr /V /N /C:"%nonExtString%" > %cpuListLog%
FOR /F "" %%a in ('type %cpuListLog% ^| find /V /C ""') DO (
 set numOfCPUs=%%a
)

IF %numOfCPUs%==0 (
 call :colorEcho "CPU-ZのログでCPUを示す「Socket N」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM　各CPUについての処理を実行。
REM　　・個別のログを抽出し、tempLogに保存。
REM　　・tempLogから必要な情報を抽出する。
REM　　・抽出した情報を【CPU】～形式で出力。
REM ---------------------------------------------------------------------

REM 次の要素である「Thread dumps」の行を抽出し、行番号を調べておく。
REM 最後の要素ではこの行まで取得することになる。
set threadDumpsCol=0
findstr /B /R /C:"[0-9]*:Thread dumps" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set threadDumpsCol=%%a
)

IF %threadDumpsCol%==0 (
 call :colorEcho "CPU-Zのログで「Thread dumps」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM cpuListLogの各行について処理を行う。
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
  call :colorEcho "CPU-ZのログでCPU情報の領域を特定できませんでした。"
  @echo.
  set exitCode=1
  exit /b !exitCode!
 )

 REM 対応する行をnlogから抜き出してtempLogに保存。
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM ---------------------------------------------------------------------
 REM tempLogから必要要素を抽出する。
 REM ---------------------------------------------------------------------
 set cores=不明
 set threads=不明
 set codename=不明
 set cpuname=不明
 set cpuSimpleName=不明
 set socket=不明
 set cpuID=不明
 set exCpuId=不明
 set coreStep=不明
 set tech=不明
 set tdplimit=不明
 set instSet=不明
 set L1DataCache=
 set L1InstCache=
 set L2Cache=
 set L3Cache=
 set L4Cache=
 set maxRatioNT=?
 set maxRatioT=?
 set maxRatioE=?
 set volt0=不明

 set coreSpeed=不明
 set mulBusSpeed=不明
 set coreSpeedNow=不明
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
 REM Socket(Package)については、
 REM　　・Package (platform ID)　←Intel系？
 REM　　・Package　←AMD系？
 REM の２パターンの要素名があるらしいので、それに対応。
 REM Packageでの検索は他の要素と被って駄目なので、Socketで検索する。
 REM Socketエントリの行が引っかからないよう、データの方を示す「\tSocket」で検索。
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
 REM　ターボブースト関連
 REM --------------------------------------------

 REM ターボブースト関連の情報が１つでも取れたら1にする
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
 REM 「Ratio N core(s)」の取得
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
 REM 結果ファイルへの出力
 REM --------------------------------------------

 IF !show_cpu_simpleName!==1 (
  (@echo 【CPU】!cpuSimpleName! ^(!codename!^)^(!cores!cores/!threads!threads^)^(!tech!^)) >> %tempResultLog%
 ) ELSE (
  (@echo 【CPU】!cpuname! ^(!codename!^)^(!cores!Cores/!threads!Threads^)^(!tech!^)) >> %tempResultLog%
 )

 IF !show_cpuFreq!==1 (
  (@echo 　　!clkspd!^(!mul!!fsb!^)^(!tdplimit!W^)^(!volt0!V^)) >> %tempResultLog%
 )

 IF !show_cpuCoreSpeedNow!==1 (
  (@echo 　　情報取得時の動作周波数→ !coreSpeedNow!) >> %tempResultLog%
 )

 IF !show_cpuTurbo!==1 (
  IF !turboFlag!==1 (
   (@echo 　　^(!maxRatioE!-!maxRatioNT!-!maxRatioT!^) !coresRatio!) >> %tempResultLog%
  )
 )

 IF !show_cpuSocket!==1 (
  (@echo 　　^(!socket!^)^(!cpuId!, !exCpuId!, !coreStep!^)) >> %tempResultLog%
 )

 IF !show_cpuCache!==1 (
  (@echo 　　!L1DataCache! !L1InstCache! !L2Cache! !L3Cache! !L4Cache!) >> %tempResultLog%
 )

 IF !show_instructionSet!==1 (
  (@echo 　　!instSet!) >> %tempResultLog%
 )

)


exit /b %exitCode%

REM =======================================================
REM　↑ :cpuの終わり。
REM =======================================================

REM =======================================================
REM　↓ :chipsetの始まり。
REM =======================================================

:chipset

REM ---------------------------------------------------------------------
REM　MotherBoard、GraphicIF、Memoryの情報を抽出する
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM　とりあえず「DMI Baseboard」から
REM　　・vendor
REM　　・model
REM　を取得しておく。
REM ---------------------------------------------------------------------
set DMIBaseBoardCol=0
FOR /F "tokens=1 delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:DMI Baseboard" %nlog%') DO (
 set DMIBaseBoardCol=%%a
)

IF %DMIBaseBoardCol%==0 (
 call :colorEcho "CPU-Zのログで「DMI Baseboard」が見つかりませんでした。"
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
set bdVendor=不明
set bdModel=不明
FOR /F "tokens=1*" %%a in ('findstr /B /C:"vendor" %dmiboardlog%') DO (
 set bdVendor=%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"model" %dmiboardlog%') DO (
 set bdModel=%%b
)


REM ---------------------------------------------------------------------
REM　Chipsetについて、処理を行う。
REM　　キーワード Chipset
REM　　次にくるキーワード Memory SPD
REM ---------------------------------------------------------------------

REM まずは「Chipset」の行を抽出し、行番号を調べておく。
set chipsetCol=0
findstr /B /R /C:"[0-9]*:Chipset" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set chipsetCol=%%a
)

IF %chipsetCol%==0 (
 call :colorEcho "CPU-Zのログで「Chipset」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM 次の要素である「Memory SPD」の行を抽出し、行番号を調べる。
set memSPDCol=0
findstr /B /R /C:"[0-9]*:Memory SPD" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set /a "memSPDCol = %%a - 1"
)

IF %memSPDCol%==0 (
 call :colorEcho "CPU-Zのログで「Memory SPD」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM -----------------------------------------------
REM 必要情報を抽出していく。
REM -----------------------------------------------

REM 対応する行をnlogから抜き出してtempLogに保存。
type nul > %tempLog%
FOR /L %%i in (!chipsetCol!, 1, !memSPDCol!) DO (
 findstr /B /C:"%%i:" %nlog% >> %tempLog%
)

REM -----------------------------------------------
REM tempLogから必要要素を抽出。
REM -----------------------------------------------
set nBridge=不明
set sBridge=不明
set graphicIF=-
set pcieLinkWidth=-
set pcieMaxLinkWidth=-
set memType=不明
set memSize=不明
set memChannel=不明
set memFreq=不明

REM tRCとtRFCはどちらかしか出ない(？)ようなので空初期化
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
REM 結果ファイルへの出力
REM -----------------------------------------------

IF !show_MB!==1 (

 IF !show_MB_vendor!==1 (
  (@echo 【MotherBoard】!bdModel! ^(!bdVendor!^)) >> %tempResultLog%
 ) ELSE (
  (@echo 【MotherBoard】!bdModel!) >> %tempResultLog%
 )

 IF !show_MB_bridge!==1 (
  (@echo 　　North:^(!nBridge!^), South:^(!sBridge!^)) >> %tempResultLog%
 )

)

IF !show_graphicIF!==1 (
 (@echo 【Graphic I/F】!graphicIF!^(!pcieLinkWidth!,max:!pcieMaxLinkWidth!^)) >> %tempResultLog%
)

IF !show_mem_timing!==1 (
 (@echo 【Memory】!memType!,!memSize!,!memChannel!,!memFreq!,!CL!-!tRCD!-!tRP!-!tRAS!!tRC!!tRFC!-!CR!) >> %tempResultLog%
) ELSE (
 (@echo 【Memory】!memType!,!memSize!,!memChannel!,!memFreq!) >> %tempResultLog%
)


exit /b %exitCode%

REM =======================================================
REM　↑ :chipsetの終わり
REM =======================================================

REM =======================================================
REM　↓ :memspecの始まり。
REM =======================================================

:memspec

REM ---------------------------------------------------------------------
REM　　キーワード SMBus address
REM　　次にくるキーワード Monitoring
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM　「SMBus address」の行をnlogから抽出し、新たに行番号をつけてmemoryListLogへ保存。
REM　memoryListLogの行数をnumOfMemoriesに格納。
REM ---------------------------------------------------------------------
set memoryListLog=%tempdir%\memoryListLog.txt
set numOfMemories=0

findstr /B /R /C:"[0-9]*:	SMBus address" %nlog% | findstr /V /N /C:"%nonExtString%" > %memoryListLog%
FOR /F "" %%a in ('type %memoryListLog% ^| find /V /C ""') DO (
 set numOfMemories=%%a
)

IF %numOfMemories%==0 (
 call :colorEcho "CPU-Zのログで「SMBus address」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM 次の要素である「SPD registers」の最初の行を抽出し、行番号を調べておく。
REM 最後の要素ではこの行まで取得することになる。
REM ---------------------------------------------------------------------
set spdRegCol=0
findstr /B /R /C:"[0-9]*:SPD registers" %nlog% > %tempLog%
set /p spdRegFirst=<%tempLog%
FOR /F "tokens=1 delims=:" %%a in ('@echo !spdRegFirst!') DO (
 set spdRegCol=%%a
)

IF %spdRegCol%==0 (
 call :colorEcho "CPU-Zのログで「SPD registers」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM　各メモリについての処理を実行。
REM　　・個別のログを抽出し、tempLogに保存。
REM　　・tempLogから必要な情報を抽出する。
REM　　・抽出した情報を【MemSpec】～形式でmemspecListLogに保存。
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
 REM 対応する行をnlogから抜き出してtempLogに保存。
 REM -----------------------------------------------
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM -----------------------------------------------
 REM tempLogから必要要素を抽出してmemspecListLogに保存。
 REM -----------------------------------------------
 set memtype=不明
 set modfmt=不明
 set manuid=不明
 set memsize=不明
 set maxband=不明
 set part=不明
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

 (@echo 【MemSpec】!memtype!,!maxband!,!memsize!,!modfmt!,!memEx!,!manuid!,!part!) >> %memspecListLog%

)

REM ---------------------------------------------------------------------
REM　結果ファイルへの出力
REM ---------------------------------------------------------------------

IF !show_allMemspec!==1 (

 type %memspecListLog% >> %tempResultLog%

) ELSE (

 REM ---------------------------------------------------------------------
 REM　内容が同一の行は１行分だけ結果ファイルに出力する。
 REM　　・memspecListLogをtempLogとしてコピー。
 REM　　・tempLogから最初の行を取り出し、結果ファイルに出力。
 REM　　・findstr /V /C:"最初の行" で最初の行と一致しないものだけを抽出し、tempLogに保存。
 REM　　・tempLog が空になるまで続ける。
 REM ---------------------------------------------------------------------

 copy /Y %memspecListLog% %tempLog% > nul
 set count=0

:memspecLoop
REM なんかIFの中にラベルを置くとシンタックスエラーが起きるが
REM ラベル直下にコメントを入れると回避できるらしいのでいれとく。

 REM ---------------------------------------------------------------------
 REM　１行目を取り出して結果ファイルへ出力
 REM ---------------------------------------------------------------------
 set /p lineData=<%tempLog%
 IF "!lineData!"=="" (
  goto memspecLoopOut
 )

 (@echo !lineData!) >> %tempResultLog%

 REM ---------------------------------------------------------------------
 REM　重複している行を取り除き、まだ行が残っているなら再ループ。
 REM　行が無くなるまで続ける。
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
REM 一応コメント文を入れておこう・・・

exit /b %exitCode%

REM =======================================================
REM　↑ :memspecの終わり
REM =======================================================

REM =======================================================
REM　↓ :biosの始まり。
REM =======================================================

:bios

REM ---------------------------------------------------------------------
REM　「DMI BIOS」から
REM　　・vendor
REM　　・version
REM　　・date
REM　を取得しておく。
REM ---------------------------------------------------------------------
set DMIBIOSCol=0
FOR /F "tokens=1 delims=:	 " %%a in ('findstr /B /R /C:"[0-9]*:DMI BIOS" %nlog%') DO (
 set DMIBIOSCol=%%a
)

IF %DMIBIOSCol%==0 (
 call :colorEcho "CPU-Zのログで「DMI BIOS」が見つかりませんでした。"
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
set biosVendor=不明
set biosVer=不明
set biosDate=不明
FOR /F "tokens=1*" %%a in ('findstr /B /C:"vendor" %dmibioslog%') DO (
 set biosVendor=%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"version" %dmibioslog%') DO (
 set biosVer=%%b
)
FOR /F "tokens=1*" %%a in ('findstr /B /C:"date" %dmibioslog%') DO (
 set biosDate=%%b
)

(@echo 【BIOS】!biosVendor!^(!biosVer!^)^(!biosDate!^)) >> %tempResultLog%

exit /b %exitCode%

REM =======================================================
REM　↑ :biosの終わり
REM =======================================================

REM =======================================================
REM　↓ :gpuの始まり。
REM =======================================================

:gpu

REM ---------------------------------------------------------------------
REM　DriverVersionのリストの作成。
REM　DriverVersionはDisplay adapterとは別のところで一覧表示されており、
REM　複数のDisplay adapterがあった場合、
REM　Display adapterとDriverVersionとを明確に紐づけることはできない。
REM　ただ、
REM　　・iGPUのDisplay adapterは一番最初にあるものと思われる
REM　　・DriverVersionはAdapterRAMの値と紐づけることが可能であり、
REM　　　また、iGPUの場合、AdapterRAMの値は比較的小さくなっていると思われる。
REM　ということから、AdapterRAMの値が最も小さいDriverVersionを
REM　最初のDisplay adapterと結び付ければ、iGPUのDriverVersionは
REM　ほぼ確実に紐づけられると考えられる。
REM　よってDriverVersionは、AdapterRAMの数値で小さい順にソートするものとする。
REM　ソート済みのリストの形式は以下のようにする
REM　　　行番号:16進数のAdapterRAM値:DriverVersion:DriverDate
REM ---------------------------------------------------------------------

set adapterRAMList=%tempdir%\adapterRAMList.txt
set numOfAdapters=0
findstr /B /C:"Win32_VideoController		AdapterRAM" %cpuzlog% > %tempLog%
findstr /V /N /C:"%nonExtString%" %tempLog% > %adapterRAMList%
FOR /F "" %%a in ('type %adapterRAMList% ^| find /V /C ""') DO (
 set numOfAdapters=%%a
)

IF %numOfAdapters%==0 (
 call :colorEcho "CPU-Zのログで「AdapterRAM」が見つかりませんでした。"
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
 call :colorEcho "CPU-Zのログで「DriverVersion」が見つかりませんでした。"
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
 call :colorEcho "CPU-Zのログで「DriverDate」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM AdapterRAMとDriverVersionとDriverDateを結びつける
REM ---------------------------------------------------------------------
type nul > %tempLog%
FOR /L %%i in (1, 1, %numOfAdapters%) DO (

 set adapterRAM=
 set driverVersion=
 set driverDate=

 REM AdapterRAMの16進数値の取り出し
 FOR /F "tokens=5 delims=:	 " %%a in ('findstr /B /C:"%%i:" %adapterRAMList%') DO (
  set adapterRAM=%%a
 )

 REM DriverVersionの取り出し
 FOR /F "tokens=5 delims=:	 " %%a in ('findstr /B /C:"%%i:" %driverVersionList%') DO (
  set driverVersion=%%a
 )

 REM DriverDateの取り出し
 FOR /F "tokens=5 delims=:	 " %%a in ('findstr /B /C:"%%i:" %driverDateList%') DO (
  set driverDate=%%a
 )

 (@echo !adapterRAM!:!driverVersion!:!driverDate!) >> %tempLog%
)

REM ---------------------------------------------------------------------
REM 内容をadapterRAMの値でソートした上で行番号をつけてdriverListに保存。
REM ---------------------------------------------------------------------
sort %tempLog% > %tempLog2%
set driverList=%tempdir%\driverList.txt
findstr /V /N /C:"%nonExtString%" %tempLog2% > %driverList%


REM ---------------------------------------------------------------------
REM　複数のDisplay adapterについて、それぞれ処理を行う。
REM　　キーワード Display adapter N
REM　　次にくるキーワード Win32_VideoController
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM　「Display adapter N」の行をnlogから抽出し、新たに行番号をつけてgpuListLogへ保存。
REM　gpuListLogの行数をnumOfGPUsに格納。
REM ---------------------------------------------------------------------
set gpuListLog=%tempdir%\gpuListLog.txt
set numOfGPUs=0
set iGPU=0

findstr /B /R /C:"[0-9]*:Display adapter [0-9]" %nlog% | findstr /V /N /C:"%nonExtString%" > %gpuListLog%
FOR /F "" %%a in ('type %gpuListLog% ^| find /V /C ""') DO (
 set numOfGPUs=%%a
)

IF %numOfGPUs%==0 (
 call :colorEcho "CPU-Zのログで「Display adapter N」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM　各GPUについての処理を実行。
REM　　・個別のログを抽出し、tempLogに保存。
REM　　・tempLogから必要な情報を抽出する。
REM　　・抽出した情報を【GPU】～形式で結果ファイルへ出力。
REM ---------------------------------------------------------------------

REM 次の要素である「Win32_VideoController」の行を抽出し、行番号を調べておく。
REM 最後の要素ではこの行まで取得することになる。
set winVidCtrlCol=0
findstr /B /R /C:"[0-9]*:Win32_VideoController" %nlog% > %tempLog%
set /p firstWinVidCtrl=<%tempLog%
FOR /F "tokens=1 delims=:" %%a in ('@echo !firstWinVidCtrl!') DO (
 set winVidCtrlCol=%%a
)

IF %winVidCtrlCol%==0 (
 call :colorEcho "CPU-Zのログで「Win32_VideoController」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM gpuListLogの各行について処理を行う。
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
 REM 対応する行をnlogから抜き出してtempLogに保存。
 REM ---------------------------------------------------------------------
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM ---------------------------------------------------------------------
 REM tempLogから必要要素を抽出して結果ファイルに出力。
 REM ---------------------------------------------------------------------
 set gname=不明
 set gmanu=不明
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
 REM DriverVersion,DriverDateの紐づけ処理
 REM ----------------------------------------------

 set driverNum=0
 set driverVersion=不明
 set driverDate=不明

 REM ----------------------------------------------
 REM DriverVersion等の紐づけは不確実なので、複数のGPUが存在する場合は?をつけて
 REM DriverVersionの確認を促す。
 REM ----------------------------------------------
 set dverAccuracy=?
 IF !numOfGPUs!==1 (
  set dverAccuracy=
 )

 REM driverListの先頭行を取る
 set /p driverInfo=<%driverList%
 FOR /F "tokens=1-4 delims=:" %%m in ('@echo !driverInfo!') DO (
　set driverNum=%%m
  set driverVersion=%%o
  set driverDate=%%p
 )

 REM driverListの先頭行を削除する
 findstr /V /B /C:"!driverNum!:" %driverList% > %tempLog2%
 move /Y %tempLog2% %driverList% > nul

 REM ----------------------------------------------
 REM tempLog内にiGPUを示す文字列が見つかったらiGPUだとみなし、
 REM それならまあDriverVersionの紐づけの確実度も高いだろうとみなす。
 REM ----------------------------------------------

 REM ----------------------------------------------
 REM gnameにIntelという文字列がある場合
 REM ----------------------------------------------
 @echo !gname! | findstr /C:"Intel" > %tempLog2%
 FOR /F "" %%m in (%tempLog2%) DO (
  set dverAccuracy=
  set iGPU=1
 )

 REM ----------------------------------------------
 REM gcodenameにAMD APUを表す文字列がある場合
 REM ----------------------------------------------
 @echo !gcodename! | findstr /C:"Llano" /C:"Trinity" /C:"Richland" /C:"Kaveri" /C:"Carrizo" /C:"Bristol Ridge" /C:"Raven Ridge" > %tempLog2%
 FOR /F "" %%m in (%tempLog2%) DO (
  set dverAccuracy=
  set iGPU=1
 )

 REM ----------------------------------------------
 REM　iGPUが見つかっており、なおかつnumOfGPUs==2なら
 REM　それはすなわちdGPUの数は１つということなので、
 REM　紐づけも確かだろうとみなす。
 REM ----------------------------------------------
 IF !iGPU!==1 (
  IF !numOfGPUs!==2 (
   set dverAccuracy=
  )
 )

 IF !show_gpu_details!==1 (
  (@echo 【GPU】!gname! ^(!driverVersion!, !driverDate!^)!dverAccuracy! ^(!gcodename!^)^(!gmemtype!,!gmemsize!,!gtech!^)^(!gmanu!^)) >> %tempResultLog%
 ) ELSE (
  (@echo 【GPU】!gname! ^(!driverVersion!, !driverDate!^)!dverAccuracy! ^(!gcodename!^)) >> %tempResultLog%
 )

)


exit /b %exitCode%

REM =======================================================
REM　↑ :gpuの終わり
REM =======================================================

REM =======================================================
REM　↓ :storageの始まり。
REM =======================================================

:storage

REM ---------------------------------------------------------------------
REM　複数のStorageについて、それぞれ処理を行う。
REM　　キーワード Drive
REM　　次にくるキーワード USB Devices
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM　「Drive」の行をnlogから抽出し、新たに行番号をつけてstorageListLogへ保存。
REM　storageListLogの行数をnumOfStoragesに格納。
REM ---------------------------------------------------------------------
set storageListLog=%tempdir%\storageListLog.txt
set numOfStorages=0

findstr /B /R /C:"[0-9]*:Drive" %nlog% | findstr /V /N /C:"%nonExtString%" > %storageListLog%
FOR /F "" %%a in ('type %storageListLog% ^| find /V /C ""') DO (
 set numOfStorages=%%a
)

IF %numOfStorages%==0 (
 call :colorEcho "CPU-Zのログで「Drive」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM　各Storageについての処理を実行。
REM　　・個別のログを抽出し、tempLogに保存。
REM　　・tempLogから必要な情報を抽出する。
REM　　・抽出した情報を【Storage】～形式で結果ファイルに出力。
REM ---------------------------------------------------------------------

REM 次の要素である「USB Devices」の行を抽出し、行番号を調べておく。
REM 最後の要素ではこの行まで取得することになる。
set USBDevicesCol=0
findstr /B /R /C:"[0-9]*:USB Devices" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set USBDevicesCol=%%a
)

IF %USBDevicesCol%==0 (
 call :colorEcho "CPU-Zのログで「USB Devices」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM storageListLogの各行について処理を行う。
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

 REM 対応する行をnlogから抜き出してtempLogに保存。
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM ---------------------------------------------------------------------
 REM tempLogから必要要素を抽出して結果ファイルに出力。
 REM ---------------------------------------------------------------------

 set sname=不明
 set stype=不明
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
 REM 「Bus Type」には「11 x3」のように数字だけでなく後ろに表記がつくことがある。
 REM　そのため変換処理前に分離処理が必要。
 REM ---------------------------------------------------------------------

 FOR /F "tokens=3* delims=:	 " %%m in ('findstr /B /R /C:"[0-9]*:	Bus Type" %tempLog%') DO (
  (@echo %%n) > %tempLog2%
 )
 set bustype=不明
 set bustypeex=
 FOR /F "tokens=1*" %%m in (%tempLog2%) DO (
  set bustype=%%m
  set bustypeex=%%n
 )

 REM ---------------------------------------------------------------------
 REM 「Bus Type」の変換処理
 REM　　参考： https://msdn.microsoft.com/en-us/library/windows/desktop/hh830493(v=vs.85).aspx
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
 REM Volumeの調査
 REM Volume行はゼロまたは複数の可能性がある。
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
 REM　結果ファイルへの出力
 REM ---------------------------------------------------------------------
 IF "!stype!"=="Removable" (
  IF !show_removableStorage!==1 (
   (@echo 【Storage】!sname!,!scapa!!volumeList!,!bustype! !bustypeex!) >> %tempResultLog%
  )
 ) ELSE (
  (@echo 【Storage】!sname!,!scapa!!volumeList!,!bustype! !bustypeex!) >> %tempResultLog%
 )

)


exit /b %exitCode%

REM =======================================================
REM　↑ :storageの終わり
REM =======================================================

REM =======================================================
REM　↓ :monitorの始まり。
REM =======================================================

:monitor

REM ---------------------------------------------------------------------
REM　複数のMonitorについて、それぞれ処理を行う。
REM　　キーワード Monitor N
REM　　次にくるキーワード Software
REM ---------------------------------------------------------------------

REM ---------------------------------------------------------------------
REM　「Monitor N」の行をnlogから抽出し、新たに行番号をつけてmonitorListLogへ保存。
REM　monitorListLogの行数をnumOfMonitorsに格納。
REM ---------------------------------------------------------------------
set monitorListLog=%tempdir%\monitorListLog.txt
set numOfMonitors=0

findstr /B /R /C:"[0-9]*:Monitor [0-9]" %nlog% | findstr /V /N /C:"%nonExtString%" > %monitorListLog%
FOR /F "" %%a in ('type %monitorListLog% ^| find /V /C ""') DO (
 set numOfMonitors=%%a
)

IF %numOfMonitors%==0 (
 call :colorEcho "CPU-Zのログで「Monitor N」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)

REM ---------------------------------------------------------------------
REM　各Monitorについての処理を実行。
REM　　・個別のログを抽出し、tempLogに保存。
REM　　・tempLogから必要な情報を抽出する。
REM　　・抽出した情報を【Monitor】～形式で結果ファイルに出力。
REM ---------------------------------------------------------------------

REM 次の要素である「Software」の行を抽出し、行番号を調べておく。
REM 最後の要素ではこの行まで取得することになる。
set SoftwareCol=0
findstr /B /R /C:"[0-9]*:Software" %nlog% > %tempLog%
FOR /F "tokens=1 delims=:" %%a in (%tempLog%) DO (
 set SoftwareCol=%%a
)

IF %SoftwareCol%==0 (
 call :colorEcho "CPU-Zのログで「Software」が見つかりませんでした。"
 @echo.
 set exitCode=1
 exit /b !exitCode!
)


REM ---------------------------------------------------------------------
REM monitorListLogの各行について処理を行う。
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

 REM 対応する行をnlogから抜き出してtempLogに保存。
 type nul > %tempLog%
 FOR /L %%i in (!startCol!, 1, !endCol!) DO (
  findstr /B /C:"%%i:" %nlog% >> %tempLog%
 )

 REM tempLogから必要要素を抽出して結果ファイルに出力。
 set monModel=不明
 set monId=不明
 set monSize=不明
 set monRes=不明
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
 REM　結果ファイルへの出力
 REM ---------------------------------------------------------------------
 (@echo 【Monitor】!monModel!, !monId!, !monSize!, !monRes!) >> %tempResultLog%

)


exit /b %exitCode%

REM =======================================================
REM　↑ :monitorの終わり
REM =======================================================

REM =======================================================
REM　↓ :replaceTabSpaceの始まり
REM =======================================================

:replaceTabSpace

REM ---------------------------------------------
REM　tempResultLogに
REM　　・タブをスペースに置き換える
REM　　・2つ以上連続しているスペースを1つにまとめる
REM　　・行末にあるスペースは削除する
REM　という処理を行った上で、最終的な結果ファイルへと出力する。
REM ---------------------------------------------

REM moreの/S(複数の空白行を1行にまとめる)は念のためにつけてるだけ
REM /T1でタブを１つのスペースに置換
more /S /T1 %tempResultLog% > %tempLog%

REM 各行ごとに複数連続したスペースや行末のスペースを削除してtempLog2に入れる
type nul > %tempLog2%
FOR /F "tokens=1 delims=" %%a in (%tempLog%) DO (
 call :replaceTabSpaceLine "%%a" %tempLog2%
)

REM tempLog2を結果ファイルに出力する
(echo.) >> %infoResultLog%
type %tempLog2% >> %infoResultLog%

exit /b %exitCode%

REM =======================================================
REM　↑ :replaceTabSpaceの終わり
REM =======================================================

REM =======================================================
REM　↓ :replaceTabSpaceLineの始まり
REM　　　引数%1： １行分の文字列。""でくくられている
REM　　　引数%2： 結果を追記するファイル名
REM
REM　　　複数連続した半角スペースは１つの半角スペースにまとめ、
REM　　　行末の半角スペースは削除してファイルに追記する
REM =======================================================

:replaceTabSpaceLine

set a=%~1%
IF NOT DEFINED a (
 @echo replaceTabSpaceLine: 引数に文字列が指定されていません
 set exitCode=1
 goto endReplaceTabSpaceLine
)

set resfile=%2
IF NOT DEFINED resfile (
 @echo replaceTabSpaceLine: 引数に出力ファイルが指定されていません
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
REM　↑ :replaceTabSpaceLineの終わり
REM =======================================================

REM =======================================================
REM　↓ :eraseSpaceの始まり
REM　　　引数%1： １行分の文字列。""でくくられている
REM　　　引数%2： 結果を追記するファイル名
REM
REM　　　行内の半角スペースを削除してファイルに追記する
REM =======================================================

:eraseSpace

set a=%~1%
IF NOT DEFINED a (
 @echo eraseSpace: 引数に文字列が指定されていません
 set exitCode=1
 goto endEraseSpace
)

set resfile=%2
IF NOT DEFINED resfile (
 @echo eraseSpace: 引数に出力ファイルが指定されていません
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
REM　↑ :eraseSpaceの終わり
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
