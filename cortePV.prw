#include "totvs.ch"
/*/{Protheus.doc} cortePV
Rotina de Corte de Pedidos de Vendas
@author Cristiam Rossi
@since 10/01/2020
@version 1.0
@param none
@type function
/*/
user function cortePV()
local   aArea     := getArea()
local   aProds    := {}
local   aGrps     := {}
local   aRede     := {}
local   oDlg
local   aSize     := MsAdvSize()
local   oLayer    := FWLayer():new()
local   oPanelUp
local   oPanelDn
local   oComb1
local   oComb2
local   cGrupo
local   lContinua := .F.
private oOk       := LoadBitmap( GetResources(), 'LBOK' )
private oNo       := LoadBitmap( GetResources(), 'LBNO' )
private oLst1
private cTitulo   := "Corte em Pedidos de Vendas"
private aAllPrd   := {}
private dCorte    := dDatabase
private cRede     := "TODAS"
private cContexto := "Filial"

	if ! getDtCorte()
		return nil
	endif

	MsgRun( "Favor aguarde", "coletando pedidos...",{|| aProds := getProds( @aGrps, @aRede )})

	if len( aProds ) == 0
		msgStop("Não há pedidos em aberto, verifique!", cTitulo )
		restArea( aArea )
		return nil
	endif
	cGrupo  := aGrps[1]
	aAllPrd := aClone( aProds )

	DEFINE MSDIALOG oDlg TITLE "FILTRO: selecione os Produtos - "+cContexto FROM 0,0 TO aSize[6] * 0.7, aSize[5] * 0.9 PIXEL
	oDlg:lEscClose := .F.
	oLayer:init( oDlg, .F., .T.)
	oLayer:AddLine( 'UP', 85, .T. )
	oLayer:addCollumn('layBRW',100,.F.,'UP')
	oPanelUp := oLayer:GetColPanel( 'layBRW', 'UP' )

	@ 5,5 ListBox oLst1 Fields Header " ", "Código", "Descrição", "Grupo", "Qtd.Original", "Qtd.Distrib.", "Qtd.Residuo", "Saldo", "Trânsito","" Size 390 /*larg*/,150 of oPanelUp Pixel
	oLst1:align := CONTROL_ALIGN_ALLCLIENT
	oLst1:SetArray( aProds )
	oLst1:bLine   := {|| { iif(aProds[oLst1:nAT][1], oOK, oNo),;
							aProds[oLst1:nAT][2],;
							aProds[oLst1:nAT][3],;
							aProds[oLst1:nAT][7],;
							aProds[oLst1:nAT][4],;
							aProds[oLst1:nAT][5],;
							aProds[oLst1:nAT][6],;
							aProds[oLst1:nAT][10],;
							aProds[oLst1:nAT][11],;
							"";
	 } }
	oLst1:bLDblClick := {|| fSelClick( aProds, oLst1:nAT ), oLst1:DrawSelect() }

	oLayer:AddLine( 'DN', 15, .T. )
	oLayer:addCollumn('layPAN',100,.F.,'DN')
	oPanelDn := oLayer:GetColPanel( 'layPAN', 'DN' )

	@ 10, 10  Button "Sel.Todos"  Size 40,15 action fSelecao( @aProds, .T., cGrupo) of oPanelDn Pixel
	@ 10, 50  Button "Sel.Nenhum" Size 40,15 action fSelecao( @aProds, .F., cGrupo) of oPanelDn Pixel

	@ 10, 105 Button "Sair"       Size 40,15 action iif( msgYesNo("Confirma a saída da rotina?", cTitulo), oDlg:end(), nil) of oPanelDn Pixel
	@ 10, 155 Button "Avançar"    Size 40,15 action iif(fTemSel( aProds ), ( lContinua := .T., oDlg:end()), nil) of oPanelDn Pixel

	@ 10, 205 Button "Resíduo"    Size 40,15 action fResiduo( @aProds ) of oPanelDn Pixel

	@ 13, 260 Say "Grupo: " of oPanelDn Pixel
	@ 12, 280 MSCOMBOBOX oComb1 VAR cGrupo ITEMS aGrps SIZE 080,011 OF oPanelDn Pixel ON CHANGE fFilGrp( @aProds, cGrupo )

	@ 13, 375 Say "Redes: " of oPanelDn Pixel
	@ 12, 395 MSCOMBOBOX oComb2 VAR cRede ITEMS aRede SIZE 080,011 OF oPanelDn Pixel ON CHANGE fFilACY( @aProds, cGrupo )


	ACTIVATE MSDIALOG oDlg CENTERED

	if lContinua
		oLst1 := nil
		oDlg  := nil
		f2Tela()
	endif

	restArea( aArea )
return nil


//------------------------------------------
static function fSelClick( aProds, nItem )
local nPos
local cProduto := aProds[nItem][2]

	aProds[nItem][1] := ! aProds[nItem][1]

	if ( nPos := aScan(aAllPrd, {|aIt| aIt[2] == cProduto } ) ) > 0
		aAllPrd[nPos][1] := aProds[nItem][1]
	endif
return nil

//------------------------------------------
static function fSelecao( aProds, xValor, cGrupo )
local nI
local nPos

	for nI := 1 to len( aProds )
		if alltrim(aProds[nI][7]) == cGrupo .or. cGrupo == "TODOS"
			aProds[nI][1] := xValor
			if ( nPos := aScan(aAllPrd, {|aIt| aIt[2] == aProds[nI][2] } ) ) > 0
				aAllPrd[nPos][1] := aProds[nI][1]
			endif
		endif
	next

	oLst1:GoPosition(1)
	oLst1:refresh()
return nil


