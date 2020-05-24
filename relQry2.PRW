#include "totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RELQRY2   ºAutor  ³Cristiam Rossi      º Data ³  22/03/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera relatório de Query p/ .csv                            º±±
±±º          ³ informar o caminho e o nome do arquivo da query no parâm.  º±±
±±º          ³ DWC_RELQRY                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DWC                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function relQry2()
Local   cAlias    := "R_Q"
Private cCadastro := "Relatorios Customizados"
Private aRotina   := {}

	aadd(aRotina, {"Pesquisar"       , "axPesqui"  ,0,1})
	aadd(aRotina, {"Visualizar"      , "axVisual"  ,0,2})
	aadd(aRotina, {"Incluir"         , "u_relQry2M",0,3})
	aadd(aRotina, {"Alterar"         , "u_relQry2M",0,4})
	aadd(aRotina, {"Excluir"         , "u_relQry2M",0,5})
	aadd(aRotina, {"Perguntas"       , "u_relQry2P",0,7})
	aadd(aRotina, {"Executar"        , "u_relQry2X",0,8})
	aadd(aRotina, {"Palav.Reservadas", "u_relQry2R",0,8})

	dbSelectArea(cAlias)
	dbSetOrder(1)

	mBrowse(6,1,22,75, cAlias)

return nil


//------------------------------------
User Function relQry2X()
local   aArea    := getArea()
local   cArquivo := CriaTrab(,.F.)+".csv"
local   cPath    := AllTrim( GetTempPath() )
private nArq
private nRegs    := 0

	if msgYesNo( "Confirma a execução do relatório?", "Relatório "+alltrim(R_Q->R_Q_DESC) )
		nArq     := fCreate(cArquivo,0)

		Processa( {|| fGeraRel()},"Aguarde","Selecionando Registros ...")
		fClose(nArq)

		if nRegs > 0
			CpyS2T(GetSrvProfString("Startpath","")+cArquivo, cPath, .T.)
			ShellExecute("open",cPath + cArquivo,"","",1)
		endif
	endif

	restArea( aArea )
return nil



//-------------------------------
Static Function fGeraRel()
local   cAliasQry := ""
local   nI
local   cTXT      := ""
private xValor

	begin transaction
		cAliasQry := fQuery()
	end transaction

	if select(cAliasQry) == 0	// sem query carrega saimos
		return nil
	endif

	if (cAliasQry)->( EOF() )
		msgAlert("Não há dados a serem exibidos", "Relatório da query")
	endif

	dbSelectArea(cAliasQry)

	for nI := 1 to (cAliasQry)->(fcount())		// cabeçalho
		cTXT += iif(nI != 1, ";", "") + fieldName(nI)
	next
	cTXT += CRLF
	FWrite(nArq,cTXT,Len(cTXT))

	while ! (cAliasQry)->( EOF() )		// imprime linhas
		nRegs++
		
		incProc("gerando linha: " + cValToChar(nRegs))

		cTXT := ""
		for nI := 1 to (cAliasQry)->(fcount())		// cabeçalho
			xValor := (cAliasQry)->(fieldGet(nI))

			if valType(xValor) == "N"
				xValor := cValToChar( xValor )
				xValor := strTran(xValor, ".", "," )
			elseif valType(xValor) == "D"
				xValor := DtoC( xValor )
			elseif valType(xValor) == "L"
				xValor := iif( xValor, "SIM", "NÃO" )
			endif

			cTXT += iif(nI != 1, ";", "") + xValor
		next
		cTXT += CRLF
		FWrite(nArq,cTXT,Len(cTXT))

		(cAliasQry)->( dbSkip() )
	end
	(cAliasQry)->( dbCloseArea() )

return nil


//-------------------------------
Static Function fQuery()
local   cQuery    := alltrim(R_Q->R_Q_QUERY)
local   cAliasQry := getNextAlias()
local   nPos
local   lContinua := .T.
local   aPergs    := {}
local   aRet      := {}
local   aValPerg  := {}
local   xInicia
private xTemp

