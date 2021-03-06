@echo off&cd /d "%~dp0"&SETLOCAL&set "_fdp=%~dp0"
rem 当拖放文件到批处理时，默认目录并非当前批处理所在目录：%~dp0，而是用户的主目录：%USERPROFILE%
for /f "tokens=2-3delims=. " %%b in ('curl -V 2^>nul^|find/i "ssl"') do set _cv=%%b%%c&goto :next
:next
if defined _cv (if 1%_cv% lss 1749 echo,CURL version is too old, please update!&pause>nul&goto :EOF) else echo,curl.exe does not exist! please download:&echo,https://curl.haxx.se/download.html#Win32&pause>nul&goto :EOF

set/a _dbg=0,_tw=2,_rt=1
rem _tw：超时时间(curl -m, --max-time <time>参数值)；_rt：超时后重试次数

set _pmt=序号,IP,SNI
set "_c=curl -sm%_tw% --retry %_rt% --connect-to ::!_ipt! --no-keepalive https://"
set "_q=>nul&&set _r=Y||(if !errorlevel! equ 28 (set _r=Timeout) else set _r=No)"
if %_dbg% equ 1 (set "_c=%_c:-s=-sS%") else if %_dbg% gtr 1 set "_c=%_c:-s=-v%"

if "%~d1" neq "" (
rem    echo 检测到参数，处理输入参数&echo,%cmdcmdline%
    set "str=%cmdcmdline:"=%"
    SETLOCAL ENABLEDELAYEDEXPANSION&set _slf=1
    set "_ipt=%~1"&call :_fle
    if not defined _psf (
	for %%d in (baidu bing Google) do %_c%%%d.com/%_q%&echo,!_ipt!	!_r!	%%d
	%_c%g.co/favicon.ico%_q%
	echo,!_ipt!	!_r!	g.co&ENDLOCAL&set str=&set _tw=&set _pmt=&set _fdp=&set _dbg=&set _c=&set _q=&goto :eof
    )
    set "str=!str:%~f0 =!"
    set "str=!str: %~d1=" "%~d1!"
    for %%n in ("!str!") do (
	if defined _slf ENDLOCAL
	if exist "%%~fn\" (cls&echo "%%~fn"是目录，不是有效的文件，跳过！&echo,) else if exist "%%~fn" (
	    title "%~f0" "%%~fn"&set _id=1&set "_otn=%%~nn"
	    for /f "eol=# usebackq" %%p in ("%%~fn") do (set "_ipt=%%p"&call :_fle
		if not defined _psf (SETLOCAL ENABLEDELAYEDEXPANSION&call :_tSNI
		    if !_id! gtr 999 (set "_sp=") else if !_id! gtr 99 (set "_sp= ") else if !_id! gtr 9 (set "_sp=  ") else set "_sp=   "
		    echo,*!_sp!!_id!	!_ipt!	!_r!
		    echo,!_id!,!_ipt!,!_r!>>"!_otn!_!_otf!"&rem 此处用%%引用变量无效
		    for %%c in ("!_otf!")do ENDLOCAL&set "_otf=%%~c"&set/a_id+=1
		)
	    )
	    SETLOCAL ENABLEDELAYEDEXPANSION&(if !_id! gtr 1 echo,&echo -----输出文件："!_fdp!!_otn!_!_otf!")&ENDLOCAL
	)
    )
) else (
    title "%~f0"
    :_rip
    echo ※※※ 没有输入文件！关闭程序，或者：※※※&echo ①：输入（包含待测IP的）文件路径，
    echo ②：或者将（IP列表）文件拖放到本程序内，回车以继续：
    set _inpt=&set /p _inpt=③：输入“y”（小写）从本机Hosts读取IP：

    if defined _inpt (
	SETLOCAL ENABLEDELAYEDEXPANSION&set _slf=1&set _inpt="!_inpt:"=!"
	if !_inpt!=="" ENDLOCAL&cls&echo 输入无效，请重试。。。&echo,&goto :_rip
	if !_inpt!=="y" (set _id=1&set _otn=Hosts
	    for /f "eol=# tokens=1" %%m in (%windir%\system32\drivers\etc\hosts) do (
		set "_tin=%%m"	&rem %%m-IP；下面利用变量去除重复项
		if not defined #!_tin! if %%m neq 127.0.0.1 (set #!_tin!=#&set "_ipt=!_tin!"&call :_fle
		    if not defined _psf (
			call :_tSNI
			if !_id! gtr 999 (set "_sp=") else if !_id! gtr 99 (set "_sp= ") else if !_id! gtr 9 (set "_sp=  ") else set "_sp=   "
			echo,*!_sp!!_id!	!_ipt!	!_r!
			echo,!_id!,!_ipt!,!_r!>>"!_otn!_!_otf!"&set/a_id+=1
		    )
		)
	    )
	    for /f "eol=# tokens=1" %%m in (%windir%\system32\drivers\etc\hosts) do (
		if defined #%%m set #%%m=
	    )
	    if !_id! gtr 1 echo,&echo -----输出文件："!_fdp!!_otn!_!_otf!"
	    ENDLOCAL
	) else (
	    for %%n in (!_inpt!) do (
		if defined _slf ENDLOCAL
		if exist "%%~fn\" (cls&echo "%%~fn"是目录，不是有效的文件！&echo,&goto :_rip) else if exist "%%~fn" (
		    title "%~f0" "%%~fn"&set _id=1&set "_otn=%%~nn"
		    for /f "eol=# usebackq" %%p in ("%%~fn") do (set "_ipt=%%~p"&call :_fle
			if not defined _psf (SETLOCAL ENABLEDELAYEDEXPANSION&call :_tSNI
			    if !_id! gtr 999 (set "_sp=") else if !_id! gtr 99 (set "_sp= ") else if !_id! gtr 9 (set "_sp=  ") else set "_sp=   "
			    echo,*!_sp!!_id!	!_ipt!	!_r!
			    echo,!_id!,!_ipt!,!_r!>>"!_otn!_!_otf!"
			    for %%c in ("!_otf!")do ENDLOCAL&set "_otf=%%~c"&set/a_id+=1
			)
		    )
		    SETLOCAL ENABLEDELAYEDEXPANSION&(if !_id! gtr 1 echo,&echo -----输出文件："!_fdp!!_otn!_!_otf!")&ENDLOCAL
		) else cls&echo 文件不存在："%%~fn"&echo,&goto :_rip
	    )
	    if defined _slf ENDLOCAL&rem 如果!_inpt!包含通配符且没有匹配的文件时，for不会执行，因此需要另外ENDLOCAL
	)
    ) else cls&echo 输入无效，请重试。。。&echo,&goto :_rip
)
set _tw=&set _pmt=&set str=&set _pef=&set _id=&set _fdp=&set _otn=&set _ipt=&set _otf=&set _psf=