//------------------------------------------
static function fFilGrp( aProds, cGrupo )
local nI

	aSize( aProds, 0 )

	for nI := 1 to len( aAllPrd )
		if ( alltrim(aAllPrd[nI][7]) == cGrupo .or. cGrupo == "TODOS" ) .and. ( alltrim(aAllPrd[nI][12]) == cRede .or. cRede == "TODAS" )
			aadd( aProds, aAllPrd[nI])
		endif
	next

	oLst1:GoPosition(1)
	oLst1:refresh()
return nil


//------------------------------------------
static function fFilACY( aProds, cGrupo )
local nI

	aSize( aProds, 0 )

	for nI := 1 to len( aAllPrd )
		if ( alltrim(aAllPrd[nI][7]) == cGrupo .or. cGrupo == "TODOS" ) .and. ( alltrim(aAllPrd[nI][12]) == cRede .or. cRede == "TODAS" )
			aadd( aProds, aAllPrd[nI])
		endif
	next

	oLst1:GoPosition(1)
	oLst1:refresh()
return nil


//-------------------------------------------
static function getProds( aGrps, aRede )
local aArea     := getArea()
local cQuery
local aProds    := {}
local nPos
local nI
local cAliasQry := getNextAlias()
local cFilSB2   := iif( cContexto=="Filial", "='"+xFilial("SB2") +"'", "like '"+left(cFilAnt, 2)+"%'" )
local cFilSC5   := iif( cContexto=="Filial", "='"+xFilial("SC5") +"'", "like '"+left(cFilAnt, 2)+"%'" )
local cFilSC7   := iif( cContexto=="Filial", "='"+xFilial("SC7") +"'", "like '"+left(cFilAnt, 2)+"%'" )

	aSize( aGrps, 0 )
	aadd( aGrps, "TODOS")

	aSize( aRede, 0 )
	aadd( aRede, "TODAS")

	cQuery := "select C6_BLQ, C6_PRODUTO, B1_DESC, C6_QTDVEN, C6_XQTDORI, C6_NUM, BM_DESC, C6_FILIAL,"
//	cQuery += "B2_QATU-B2_QEMP SALDO, isnull(TRANSITO, 0) TRANSITO,"
	cQuery += "SALDO, isnull(TRANSITO, 0) TRANSITO,"
	cQuery += "A1_GRPVEN, isnull(ACY_DESCRI, '') ACY_DESCRI"
	cQuery += " from "+retSqlName("SC5")+" SC5 "
	cQuery += " join "+retSqlName("SC6")+" SC6 on C6_FILIAL=C5_FILIAL and C6_NUM=C5_NUM and SC6.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SB1")+" SB1 on B1_FILIAL='"+xFilial("SB1")+"' and B1_COD=C6_PRODUTO and SB1.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SBM")+" SBM on BM_FILIAL='"+xFilial("SBM")+"' and BM_GRUPO=B1_GRUPO and SBM.D_E_L_E_T_=' '"

//	cQuery += " join "+retSqlName("SB2")+" SB2 on B2_FILIAL "+cFilSB2+" and B2_COD=C6_PRODUTO and SB2.D_E_L_E_T_=' '"
	cQuery += " left join ("
	cQuery += " select sum(B2_QATU-B2_QEMP) SALDO, B2_COD from "+retSqlName("SB2")+" SB2 "
	cQuery += " where B2_FILIAL "+cFilSB2
	cQuery += " and B2_LOCAL = '01'"
	cQuery += " and SB2.D_E_L_E_T_=' '"
	cQuery += " group by B2_COD ) tmpB2 on B2_COD = C6_PRODUTO"

	cQuery += " join "+retSqlName("SA1")+" SA1 on A1_FILIAL='"+xFilial("SA1")+"' and A1_COD=C5_CLIENTE and A1_LOJA=C5_LOJACLI and SA1.D_E_L_E_T_=' '"
	cQuery += " left join "+retSqlName("ACY")+" ACY on ACY_FILIAL='"+xFilial("ACY")+"' and ACY_GRPVEN=A1_GRPVEN and ACY.D_E_L_E_T_=' '"

	cQuery += " left join ("
	cQuery += " select sum(C7_QUANT) TRANSITO, C7_PRODUTO from "+retSqlName("SC7")+" SC7 "
	cQuery += " where C7_FILIAL "+cFilSC7
	cQuery += " and C7_CONAPRO='L'"
	cQuery += " and SC7.D_E_L_E_T_=' '"
	cQuery += " group by C7_PRODUTO ) tmp on C7_PRODUTO = C6_PRODUTO"

	cQuery += " where C5_FILIAL "+cFilSC5
	cQuery += " and C5_EMISSAO >= '"+DtoS( dCorte )+"'"
	cQuery += " and C5_NOTA in (' ','"+replicate("X", len(SC5->C5_NOTA))+"')"

	if SC5->( fieldPos("C5_XDTREPO") ) > 0		// Não considerar REPOSIÇÃO
		cQuery += " and C5_XDTREPO = ' '"
	endif

	cQuery += " and C6_NOTA=' '"
	cQuery += " and C6_QTDEMP = 0"
//	cQuery += " and B2_LOCAL = '01'"
	cQuery += " and SC5.D_E_L_E_T_=' '"

	if cRede != "TODAS"
		ACY->( dbSetOrder(3) )	// ACY_DESCRI
		ACY->( dbSeek( xFilial("ACY") + cRede ) )

		cQuery += " and A1_GRPVEN='"+ACY->ACY_GRPVEN+"'"
	endif

	cQuery += " order by C6_PRODUTO "
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	while ! (cAliasQry)->( eof() )

		if ( nPos := aScan(aProds, {|it| it[2] == (cAliasQry)->C6_PRODUTO}) ) == 0
			aadd( aProds, { .T.,;			// 1-SELEÇÃO
							C6_PRODUTO,;	// 2-CÓDIGO PRODUTO
							B1_DESC,;		// 3-DESCRIÇÃO PRODUTO
							0,;				// 4-QTD ORIG
							0,;				// 5-QTD DISTRIB
							0,;				// 6-QTD RESIDUO
							BM_DESC,;		// 7-DESCRIÇÃO GRUPO DE PRODUTO
							0,;				// 8-NÚMERO DE PEDIDOS DE VENDAS COM O ITEM
							{},;			// 9-PEDIDOS
							SALDO,;			// 10-SALDO DISPONÍVEL
							TRANSITO,;		// 11-SALDO EM TRANSITO ( PED COMPRAS )
							(cAliasQry)->ACY_DESCRI	;	// 12-REDE
			} )
			nPos := len(aProds)

			if aScan( aGrps, BM_DESC ) == 0
				aadd( aGrps, BM_DESC )
			endif
		endif

		aProds[nPos][4] += (cAliasQry)->C6_XQTDORI
		if empty( (cAliasQry)->C6_BLQ )
			aProds[nPos][5] += (cAliasQry)->C6_QTDVEN
		else
			aProds[nPos][6] += (cAliasQry)->C6_XQTDORI
		endif
