SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, mouse, screen



Gui, Add, Text,, Initials:
Gui, Add, Text,, Date:
Gui, Add, Text,, Batch-nr:
Gui, Add, Text,, Tid EOS:
Gui, Add, Text,, Prøvestørrelse (mL):
Gui, Add, Text,, Total mængde i batch(mL):
Gui, Add, Text,, Aktivitet for hele batch ved EOS(GBq):
Gui, Add, Text,, Filename (Same as Batch):
Gui, Add, Text,, Measuring time(min):
Gui, Add, Text,, Nuclide:
Gui, Add, Edit, vInitials ym  ; The ym option starts a new column of controls.
Gui, Add, Edit, vDate
Gui, Add, Edit, vBatchNr
Gui, Add, DateTime, vEOS, dddd d, MMMM yyyy hh:mm:ss 
Gui, Add, Edit, vTempSizeOfSample
Gui, Add, Edit, vTempSizeOfBatch
Gui, Add, Edit, vTempEOSBq
Gui, Add, Edit, vFileName
Gui, Add, Edit, vUserInput
Gui, Add, DropDownList, vNuclideChoice, 18F||11C|68Ga
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Add, Button, , Cancel ;
Gui, Show,, Gamma spektroskopi
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:

ButtonCancel:
ExitApp

ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.

ratioOfActivity := TempSizeOfSample / TempSizeOfBatch

Gui, 2:Add, Text,, Initials: %Initials%
Gui, 2:Add, Text,, Date: %Date%
Gui, 2:Add, Text,, Batch-nr: %BatchNr%
Gui, 2:Add, Text,, EOS(YYYYMMDDHHMISS): %EOS%
Gui, 2:Add, Text,, Prøvestørrelse (mL): %TempSizeOfSample%
Gui, 2:Add, Text,, Total mængde i batch(mL): %TempSizeOfBatch%
Gui, 2:Add, Text,, Aktivitet for hele batch ved EOS(GBq): %TempEOSBq%
Gui, 2:Add, Text,, Filename: %FileName%
Gui, 2:Add, Text,, Measuring time: %UserInput%
Gui, 2:Add, Text,, Nuclide: %NuclideChoice%
Gui, 2:Add, Button, default, Confirm  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, 2:Add, Button, , Abort ;
Gui, 2:Show,, Gamma spek
return

2ButtonAbort:
ExitApp

;Program goes here
2ButtonConfirm:
Gui, Destroy
Gui, 2:Destroy

EOSBq := ratioOfActivity*TempEOSBq*1000000000


;Omregn tid tid i minutter til ms, da Autohotkey bruger ms i sleep kommandoen
;Det der bliver lagt til er en deadtime paa 10 % af det indtastede for at vaere sikker
RunTime := (UserInput*60*1000)+(UserInput*60*1000*0.02)

;Start Genie
Sleep 6000
Send #r
Sleep 1000
Send C:\GENIE2K\EXEFILES\mvcg.exe
Sleep 1000
Send {Enter}
Sleep 6000
Click 456, 103
Sleep 1000

;Maksimer vindue
IfWinExist, Gamma Acquisition & Analysis
{
	WinActivate
	WinMaximize
}

;Open Ge-detector
Sleep 1000
Send !+F
Sleep 1000
Send O
Sleep 1000
Click 378,396
Sleep 1000
Click 342,308
Sleep 1000
Click 673,364
Sleep 6000

;Load Energy- og FWHM-kalibration
Sleep 1000
Send !+C
Sleep 2000
Send L
Sleep 2000
Click 355,230
Sleep 2000
Click 655,380
Sleep 2000
Click 355,230
Sleep 2000
Click 328,464
Sleep 2000
Click 655,380

;Vaelg live time
Sleep 2000
Send !+m
Sleep 1000
Send s
Sleep 1000
Click 435,273

;Vaelg minutes
Sleep 1000
Click 541,319

;Slet gammel tid og indtast ny tid
Sleep 2000
Click 569,274
Sleep 1000
Click down right
Sleep 1000
Click up right
Sleep 1000
Send {Down}
Send {Down}
Send {Down}
Send {Down}
Send {Down}
Send {Down}
Sleep 1000
Send {Enter}
Sleep 1000
Send %UserInput%

