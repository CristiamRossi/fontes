#include "totvs.ch"
/*/{Protheus.doc} DDSrPrd1
Impressao do Romaneio Compartilhado
@author Cristiam Rossi
@since 15/04/2020
@version 1.0
@param none
@type function
/*/
user function DDSRPRD1()
Local   aArea     := GetArea()
Local   oReport
private cAliasQry := getNextAlias()
private cTitulo   := "Relatorio de Producao"
private cPerg     := "DDSRPRD1"
private cGrupos   := ""

	AjustaSX1()

	if ! Pergunte(cPerg,.T.)
		MsgAlert("Operacao cancelada pelo usuario", cTitulo)
		Return nil
	endif

	fSelGrupos( MV_PAR03 )	// seleção dos grupos de produtos

	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea( aArea )
return nil

//-------------------------------------------
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2

	oReport := TReport():New(cPerg,cTitulo,cPerg,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a Produtividade conforme par�metros informados")
	oReport:setPortrait()
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:nFontBody := 15
	oReport:nLineHeight := oReport:nFontBody * 4

	oSection1 := TRSection():New(oReport,"Rede" ,{cAliasQry})
	oSection2 := TRSection():New(oReport,"Itens",{cAliasQry})

	TRCell():New(oSection1,'REDE'			,cAliasQry,"Rede"			,			,25 /*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,, .T. /*Bold*/)
	TRCell():New(oSection1,'SETOR'			,cAliasQry,"Setor"			,			,20						,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,, .T. /*Bold*/)
	TRCell():New(oSection1,'CORTE'			,         ,"Corte"			,			,25/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,, .T. /*Bold*/)
	TRCell():New(oSection1,'HORA'			,         ,"Hora"			,			,6/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,, .T. /*Bold*/)

	TRCell():New(oSection2,'ITEM'			,         ,"Item"			,			,05/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'CODIGO'			,cAliasQry,"Codigo"			,			,10						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'PRODUTO'		,cAliasQry,"Descricao"  	,			,35/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'PERFIL'			,cAliasQry,"Perfil"			,			,07						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'QTDE'			,cAliasQry,"Qtde"			,			,08/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'ATENDIDO'		,         ,"Atendido"		,			,08						,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,'LOTE'			,         ,"Lote" 		 	,			,05/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport


//-------------------------------------------
static function PrintReport(oReport)
local oSection1 := oReport:Section(1)
local oSection2 := oReport:Section(2)
local cQryAux
local cKey
local nQtde
local nSeq

	cQryAux := "SELECT ACY_DESCRI REDE, BM_DESC SETOR, C6_PRODUTO CODIGO, C6_DESCRI PRODUTO, C6_UM PERFIL, SUM(C6_QTDVEN) QTDE "

	cQryAux += " from "+ RetSQLName("SC6") +" A, "+RetSQLName("SC5") +" B, "+RetSQLName("SA1") +" E "
	cQryAux += " left join "+retSqlName("ACY")+" ACY on ACY_FILIAL='"+xFilial("ACY")+"' and ACY_GRPVEN=A1_GRPVEN and ACY.D_E_L_E_T_='' , "
	cQryAux += RetSQLName("SB1") +" C "+"join "+retSqlName("SBM")+" SBM on BM_FILIAL='"+xFilial("SBM")+"' and BM_GRUPO=B1_GRUPO and SBM.D_E_L_E_T_=' '"
	cQryAux += " WHERE A.D_E_L_E_T_ = '' AND B.D_E_L_E_T_ = '' AND C.D_E_L_E_T_ = '' AND E.D_E_L_E_T_ = ''  "
	cQryAux += " AND SUBSTRING(C5_FILIAL,1,2) = '"+SubStr(cFilAnt,1,2)+"' "
	cQryAux += " AND SUBSTRING(A1_FILIAL,1,2) = '"+SubStr(cFilAnt,1,2)+"' "
	cQryAux += " AND C6_BLQ <> 'R' "
	cQryAux += " AND C5_NUM = C6_NUM"
	cQryAux += " AND C5_FILIAL = C6_FILIAL"
	cQryAux += " AND C6_CLI+C6_LOJA = A1_COD+A1_LOJA"
	cQryAux += " AND C6_PRODUTO = B1_COD"
	cQryAux += " AND BM_GRUPO = B1_GRUPO "
	cQryAux += " AND BM_FILIAL = B1_FILIAL"
	cQryAux += " AND C5_EMISSAO between '"+DtoS(mv_par01)+"' and '"+DtoS(mv_par02)+"' "

	cQryAux += " AND C6_QTDVEN > 0 "	// não trazer item Cortado / Resíduo

	if ! empty( cGrupos )
		cQryAux += " and B1_GRUPO in ("+cGrupos+")"
	endif

	If ! Empty(mv_par04)
		cQryAux += " AND A1_GRPVEN = '"+mv_par04+"' "
	EndIf

	cQryAux += " GROUP BY ACY_DESCRI, BM_DESC, C6_PRODUTO, C6_DESCRI, C6_UM"
	cQryAux += " ORDER BY ACY_DESCRI, BM_DESC, C6_DESCRI"

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQryAux),cAliasQry,.T.,.T.)

	while ! (cAliasQry)->( eof() )

		cKey  := (cAliasQry)->(REDE + SETOR)
		nQtde := 0
		nSeq  := 0
		oReport:startPage()

		oSection1:init()
		oSection1:Cell("CORTE"):SetValue( DtoC(MV_PAR01) + " a " + DtoC(MV_PAR02) )
		oSection1:Cell("HORA" ):SetValue( left(time(),5) )
		oSection1:printline()
		oSection2:init()

		while ! (cAliasQry)->( eof() ) .and. cKey == (cAliasQry)->(REDE + SETOR)
			nSeq++
			nQtde += (cAliasQry)->QTDE

			oSection2:Cell("ITEM"    ):SetValue( strZero(nSeq,3,0) )

			oSection2:Cell("CODIGO" ):SetValue( (cAliasQry)->CODIGO )
			oSection2:Cell("PRODUTO"):SetValue( (cAliasQry)->PRODUTO )
			oSection2:Cell("PERFIL" ):SetValue( (cAliasQry)->PERFIL )
			oSection2:Cell("QTDE"   ):SetValue( (cAliasQry)->QTDE )

			oSection2:Cell("ATENDIDO"):SetValue( space(10) )
			oSection2:Cell("LOTE"    ):SetValue( space(20) )
			oSection2:printline()
			oReport:thinLine()

			(cAliasQry)->( dbSkip() )
		end

		oReport:thinLine()

		oSection2:Cell("ITEM"   ):SetValue( "" )
		oSection2:Cell("CODIGO" ):SetValue( "" )
		oSection2:Cell("PRODUTO"):SetValue( "" )
		oSection2:Cell("PERFIL" ):SetValue( "" )
		oSection2:Cell("QTDE"   ):SetValue( nQtde )
		oSection2:printline()
		oSection2:Finish()
		oSection1:Finish()
		oReport:endPage()
	end

	(cAliasQry)->( dbCloseArea() )