//		if aScan(aProds[nPos][9], (cAliasQry)->C6_NUM ) == 0
//			aadd(aProds[nPos][9], (cAliasQry)->C6_NUM )
		if aScan(aProds[nPos][9], (cAliasQry)->( C6_FILIAL + C6_NUM ) ) == 0
			aadd(aProds[nPos][9], (cAliasQry)->( C6_FILIAL + C6_NUM ) )
		endif

		if aScan(aRede, (cAliasQry)->ACY_DESCRI) == 0
			aadd(aRede, (cAliasQry)->ACY_DESCRI)
		endif

		(cAliasQry)->( dbSkip() )
	end
	(cAliasQry)->( dbCloseArea() )

	for nI := 1 to len( aProds )
		if aProds[nI,5] == 0
			aProds[nI,1] := .F.
		endif
		aProds[nI,8] := len( aProds[nI,9] )
	next

	restArea( aArea )
return aProds


//-------------------------------------------
static function fTemSel( aProds )
local nItens := 0

	aEval(aProds, {|it| iif(it[1], nItens++, nil)})

	if nItens == 0
		msgStop("Favor selecione os itens antes", "Resíduo em Pedidos de Vendas")
	endif
return nItens > 0


//-------------------------------------------
static function fResiduo( aProds )
local aArea    := getArea()
local nI
local nJ
local cProduto
local cPedido
local nPos

	if ! fTemSel( aProds )
		return nil
	endif

	nResp := Aviso("Resíduo em Pedidos de Vendas", "Atenção: Esta rotina Marca ou Remove o bloqueio de Resíduo de itens dos pedidos de vendas selecionados. Clique a opção desejada abaixo.", { "Remove Resíduo", "Marcar Resíduo", "Voltar"}, 3 )
	if nResp < 1 .or. nResp == 3
		return nil
	endif

	SC5->( dbSetOrder(1) )
	SC6->( dbSetOrder(12) )

	for nI := 1 to len( aProds )
		if aProds[nI,1]

			cProduto := padR( aProds[nI][2]    , len(SC6->C6_PRODUTO) )
			if ( nPos := aScan(aAllPrd, {|aIt| aIt[2]==cProduto}) ) > 0
				if nResp == 1	// remove Resíduo
					aProds [nI  ,5] := aProds [nI  ,4]
					aProds [nI  ,6] := 0
					aAllPrd[nPos,5] := aProds [nI  ,4]
					aAllPrd[nPos,6] := 0
				else
					aProds [nI  ,1] := .F.
					aProds [nI  ,5] := 0
					aProds [nI  ,6] := aProds [nI  ,4]
					aAllPrd[nPos,1] := .F.
					aAllPrd[nPos,5] := 0
					aAllPrd[nPos,6] := aProds [nI  ,4]
				endif
			endif

			for nJ := 1 to len( aProds[nI][9] )
				cPedido  := padR( aProds[nI][9][nJ], len(SC5->C5_NUM)     )

				begin transaction

				SC5->( dbSeek( xFilial("SC5") + cPedido ) )

				SC6->( dbSeek( xFilial("SC6") + cPedido + cProduto ) )
				while ! SC6->( eof() ) .and. SC6->( C6_FILIAL + C6_NUM + C6_PRODUTO ) == xFilial("SC6") + cPedido + cProduto
					recLock("SC6", .F.)
					SC6->C6_BLQ := iif( nResp==1, " ", "R" )
					msUnlock()
					SC6->( dbSkip() )
				end

				nItem    := 0
				nResiduo := 0
				nFat     := 0

				SC6->( dbSeek( xFilial("SC6") + cPedido ) )
				while ! SC6->( eof() ) .and. SC6->( C6_FILIAL + C6_NUM ) == xFilial("SC6") + cPedido
					nItem++

					if alltrim(SC6->C6_BLQ) == "R"	// é resíduo
						nResiduo++
					else
						if SC6->C6_QTDEMP > 0		// existe item liberado
							exit
						endif

						if SC6->C6_QTDENT == SC6->C6_QTDVEN
							nFat++
						endif
					endif

					SC6->( dbSkip() )
				end

				recLock("SC5", .F.)
				if nItem == ( nResiduo + nFat )
					SC5->C5_LIBEROK := "S"
					if empty( SC5->C5_NOTA )
						SC5->C5_NOTA := replicate("X", len(SC5->C5_NOTA) )
					endif
				else
					SC5->C5_LIBEROK := " "
					SC5->C5_NOTA    := " "
				endif
				msUnlock()

				end transaction
			next
		endif
	next

	oLst1:GoPosition(1)
	oLst1:refresh()
	restArea( aArea )
return nil


