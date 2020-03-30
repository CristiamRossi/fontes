#include "totvs.ch"
/*/{Protheus.doc} fRomaneio
Impressao do Romaneio Compartilhado
@author Cristiam Rossi
@since 22/01/2020
@version 1.0
@param none
@type function
/*/
user function fRomaneio()
Local   aArea     := GetArea()
Local   oReport
private cAliasQry := getNextAlias()
private cTitulo   := "Romaneio de Expedicao"
private cPerg     := "FROMANEIO"

	AjustaSX1()

	if ! Pergunte(cPerg,.T.)
		MsgAlert("Operacao cancelada pelo usuario", cTitulo)
		Return nil
	endif

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea( aArea )
return nil

//-------------------------------------------
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2

	oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir o Romaneio de Expedicao.")
	oReport:nFontBody := 7

	oSection1 := TRSection():New(oReport,"Cliente e NF"       ,{cAliasQry})
	oSection2 := TRSection():New(oReport,"Itens a transportar",{cAliasQry})

	TRCell():New(oSection1,'CODIGO'			,cAliasQry,"Codigo"			,			,06 /*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'NOME'			,cAliasQry,"Nome Cliente"	,			,40						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DOC'			,cAliasQry,"Nota Fiscal"	,			,10/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'SERIE'			,cAliasQry,"Serie"	 		,			,03						,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,'QTD1'			,cAliasQry,"Qtde"			,			,08/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'COD1'			,cAliasQry,"Codigo"			,			,15						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'DES1'			,cAliasQry,"Descricao"  	,			,40/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'FILLER'			,         ,""				,			,10						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'QTD2'			,cAliasQry,"Qtde"			,			,08/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'COD2'			,cAliasQry,"Codigo"			,			,15						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'DES2'			,cAliasQry,"Descricao"  	,			,40/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport


//-------------------------------------------
static function PrintReport(oReport)
local oSection1 := oReport:Section(1)
local oSection2 := oReport:Section(2)
local cQuery
local aTotal    := {}
local nI
local aEmb      := {}

	chkFile("SZC")
	SZC->( dbSetOrder(2) )		// Filial + Transp + Doc + Serie + Modelo

	cQuery := "select C5_XROTA, F2_TRANSP, A4_NOME, A1_CEP, A1_COD, A1_LOJA, A1_NREDUZ, F2_DOC, F2_SERIE,"
	cQuery += " D2_QUANT, D2_COD, B1_DESC, ZR_DESCR"
	cQuery += " from "+retSqlName("SF2")+" SF2 "
	cQuery += " join "+retSqlName("SD2")+" SD2 on D2_FILIAL=F2_FILIAL and D2_DOC=F2_DOC and D2_SERIE=F2_SERIE and D2_CLIENTE=F2_CLIENTE and SD2.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SC5")+" SC5 on C5_FILIAL=D2_FILIAL and C5_NUM=D2_PEDIDO and SC5.D_E_L_E_T_=' '"
if .T.	// Cliente
	cQuery += " join "+retSqlName("SA1")+" SA1 on A1_FILIAL=LEFT(C5_FILIAL,2) and A1_COD=C5_CLIENT and A1_LOJA=C5_LOJAENT and SA1.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SA4")+" SA4 on A4_FILIAL=LEFT(C5_FILIAL,2) and A4_COD=F2_TRANSP and SA4.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SB1")+" SB1 on B1_FILIAL=LEFT(C5_FILIAL,2) and B1_COD=D2_COD and SB1.D_E_L_E_T_=' '"
else
	cQuery += " join "+retSqlName("SA1")+" SA1 on A1_FILIAL='' and A1_COD=C5_CLIENT and A1_LOJA=C5_LOJAENT and SA1.D_E_L_E_T_=' '"
	cQuery += " LEFT join "+retSqlName("SA4")+" SA4 on A4_FILIAL='' and A4_COD=F2_TRANSP and SA4.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SB1")+" SB1 on B1_FILIAL='' and B1_COD=D2_COD and SB1.D_E_L_E_T_=' '"
endif
	cQuery += " left join "+retSqlName("SZR")+" SZR on ZR_FILIAL=' ' and ZR_CODIGO=C5_XROTA and SZR.D_E_L_E_T_=' '"
	cQuery += " left join "+retSqlName("SZF")+" SZF on ZF_FIL=F2_FILIAL and SZF.D_E_L_E_T_=' '"
	cQuery += " where F2_EMISSAO between '"+DtoS(mv_par01)+"' and '"+DtoS(mv_par02)+"'"
	cQuery += " and SF2.D_E_L_E_T_=' '"
	If mv_par03 == 1 //NAO"
		cQuery += " and SUBSTRING(F2_FILIAL,1,2) = '"+SubStr(xFilial("SF2"),1,2)+"' "
	EndIf	
	cQuery += " order by C5_XROTA, F2_TRANSP, A1_CEP, A1_COD, A1_LOJA"
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	while ! (cAliasQry)->( eof() )

		aEmb    := {}
		cKey    := xFilial("SZC") + (cAliasQry)->( F2_TRANSP + F2_DOC + F2_SERIE )
		SZC->( dbSeek( cKey, .T. ) )
		while ! SZC->( eof() ) .and. cKey == SZC->( ZC_FILIAL + ZC_TRANSP + ZC_DOC + ZC_SERIE )

			if ( nPos := aScan(aEmb, {|it| it[1] == SZC->ZC_MODELO}) ) == 0
				aadd(aEmb, { SZC->ZC_MODELO, 0 })
				nPos := len(aEmb)
			endif
			aEmb[nPos,2] += SZC->ZC_QTDE

			SZC->( dbSkip() )
		end


		cKey    := (cAliasQry)->(C5_XROTA + F2_TRANSP)
		cRota   := (cAliasQry)->C5_XROTA + " - " + (cAliasQry)->ZR_DESCR
		cTransp := (cAliasQry)->F2_TRANSP + " - " + (cAliasQry)->A4_NOME
		aItens  := {}
		aTotal  := {}

		while ! (cAliasQry)->( eof() ) .and. cKey == (cAliasQry)->(C5_XROTA + F2_TRANSP)
			aTemp := {}
			for nI := 1 to (cAliasQry)->(fCount())
				aadd( aTemp, (cAliasQry)->(fieldGet(nI)) )
			next
			aadd( aItens, aClone(aTemp) )

			if ( nPos := aScan(aTotal, {|it| it[2] == (cAliasQry)->D2_COD}) ) == 0
				aadd(aTotal, { 0, (cAliasQry)->D2_COD, (cAliasQry)->B1_DESC})
				nPos := len(aTotal)
			endif
			aTotal[nPos,1] += (cAliasQry)->D2_QUANT

			(cAliasQry)->( dbSkip() )
		end

		nDif1 := abs( val(aItens[1,7]) - val(SM0->M0_CEPENT) )
		nDif2 := abs( val(aItens[len(aItens),7]) - val(SM0->M0_CEPENT) )

		if Min( nDif1, nDif2 ) == nDif1
			nIni  := 1
			nFim  := len(aItens)
			nStep := 1
		else
			nIni  := len(aItens)
			nFim  := 1
			nStep := -1
		endif

		oReport:SetCustomText( {|| criaCab(oReport)} )
		oReport:startPage()

		cChave := ""
		for nI := nIni to nFim step nStep
			if cChave != aItens[nI,4] + aItens[nI,5] + aItens[nI,6]
				if nI != 1
					oReport:skipLine()
					oReport:thinLine()
				endif

				oSection2:Finish()
				oSection1:Finish()

				oSection1:init()
				oSection1:Cell("CODIGO"):SetValue( aItens[nI,5] + "/" + aItens[nI,6] )
				oSection1:Cell("NOME"  ):SetValue( aItens[nI,7] )
				oSection1:Cell("DOC"   ):SetValue( aItens[nI,8] )
				oSection1:Cell("SERIE" ):SetValue( aItens[nI,9] )
				oSection1:printline()
				oSection2:init()
				cChave := aItens[nI,4] + aItens[nI,5] + aItens[nI,6]
			endif

			oSection2:Cell("QTD1"):SetValue( aItens[nI,10] )
			oSection2:Cell("COD1"):SetValue( aItens[nI,11] )
			oSection2:Cell("DES1"):SetValue( aItens[nI,12] )

			if nI + 1 <= len(aItens) .and.  cChave == aItens[nI+1,4] + aItens[nI+1,5] + aItens[nI+1,6]
				oSection2:Cell("QTD2"):SetValue( aItens[nI+1,10] )
				oSection2:Cell("COD2"):SetValue( aItens[nI+1,11] )
				oSection2:Cell("DES2"):SetValue( aItens[nI+1,12] )
				nI++
			else
				oSection2:Cell("QTD2"):SetValue( "" )
				oSection2:Cell("COD2"):SetValue( "" )
				oSection2:Cell("DES2"):SetValue( "" )
			endif

			oSection2:printline()
		next
		oReport:skipLine()
		oReport:thinLine()
		oSection2:Finish()

		oReport:skipLine()

		oReport:PrtLeft("TOTAIS: ")

		oSection2:setHeaderSection(.F.)
		oSection2:init()
		for nI := 1 to len( aTotal )
			oSection2:Cell("QTD1"):SetValue( aTotal[nI,1] )
			oSection2:Cell("COD1"):SetValue( aTotal[nI,2] )
			oSection2:Cell("DES1"):SetValue( aTotal[nI,3] )

			if nI + 1 <= len( aTotal )
				oSection2:Cell("QTD2"):SetValue( aTotal[nI+1,1] )
				oSection2:Cell("COD2"):SetValue( aTotal[nI+1,2] )
				oSection2:Cell("DES2"):SetValue( aTotal[nI+1,3] )
				nI++
			else
				oSection2:Cell("QTD2"):SetValue( "" )
				oSection2:Cell("COD2"):SetValue( "" )
				oSection2:Cell("DES2"):SetValue( "" )
			endif

			oSection2:printline()
		next
		oSection2:Finish()
		oSection2:setHeaderSection(.T.)
		oReport:skipLine(2)

// Imprimir Embalagens Retornaveis
		if len( aEmb ) > 0
			oReport:PrtLeft("Embalagens Retornaveis:")
			oReport:skipLine(1)
			oReport:PrtLeft("=======================")
			oReport:skipLine(1)

			cLinha := ""
			for nI := 1 to len( aEmb )
				cLinha += space(10) + aEmb[nI,1] + " x " + transform( aEmb[nI,2], "999" )
				if len( cLinha ) > 150
					oReport:PrtLeft( cLinha )
					oReport:skipLine(1)
					cLinha := ""
				endif
			next
			if ! empty( cLinha )
				oReport:PrtLeft( cLinha )
				oReport:skipLine(1)
			endif

			oReport:skipLine(2)
		endif

		oReport:PrtLeft(Space(25)+replicate("-",40)+space(40)+replicate("-",40))
		oReport:skipLine(1)
		oReport:PrtLeft(space(40)+"SEPARADOR"+space(70)+"TRANSPORTADOR")

		oSection1:Finish()
		oReport:endPage()
	end

	(cAliasQry)->( dbCloseArea() )
return nil


//-----------------------------------------------------------------------------------
static function criaCab(oReport)
local cChar		:= chr(160)  // caracter dummy para alinhamento do cabecalho     
local _linha0,_linha1,_linha2,_linha3,_linha4,_linha5

	_linha0 := "__LOGOEMP__"
	_linha1 := cChar + "         " + "ROMANEIO DE EXPEDICAO" + "         "  + cChar + RptFolha + TRANSFORM(oReport:Page(),'999999')
	_linha2 := "SIGA/FROMANEIO.prt/v." + cVersao + "         " + cChar + "Rota: " + cRota +  "         " + cChar
	_linha3 := RptHora + " " + time() + "         " + cChar + RptEmiss + " " + Dtoc(dDataBase)
	_linha4 := cChar + "    " + "Transportador: "+cTransp + " " 
	_linha5 := Trim(SM0->M0_NOME)

	aRet := {_linha0,_linha1,_linha2,_linha3,_linha4,_linha5 }

return {_linha0,_linha1,_linha2,_linha3,_linha4,_linha5 }


//-------------------------------------------
// Cria o grupo de perguntas do relatorio
//-------------------------------------------
static function AjustaSX1()
	//    cGrupo,cOrdem ,cPergunt         	,cPergSpa   ,cPergEng      	,cVar     ,cTipo,nTamanho,nDecimal,nPreSel,cGSC ,cValid            	,cF3    	,cGrpSXG,cPyme,cVar01    ,cDef01        	,cDefSpa1      		,cDefEng1      		,cDef02       	,cDefSpa2     		,cDefEng2     		,cDef03  		,cDefSpa3		,cDefEng3 	,cDef04  	,cDefSpa4		,cDefEng4		,cDef05 	 		,cDefSpa5		,cDefEng5		,aHelpPor		,aHelpEng		,aHelpSpa		,cHelp)
	U_PutSx1(cPerg,"01"   ,"Faturamento de ?"		,""			,""				,"mv_ch1" ,"D"  ,08      ,0       ,1      ,"G"  ,""					,"" 		,""     ,"S"  ,"mv_par01",""            	,""            		,""            		,""    			,""           		,""           		,""           	,""    			,""      	,""      	,""    			,""      		,""      	  		,""      		,""      		,""      		,""				,""				,""	)
	U_PutSx1(cPerg,"02"   ,"Faturamento ate ?"		,""			,""				,"mv_ch2" ,"D"  ,08		 ,0		  ,1  	  ,"G"	,"naovazio()"		,""	    	,""	  	,""   ,"mv_par02",""				,""					,""					,""				,""					,""					,""				,""				,""			,""			,""				,""				,""					,""				,""				,""      		,""				,""				,""	)    
	U_PutSx1(cPerg,"03"   ,"Todas Empresas ?"	    ,""			,"" 			,"mv_ch3" ,"C"  ,01      ,0       ,1      ,"C"  ,""                 ,""         ,""     ,""   ,"mv_par03","NAO","NAO","NAO"  ,"","SIM","SIM","SIM","","","","","","","","","")
return nil