return nil


//--------------------------------------------------------
static function fSelGrupos( cParGrp )
local aGrupos := {}
local aArea   := getArea()
local oDlg
local oLst
local nAt
local nI
local oOk  	:= LoadBitmap(GetResources(), 'LBOK')
local oNo  	:= LoadBitmap(GetResources(), 'LBNO')

	cGrupos := ""

	SBM->( dbSetOrder(1))
	SBM->( dbSeek( xFilial("SBM"), .T. ) )
	while ! SBM->( eof() ) .and. SBM->BM_FILIAL == xFilial("SBM")
		aadd( aGrupos, { alltrim(SBM->BM_GRUPO) $ cParGrp, SBM->BM_GRUPO, SBM->BM_DESC })
		SBM->( dbSkip() )
	end

	define msDialog oDlg title "Selecao de Grupos de Produto" from 0,0 to 300,450 pixel
	@ 1,1 listbox oLst var nAT fields header "", "Codigo", "Descricao" size 224, 128 pixel of oDlg

	oLst:SetArray(aGrupos)
	
	oLst:bLine :=	{|| {;
							iif(aGrupos[oLst:nAt,01], oOk, oNo ),;
							aGrupos[oLst:nAt,02],;
							aGrupos[oLst:nAt,03],;
	}}

	oLst:bLDbLClick	:= { || (aGrupos[oLst:nAt][1] := ! aGrupos[oLst:nAt][1], oLst:Refresh()) }

	@ 135,184 button "Ok" size 40,12 of oDlg pixel action oDlg:end()
	activate msDialog oDlg

	for nI := 1 to len(aGrupos)
		if aGrupos[nI,1]
			cGrupos += iif(empty(cGrupos), "", ",") + "'" + aGrupos[nI,2] + "'"
		endif
	next

	restArea( aArea )
return nil


//-------------------------------------------
// Cria o grupo de perguntas do relatorio
//-------------------------------------------
static function AjustaSX1()
	u_PutSx1(cPerg,"01","Emissao de?"	 ,"","" ,"mv_ch1","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",,,)
	u_PutSx1(cPerg,"02","Emissao Ate?"	 ,"","" ,"mv_ch2","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",,,)
	u_PutSx1(cPerg,"03","GRP Produto?","",""     ,"mv_ch3","C",30,0,0,"G","","SBM","","","mv_par03","","","","","","","","","","","","","","","","","","","")
	u_PutSx1(cPerg,"04","GRP Cliente?","",""     ,"mv_ch4","C",6,0,0,"G","","ACY","","","mv_par04","","","","","","","","","","","","","","","","","","","")
return nil