//-------------------------------------------
static function getDtCorte()
local lRet   := .F.
local aParam := {}
local aRet   := ""
local aItens := {"Filial","Grupo"}

	aAdd(aParam,{ 1, "Data corte:", dCorte, "",, "", ".T.", 50, .F.} )
	aAdd(aParam,{ 3, "Contexto:",1,aItens,50,"",.F.} )

	if ParamBox(aParam,"Filtros...",@aRet,,,,,,,,.F.)
		dCorte    := aRet[1]
		cContexto := aItens[ aRet[2] ]
		lRet      := .T.
	endif

return lRet


//---------------------------------------------------------
//                     Segunda tela
//---------------------------------------------------------
static function f2Tela()
local   aSize     := MsAdvSize()
local   oLayer    := FWLayer():new()
local   oTabTemp
local   oBrwTMP
local   nI
local   aEstru    := {}
private aProds    := {}
private oLst2
private oLst3
private oNGetD1

	aadd( aEstru, {"A1_NOME"   ,"C",len(SA1->A1_NOME)   ,0} )
	aadd( aEstru, {"C6_XQTDORI","N",12                  ,2} )
	aadd( aEstru, {"C6_QTDVEN" ,"N",12                  ,2} )
	aadd( aEstru, {"A1_PRIOR"  ,"C", 1                  ,0} )
	aadd( aEstru, {"ROTA"      ,"C",40                  ,0} )
	aadd( aEstru, {"A1_COD"    ,"C", 6                  ,0} )
	aadd( aEstru, {"A1_LOJA"   ,"C", 2                  ,0} )
	aadd( aEstru, {"C6_NUM"    ,"C", 6                  ,0} )
	aadd( aEstru, {"C6_ITEM"   ,"C", 2                  ,0} )
	aadd( aEstru, {"C6_PRODUTO","C",len(SC6->C6_PRODUTO),0} )
	aadd( aEstru, {"FILIAL"    ,"C",len(cFilAnt)        ,0} )

	oTabTemp := FWTemporaryTable():New( "TEMP" )  
	oTabTemp:SetFields( aEstru )
	oTabTemp:AddIndex("1", {"A1_PRIOR","A1_NOME"})
	oTabTemp:AddIndex("2", {"ROTA","A1_NOME"})
	oTabTemp:AddIndex("3", {"A1_NOME"})
	oTabTemp:AddIndex("4", {"C6_PRODUTO"})
	oTabTemp:Create()

	for nI := 1 to len( aAllPrd )
		if aAllPrd[nI][1]
			aadd( aProds, aClone(aAllPrd[nI]) )
			nPos := len( aProds )
			aProds[nPos][8] := aProds[nPos][10] - aProds[nPos][5]
		endif
	next

	getPvItem( aProds )		// alimenta tabela temporária TEMP

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO aSize[6], aSize[5] PIXEL
	oDlg:lEscClose := .F.

	oLayer:init( oDlg, .F., .T.)
	oLayer:AddLine( 'PRD', 45, .T. )
	oLayer:AddLine( 'PV' , 45, .T. )
	oLayer:AddLine( 'PAN', 10, .T. )

	oLayer:addCollumn('layPRD',100,.F.,'PRD')
	oLayer:addCollumn('layPV' ,100,.F.,'PV' )
	oLayer:addCollumn('layPAN',100,.F.,'PAN')
	oPanelPRD := oLayer:GetColPanel( 'layPRD', 'PRD' )
	oPanelPV  := oLayer:GetColPanel( 'layPV' , 'PV'  )
	oPanelPAN := oLayer:GetColPanel( 'layPAN', 'PAN' )

	@ 5,5 ListBox oLst2 Fields Header "Código", "Descrição", "Grupo", "Qtd.Original", "Qtd.Distrib.", "Estoque", "Saldo", "Qtd.Residuo", "Trânsito","" Size 390 /*larg*/,150 of oPanelPRD Pixel
	oLst2:align := CONTROL_ALIGN_ALLCLIENT
	oLst2:bChange := {|| fChangePrd( aProds[oLst2:nAT][2], oBrwTMP ) }
	oLst2:SetArray( aProds )
	oLst2:bLine   := {|| {	aProds[oLst2:nAT][2],;
							aProds[oLst2:nAT][3],;
							aProds[oLst2:nAT][7],;
							aProds[oLst2:nAT][4],;
							aProds[oLst2:nAT][5],;
							aProds[oLst2:nAT][10],;
							aProds[oLst2:nAT][8],;
							aProds[oLst2:nAT][6],;
							aProds[oLst2:nAT][11],;
							"";
	 } }


	oBrwTMP := FWMBrowse():New()
	oBrwTMP:SetDataTable(.T.)
	oBrwTMP:SetAlias( "TEMP" )
	oBrwTMP:DisableDetails()
	oBrwTMP:DisableConfig()
	oBrwTMP:DisableReport()
	oBrwTMP:DisableFilter( )
	oBrwTMP:SetMenuDef("")
	oBrwTMP:SetChange( {|| oBrwTMP:goColumn(3) } )
	oBrwTMP:SetColumns( DefColBrw() )
	oBrwTMP:SetEditCell( .T. )
	oBrwTMP:Activate( oPanelPV )

	@ 10,  10  Button "Zerar"       Size 40,15 action fZerar( oBrwTMP )        of oPanelPAN Pixel
	@ 10,  60  Button "100%"        Size 40,15 action f100( oBrwTMP )          of oPanelPAN Pixel
	@ 10, 110  Button "+"           Size 20,15 action fMaisMe( oBrwTMP, 1 )    of oPanelPAN Pixel
	@ 10, 140  Button "-"           Size 20,15 action fMaisMe( oBrwTMP, 2 )    of oPanelPAN Pixel
	@ 10, 170  Button "Distribuir"  Size 40,15 action fDistr( oBrwTMP )        of oPanelPAN Pixel
	@ 10, 220  Button "Salvar"      Size 40,15 action fSalvar( oBrwTMP )       of oPanelPAN Pixel
	@ 10, 270  Button "Liberar"     Size 40,15 action fLibera( oBrwTMP, oDlg ) of oPanelPAN Pixel
	@ 10, 330  Button "Sair"        Size 40,15 action iif( msgYesNo("Confirma a saída da rotina?", cTitulo), oDlg:end(), nil) of oPanelPAN Pixel
	ACTIVATE MSDIALOG oDlg CENTERED

	TEMP->( dbCloseArea() )
	oTabTemp:Delete()
	oTabTemp := nil