// perguntas
	dbSelectArea("R_P")
	dbSeek( xFilial() + R_Q->R_Q_COD, .T. )
	while ! EOF() .and. R_Q->R_Q_COD == R_P->R_P_COD

		if R_P_TIPO != "4"

			if R_P_TIPO == "1"
				xInicia := 0
			elseif R_P_TIPO == "2"
				xInicia := Space(200)
			elseif R_P_TIPO == "3"
				xInicia := CtoD("  /  /  ")
			else
				xInicia := Space(200)
			endif
			aAdd( aPergs, { 1, alltrim(R_P_DESC), xInicia, alltrim(R_P_PICT), '.T.' /*validacao*/, /*"SA1"*/, '.T.' /*when*/, 60, R_P_OBRIGA=="S"} )

		else	// combo
			xInicia := strTokArr(R_P_COMBO, ";")
//			aAdd( aPergs, { 2, alltrim(R_P_DESC),1, xInicia, 60, ".T.", R_P_OBRIGA=="S"})
			aAdd( aPergs, { 2, alltrim(R_P_DESC), xInicia[1], xInicia, 60, ".T.", R_P_OBRIGA=="S"})
		endif
		
		aadd( aValPerg, R_P_TIPO )

		dbSkip()
	end

	if len( aPergs ) > 0
		ParamBox(aPergs ,"Parametros: ",aRet, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.)
	endif

	dbSelectArea("R_Q")


// substituições
	while ( nPos := AT("%", cQuery) ) > 0
		nPos2 := AT("%", substr(cQuery, nPos+1) )
		if nPos2 == 0
			msgAlert("Os parâmetros na Query estão incorretos verifique!"+CRLF+"próximo a: "+substr(cQuery, nPos))
			return cAliasQry
		endif

		xPart := upper( substr(cQuery,nPos, nPos2+1) )

		do case
			case left(xPart,7) == "%ALIAS."
				xAlias := substr(xPart,8,3)
				xNovo  := retSqlName(xAlias) + " "+ xAlias+ " "
				cQuery := strTran(cQuery, xPart, xNovo)

			case left(xPart,8) == "%FILIAL."
				xAlias := substr(xPart,9,3)
				xNovo  := "'"+ xFilial(xAlias) +"'"
				cQuery := strTran(cQuery, xPart, xNovo)
				
			case left(xPart,5) == "%DEL."
				xAlias := substr(xPart,6,3)
				xNovo  := xAlias+".D_E_L_E_T_=' '"
				cQuery := strTran(cQuery, xPart, xNovo)

			case left(xPart,7) == "%MV_PAR"
				nPos := val( substr(xPart,8,2) )
				if len(aRet) < nPos
					msgAlert("Palavra reservada ["+xPart+"] não possui relação com grupo de perguntas ou não foi preenchida!")
					return cAliasQry
				endif

				if aValPerg[nPos] == "1"		// Numero
					xNovo := cValToChar( aRet[nPos] )

				elseif aValPerg[nPos] == "2"	// Caracter
					xNovo := "'" + alltrim( aRet[nPos] ) + "'"

				elseif aValPerg[nPos] == "3"	// Data
					xNovo := "'" + DtoS( aRet[nPos] ) + "'"

				elseif aValPerg[nPos] == "4"	// Combo
					xNovo := "'" + alltrim( aRet[nPos] ) + "'"					

				else							// Lista
					xNovo := " in " + formatIn(alltrim(aRet[nPos]),";")
				endif

				cQuery := strTran(cQuery, xPart, xNovo)

			otherwise
				msgAlert("Palavra reservada ["+xPart+"] não identificada!")
				return cAliasQry
		endcase
	end

	if empty( cQuery )
		msgStop("A query está vazia, verifique!", "problema na carga da query")
	else
		if isInCallStack("U_RELQRY2")
			if aviso("Query após as substituições", cQuery, {"Ok","Sair"}, 3) == 2
				lContinua := .F.
			endif
		endif

		if lContinua
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		endif
	endif

