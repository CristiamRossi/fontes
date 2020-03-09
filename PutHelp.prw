#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

Static __lInDark := .F.
Static __lInHelp := .F.
Static __lHlpLog := .T.
Static __aHelp   := {}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Help     ³ Autor ³ Wilson Godoy          ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta uma ajuda do sistema a nivel de campo.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void Help(ExpC1,ExpN1,ExpC2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome da Rotina chamadora do help.                  ³±±
±±³          ³ ExpN1 = Numero da linha da rotina chamadora.               ³±±
±±³          ³ ExpC2 = Titulo do campo.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PutHelp(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)
Return U_PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)

User Function PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)
Local cFilePor := "SIGAHLP.HLP"
Local cFileEng := "SIGAHLE.HLE"
Local cFileSpa := "SIGAHLS.HLS"
Local nRet
Local nT
Local nI
Local cLast
Local cNewMemo
Local cAlterPath := ''
Local nPos	

If ( ExistBlock('HLPALTERPATH') )
	cAlterPath := Upper(AllTrim(ExecBlock('HLPALTERPATH', .F., .F.)))
	If ( ValType(cAlterPath) != 'C' )
        cAlterPath := ''
	ElseIf ( (nPos:=Rat('\', cAlterPath)) == 1 )
		cAlterPath += '\'
	ElseIf ( nPos == 0	)
		cAlterPath := '\' + cAlterPath + '\'
	EndIf
	
	cFilePor := cAlterPath + cFilePor
	cFileEng := cAlterPath + cFileEng
	cFileSpa := cAlterPath + cFileSpa
	
EndIf

Default aHelpPor := {}
Default aHelpEng := {}
Default aHelpSpa := {}
Default lUpdate  := .T.
Default cStatus  := ""

If Empty(cKey)
	Return
EndIf

If !(cStatus $ "USER|MODIFIED|TEMPLATE")
	cStatus := NIL
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpPor)

For nI:= 1 to nT
   cLast := Padr(aHelpPor[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFilePor, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFilePor, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpEng)

For nI:= 1 to nT
   cLast := Padr(aHelpEng[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFileEng, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFileEng, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpSpa)

For nI:= 1 to nT
   cLast := Padr(aHelpSpa[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFileSpa, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFileSpa, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

Return nil