return nil


//------------------------
static function fZerar( oBrwTMP, lQuiet, nRpar )
local   aArea  := getArea()
local   nResp  := 0
local   nI
local   nINI   := 1
local   nFIM   := len( aProds )
default lQuiet := .F.

	if lQuiet
		nResp := nRpar
	else
		nResp := aviso(cTitulo, "Confirma limpar o campo Qtd a Distribuir?"+CRLF+"Pode ser o produto selecionado ou Todos os produtos", {"Todos","Selecionado","Sair"})
		if nResp == 0 .or. nResp == 3
			return nil
		endif
	endif

	if nResp == 1
		fChangePrd( "", oBrwTMP )
	else
		nINI := oLst2:nAT
		nFIM := oLst2:nAT
	endif

	dbGotop()
	while ! eof()
		TEMP->C6_QTDVEN := 0
		dbSkip()
	end

	for nI := nINI to nFIM
		aProds[nI][5] := 0
		aProds[nI][8] := aProds[nI][10]
	next
	oLst2:refresh()

	restArea( aArea )
	fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )
return nil


//------------------------
static function fSalvar( oBrwTMP )
local aArea := getArea()

	if ! msgYesNo("Salva as quantidades? Poderá continuar seu trabalho depois."+CRLF+"Quantidades zeradas serão colocadas como Resíduo.", cTitulo)
		return nil
	endif

	SC6->( dbSetOrder(12) )

	fChangePrd( "", oBrwTMP )

	TEMP->( dbGotop() )
	while ! TEMP->( eof() )

		SC6->( dbSeek( xFilial("SC6") + TEMP->( C6_NUM + C6_PRODUTO ) ) )
		while ! SC6->( eof() ) .and. SC6->( C6_FILIAL + C6_NUM + C6_PRODUTO ) == xFilial("SC6") + TEMP->( C6_NUM + C6_PRODUTO )
			recLock("SC6", .F.)
			if TEMP->C6_QTDVEN == 0
				SC6->C6_BLQ    := "R"
			else
				SC6->C6_QTDVEN := TEMP->C6_QTDVEN
				SC6->C6_BLQ    := ""
			endif
			msUnlock()
			SC6->( dbSkip() )
		end
		TEMP->( dbSkip() )
	end

	restArea( aArea )
	fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )
return nil


//------------------------
static function fDistr( oBrwTMP )
local aArea := getArea()
local nOpc  := 0
local nResp  := 0
local nI
local nJ
local nINI   := 1
local nFIM   := len( aProds )
local aPrior := {"1","2","3","4","5","9"}
local nSALDO
//local cRegiao
local cRota

	nOpc := aviso( cTitulo, "Esta rotina efetua a distribuição do Estoque. Selecione abaixo as opções:", {"Prioridade","Região","Geral","Sair"})

	if nOpc == 0 .or. nOpc == 4
		return nil
	endif

	nResp := aviso( cTitulo, "Escolha Todos os produtos ou apenas o Selecionado.", {"Todos","Selecionado","Sair"})
	if nResp == 0 .or. nResp == 3
		return nil
	endif

	if nOpc == 2	// Rota
		cRota   := TEMP->ROTA
	endif

	fZerar( oBrwTMP, .T., nResp )

	if nResp == 2
		nINI := oLst2:nAT
		nFIM := oLst2:nAT
	endif

	if nOpc == 1	// Prioridade
		for nI := nINI to nFIM
			oLst2:nAT := nI
			fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )

			TEMP->( dbSetOrder(1) )		// Prioridade

			nSALDO := aProds[oLst2:nAT][10]

			for nJ := 1 to len( aPrior )
				TEMP->( dbGotop() )
				while ! TEMP->( eof() ) .and. nSALDO > 0
					if aPrior[nJ] == TEMP->A1_PRIOR

						if nSALDO > TEMP->C6_XQTDORI
							TEMP->C6_QTDVEN := TEMP->C6_XQTDORI
							nSALDO -= TEMP->C6_XQTDORI
						else
							TEMP->C6_QTDVEN := nSALDO
							nSALDO := 0
						endif

						aProds[oLst2:nAT][5] += TEMP->C6_QTDVEN
						aProds[oLst2:nAT][8] := aProds[oLst2:nAT][10] - aProds[oLst2:nAT][5]

					endif
					TEMP->( dbSkip() )
				end
			next
		next
	endif

	if nOpc == 2	// Rota

		for nI := nINI to nFIM
			oLst2:nAT := nI
			fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )

			TEMP->( dbSetOrder(1) )		// Prioridade

			nSALDO := aProds[oLst2:nAT][10]

			for nJ := 1 to 2
				TEMP->( dbGotop() )
				while ! TEMP->( eof() ) .and. nSALDO > 0
					if (nJ == 1 .and. cRota == TEMP->ROTA) .OR. (nJ == 2 .and. cRota != TEMP->ROTA)

						if nSALDO > TEMP->C6_XQTDORI
							TEMP->C6_QTDVEN := TEMP->C6_XQTDORI
							nSALDO -= TEMP->C6_XQTDORI
						else
							TEMP->C6_QTDVEN := nSALDO
							nSALDO := 0
						endif

						aProds[oLst2:nAT][5] += TEMP->C6_QTDVEN
						aProds[oLst2:nAT][8] := aProds[oLst2:nAT][10] - aProds[oLst2:nAT][5]

					endif
					TEMP->( dbSkip() )
				end
			next
		next
	endif


	if nOpc == 3	// Geral
		for nI := nINI to nFIM
			oLst2:nAT := nI
			fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )

			TEMP->( dbSetOrder(3) )		// Cliente

			nSALDO := aProds[oLst2:nAT][10]

			TEMP->( dbGotop() )
			while ! TEMP->( eof() ) .and. nSALDO > 0

				if nSALDO > TEMP->C6_XQTDORI
					TEMP->C6_QTDVEN := TEMP->C6_XQTDORI
					nSALDO -= TEMP->C6_XQTDORI
				else
					TEMP->C6_QTDVEN := nSALDO
					nSALDO := 0
				endif

				aProds[oLst2:nAT][5] += TEMP->C6_QTDVEN
				aProds[oLst2:nAT][8] := aProds[oLst2:nAT][10] - aProds[oLst2:nAT][5]

				TEMP->( dbSkip() )
			end
		next
	endif

	restArea( aArea )
	oLst2:nAT := 1
	fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )
return nil


//--------------------
static function f100( oBrwTMP )
local aArea := getArea()
local nI
local nResp
local nINI  := 1
local nFIM  := len( aProds )

	nResp := aviso(cTitulo, "Esta rotina preenche a quantidade a distribuir com a quantidade original do pedido, continua?"+CRLF+"Pode ser o produto selecionado ou Todos os produtos", {"Todos","Selecionado","Sair"})
	if nResp == 0 .or. nResp == 3
		return nil
	endif

	fZerar( oBrwTMP, .T., nResp )

	if nResp == 2		// Selecionado
		nINI := oLst2:nAT
		nFIM := oLst2:nAT
	endif

	for nI := nINI to nFIM
		oLst2:nAT := nI
		fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )

		TEMP->( dbGotop() )
		while ! TEMP->( eof() )

			TEMP->C6_QTDVEN := TEMP->C6_XQTDORI

			aProds[oLst2:nAT][5] += TEMP->C6_QTDVEN
			aProds[oLst2:nAT][8] := aProds[oLst2:nAT][10] - aProds[oLst2:nAT][5]

			TEMP->( dbSkip() )
		end
	next

	restArea( aArea )
	oLst2:nAT := nINI
	fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )
return nil


//--------------------
static function fMaisMe( oBrwTMP, nOper )
local   aArea     := getArea()
local   oDlg
local   nSelect   := oLst2:nAT
local   nI
local   nINI      := oLst2:nAT
local   nFIM      := oLst2:nAT
local   oLayer    := FWLayer():new()
local   lOk       := .F.
local   cTitulo   := iif(nOper==1, "Adicionar", "Remover") + " quantidades a distribuir"
local   oRadio1
local   oRadio2
local   nTemp
local   nQtdNova  := 0
private lLst3
private nValor    := 0
private nUM       := 1
private nProd     := 1
private aQtds     := getQtds( oBrwTMP )
private bAcao     := {|nIt| nIt}

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 300, 600 PIXEL
	oLayer:init( oDlg, .F., .T.)
	oLayer:AddLine( 'UP', 40, .T. )
	oLayer:AddLine( 'DN', 40, .T. )
	oLayer:AddLine( 'BT', 20, .T. )

	oLayer:addCollumn('lay1', 33,.F.,'UP')
	oLayer:addCollumn('lay2', 33,.F.,'UP')
	oLayer:addCollumn('lay3', 33,.F.,'UP')
	oLayer:addCollumn('lay4', 99,.F.,'DN')
	oLayer:addCollumn('lay5',100,.F.,'BT')
	oLayer:addWindow('lay1','Win1','Valor'   ,100,.F.,.T.,,'UP')
	oLayer:addWindow('lay2','Win2','U.M.'    ,100,.F.,.T.,,'UP')
	oLayer:addWindow('lay3','Win3','Produto' ,100,.F.,.T.,,'UP')

	oPanel1   := oLayer:GetWinPanel('lay1','Win1','UP')
	oPanel2   := oLayer:GetWinPanel('lay2','Win2','UP')
	oPanel3   := oLayer:GetWinPanel('lay3','Win3','UP')
	oPanelPrv := oLayer:GetColPanel( 'lay4', 'DN' )
	oPanelBT  := oLayer:GetColPanel( 'lay5', 'BT' )

	@  7, 10 msGet oGet1 var nValor valid nValor >= 0 size 40,10 picture PesqPict("SC6","C6_QTDVEN") of oPanel1 pixel on change fAtuPrev( nOper, oBrwTMP )

	oRadio1 := tRadMenu():New( 5,10,{  "Quantidade", "Percentual" },{|u|if(PCount()>0,nUM:=u,nUM)}    ,oPanel2,,{|| fAtuPrev( nOper, oBrwTMP )},,,,,,50,10,,,,.T.)
	oRadio2 := tRadMenu():New( 5,10,{ "Selecionado", "Todos"      },{|u|if(PCount()>0,nProd:=u,nProd)},oPanel3,,{|| fAtuPrev( nOper, oBrwTMP )},,,,,,50,10,,,,.T.)

	@ 5,5 ListBox oLst3 Fields Header "Produto", "Qtd Original", "Estoque", "Qtd Distrib", "Qtd NOVA", "Saldo" Size 390 /*larg*/,150 of oPanelPrv Pixel
	oLst3:align := CONTROL_ALIGN_ALLCLIENT
	oLst3:SetArray( aQtds )
	oLst3:bLine   := {|| {	aQtds[oLst3:nAT][6],;
							aQtds[oLst3:nAT][1],;
							aQtds[oLst3:nAT][2],;
							aQtds[oLst3:nAT][3],;
							aQtds[oLst3:nAT][4],;
							aQtds[oLst3:nAT][5];
	 } }

	@ 10,  10  Button "Concluir"    Size 40,15 action iif( nValor == 0, alert("Informe um valor antes!"),(lOK := .T., oDlg:end())) of oPanelBT Pixel
	@ 10,  60  Button "Sair"        Size 40,15 action oDlg:end()               of oPanelBT Pixel

	ACTIVATE MSDIALOG oDlg CENTERED

	if lOK .and. nValor > 0

		if nProd == 2			// Todos
			nINI := 1
			nFIM := len( aProds )
		endif

		for nI := nINI to nFIM
			nQtdNova  := 0
			oLst2:nAT := nI
			fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )

			TEMP->( dbGotop() )
			while ! TEMP->( eof() )
				nTemp := round( eVal( bAcao, TEMP->C6_QTDVEN), 0 )
				TEMP->C6_QTDVEN := iif( nTemp > 0, nTemp, 0 )
				nQtdNova += TEMP->C6_QTDVEN
				TEMP->( dbSkip() )
			end

			aProds[nI][5] := nQtdNova
			aProds[nI][8] := aProds[nI][10] - aProds[nI][5]
		next
	endif

	restArea( aArea )
	oLst2:nAT := nSelect
	fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )
return nil


//------------------------
static function fAtuPrev( nOper, oBrwTMP )
local nI
local nJ
local nINI    := oLst2:nAT
local nFIM    := oLst2:nAT
local nSelect := oLst2:nAT

	for nI := 1 to len( aQtds )
		aQtds[nI][4] := 0
		aQtds[nI][5] := aQtds[nI][2] - aQtds[nI][3]
	next

	if nValor > 0
		if 	nUM == 2	// Percentual
			if nOper == 1		// Adição
				bAcao := {|nIt| nIt + (nIt * nValor / 100) }
			else				// Remoção
				bAcao := {|nIt| nIt - (nIt * nValor / 100) }
			endif
		else			// Qtd
			if nOper == 1		// Adição
				bAcao := {|nIt| nIt + nValor }
			else				// Remoção
				bAcao := {|nIt| nIt - nValor }
			endif
		endif

		if nProd == 2		// Todos
			nINI := 1
			nFIM := len( aProds )
		endif

		for nI := nINI to nFIM
			nAcmNovo  := 0
			oLst2:nAT := nI
			fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )

			TEMP->( dbGotop() )
			while ! TEMP->( eof() )
				nAcmNovo += eVal( bAcao, TEMP->C6_QTDVEN)
				TEMP->( dbSkip() )
			end

			nAcmNovo := round(nAcmNovo, 0)

			if nProd == 1		// Selecionado
				aQtds[1][4] := nAcmNovo
				if nAcmNovo > 0
					aQtds[1][5] := aQtds[1][2] - aQtds[1][4]
				else
					aQtds[1][5] := aQtds[1][2] - aQtds[1][3]
				endif

				aQtds[2][4] += nAcmNovo
				if nAcmNovo > 0
					aQtds[2][5] := aQtds[2][2] - aQtds[2][4]
				else
					aQtds[2][5] := aQtds[2][2] - aQtds[2][3]
				endif

			else				// Todos
				if nI == nSelect
					aQtds[1][4] := nAcmNovo
					aQtds[1][5] := aQtds[1][2] - aQtds[1][4]
				endif
				aQtds[2][4] += nAcmNovo
				aQtds[2][5] := aQtds[2][2] - aQtds[2][4]
			endif

			for nJ := 1 to len( aQtds )
				if aQtds[nJ][5] < 0
					aQtds[nJ][5] := 0
				endif
			next
		next
	endif

	oLst2:nAT := nSelect
	fChangePrd( aProds[oLst2:nAT][2], oBrwTMP )
	oLst3:refresh()
return nil


//------------------------
static function getQtds( oBrwTMP )
local aRet    := {}
local nI
local nJ
local nINI    := 2

	aadd( aRet, {0, 0, 0, 0, 0, "Selecionado"} )
	aadd( aRet, {0, 0, 0, 0, 0, "Todos"      } )

	for nI := 1 to len( aProds )
		if oLst2:nAt == nI
			nINI := 1
		else
			nINI := 2
		endif

		for nJ := nINI to 2
			aRet[nJ][1] += aProds[nI][4]					// qtd Orig
			aRet[nJ][2] += aProds[nI][10]					// Estoque disponivel
			aRet[nJ][3] += aProds[nI][5]					// qtd Distrib
			aRet[nJ][4] := 0								// novo
			aRet[nJ][5] := aRet[nJ][2] - aRet[nJ][3]		// Saldo
		next
	next
return aRet

//------------------------
static function getPvItem( aProds )
local aArea := getArea()
local nI
local nJ
local cProduto
local cPedido

	SC6->( dbSetOrder(12) )
	SA1->( dbSetOrder(1)  )

	for nI := 1 to len( aProds )
		cProduto := padR( aProds[nI][2], len(SC6->C6_PRODUTO) )

		for nJ := 1 to len( aProds[nI][9] )
//			cPedido  := padR( aProds[nI][9][nJ], len(SC5->C5_NUM) )
			cPedido  := padR( aProds[nI][9][nJ], len(cFilAnt)+len(SC5->C5_NUM) )