return cAliasQry


//------------------------------------
User Function relQry2R()
local cTexto := ""

	cTexto += "Com o intuito de flexibilizar a funcionalidade foram criadas as seguintes palavras reservadas:" + CRLF + CRLF
	cTexto += "%ALIAS.SA1% --> "+retSqlName("SA1") + " SA1 " + CRLF
	cTexto += "%FILIAL.SA1% --> '"+xFilial("SA1")+"'" + CRLF
	cTexto += "%DEL.SA1% --> SA1.D_E_L_E_T_=' '" + CRLF
	cTexto += "%MV_PAR01% --> conteúdo do MV_PAR01" + CRLF + CRLF
	cTexto += "Obs: onde está SA1 pode ser qualquer alias existente no protheus. Os MV_PARXX devem ser criados nas perguntas e substituídos na query. Exemplos:" + CRLF + CRLF

	cTexto += "Pergunta Tipo 1=Numérico:" + CRLF
	cTexto += "      select * from %ALIAS.SA1% where A1_LC > %MV_PAR01%" + CRLF
	cTexto += " ficará:"+CRLF
	cTexto += "      select * from "+retSqlName("SA1") + " SA1 where A1_LC > 10000" + CRLF + CRLF

	cTexto += "Pergunta Tipo 2=Caracter:" + CRLF
	cTexto += "      select * from %ALIAS.SA1% where A1_COD between %MV_PAR02% and %MV_PAR03%" + CRLF
	cTexto += " ficará:"+CRLF
	cTexto += "      select * from "+retSqlName("SA1") + " SA1 where A1_COD between '' and 'ZZZZZZ'" + CRLF + CRLF

	cTexto += "Pergunta Tipo 3=Data:" + CRLF
	cTexto += "      select * from %ALIAS.SA1% where A1_DTNASC < %MV_PAR04%" + CRLF
	cTexto += " ficará:"+CRLF
	cTexto += "      select * from "+retSqlName("SA1") + " SA1 where A1_DTNASC < '20180101'" + CRLF + CRLF

	cTexto += "Pergunta Tipo 4=Combo:" + CRLF
	cTexto += "      select * from %ALIAS.SA1% where A1_MSBLQL != %MV_PAR05%" + CRLF
	cTexto += " ficará:"+CRLF
	cTexto += "      select * from "+retSqlName("SA1") + " SA1 where A1_MSBLQL != '1'" + CRLF + CRLF

	cTexto += "Pergunta Tipo 5=Lista:" + CRLF
	cTexto += "      select * from %ALIAS.SA1% where A1_EST %MV_PAR06%" + CRLF
	cTexto += " ficará:"+CRLF
	cTexto += "      select * from "+retSqlName("SA1") + " SA1 where A1_EST in ('SP','RJ','MG')" + CRLF + CRLF

	aviso("Palavras reservadas", cTexto, {"Ok"}, 3)

return nil


//------------------------------------
User Function relQry2M( param1, param2, param3 )
local aButton := {{"AUTOM", {|| u_relQry2R()}, "Palav.Reservadas"}}
local nRet

	if param3 == 3
		nRet := axInclui( param1, param2, param3,,,,,,, aButton )
	endif

	if param3 == 4
		aadd( aButton, {"AUTOM", {|| u_relQry2P()}, "Perguntas"} )
		nRet := axAltera( param1, param2, param3,,,,,,,, aButton )
	endif

	if param3 == 5
		nRet := axDeleta( param1, param2, param3 )		// 1-Cancelar; 2-Confirmar
		if nRet == 2
			dbSelectArea("R_P")
			dbSeek( xFilial() + R_Q->R_Q_COD, .T. )
			while ! R_P->( EOF() ) .and. R_Q->R_Q_COD == R_P->R_P_COD
				recLock("R_P")
				dbDelete()
				msUnlock()
				R_P->( dbSkip() )
			end
			dbSelectArea("R_Q")
		endif
	endif

