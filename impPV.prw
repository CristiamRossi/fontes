#include "totvs.ch"
#include "apwizard.ch"
/*/{Protheus.doc} impPV
Importação Pedido de Vendas por planilha em .CSV, layout Padrão de Açúcar e layout Neogrid
@type function
@author Cristiam Rossi
@since 29/11/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

user function impPV()
local lContinua := .T.

	while lContinua		// loop criado para ficar com a rotina em execução sem sair
		RodaImpPv()
		lContinua := msgYesNo( "Deseja Continuar na rotina?", "Rotina de Importação dos Pedidos de Vendas" )
	end

return nil

Static function RodaImpPv()
local   aArea    := getArea()
local   oWizard
local   oPanel
local   oBtn
private nMAXLIN  := 1500							// total de linhas a serem consideradas no CSV
private nMAXCOL  := 200								// total de colunas a serem consideradas no CSV
private oArquivo
private cArquivo := space(100)
private cTitulo  := "Importação de Pedidos de Vendas"
private nHdl     := 0
private cPath    := GetTempPath()
private cLOG     := criaTrab(,.F.)+".htm"
//private oTIBrowser
private oSE

//---------- Parâmetros ----------//
private AT_CONDPV  := ""	// condição de pagto
private AT_PVTES   := ""	// TES

//	chkParam()

	DEFINE WIZARD oWizard TITLE cTitulo ;
		HEADER "Gerar novos pedidos de vendas" ;
		MESSAGE "" ;
		TEXT "Esta rotina irá carregar um arquivo no formato .TXT (layout NEOGRID), .SCP (layout Pão de Açúcar) ou .CSV (layout Planilha), fazer as devidas consistências e importar os Pedidos de Vendas." ;
		NEXT {||.T.} ;
		FINISH {|| .T. } ;
		PANEL

	CREATE PANEL oWizard ;
		HEADER "Informe o arquivo a ser importado" ;
		MESSAGE "A rotina irá carregar o arquivo, fazer as devidas consistênciass e gerar os Pedidos de Vendas" ;
		BACK {|| .T. } ;
		NEXT {|| ! empty( cArquivo ) .and. fDistrib() } ;
		FINISH {|| .T. } ;
		PANEL
		oPanel := oWizard:GetPanel(2)
		@ 15,15 SAY "Arquivo:" SIZE 45,8 PIXEL OF oPanel
		@ 13,60 button oBtn prompt "Selecionar" size 45, 12 action getArq()  PIXEL OF oPanel
		@ 30,15 MSGET oArquivo Var cArquivo SIZE 240,10 PIXEL OF oPanel when .F.

	CREATE PANEL oWizard ;
		HEADER "Finalização" ;
		MESSAGE "Importação finalizada!" ;
		BACK {|| .F. } ;
		NEXT {|| .F. } ;
		FINISH {|| .T. } ;
		PANEL
		oPanel := oWizard:GetPanel(3)

//		oTIBrowser := TIBrowser():New( 0, 5, /*larg*/ 290, /*altura*/ 140, "", oPanel )
		oSE        := tSimpleEditor():new(0,5, oPanel, 290, 140)

	ACTIVATE WIZARD oWizard CENTERED

	if file( cPath + cLog )
		if msgYesNo("Deseja abrir o arquivo de LOG no excel?", cTitulo)
			ShellExecute("Open","EXCEL.EXE",cPath + cLog,"C:\",1)   
		endif
	endif

	restArea( aArea )
return nil


//--------------------------------------------
Static Function getArq()
local cArqTmp  := ""
local nPos     := 0
local cTipFile := "Arquivos TXT|*.txt|Arquivos SCP|*.scp|Arquivos CSV|*.csv"

	cArquivo   := cGetFile( cTipFile, 'Selecione o arquivo a ser importado',1,'C:\',.T., GETF_LOCALHARD, .T., .T. )

	nPos := RAT("\",cArquivo)
	if nPos > 0
		cArqTmp := substr(cArquivo, nPos+1)
	else
		cArqTmp := cArquivo
	endif

	oArquivo:SetText(cArquivo)
	oArquivo:Refresh()
return nil


//--------------------------------------------
static function fDistrib()
local cExtensao := upper(right(cArquivo,3))
local lRet      := .F.

	do case
		case cExtensao == "TXT"
			lRet := Importa()
		case cExtensao == "SCP"
			lRet := impPAO()
		case cExtensao == "CSV"
			lRet := impCSV()
		otherwise
			msgStop( "Extensão não reconhecida", "Seleção do arquivo" )
			lRet := .F.
	end case
return lRet


//--------------------------------------------
Static Function importa()
local   cLinha
local   nOK      := 0
local   nERR     := 0
local   lOK      := .T.
local   cPedCli  := ""
local   cCNPJfor := ""
local   cCNPJCli := ""
local   cCNPJFat := ""
local   cCNPJEnt := ""
local   aCond    := {}
local   lReg09   := .T.
local   aCabec   := {}
local   aItens   := {}
local   cItem    := StrZero(1, len(SC6->C6_ITEM), 0)
local   nI
Local 	lPedExis := .F.
private nLin     := 0
private lBack    := .T.
private aProcOK  := {}
private aProcERR := {}

	if FT_FUSE( cArquivo ) == -1
		msgAlert("Não foi possível abrir o arquivo "+cArquivo, cTitulo)
		return .F.
	endif

	nHdl := fCreate(cLOG, 0)
	if nHdl == -1
		msgAlert( "Problema na criação do arquivo de log: "+cLOG, cTitulo)
		return .F.
	else
		cTXT := "<html>"
		cTXT += "<head><title>LOG da "+cTitulo+"</title>"
		cTXT += "<style>"

		cTXT += "body, table {"
		cTXT += 	"font-family: verdana, arial;"
		cTXT += 	"font-size: 10px;"
		cTXT += "}"
		cTXT += "</style>"

		cTXT += "</head>"
		cTXT += "<body>"
		cTXT += "<h4>Problemas encontrados:</h4>"
		cTXT += "<table border='0' width='100%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Linha</th><th>Inconsistência</th><th>Descrição</th></tr>"
		lBack := !lBack
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	while !FT_FEOF()
		cLinha := FT_FREADLN()
		nLin++
		lPedExis := .F.

// registro 01 - CABEÇALHO
		if nLin == 1
			if left(cLinha, 2) != "01"
				// não é o cabeçalho NEOGRID
				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Arquivo inválido</td><td>Este arquivo não é layout NEOGRID</td></tr>"
				lBack := !lBack
				fWrite(nHdl, cTXT, Len(cTXT))
				lOk := .F.
				exit
			endif

			if substr(cLinha,3,3) != "9  "
				// só será tratada INCLUSÃO
				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Tipo de Pedido Inválido</td><td>Esta rotina efetua apenas INCLUSÃO ["+substr(cLinha,3,3)+"]</td></tr>"
				lBack := !lBack
				fWrite(nHdl, cTXT, Len(cTXT))
				lOk := .F.
				exit
			endif

			cPedCli  := substr(cLinha,9,20)
			SC5->( dbOrderNickname("C5PEDCLI") )
			lPedExis := SC5->(dbSeek(xFilial("SC5")+cPedCli)) 
			
			If lPedExis
				If MsgYesNo("Pedido de venda com o codigo pedido do cliente "+cPedCli+" ja existe, deseja criar assim mesmo?","PEDIDO JA EXISTE")			
					lPedExis := .F.    // .F. pedido será criado
				Else	
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>PV já existente</td><td>Este PV já foi lançado. Pedido cliente: ["+cPedCli+"], pedido protheus: ["+SC5->C5_NUM+"]</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
					//exit -- alinhado com Vinicius e retirado em 11/03/2020
				EndIf
			endif
            
			If ! lPedExis
				cCNPJfor := substr(cLinha,167,14)
				cCNPJCli := substr(cLinha,181,14)
				cCNPJFat := substr(cLinha,195,14)
				cCNPJEnt := substr(cLinha,209,14)
	/*
				if empty( cCNPJfor ) .or. cCNPJfor != SM0->M0_CGC
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>PV p/ outro CNPJ</td><td>Este PV não é pra este CNPJ ["+cCNPJfor+"]</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
					exit
				endif
	*/
				if empty(cCNPJEnt)			// caso for vazio assume o CNPJ do cliente
					cCNPJFat := cCNPJCli
				endif
	
				SA1->( dbSetOrder(3) )
				if empty( cCNPJEnt ) .or. ! SA1->( dbSeek( xFilial("SA1") + cCNPJEnt ) )
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>CNPJ cliente</td><td>O cliente com CNPJ ["+cCNPJFat+"] não foi encontrado</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
					exit
				Else
					cCodCli := SA1->A1_COD
					cLojCli := SA1->A1_LOJA
					cCodEnt := SA1->A1_COD
					cLojEnt := SA1->A1_LOJA
				EndIf	
	
				/*
				if cCNPJEnt != cCNPJCli
					SA1->( dbSetOrder(3) )
					if empty( cCNPJEnt ) .or. ! SA1->( dbSeek( xFilial("SA1") + cCNPJEnt ) )
						cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>CNPJ cliente Entrega</td><td>O cliente de Entrega com CNPJ ["+cCNPJEnt+"] não foi encontrado</td></tr>"
						lBack := !lBack
						fWrite(nHdl, cTXT, Len(cTXT))
						lOk := .F.
					endif
					cCodEnt := SA1->A1_COD
					cLojEnt := SA1->A1_LOJA
				else
					cCodEnt := cCodCli
					cLojEnt := cLojCli
				endif
				*/
				aAdd(aCabec,{"C5_TIPO"		,"N"					,Nil})
				aAdd(aCabec,{"C5_CLIENTE"	,cCodCli				,Nil})
				aAdd(aCabec,{"C5_LOJACLI"	,cLojCli				,Nil})
				aAdd(aCabec,{"C5_CLIENT"	,cCodEnt				,Nil})
				aAdd(aCabec,{"C5_LOJAENT"	,cLojEnt				,Nil})
	//			aAdd(aCabec,{"C5_FRETE"		,1000					,Nil})			// VALOR DO FRETE, VER ROTA
				aAdd(aCabec,{"C5_XPEDCLI"	,cPedCli				,Nil})
			EndIf	
		endif

// registro 02 - Condição de Pagamento
		if left(cLinha, 2) == "02"				// podem ser N registros
//			if substr(cLinha,3,3) != "1  "
//				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Cond.Pagto</td><td>A condição de pagamento está ["+substr(cLinha,3,3)+"] no arquivo, apenas verifique</td></tr>"
//				lBack := !lBack
//				fWrite(nHdl, cTXT, Len(cTXT))
//			endif

			aadd( aCond, substr(cLinha,15,3) )
		endif

// registro 04 - Itens
		if left(cLinha, 2) == "04"				// podem ser N registros
			//NEOGRID  Len = 13 (B1_CODBAR), se Len = 14 (B1_XCODDUN)
			cCodArq	:=  AllTrim(SubStr(cLinha,18,14))
			cTpCod   := substr(cLinha,15,3)		// nos modelos que recebi são EN = EAN
			cDescri  := alltrim( substr(cLinha,32,40) )
			cTipo	 := AllTrim( substr(cLinha,18,13) )                               
			
			If Len(cCodArq) == 13 
				cCodPrd  := AllTrim(SubStr(cLinha,18,13))      
				SB1->( dbSetOrder( 5 ) )                                 
			Else	
				cCodPrd  := AllTrim(SubStr(cLinha,18,14))
				SB1->(dbOrderNickname("B1XDUN"))				
			EndIf	
			
			if ! SB1->( dbSeek( xFilial("SB1") + cCodPrd) )
				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Produto não encontrado</td><td>O produto código ["+cCodPrd+"] e descrição ["+cDescri+"] não foi encontrado</td></tr>"
				lBack := !lBack
				fWrite(nHdl, cTXT, Len(cTXT))
				lOK := .F.
			endif

			nQtdPed  := val(substr(cLinha,100,15))/100

			nVlLINHA := val(substr(cLinha,168,15))/100
			nVlBrut  := val(substr(cLinha,183,15))/100
			nVlLiq   := val(substr(cLinha,198,15))/100

			aLinha := {}
			aAdd(aLinha,{"C6_ITEM"		,cItem				,Nil})
			aAdd(aLinha,{"C6_PRODUTO"	,SB1->B1_COD		,Nil})
			aAdd(aLinha,{"C6_QTDVEN"	,nQtdPed			,Nil})
			aAdd(aLinha,{"C6_PRCVEN"	,nVlBrut			,Nil})
			aAdd(aLinha,{"C6_PEDCLI"	,cPedCli			,Nil})
			aAdd(aItens, aLinha)

			cItem := soma1( cItem )
		endif

// registro 09 - Sumário
		if left(cLinha, 2) == "09"
			lReg09 := .T.
		endif

		if lOk
			nOK++
		else
			nERR++
		endif

		FT_FSKIP()
	end

	if ! lReg09		// Arquivo corrompido, tem que ter o registro TRAILLER
		cTXT  := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Arquivo corrompido</td><td>ausência do registro 09 - Sumário</td></tr>"
		lBack := !lBack
		lOk   := .F.
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

// check cond pagto

	FT_FUSE()

	cTXT := "</table><br />"
	cTXT += "<h4>Resumo:</h4>"
	cTXT += "<table border='0'  width='50%'>"
	cTXT += "<tr style='background-color: #CCCCCC'><td width='60%'>Linhas:</td><td>" + cValToChar(nLin) + "</td></tr>"
	cTXT += "<tr><td>Linha OK:</td><td>" + cValToChar(nOK)  + "</td></tr>"
	cTXT += "<tr style='background-color: #CCCCCC'><td>Linha ERRO:</td><td>"  + cValToChar(nERR) + "</td></tr>"
	cTXT += "</table>"
	fWrite(nHdl, cTXT, Len(cTXT))

	if lOk
		Processa({|| ProcPV( aCabec, aItens )},"Incluindo Pedidos...","Aguarde!...")

		lBack := .T.
		cTXT := "<h4>Pedidos gerados:</h4>"
		cTXT += "<table border='0' width='50%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Filial</th><th>Número</th></tr>"
		fWrite(nHdl, cTXT, Len(cTXT))
	
		for nI := 1 to len( aProcOK )
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>"+aProcOK[nI,1]+"</td><td>"+aProcOK[nI,2]+"</td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
		next

		lBack := .T.

		if len( aProcERR ) > 0
			cTXT := "</table><br />"
			cTXT += "<h4>Erros na inclusão:</h4>"
			cTXT += "<table border='0' width='100%'>"
			cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Filial</th><th>Erro</th></tr>"
			fWrite(nHdl, cTXT, Len(cTXT))

			for nI := 1 to len( aProcERR )
				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>"+aProcERR[nI,1]+"</td><td><pre>"+aProcERR[nI,2]+"</pre></td></tr>"
				lBack := !lBack
				fWrite(nHdl, cTXT, Len(cTXT))
			next
		endif

		cTXT := "</table><br />"
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	cTXT := "</body></html>"
	fWrite(nHdl, cTXT, Len(cTXT))

	fClose( nHdl )

	CpyS2T(GetSrvProfString("Startpath","")+cLOG, cPath, .T.)

	cTXT := memoRead( GetSrvProfString("Startpath","")+cLOG )

//	oTIBrowser:Navigate( "file:///"+cPath+cLOG )
	oSE:load( cTXT )
return .T.


//---------------------------------------------------
Static Function impPAO()	// layout Pão de Açúcar
local   cLinha
local   nOK      := 0
local   nERR     := 0
local   lOK      := .F.
local   cPedCli  := ""
local   aCabec   := {}
local   aItens   := {}
local   cItem    := StrZero(1, len(SC6->C6_ITEM), 0)
local   nI  
Local   lPedExis := .F.
private nLin     := 0
private lBack    := .T.
private aProcOK  := {}
private aProcERR := {}

	if FT_FUSE( cArquivo ) == -1
		msgAlert("Não foi possível abrir o arquivo "+cArquivo, cTitulo)
		return .F.
	endif

	nHdl := fCreate(cLOG, 0)
	if nHdl == -1
		msgAlert( "Problema na criação do arquivo de log: "+cLOG, cTitulo)
		return .F.
	else
		cTXT := "<html>"
		cTXT += "<head><title>LOG da "+cTitulo+"</title>"
		cTXT += "<style>"

		cTXT += "body, table {"
		cTXT += 	"font-family: verdana, arial;"
		cTXT += 	"font-size: 10px;"
		cTXT += "}"
		cTXT += "</style>"

		cTXT += "</head>"
		cTXT += "<body>"
		cTXT += "<h4>Problemas encontrados:</h4>"
		cTXT += "<table border='0' width='100%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Linha</th><th>Inconsistência</th><th>Descrição</th></tr>"
		lBack := !lBack
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	while !FT_FEOF()
		cLinha := FT_FREADLN()
		nLin++         
		lPedExis := .F.

// registro 01 - CABEÇALHO
		if left(cLinha, 2) == "01"
			cPedCli := substr(cLinha,3,15)
			aSize(aCabec,0)
			aLinha  := {}
			aItens  := {}
			lOk     := .T.
			lReg09  := .F.

			SC5->( dbOrderNickname("C5PEDCLI") )
			lPedExis := SC5->(dbSeek(xFilial("SC5")+cPedCli)) 
			
			If lPedExis
				If MsgYesNo("Pedido de venda com o codigo pedido do cliente "+cPedCli+" ja existe, deseja criar assim mesmo?","PEDIDO JA EXISTE")			
					lPedExis := .F.    // .F. pedido será criado
				Else	
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>PV já existente</td><td>Este PV já foi lançado. Pedido cliente: ["+cPedCli+"], pedido protheus: ["+SC5->C5_NUM+"]</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
                EndIf
	        EndIf
			
			If ! lPedExis
				dEmissao := substr(cLinha,21,8)
				dEntrega := substr(cLinha,37,8)
				nVlFrete := val(substr(cLinha,114,11)) / 100

				cFornec1 := substr(cLinha,127,5)
				cFornec2 := substr(cLinha,132,4)

				cEANcomp := substr(cLinha,59,13)
				cEANforn := substr(cLinha,72,13)
				cEANentr := substr(cLinha,85,13)
				cEANcobr := substr(cLinha,98,13)

				SA1->(dbOrderNickname("A1XEANPAO"))
				if ! SA1->( dbSeek( xFilial("SA1") + cEANentr) )		// nao encontrou endereco de Entrega
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Local Pão de Açúcar</td><td>Não encontrou Endereço de Entrega p/ EAN: ["+cEANentr+"], pedido cliente: ["+cPedCli+"]</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
				else
					cCodEnt := SA1->A1_COD
					cLojEnt := SA1->A1_LOJA

					cCodCli := SA1->A1_COD		// mesmo cliente cobrança e entrega
					cLojCli := SA1->A1_LOJA		// mesmo cliente cobrança e entrega
				endif
/*
				if ! SA1->( dbSeek( xFilial("SA1") + cEANcobr) )		// nao encontrou Cliente de Cobrança
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Local Pão de Açúcar</td><td>Não encontrou Endereço de Cobrança p/ EAN: ["+cEANcobr+"], pedido cliente: ["+cPedCli+"]</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
				else
					cCodCli := SA1->A1_COD
					cLojCli := SA1->A1_LOJA
				endif
*/
				if lOk
					aAdd(aCabec,{"C5_TIPO"		,"N"					,Nil})
					aAdd(aCabec,{"C5_CLIENTE"	,cCodCli				,Nil})
					aAdd(aCabec,{"C5_LOJACLI"	,cLojCli				,Nil})
					aAdd(aCabec,{"C5_CLIENT"	,cCodEnt				,Nil})
					aAdd(aCabec,{"C5_LOJAENT"	,cLojEnt				,Nil})
					aAdd(aCabec,{"C5_FRETE"		,nVlFrete				,Nil})			// VALOR DO FRETE, VER ROTA
					aAdd(aCabec,{"C5_XPEDCLI"	,cPedCli				,Nil})
				endif
			endif

			cItem  := StrZero(1, len(SC6->C6_ITEM), 0)
		endif


		if lOK		// tá com cabeçalho
			if left(cLinha, 2) == "11"				// mensagem
/*
11011840495562380
11
  011840495562380
                 XXXX
*/

				cTemp := alltrim( substr(cLinha,18,140) )
//				aAdd(aCabec,{"C5_"		,cTemp, Nil})		// não tem campo padrão, Cria?
			endif

			if left(cLinha, 2) == "02"				// condição de pagto
/*
020118404955623800012FS0450000000000210010000000000000000000                                                     0000000000000000000000   000000000000
  011840495562380
                 001
                    2
                     FS
                       045
                          00000000
                                  002100
                                        10000
*/
//				cTemp := substr(cLinha,24,3) + "-" + substr(cLinha,22,2)
//				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Condição de Pagamento</td><td>A condição de pagamento está ["+cTemp+"] no arquivo, apenas verifique</td></tr>"
//				lBack := !lBack
//				fWrite(nHdl, cTXT, Len(cTXT))
			endif

			if left(cLinha, 2) == "03"				// itens
/*
03011840495562380EAN07895000288205000001TQ COUVE FLOR ORG TAEQ 350G           0000040000000000000698000000000000000000000000000000000000000000000000000000000000000000000000000               000000000000000000000  000000000000000000000000                         0000000000000                         000000000000000000000000000000
03
  011840495562380
                 EAN
                    07895000288205
                                  000001
                                        TQ COUVE FLOR ORG TAEQ 350G        
                                                                           XXX
                                                                              000004000
                                                                                       00000000006980000
                                                                                                        00000000000000000000000000000000000000000000000000000000000000000000000               000000000000000000000  000000000000000000000000                         0000000000000                         000000000000000000000000000000                    
*/              
				//PAO DE AÇUCAR - Se posição 18 = EAN (B1_CODBAR), se 18 = DUN (B1_XCODDUN)
				
				cTpCod   := substr(cLinha,18,3)		// Tipo EAN - DUN (GTIN)
				cDescri  := alltrim( substr(cLinha,41,35) )

				If cTpCod == "EAN"
					cCodPrd  := alltrim( substr(cLinha,22,13) )
					SB1->( dbSetOrder( 5 ) )                       
				Else // DUN
					cCodPrd  := alltrim( substr(cLinha,21,14) )
					SB1->(dbOrderNickname("B1XDUN"))				
				endif
									
				if ! SB1->( dbSeek( xFilial("SB1") + cCodPrd) )

					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Produto não encontrado</td><td>O produto código ["+cCodPrd+"] e descrição ["+cDescri+"] não foi encontrado</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOK := .F.
/*
reclock("SB1", .T.)
SB1->B1_FILIAL := xFilial("SB1")
SB1->B1_COD    := cCodPrd
SB1->B1_CODBAR := cCodPrd
SB1->B1_DESC   := cDescri
SB1->B1_UM     := "UN"
SB1->B1_TS     := "501"
SB1->B1_LOCPAD := "01"
msUnlock()
*/
				endif

				if lOK
//					nQtdPed  := val( substr(cLinha,35,6) )
					nQtdPed  := val( substr(cLinha,79,9) ) / 1000

					nVlBrut  := val(substr(cLinha,88,17))/1000000
					nVlLiq   := nVlBrut
					nVlLINHA := nVlBrut * nQtdPed

					aLinha := {}
					aAdd(aLinha,{"C6_ITEM"		,cItem				,Nil})
					aAdd(aLinha,{"C6_PRODUTO"	,SB1->B1_COD		,Nil})
					aAdd(aLinha,{"C6_QTDVEN"	,nQtdPed			,Nil})
					aAdd(aLinha,{"C6_PRCVEN"	,nVlBrut			,Nil})
					aAdd(aLinha,{"C6_PEDCLI"	,cPedCli			,Nil})
					aAdd(aItens, aLinha)

					cItem := soma1( cItem )
				endif
			endif

			if lOk .and. left(cLinha, 2) == "09"				// trailler
				lReg09 := .T.
				Processa({|| ProcPV( aCabec, aItens )},"Incluindo Pedidos...","Aguarde!...")
			endif
		endif

		if lOk
			nOK++
		else
			nERR++
		endif

		FT_FSKIP()
	end

	lBack := .T.
	cTXT := "</table><br />"
	cTXT += "<h4>Pedidos gerados:</h4>"
	cTXT += "<table border='0' width='50%'>"
	cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Filial</th><th>Número</th></tr>"
	fWrite(nHdl, cTXT, Len(cTXT))

	for nI := 1 to len( aProcOK )
		cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>"+aProcOK[nI,1]+"</td><td>"+aProcOK[nI,2]+"</td></tr>"
		lBack := !lBack
		fWrite(nHdl, cTXT, Len(cTXT))
	next

	lBack := .T.

	if len( aProcERR ) > 0
		cTXT := "</table><br />"
		cTXT += "<h4>Erros na inclusão:</h4>"
		cTXT += "<table border='0' width='100%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Filial</th><th>Erro</th></tr>"
		fWrite(nHdl, cTXT, Len(cTXT))

		for nI := 1 to len( aProcERR )
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>"+aProcERR[nI,1]+"</td><td><pre>"+aProcERR[nI,2]+"</pre></td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
		next
	endif

	FT_FUSE()

	cTXT := "</table><br />"
	cTXT += "<h4>Resumo:</h4>"
	cTXT += "<table border='0'  width='50%'>"
	cTXT += "<tr style='background-color: #CCCCCC'><td width='60%'>Linhas:</td><td>" + cValToChar(nLin) + "</td></tr>"
	cTXT += "<tr><td>Linha OK:</td><td>" + cValToChar(nOK)  + "</td></tr>"
	cTXT += "<tr style='background-color: #CCCCCC'><td>Linha ERRO:</td><td>"  + cValToChar(nERR) + "</td></tr>"
	cTXT += "</table>"
	fWrite(nHdl, cTXT, Len(cTXT))

	cTXT := "</body></html>"
	fWrite(nHdl, cTXT, Len(cTXT))

	fClose( nHdl )

	CpyS2T(GetSrvProfString("Startpath","")+cLOG, cPath, .T.)

	cTXT := memoRead( GetSrvProfString("Startpath","")+cLOG )

	oSE:load( cTXT )
return .T.


//--------------------------------------------
Static Function impCSV()
local   cLinha
local   xTmp
local   nOK      := 0
local   nERR     := 0
local   lOK      := .T.
local   nTamPrd  := len( SB1->B1_COD )
local   nTamCli  := len( SA1->A1_COD )
local   aCol     := {}
local   aCabec   := {}
local   aItens   := {}
local   cItem    := StrZero(1, len(SC6->C6_ITEM), 0)
local   nI
local   nJ
local   aPVs     := {}
private nLin     := 0
private lBack    := .T.
private aProcOK  := {}
private aProcERR := {}

	if FT_FUSE( cArquivo ) == -1
		msgAlert("Não foi possível abrir o arquivo "+cArquivo, cTitulo)
		return .F.
	endif

	nHdl := fCreate(cLOG, 0)
	if nHdl == -1
		msgAlert( "Problema na criação do arquivo de log: "+cLOG, cTitulo)
		return .F.
	else
		cTXT := "<html>"
		cTXT += "<head><title>LOG da "+cTitulo+"</title>"
		cTXT += "<style>"

		cTXT += "body, table {"
		cTXT += 	"font-family: verdana, arial;"
		cTXT += 	"font-size: 10px;"
		cTXT += "}"
		cTXT += "</style>"

		cTXT += "</head>"
		cTXT += "<body>"
		cTXT += "<h4>Problemas encontrados:</h4>"
		cTXT += "<table border='0' width='100%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Linha</th><th>Inconsistência</th><th>Descrição</th></tr>"
		lBack := !lBack
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	while !FT_FEOF()
		nLin++

		if nLin == 1 .or. nLin == 3		// linhas a serem ignoradas
			nOK++
			FT_FSKIP()
			loop
		endif

		cLinha := FT_FREADLN()
		cLinha := strTran( cLinha, ";", " ; " )
		aCol   := strTokArr( cLinha, ";" )

		if nLin == 2	// clientes
			if len( aCol ) < 7 .or. ! "CLIENTE" $ upper(aCol[4])
				// não é a Planilha padrão
				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Arquivo inválido</td><td>Este arquivo não é layout padrão da planilha</td></tr>"
				lBack := !lBack
				fWrite(nHdl, cTXT, Len(cTXT))
				lOk := .F.
				nERR++
				exit
			endif

			SA1->( dbSetOrder(1) )
			for nI := 7 to nMAXCOL
				if empty( aCol[nI] )		// término dos clientes
					nMAXCOL := nI
					exit
				endif

				xTmp := alltrim( aCol[nI] )

				if ! SA1->( dbSeek( xFilial("SA1") + padR( xTmp, nTamCli) ) .or. dbSeek( xFilial("SA1") + right( "000000"+xTmp, nTamCli) ) )
					cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Cliente não encontrado</td><td>Verifique o código do cliente ["+xTmp+"], não foi encontrado!</td></tr>"
					lBack := !lBack
					fWrite(nHdl, cTXT, Len(cTXT))
					lOk := .F.
					nERR++
				else
					aadd( aPVs, { {SA1->A1_COD,SA1->A1_LOJA} /*cod,loja*/, {} /*pedidos*/} )
				endif
			next

			nOK++
			FT_FSKIP()
			loop
		endif

		if nLin > nMAXLIN
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Interompido por excesso de linhas</td><td>Verifique se o arquivo está com a linha dos TOTAIS</td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
			lOk := .F.
			nERR++
			exit
		endif

		if "TOTA" $ upper(aCol[1])		// término dos itens
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Término dos itens</td><td>Encontrada linha dos TOTAIS</td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
			exit
		endif

		if empty( aCol[3] )		// produto não informado
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>sem código do produto</td><td>linha sem o código do produto, ignorada</td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
			FT_FSKIP()
			loop
		endif

		xTmp := alltrim( aCol[3] )
		SB1->( dbSetOrder(1) )
		if ! SB1->( dbSeek( xFilial("SB1") + padR(xTmp,nTamPrd) ) .or. dbSeek( xFilial("SB1") + padR( right("000000"+xTmp,6) ,nTamPrd) ) )
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Código do Produto ["+xTmp+"] não foi encontrado, verificar!</td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
			lOk := .F.
			nERR++
		endif

		for nI := 7 to nMAXCOL
			xTmp := val( aCol[nI] )
			if xTmp > 0 .and. len(aPVs) >= nI-6
				aadd( aPVs[nI-6][2], { SB1->B1_COD, xTmp } )
			endif
		next

		FT_FSKIP()
	end
	FT_FUSE()

	if ! lOk		// problemas encontrados que impedem a inclusão dos pedidos
		cTXT  := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>#"+cValTochar(nLin)+"</td><td>Arquivo corrompido</td><td>Problemas graves encontrados que impedem o processamento, verifique o arquivo!</td></tr>"
		lBack := !lBack
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	cTXT := "</table><br />"
	cTXT += "<h4>Resumo:</h4>"
	cTXT += "<table border='0'  width='50%'>"
	cTXT += "<tr style='background-color: #CCCCCC'><td width='60%'>Linhas:</td><td>" + cValToChar(nLin) + "</td></tr>"
	cTXT += "<tr><td>Linha OK:</td><td>" + cValToChar(nOK)  + "</td></tr>"
	cTXT += "<tr style='background-color: #CCCCCC'><td>Linha ERRO:</td><td>"  + cValToChar(nERR) + "</td></tr>"
	cTXT += "</table>"
	fWrite(nHdl, cTXT, Len(cTXT))

	if lOk

		for nI := 1 to len( aPVs )

			aCabec := {}
			aItens := {}
			cItem  := StrZero(1, len(SC6->C6_ITEM), 0)

			aAdd(aCabec,{"C5_TIPO"		,"N"					,Nil})
			aAdd(aCabec,{"C5_CLIENTE"	,aPVs[nI][1][1]			,Nil})
			aAdd(aCabec,{"C5_LOJACLI"	,aPVs[nI][1][2]			,Nil})

			for nJ := 1 to len( aPVs[nI][2] )

				aLinha := {}
				aAdd(aLinha,{"C6_ITEM"		,cItem				,Nil})
				aAdd(aLinha,{"C6_PRODUTO"	,aPVs[nI][2][nJ][1]	,Nil})
				aAdd(aLinha,{"C6_QTDVEN"	,aPVs[nI][2][nJ][2]	,Nil})
				aAdd(aItens, aLinha)

				cItem := soma1( cItem )
			next

			Processa({|| ProcPV( aCabec, aItens )},"Incluindo Pedidos...","Aguarde!...")
		next

		lBack := .T.
		cTXT := "<h4>Pedidos gerados:</h4>"
		cTXT += "<table border='0' width='50%'>"
		cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Filial</th><th>Número</th></tr>"
		fWrite(nHdl, cTXT, Len(cTXT))

		for nI := 1 to len( aProcOK )
			cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>"+aProcOK[nI,1]+"</td><td>"+aProcOK[nI,2]+"</td></tr>"
			lBack := !lBack
			fWrite(nHdl, cTXT, Len(cTXT))
		next

		lBack := .T.

		if len( aProcERR ) > 0
			cTXT := "</table><br />"
			cTXT += "<h4>Erros na inclusão:</h4>"
			cTXT += "<table border='0' width='100%'>"
			cTXT += "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><th>Filial</th><th>Erro</th></tr>"
			fWrite(nHdl, cTXT, Len(cTXT))

			for nI := 1 to len( aProcERR )
				cTXT := "<tr"+iif(lBack," style='background-color: #CCCCCC'","")+"><td>"+aProcERR[nI,1]+"</td><td><pre>"+aProcERR[nI,2]+"</pre></td></tr>"
				lBack := !lBack
				fWrite(nHdl, cTXT, Len(cTXT))
			next
		endif

		cTXT := "</table><br />"
		fWrite(nHdl, cTXT, Len(cTXT))
	endif

	cTXT := "</body></html>"
	fWrite(nHdl, cTXT, Len(cTXT))

	fClose( nHdl )

	CpyS2T(GetSrvProfString("Startpath","")+cLOG, cPath, .T.)

	cTXT := memoRead( GetSrvProfString("Startpath","")+cLOG )

	oSE:load( cTXT )
return .T.


//-------------------------------------------------
static function ProcPV( aCabec, aItens )
local   aArea    := getArea()
local   xStat    := ""

	xStat := geraPV( aCabec, aItens )

	If left(xStat, 2) == "OK"
		aadd( aProcOK , { cFilAnt, substr( xStat, 4) } )		// Filial, NumPV
	Else
		aadd( aProcERR, { cFilAnt, xStat             } )		// Filial, ERRO
	EndIf

	restArea( aArea )
return nil


//---------------------------------------------------------
static function geraPV( aCabec, aItens )
local   nOpc           := 3		// inclusão
local   oErro          := ErrorBlock({|e| FilterErro(e)})
local   nI
local   aLogAuto       := {}
private lAutoErrNoFile := .T.
private lMsErroAuto    := .F.
private lMsHelpAuto    := .F. 

	cRetExec := ""

	begin sequence

	msExecAuto({|x,y,w| MATA410(x,y,w)}, aCabec, aItens, nOpc)
  	if lMsErroAuto
	    aLogAuto := GetAutoGRLog()
	    For nI := 1 To Len(aLogAuto)
	        cRetExec += aLogAuto[nI] + CRLF
	    Next
	else
		cRetExec := "OK "+SC5->C5_NUM
  	Endif

  	end sequence

	ErrorBlock(oErro)
return cRetExec


//------------------------------------------------------------------------------------//
Static Function FilterErro(e)

	if e:gencode > 0
		cRetExec := "Ocorreu erro!" + CRLF
		cRetExec += e:ERRORSTACK
		BREAK
	endIf
	
Return nil
