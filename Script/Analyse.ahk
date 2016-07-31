SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, mouse, screen

MsgBox, Please select af CNF file for analysis.

FileSelectFile, SelectedFile, 3, C:\GENIE2K\CAMFILES , Open a file, CAM Files (*.CNF) ;Text Documents (*.txt; *.doc)
;if SelectedFile =
;    MsgBox, The user didn't select anything.
;else
;    MsgBox, The user selected the following:`n%SelectedFile%
	
FirstWin:
Gui, Add, Text,, Initialer:
Gui, Add, Text,, Dato:
Gui, Add, Text,, Batch-nr:
Gui, Add, Text,, Tid EOS:
Gui, Add, Text,, Prøvestørrelse (mL):
Gui, Add, Text,, Total mængde i batch(mL):
Gui, Add, Text,, Aktivitet for hele batch ved EOS(GBq):
Gui, Add, Text,, Filnavn (Normalt samme som Batch-nr):
Gui, Add, Text,, Nuclide:
Gui, Add, Edit, vInitials ym  ; The ym option starts a new column of controls.
Gui, Add, Edit, vDate
Gui, Add, Edit, vBatchNr
Gui, Add, DateTime, vEOS, dddd d, MMMM yyyy HH:mm:ss
Gui, Add, Edit, vTempSizeOfSample
Gui, Add, Edit, vTempSizeOfBatch 
Gui, Add, Edit, vTempEOSBq
Gui, Add, Edit, vFileName
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

FormatTime, ReadableTime, %EOS%, dd-MM-yyyy HH:mm:ss
;MsgBox, EOS tidspunkt i laesbart format:`n%ReadableTime%

ratioOfActivity := TempSizeOfSample / TempSizeOfBatch


Gui, 2:Add, Text,, Analysed file: %SelectedFile%
Gui, 2:Add, Text,, Initials: %Initials%
Gui, 2:Add, Text,, Date: %Date%
Gui, 2:Add, Text,, Batch-nr: %BatchNr%
Gui, 2:Add, Text,, EOS(YYYYMMDDHHMISS): %EOS%
Gui, 2:Add, Text,, Prøvestørrelse (mL): %TempSizeOfSample%
Gui, 2:Add, Text,, Total mængde i batch(mL): %TempSizeOfBatch%
Gui, 2:Add, Text,, Aktivitet for hele batch ved EOS(GBq): %TempEOSBq%
Gui, 2:Add, Text,, Filename: %FileName%
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

;Aaben den valgte fil:
Sleep 1000
Send !+F
Sleep 1000
Send O
Sleep 1000
Click 452, 395
Sleep 1000
Click 440, 371
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
Send %SelectedFile%
Sleep 1000
Click 675, 362
Sleep 2000

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
Sleep 2000
	
;Slet gamle ROIs
Send !+D
Sleep 2000
Send R
Sleep 2000
Send D
Sleep 2000

;Saet scale til auto og til log
Send !+D
Sleep 2000
Send D
Sleep 2000
Send A
Sleep 2000
Send !+D
Sleep 2000
Send D
Sleep 2000
Send G
Sleep 2000

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


;Byg part1 filen
;æøå
FileAppend, <pre>`n, C:\kemi\%FileName%part1.txt

FileAppend,
(
<font size="7" color="Black">Analysedata for Batch: %BatchNr%</font>

EOS: <b>%ReadableTime%</b> `t `t `t EOS aktivitet for hele batch: <b>%TempEOSBq% GBq</b>
Prøvestørrelse: <b>%TempSizeOfSample% mL</b>`t `t `t `t Total mængde i batch: <b>%TempSizeOfBatch% mL</b>
Prøve analyseret: <b>%Date%</b> `t Prøve målt og analyseret af: <b>%Initials%</b>



), C:\kemi\%FileName%part1.txt
FileAppend, </pre>`n, C:\kemi\%FileName%part1.txt



;Byg part2 filen
FileAppend, <pre>`n, C:\kemi\%FileName%part2.txt
FileAppend,
(
<img src="c:\kemi\%FileName%.jpg" alt="">

*************************************************************************
*****            AUTOMATIC GAMMA ACQUISITION REPORT                 *****
*************************************************************************

), C:\kemi\%FileName%part2.txt

Loop, read, C:\kemi\%FileName%.txt, C:\kemi\%FileName%part2.txt
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


;FileAppend, Rapport godkendt af (Dato og signatur):`n, C:\kemi\%FileName%part2.txt
FileAppend, `n, C:\kemi\%FileName%part2.txt
FileAppend, `n, C:\kemi\%FileName%part2.txt
FileAppend, `n, C:\kemi\%FileName%part2.txt
FileAppend, </pre>`n, C:\kemi\%FileName%part2.txt

string1 = Acquisition Started