echo,&echo 完成，按任意键退出。&pause>nul
goto :eof

:_fle	rem 输入内容有效性验证
    SETLOCAL ENABLEDELAYEDEXPANSION&rem echo 输入：!_ipt!
    set _isf=&set _psf=
    if defined _ipt (rem 判断是否含有引号以及无效字符
	set "_in1=!_ipt:"=#!"
	set "_in2=!_ipt:"=@!"
	if "!_in1!" neq "!_in2!" ENDLOCAL&set _psf=1&goto :eof	rem !_ipt!包含引号，不能继续判断
	for /f "tokens=*delims=0123456789.abcdefghijklmnopqrstuvwxyz-ABCDEFGHIJKLMNOPQRSTUVWXYZ eol=" %%a in ("!_ipt!")do if "%%a" neq "" set _psf=1
    ) else set _psf=1&rem echo in :_fle 输入无效。

    if defined _psf (ENDLOCAL&set _psf=1&goto :eof)else (
	set _in1=!_ipt:..=!
	if "!_in1!" neq "!_ipt!" set _psf=1&rem echo 有多余的连续句点
	set _b=!_ipt:~0,1!&set _e=!_ipt:~-1!
	if "!_b!"=="." set _psf=1&rem echo 首有多余句点。。。
rem	if "!_e!"=="." set _psf=1&rem echo 尾有多余句点。。。
	set _in2=!_ipt:.=;!
	if "!_in2!"=="!_ipt!" set _psf=1&rem echo 不包含句点。。。

	set/a_ii=_it=0
	for %%c in (!_in2!) do (
	    set/a_ii+=1&set _!_ii!=%%c
	    if %%c leq 255 if %%c geq 0 set/a_it+=1
	    call set _bb=%%_!_ii!:~0,1%%&call set _ee=%%_!_ii!:~-1%%
	    if !_bb!==- set _psf=1&rem echo 有多余的横线-。
	    if !_ee!==- set _psf=1&rem echo 有多余的横线-。
	)
	for /f "tokens=*delims=0123456789. eol=" %%a in ("!_ipt!") do if "%%a"=="" if !_e! neq . if !_it! equ 4 if !_ii! equ 4 set _isf=1
	if not defined _isf set _psf=1&rem echo 不是有效的IP
    )
    if defined _psf ENDLOCAL&set _psf=1
goto :eof

:_tSNI
    if #%1==# if %_id%==1 (
	set _d=!date:~0,10!_!time:~0,-3!&set _d=!_d: =0!&set _d=!_d:/=!&set _d=!_d:-=!&set _d=!_d:.=!
	set "_otf=SNI-Test_!_d::=!.csv"&echo,%_pmt%>"%_otn%_!_otf!")
    %_c%google.com/%_q%
goto :eof


rem curl -sm2 --resolve g.co:443:%1 https://g.co/favicon.ico

curl -m2 --resolve www.google.com:443:203.210.8.42 https://www.google.com
curl -sm2 --resolve g.co:443:203.210.8.19 https://g.co/favicon.ico>nul&&set _r=1||set _r=0
curl -sm2 --resolve a.akamaihd.net:443:203.210.8.19 https://a.akamaihd.net>nul&&echo OK||echo No

curl -sm2 --connect-to ::203.210.8.37 https://www.google.com/ncr
curl -km2 --connect-to ::203.210.8.37 https://www.google.com/ncr