return nRet


//------------------------------------
User Function relQry2P()
local   aArea    := getArea()
local   cCodRel  := R_Q->R_Q_COD
local   oDlg
local   aAlter   := {}
local   aTmp
local   lOk      := .F.
local   nI
local   nRecno
private oGet
private lRefresh := .T.
private aHeader  := {}
private aCols    := {}


	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("R_P")
	while ! EOF() .and. X3_ARQUIVO == "R_P"
		if X3USO(X3_USADO) .and. cNivel >= X3_NIVEL .and. X3_BROWSE == "S"

			if X3_VISUAL == "A"
				aadd( aAlter, SX3->X3_CAMPO )
			endif

			aadd( aHeader , {;
                           SX3->X3_TITULO ,;
                           SX3->X3_CAMPO   ,;
                           SX3->X3_PICTURE ,;
                           SX3->X3_TAMANHO ,;
                           SX3->X3_DECIMAL ,;
                           SX3->X3_VALID   ,;
                           SX3->X3_USADO   ,;
                           SX3->X3_TIPO    ,;
                           SX3->X3_F3      ,;
                           SX3->X3_CBOX    ;
                         } )
		endif
		dbSkip()
	end
	aadd( aHeader , {;
                     "Record" ,;
                     "R_P_RECNO"   ,;
                     "" ,;
                     9 ,;
                     0 ,;
                     "" ,;
                     "" ,;
                     "N" ,;
                     "" ,;
                     "" ;
                   } )

	dbSelectArea("R_P")
	dbSetOrder(1)
	dbSeek(xFilial() + cCodRel, .T.)
	while ! EOF() .and. R_P_FILIAL == xFilial() .and. R_P_COD == cCodRel

		aTmp := {}
		for nI := 1 to len(aHeader)-1
			aadd( aTmp, R_P->( fieldGet( fieldPos( aHeader[nI,2] ) ) ) )
		next
		aadd( aTmp, R_P->( RECNO() ) )
		aadd( aTmp, .F. )
		
		aadd( aCols, aClone(aTmp) )

		dbSkip()
	end
	
	if empty( aCols )
		aTmp := {}
		for nI := 1 to len(aHeader)-1
			aadd( aTmp, criavar(aHeader[nI,2]) )
		next
		aadd( aTmp, 0 )
		aadd( aTmp, .F. )

		aadd( aCols, aClone(aTmp) )
	endif

	DEFINE MSDIALOG oDlg TITLE "Perguntas para "+alltrim(R_Q->R_Q_DESC) FROM 0,0 TO 420,800 PIXEL
	oGet := MSNewGetDados():New( 32, 2, 209, 402,GD_INSERT+GD_DELETE+GD_UPDATE,"U_RQRYLOK","U_RQRYTOK",,aAlter,,4096,/*"u_VlLin()"*/,,"U_RQRYDEL",oDlg,aHeader,aCols)

	ACTIVATE MSDIALOG oDlg CENTERED on init EnchoiceBar( oDlg, { || iif(oGet:TudoOk(), (lOk:=.T.,oDlg:End()), nil) } , { || lOk := .F., oDlg:End() } )

	if lOk
		dbSelectArea("R_P")
		aCols := oGet:aCols
		for nI := 1 to len(aCols)
			nTmp := aScan(aHeader, {|it| alltrim(it[2]) == "R_P_RECNO" } )
			if ( nRecno := aCols[nI, nTmp] ) > 0
				dbGoto( nRecno )
			endif

			nTmp := aScan(aHeader, {|it| alltrim(it[2]) == "R_P_DESC" } )

			if gdDeleted(nI) .and. nRecno > 0
				recLock("R_P")
				dbDelete()
				msUnlock()
			elseif ! empty( aCols[nI, nTmp] )
				recLock("R_P", nRecno == 0)
				R_P->R_P_FILIAL := xFilial()
				R_P->R_P_COD    := cCodRel

				for nJ := 1 to len( aCols[nI] ) - 2
					fieldPut( fieldPos( aHeader[nJ,2] ), aCols[nI,nJ] )
				next
				msUnlock()
			endif
		next
	endif

	restArea( aArea )