//			SC5->( dbSeek( xFilial("SC5") + cPedido ) )
			SC5->( dbSeek( cPedido ) )
			SA1->( dbSeek( xFilial("SA1") + SC5->(C5_CLIENT+C5_LOJAENT) ) )
			
			if cRede != "TODAS"
				ACY->( dbSetOrder(3) )	// ACY_DESCRI
				if ! ACY->( dbSeek( xFilial("ACY") + cRede ) ) .or. SA1->A1_GRPVEN != ACY->ACY_GRPVEN
					loop
				endif
			endif
			
			SZR->( dbSeek( xFilial("SZR") + SA1->A1_XROTA ) )

			SC6->( dbSeek( SC5->C5_FILIAL + SC5->C5_NUM + cProduto ) )
			while ! SC6->( eof() ) .and. SC6->( C6_FILIAL + C6_NUM + C6_PRODUTO ) == SC5->C5_FILIAL + SC5->C5_NUM + cProduto
				recLock("TEMP", .T.)
				TEMP->A1_NOME    := SA1->A1_NREDUZ	// SA1->A1_NOME
				TEMP->C6_XQTDORI := SC6->C6_XQTDORI
				TEMP->C6_QTDVEN  := SC6->C6_QTDVEN
				TEMP->A1_PRIOR   := iif( empty(SA1->A1_PRIOR), "9", SA1->A1_PRIOR )
				TEMP->ROTA       := SZR->ZR_CODIGO + "-" + SZR->ZR_DESCR
				TEMP->A1_COD     := SA1->A1_COD
				TEMP->A1_LOJA    := SA1->A1_LOJA
				TEMP->C6_NUM     := SC6->C6_NUM
				TEMP->C6_ITEM    := SC6->C6_ITEM
				TEMP->C6_PRODUTO := SC6->C6_PRODUTO
				TEMP->FILIAL     := SC6->C6_FILIAL
				msUnlock()

				SC6->( dbSkip() )
			end
		next
	next
	restArea( aArea )
return nil


//-------------------------------------------
static function fChangePrd( cProduto, oBrwTMP )
	if empty( cProduto )
		oBrwTMP:SetFilterDefault( ".T." )
	else
		oBrwTMP:SetFilterDefault( "C6_PRODUTO == '"+cProduto+"'" )
	endif
return nil


//---------------------------------------------
// validação da quantidade a ser Atendida
//---------------------------------------------

static function fValCpo( lA, oBrwTMP)
local aArea   := getArea()
local nQtDist := 0

	if C6_QTDVEN < 0
		return .F.
	endif

	dbGotop()
	while ! eof()
		nQtDist += C6_QTDVEN
		dbSkip()
	end

	aProds[oLst2:nAT][5] := nQtDist
	aProds[oLst2:nAT][8] := aProds[oLst2:nAT][10] - nQtDist
	oLst2:DrawSelect()

	restArea( aArea )
return .T.


//---------------------------------------------
static function DefColBrw()
local aColumns	:= {}
local oColumn
local nI
local aHead1    := {}

	aAdd(aHead1,{"Nome Cliente","A1_NOME"   ,"C", len(SA1->A1_NOME)   , 0,"@!"               })
	aAdd(aHead1,{"Qtd.Original","C6_XQTDORI","N", 12                  , 2,"@E 999,999,999.99"})
	aAdd(aHead1,{"Qtd.Atende"  ,"C6_QTDVEN" ,"N", 12                  , 2,"@E 999,999,999.99"})
	aAdd(aHead1,{"Prioridade"  ,"A1_PRIOR"  ,"C",  1                  , 0,"9"                })
	aAdd(aHead1,{"Rota"        ,"ROTA"      ,"C", 40                  , 0,"@X"               })
	aAdd(aHead1,{"Cód.Cliente" ,"A1_COD"    ,"C",  6                  , 0,"@!"               })
	aAdd(aHead1,{"Loja Cliente","A1_LOJA"   ,"C",  2                  , 0,"@!"               })
	aAdd(aHead1,{"Pedido"      ,"C6_NUM"    ,"C",  6                  , 0,"@X"               })
	aAdd(aHead1,{"Item"        ,"C6_ITEM"   ,"C",  2                  , 0,"@X"               })
	aAdd(aHead1,{"Produto"     ,"C6_PRODUTO","C", len(SC6->C6_PRODUTO), 0,"@X"               })
	aAdd(aHead1,{"Filial"      ,"FILIAL"    ,"C", len(cFilAnt)        , 0,"@X"               })

	for nI := 1 to len( aHead1 )
		aAdd(aColumns , FWBrwColumn():New())
		oColumn := aTail(aColumns)

		oColumn:SetData( &("{||"+ aHead1[nI][2] +"}") )
		oColumn:SetTitle( aHead1[nI][1] )
		oColumn:SetType( aHead1[nI][3] )
		oColumn:SetSize( aHead1[nI][4] )
		oColumn:SetDecimal( aHead1[nI][5] )
		If alltrim(aHead1[nI][2]) == "C6_QTDVEN"
			oColumn:SetEdit( .T. )
			oColumn:SetValid( {|a,b| fValCpo(a,b)} )
		EndIf
		oColumn:SetReadVar( aHead1[nI][2] )
		oColumn:SetPicture( aHead1[nI][6] )
	next

return aColumns


//----------------------------
static function fLibera( oBrwTMP, oDlg )
local lCredito := .t.
local lEstoque := .t.
local lLiber   := .t.
local lTransf  := .f.
local lAvCred  := .f.
local lAvEst   := GetMv("MV_ESTNEG") != "S"
local xFilAnt  := cFilAnt

	if ! msgYesNo( "Confirma a liberação destes Itens?", cTitulo)
		return nil
	endif

	SC6->( dbSetOrder(1) )

	fChangePrd( "", oBrwTMP )
	TEMP->( dbGotop() )

	while ! TEMP->(eof())
		if TEMP->C6_QTDVEN > 0

			cFilAnt := TEMP->FILIAL

			if SC6->( dbSeek( xFilial("SC6") + TEMP->C6_NUM + TEMP->C6_ITEM + TEMP->C6_PRODUTO) )
				recLock("SC6", .F.)
				SC6->C6_QTDVEN := TEMP->C6_QTDVEN
				SC6->C6_VALOR  := SC6->C6_PRCVEN * SC6->C6_QTDVEN
				msUnlock()

				dbSelectArea("SC6")
				nQtdLib := MaLibDoFat(SC6->(RecNo()),TEMP->C6_QTDVEN,@lCredito,@lEstoque,lAvCred,lAvEst,lLiber,lTransf)

				X := 1
			endif
		endif
		TEMP->( dbSkip())
	end

	cFilAnt := xFilAnt
	oDlg:end()
return nil