;Tryk ok
Sleep 2000
Click 380, 497


;Slet gammel data og ROIs
Sleep 2000
Click 58,166
Sleep 1000
Click 520,401
Sleep 2000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Timestamp for start for måling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MesStarted = %A_NOW%

;Start opsamling
Sleep 2000
Send {F4}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Opsamlingen er nu igang
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sleep for den tid som det tager plus 10% deadtime
Sleep %RunTime%

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Opsamlingen er faerdig
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Gem spectra
Sleep 1000
Send !+F
Sleep 1000
Send A
Sleep 1000
Click 392,470
Sleep 1000
Send c:\Kemi\
Sleep 1000
Send %FileName%
Sleep 1000
Send {Enter}



;Koer sekvens, her vaegles den rette sekvens udfra valget i starten
If NuclideChoice = 18F
{
	Send !+A
	Sleep 1000
	Send {Right}
	Sleep 1000
	Send {Down}
	Sleep 1000
	Send {Enter}
	Sleep 10000
}
else if NuclideChoice = 11C
{
	Send !+A
	Sleep 1000
	Send {Right}
	Sleep 1000
	Send {Enter}
	Sleep 10000
}
else if NuclideChoice = 68Ga
{
	Send !+A
	Sleep 1000
	Send {Right}
	Sleep 1000
	Send {Down}
	Send {Down}
	Sleep 1000
	Send {Enter}
	Sleep 10000
}

;Kopier plot til clipboard
Sleep 6000
Send !+F
Sleep 3000
Send b
Sleep 3000
Send {Enter}

;Gem plot som jpg
Sleep 6000
Send #r
Sleep 1000
Send C:\IrfanView\i_view32.exe /clippaste /convert=C:\kemi\
Sleep 1000
Send %FileName%
Sleep 1000
Send .jpg
Sleep 3000
Send {Enter}
Sleep 6000
Click 456, 103
Sleep 6000

;Kopier indhold fra rapport vindue
Send !+O
Sleep 3000
Send R
Sleep 3000
Send C

;Gem indhold fra rapport vindue til rapport fil
Sleep 6000
FileAppend, %Clipboard%, C:\Kemi\%FileName%.txt
Sleep 6000

string1 = Acquisition Started
string2 = Live Time
string3 = Real Time
string4 = Dead Time
string5 = Spectrum File Name
string6 = ****************************
string7 = I N T E R F E R E N C E
writerestoffile = 0

FileAppend, <pre>`n, C:\kemi\%FileName%part1.txt

FileAppend,
(
Initials: %Initials%
Date: %Date%
Batch-nr: %BatchNr%
EOS: %EOS%
EOS Activity: %EOSBq%

<img src="c:\kemi\%FileName%.jpg" alt="">

*************************************************************************
*****            AUTOMATIC GAMMA ACQUISITION REPORT                 *****
*************************************************************************

), C:\kemi\%FileName%part1.txt

Loop, read, C:\kemi\%FileName%.txt, C:\kemi\%FileName%part1.txt
{
    IfInString, A_LoopReadLine, %string2%
	{
		IfInString, lastline, %string1%, FileAppend, %lastline%`n
		;MsgBox, The string was found %lastline%.
	}
	
	IfInString, A_LoopReadLine, %string2%, FileAppend, %A_LoopReadLine%`n
	
	IfInString, A_LoopReadLine, %string3%, FileAppend, %A_LoopReadLine%`n
	
	IfInString, A_LoopReadLine, %string4%, FileAppend, %A_LoopReadLine%`n
	
	IfInString, A_LoopReadLine, %string5%, FileAppend, %A_LoopReadLine%`n
	
    IfInString, A_LoopReadLine, %string7%
	{
		IfInString, lastline, %string6%
			{
				FileAppend, %lastline%`n, C:\kemi\%FileName%part2.txt
				writerestoffile = 1
				
			}
	}	
	
	if (writerestoffile = 1)
	{
		FileAppend, %A_LoopReadLine%`n, C:\kemi\%FileName%part2.txt
	}
	lastline = %A_LoopReadLine%
}