;Kig efter overstående string1 i filen: C:\kemi\%FileName%.txt, skr derefter alle delene ud af linien
;og smid derefter samlet i en YYYYMMDDHHMISS variabel
Loop, read, C:\kemi\%FileName%.txt, C:\kemi\%FileName%partEOS.txt
{
	IfInString, A_LoopReadLine, %string1%
	{
		StringTrimLeft, test1, A_LoopReadLine, 40
		;MsgBox %test1%
		
		StringTrimRight, timetoadd, test1, 12
		
		EOSYear = 20%timetoadd%
		;MsgBox %EOSYear%
		
		StringTrimLeft, test1, A_LoopReadLine, 37
		;MsgBox %test1%
		
		StringTrimRight, timetoadd, test1, 15
		
		EOSMonth = %timetoadd%
		;MsgBox %Month%
		
		
		StringTrimLeft, test1, A_LoopReadLine, 34
		;MsgBox %test1%
		
		StringTrimRight, timetoadd, test1, 18
		
		EOSDay = %timetoadd%
		;MsgBox %EOSDay%
		
		StringTrimLeft, test1, A_LoopReadLine, 43
		;MsgBox %test1%
		
		StringTrimRight, timetoadd, test1, 9
		
		EOSHours = %timetoadd%
		;MsgBox %EOSHours%
		
		StringTrimLeft, test1, A_LoopReadLine, 46
		;MsgBox %test1%
		
		StringTrimRight, timetoadd, test1, 6
		
		EOSMinutes = %timetoadd%
		;MsgBox %EOSMinutes%
		
		StringTrimLeft, test1, A_LoopReadLine, 49
		;MsgBox %test1%
		
		StringTrimRight, timetoadd, test1, 3
		
		EOSSeconds = %timetoadd%
		;MsgBox %EOSSeconds%
		
		;YYYYMMDDHHMISS
		StartOfMes = %EOSYear%%EOSMonth%%EOSDay%%EOSHours%%EOSMinutes%%EOSSeconds%
		;MsgBox %StartOfMes%
		break
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Læg realtime til tidspunkt for start af måling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string1 = Real Time

	   
EndOfMes = %StartOfMes%

Loop, read, C:\kemi\%FileName%.txt, C:\kemi\TimeSinceEOS.txt
{
	IfInString, A_LoopReadLine, %string1%
	{
		TimeSinceEOS = %EndOfMes%
		StringTrimLeft, test1, A_LoopReadLine, 37
		StringTrimRight, timetoadd, test1, 10
		;MsgBox Time to add in seconds: %timetoadd%
		;MsgBox Value of EndOfMes: %EndOfMes%
		;EndOfMes += %timetoadd%, seconds
		EnvAdd, EndOfMes, %timetoadd%, seconds
		;MsgBox EndOfMes after added seconds: %EndOfMes%
		
		
		EnvSub, TimeSinceEOS, %EOS%, minutes
		;ekstra := EnvSub, TimeSinceEOS, %EOS%, minutes
		TimeSinceEOS := TimeSinceEOS / 60 
		
		;MsgBox TimeSinceEOS: %TimeSinceEOS%
		;FileAppend, Ekstra: %ekstra%`n
		FileAppend, EOS: %EOS%`n
		FileAppend, Slut for maaling: %EndOfMes%`n
		FileAppend, Tid siden EOS(Timer): %TimeSinceEOS%`n
		FileAppend, StartOfMes: %StartOfMes%`n
		break
	}
	
}

;Nu vil vi koere GAMMAlyser, det er igen afhaengigt af hvilken isotop der er valgt i starten, derfor denne if-else
If NuclideChoice = 18F
{
	Sleep 6000
	Send #r
	Sleep 1000
	Send C:\GAMMAlyser\GAMMAlyser.exe C:\kemi\%FileName%part2.txt %TimeSinceEOS% %EOSBq% 1 0 isotopes-18F.txt 6 109.7
	Sleep 6000
	Send {Enter}
	Sleep 12000
}
else if NuclideChoice = 11C
{
	Sleep 6000
	Send #r
	Sleep 1000
	Send C:\GAMMAlyser\GAMMAlyser.exe C:\kemi\%FileName%part2.txt %TimeSinceEOS% %EOSBq% 1 0 isotopes-18F.txt 3 20.5
	Sleep 6000
	Send {Enter}
	Sleep 12000
}
else if NuclideChoice = 68Ga
{
	Sleep 6000
	Send #r
	Sleep 1000
	Send C:\GAMMAlyser\GAMMAlyser.exe C:\kemi\%FileName%part2.txt %TimeSinceEOS% %EOSBq% 1 0 isotopes-18F.txt 5 68
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
Send copy C:\kemi\%FileName%part1.txt{+}C:\kemi\cnuclide-report.txt{+}C:\kemi\%FileName%part2.txt C:\kemi\%FileName%report.html
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