Return nil


//---------------------------------
User Function RQRYLOK()
local nTmp := aScan(aHeader, {|it| alltrim(it[2]) == "R_P_TIPO" } )

	if ! gdDeleted( N ) .and. aCols[N,nTmp] == "4"		// é combo
		nTmp := aScan(aHeader, {|it| alltrim(it[2]) == "R_P_COMBO" } )
		if empty( aCols[N,nTmp] )
			msgAlert("Campo do tipo Combo deve ter preenchida a coluna OPCAO COMBO!")
			return .F.
		endif
	endif

return .T.


//---------------------------------
User Function RQRYTOK()
private N

	for N := 1 to len( aCols )
		if ! U_RQRYLOK()
			return .F.
		endif
	next

return .T.

//---------------------------------
User Function RQRYDEL()
local nTmp   := aScan(aHeader, {|it| alltrim(it[2]) == "R_P_ORDEM" } )
local lDel   := gdDeleted( N )
local nOrdem := aCols[N, nTmp] + iif( lDel, 1, 0 )
local nI

	for nI := N + 1 to len(aCols)
		aCols[nI, nTmp] := nOrdem
		if ! gdDeleted( nI )
			nOrdem++
		endif
	next

return .T.

//---------------------------------
User Function RQRYORD()
local nPosOrd := aScan(aHeader, {|it| alltrim(it[2]) == "R_P_ORDEM" } )
local nOrdem  := aCols[N, nPosOrd]
local nNewOrd := 1
local aLinha  := aClone( aCols[N] )
local nOld    := N
local nI

	aDel(  aCols, N )

	for nI := 1 to len( aCols ) - 1
		aCols[nI,nPosOrd] := nNewOrd
		if ! gdDeleted( nI )
			nNewOrd++
		endif
	next

	nNewOrd := 1

	for nI := 1 to len( aCols ) - 1
		if aCols[nI,nPosOrd] >= nOrdem
			aIns( aCols, nI)
			aCols[nI] := aClone( aLinha )
			aLinha    := {}
			exit
		endif
	next
	
	if len(aLinha) > 0
		aCols[ len(aCols) ] := aClone( aLinha )
	endif

	for nI := 1 to len( aCols )
		aCols[nI,nPosOrd] := nNewOrd
		if ! gdDeleted( nI )
			nNewOrd++
		endif
	next

	oGet:Refresh()

return aCols[nOld,nPosOrd]


//---------------------------------
User Function relQry2C()	// execução via Menu
local aArea := getArea()
local oDlg
local oLst
local aRels := {}

	dbSelectArea("R_Q")
	dbGotop()
	while ! EOF()
		aadd( aRels, { R_Q_DESC, RECNO() } )
		dbSkip()
	end

	if len( aRels ) == 0
		msgAlert("Não existem relatórios disponíveis!")
		restArea( aArea )
		return nil
	endif

	DEFINE MSDIALOG oDlg TITLE "Relatórios Customizados" FROM 0,0 TO 420,400 PIXEL

	@ 32,2 ListBox oLst Fields Header '' Size 209,202 of oDlg Pixel
	oLst:SetArray( aRels )
	oLst:bLine      := {|| { aRels[oLst:nAT,1] } }
	oLst:blDblClick := { || ExecRela( aRels[oLst:nAT,2] ) }
	oLst:Refresh()



	ACTIVATE MSDIALOG oDlg CENTERED on init EnchoiceBar( oDlg, { || ExecRela( aRels[oLst:nAT,2] ) } , { || oDlg:End() } )

	restArea(aArea)
return nil


//--------------------------------
static function ExecRela( nRecno )
	dbGoto( nRecno )
	U_relQry2X()
return nil