FileAppend, Rapport godkendt af (Dato og signatur):`n, C:\kemi\%FileName%part2.txt
FileAppend, `n, C:\kemi\%FileName%part2.txt
FileAppend, `n, C:\kemi\%FileName%part2.txt
FileAppend, `n, C:\kemi\%FileName%part2.txt
FileAppend, </pre>`n, C:\kemi\%FileName%part2.txt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Læg realtime til tidspunkt for start af måling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string1 = Real Time

	   
;OLD: EndOfMes := %MesStarted%
EndOfMes = %MesStarted%
;TimeSinceEOS
Loop, read, C:\kemi\%FileName%.txt, C:\kemi\TimeSinceEOS.txt
{
	;IfInString, A_LoopReadLine, %string1%, FileAppend, %A_LoopReadLine%`n
	
	IfInString, A_LoopReadLine, %string1%
	{
		StringTrimLeft, test1, A_LoopReadLine, 37
		StringTrimRight, timetoadd, test1, 10
		
		
		EndOfMes += %timetoadd%, seconds
		;OLD: TimeSinceEOS := %EndOfMes%
		TimeSinceEOS = %EndOfMes%
		EnvSub, TimeSinceEOS, %EOS%, minutes 
		TimeSinceEOS := TimeSinceEOS / 60

		;Udkommenter det nedenunder for at få tid siden måling start i timer skrevet til fil: tidsleg
		FileAppend, EOS: %EOS%`n
		FileAppend, Slut for maaling: %EndOfMes%`n
		FileAppend, Tid siden EOS(Timer): %TimeSinceEOS%`n
		
	}
	
}

;Nu vil vi koere GAMMAlyser, det er igen afhaengigt af hvilken isotop der er valgt i starten, derfor denne if-else
If NuclideChoice = 18F
{
	Sleep 6000
	Send #r
	Sleep 1000
	Send C:\GAMMAlyser\GAMMAlyser.exe C:\kemi\%FileName%part2.txt %TimeSinceEOS% %EOSBq% 1 1 isotopes-18F.txt 6 109.7
	Sleep 6000
	Send {Enter}
	Sleep 12000
}
else if NuclideChoice = 11C
{
	Sleep 6000
	Send #r
	Sleep 1000
	Send C:\GAMMAlyser\GAMMAlyser.exe C:\kemi\%FileName%part2.txt %TimeSinceEOS% %EOSBq% 1 1 isotopes-18F.txt 3 20.5
	Sleep 6000
	Send {Enter}
	Sleep 12000
}
else if NuclideChoice = 68Ga
{
	Sleep 6000
	Send #r
	Sleep 1000
	Send C:\GAMMAlyser\GAMMAlyser.exe C:\kemi\%FileName%part2.txt %TimeSinceEOS% %EOSBq% 1 1 isotopes-18F.txt 5 68
	Sleep 6000
	Send {Enter}
	Sleep 12000
}

Sleep 6000
Send #r
Sleep 3000
Send cmd
Sleep 3000
Send {Enter}
Sleep 2000
Send copy C:\kemi\cnuclide-report.txt{+}C:\kemi\%FileName%part1.txt{+}C:\kemi\%FileName%part2.txt C:\kemi\%FileName%report.html
Sleep 3000
Send {Enter}
Sleep 3000
Send exit
Sleep 3000
Send {Enter}

;Indsæt her kopir reporthtml til en txt fil som kan læses af analyse programmet

;Generer PDF rapport
Sleep 12000
Send #r
Sleep 3000
Send C:\wkhtmltopdf\bin\wkhtmltopdf.exe C:\kemi\%FileName%report.html C:\kemi\%FileName%report.pdf
Sleep 3000
Send {Enter}
Sleep 2000

;Ryk alt til en folder med samme navn som filnavnet
Sleep 6000
Send #r
Sleep 3000
Send cmd
Sleep 3000
Send {Enter}
Sleep 2000
Send mkdir C:\kemi\%FileName%
Sleep 3000
Send {Enter}
Sleep 2000
Send move C:\kemi\* C:\kemi\%FileName%
Sleep 3000
Send {Enter}
Sleep 3000
Send exit
Sleep 3000
Send {Enter}

MsgBox Analysis for file: %Filename% is done. 
ExitApp

#x::ExitApp
ExitApp
