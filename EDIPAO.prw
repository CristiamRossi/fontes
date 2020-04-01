#INCLUDE "PROTHEUS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ºAutor  ³Elvis Kinuta                 º Data ³  06/03/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exporta um arquivo texto de notas fiscais de saida.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EDI Pao de açucar                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EDIPAO()
Local    aArea   := getArea()
Local    cPerg   := "TXTNFS"
Local    cNome 
local    lRet    := .F.
Private  nHandle
Private  cEol    := CHR(13)+CHR(10) 
Private  cTitulo := "EDI NF Saída - Pão de Açúcar"

xPutSx1(cPerg,"08","Emissao de?"	 ,"","" ,"mv_ch1","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",,,)
xPutSx1(cPerg,"09","Emissao Ate?"	 ,"","" ,"mv_ch2","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",,,)

If Pergunte(cPerg,.T.)
     makeDir("\TEMP")
	cNome   := "\TEMP\"+"PAO_"+DTOS(MV_PAR01)+".TXT"
	if ( nHandle := FCreate(cNome,0) ) == -1
          msgAlert( "Falha na criação do arquivo: "+cNome, cTitulo )
          return 
     endif

	Processa( {|| lRet := ProcArq() },"Aguarde" ,"Processando... "+cTitulo)

	fClose(nHandle)

     if lRet
          makeDir("C:\TEMP")
          __CopyFile( cNome, "C:"+cNome )
          msgInfo("Processamento finalizado. Arquivo gerado:"+CRLF+"C:"+cNome, cTitulo)
     endif
EndIf

restArea( aArea )
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERATXTNF ºAutor  ³Microsiga           º Data ³  03/06/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  PROCESSAMENTO                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ProcArq()
Local   nContador := 0
Private cTXT 		:= ""
Private nQtdItens := 0                                                  

SA1->( dbSetOrder(3) )
if ! SA1->( dbSeek( xFilial("SA1") + SM0->M0_CGC) )
     msgAlert( "Não encontrado cliente (SA1) com o CNPJ: "+SM0->M0_CGC, cTitulo)
     return .F.
endif

if empty( SA1->A1_XEANPAO )
     msgAlert( "Não cadastrado o EAN Pão do cliente "+ SA1->A1_COD, cTitulo)
     return .F.
endif

if empty( SA1->A1_BCO1 )
     msgAlert( "Não cadastrado o banco no cliente "+ SA1->A1_COD, cTitulo)
     return .F.
endif

SA6->( dbSetOrder(1) )
if ! SA6->( dbSeek( xFilial("SA6") + SA1->A1_BCO1 ) )
     msgAlert( "Não encontrado o banco (SA6) código: "+SA1->A1_BCO1, cTitulo)
     return .F.
endif

if select("TMP") > 0
     TMP->( dbCloseArea() )
endif

cQuery := "SELECT SF2.R_E_C_N_O_ F2REC, A1_NREDUZ, A1_XEANPAO "+cEol
cQuery += "FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("SA1")+" SA1 "+cEol
cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' ' "+cEol
cQuery += "AND F2_EMISSAO between '"+DtoS(mv_par01)+"' and '"+DtoS(mv_par02)+"' "
cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = ' ' "+cEol
cQuery += "AND A1_COD = F2_CLIENTE "+cEol
cQuery += "AND A1_LOJA = F2_LOJA "+cEol
cQuery += "AND A1_XEANPAO <> '' "+cEol
cQuery += "ORDER BY F2_EMISSAO, F2_DOC "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)

dbSelectArea("TMP")
dbEval({||nContador++})
dbGotop()

ProcRegua(nContador)

While TMP->(!Eof())

     SF2->( dbGoto( TMP->F2REC ) )

     incProc("Data: "+DtoC(SF2->F2_EMISSAO)+"  - Documento: "+SF2->F2_DOC)

    //posiciona nos itens da nota fiscal
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))

   //posiciona no pedido da da nota
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(SD2->(D2_FILIAL+D2_PEDIDO)))

     dbSelectArea("SE4")
	SE4->(dbSetOrder(1)	)
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
          cCondP := SubStr(SE4->E4_COND,1,2)
          cTipoP := SE4->E4_TIPO
     EndIf                            
    //seta o cabecalho
	CabecNF()

	//Itens da Nota Fiscal
	nQtdItens := 0
	While SD2->(!Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

		nQtdItens += SD2->D2_QUANT
		Item()

		SD2->(dbSkip())
	EndDo
	
	//Trailler da Nota Fiscal
	FimNF()

	TMP->( dbSkip() )
EndDo
TMP->( dbCloseArea() )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERATXTNF ºAutor  ³Microsiga           º Data ³  03/06/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  CABEÇALHO                                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function CabecNF()
//Local aSM0Data1 := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CODFIL" } )  

       //REGISTRO HEADER            
cTXT := "01"            						//tipo do registro
cTXT += "2" 	//1=cancelar, 2=incluir, 9=original																	
cTXT += SF2->F2_DOC																									
cTXT += SF2->F2_SERIE																								
cTXT += DtoS(SF2->F2_EMISSAO)+strTran( SF2->F2_HORA, ":", "")
cTXT += Replicate("0",12)
cTXT += Replicate("0",12)
cTXT += PadL(AllTrim(SD2->D2_CF),04,"0")
//cTXT += PadL(AllTrim(SD2->D2_PEDIDO+SubStr(TMP->A1_NREDUZ,1,4)),15,"0") 
cTXT += PadL(AllTrim(SC5->C5_XPEDCLI),15,"0")
cTXT += Replicate("0",15)          // pedido 2
cTXT += Replicate("0",15)          // pedido 3
cTXT += PadL("7895000000001",13,"0") // 101-113     EAN COMPRADOR      <- Cristiam 27/03/2020

//cTXT += "1003190900005"	//114-126      // EAN VENDEDOR
cTXT += PadL(AllTrim(SA1->A1_XEANPAO),13,"0") // 114-126     EAN da empresa logada
cTXT += PadL(AllTrim(SM0->M0_CGC)   ,15,"0") // 127-141     CNPJ EMISSOR      <- Cristiam 23/02/2020
cTXT += PadL(AllTrim(SM0->M0_INSC)  ,20,"0") // 142-161     IE. EMISSOR      <- Cristiam 23/02/2020
cTXT += PadL(AllTrim(SM0->M0_ESTCOB),02,"0") // 162-163     UF. EMISSOR      <- Cristiam 23/02/2020
cTXT += PadL(AllTrim(TMP->A1_XEANPAO),13,"0") // 164-176     loc entrega-EAN COMPRADOR
cTXT += PadL("7895000088232",13,"0") // 177-189     loc COBRANÇA-EAN COMPRADOR      <- Cristiam 27/03/2020

cTXT += padL(alltrim(SA6->A6_NUMBCO) ,04,"0")     // 190-193 BANCO
cTXT += padL(alltrim(SA6->A6_AGENCIA),05,"0")     // 194-198 AGENCIA
cTXT += padL(alltrim(SA6->A6_NUMCON) ,11,"0")     // 199-209 CONTA
cTXT += Replicate(" ",71)     // 210-280 FILLER
fWrite(nHandle,cTXT+cEol)

//REGISTRO DE CONDIÇÕES DE PAGAMENTO           
cTXT := "02"                                                                   						//tipo do registro
cTXT += SF2->F2_DOC																									
cTXT += SF2->F2_SERIE																								
cTXT += "1  "
cTXT += "2"      //18-18
cTXT += "FS"      
If cTipoP == "1"
     cTXT += PadL(AllTrim(cCondP),03,"0")
else
     cTXT += "050"
EndIf     
cTXT += Replicate("0",08)     // 24-31 Vencimento
cTXT += Replicate("0",06)     // 32-37 Desconto Financeiro
cTXT += "100"+"00"            // 38-42 Percentual a pagar
cTXT += Replicate(" ",238)    // 43-280 FILLER
fWrite(nHandle,cTXT+cEol)
              
//REGISTRO HEADER 03
cTXT := "03"                                                                   						//tipo do registro
cTXT += SF2->F2_DOC																									
cTXT += SF2->F2_SERIE																								
cTXT += Replicate(" ",04)
cTXT += Replicate("0",15)
cTXT += Replicate(" ",03)
cTXT += Replicate(" ",25)
cTXT += Replicate(" ",12)  
If SC5->C5_TPFRETE == "F"
	cTXT += "FOB"  //74-76
Else                      
	cTXT += "CIF"  //74-76
EndIf
cTXT += Replicate("0",13)  
cTXT += Replicate("0",05)  
cTXT += Replicate("0",05)  
cTXT += Replicate(" ",181)

fWrite(nHandle,cTXT+cEol)       

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EDIPAO    ºAutor  ³Microsiga           º Data ³  03/06/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  ITENS                                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Item()
    
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))     

dbSelectArea("SF4")
SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
             
//REGISTRO DETALHES
cTXT := "04"
cTXT += SF2->F2_DOC
cTXT += SF2->F2_SERIE
If Empty(SB1->B1_CODBAR)
	cTXT +=	PadL(AllTrim(SB1->B1_XCODDUN),14,"0")
Else
	cTXT +=	PadL(AllTrim(SB1->B1_CODBAR) ,14,"0")
EndIf
cTXT += Replicate("0",10)

cTXT += strTran(strZero(SD2->D2_QUANT,11,3),".","")	// 39-48
cTXT += PadR(AllTrim(SD2->D2_UM),03," ")                         // 49-51
cTXT += strTran(strZero(SD2->D2_QUANT,11,3),".","")	// 52-61
cTXT += PadR(AllTrim(SD2->D2_UM),03," ")                         // 62-64
cTXT += Replicate("0",08)
cTXT += strTran(strZero(SD2->D2_TOTAL,16,2),".","") 		// 73-87
cTXT += strTran(strZero(SD2->D2_TOTAL,16,2),".","")
cTXT += strTran(strZero(SD2->D2_PRCVEN,14,2),".","")
cTXT += strTran(strZero(SD2->D2_PRCVEN,14,2),".","")
cTXT += PadL(AllTrim(SF4->F4_SITTRIB),02,"0") //   129-130
cTXT += Replicate("0",05)
cTXT += Replicate("0",05)
cTXT += Replicate("0",05)
cTXT += Replicate("0",05)
cTXT += Replicate("0",13)
cTXT += Replicate("0",05) 
cTXT += strTran(strZero(SD2->D2_BASEICM,16,2),".","")       		//169-183
cTXT += strTran(strZero(SD2->D2_VALICM,16,2),".","")
cTXT += strTran(strZero(SD2->D2_BRICMS,16,2),".","")
cTXT += strTran(strZero(SD2->D2_ICMSRET,16,2),".","")
cTXT += PadL(AllTrim(SB1->B1_POSIPI),08,"0")
cTXT += Replicate("0",02)
cTXT += PadL(AllTrim(SF4->F4_CSTPIS) ,02,"0") 
cTXT += PadL(AllTrim(SF4->F4_CSTCOF) ,02,"0") 
cTXT += PadL(AllTrim(SF4->F4_CTIPI)  ,02,"0") 
cTXT += PadL(AllTrim(SF4->F4_SITTRIB),02,"0") 
cTXT += Replicate("0",5)
cTXT += Replicate("0",5)
cTXT += Replicate("0",5)
cTXT += Space(19)

fWrite(nHandle,cTXT+cEol)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FimNF     ºAutor  ³Stanko              º Data ³  13/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FimNF 			                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FATURAMENTO - Especifico                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FimNF()

cTXT := "09"																			//tipo do registro    
cTXT += SF2->F2_DOC																									
cTXT += SF2->F2_SERIE         
cTXT += padL(cValToChar(nQtdItens),4,"0")
cTXT += replicate("0",4)
cTXT += replicate("0",15)
cTXT += strTran(strZero(SF2->F2_PBRUTO,10,3) ,".","") // 38-46 Peso Bruto
cTXT += strTran(strZero(SF2->F2_PLIQUI,9,3)  ,".","") // 47-54 Peso Liquido
cTXT += strTran(strZero(SF2->F2_BASEICM,17,2),".","") 		//base de calculo do ICMS
cTXT += strTran(strZero(SF2->F2_VALICM ,16,2),".","") 		//valor do ICMS
cTXT += strTran(strZero(SF2->F2_BRICMS ,17,2),".","")
cTXT += strTran(strZero(SF2->F2_ICMSRET,16,2),".","")
cTXT += strTran(strZero(SF2->F2_VALMERC,16,2),".","")  //valor total da nota 117-131
cTXT += replicate("0", 13)
cTXT += replicate("0", 13)
cTXT += replicate("0", 13)
cTXT += strTran(strZero(SF2->F2_BASEIPI,17,2),".","") 	 	//valor base do IPI
cTXT += strTran(strZero(SF2->F2_VALIPI ,16,2),".","") 	 	//valor total do IPI
cTXT += replicate("0", 15)
cTXT += strTran(strZero(SF2->F2_VALBRUT,16,2),".","")
cTXT += replicate("0", 13)
cTXT += Space(36)
fWrite(nHandle,cTXT+cEol)

Return Nil


Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     Reclock( "SX1" , .T. ) 

     Replace X1_GRUPO   With cGrupo 
     Replace X1_ORDEM   With cOrdem 
     Replace X1_PERGUNT With cPergunt 
     Replace X1_PERSPA With cPerSpa 
     Replace X1_PERENG With cPerEng 
     Replace X1_VARIAVL With cVar 
     Replace X1_TIPO    With cTipo 
     Replace X1_TAMANHO With nTamanho 
     Replace X1_DECIMAL With nDecimal 
     Replace X1_PRESEL With nPresel 
     Replace X1_GSC     With cGSC 
     Replace X1_VALID   With cValid 

     Replace X1_VAR01   With cVar01 

     Replace X1_F3      With cF3 
     Replace X1_GRPSXG With cGrpSxg 

     If Fieldpos("X1_PYME") > 0 
          If cPyme != Nil 
               Replace X1_PYME With cPyme 
          Endif 
     Endif 

     Replace X1_CNT01   With cCnt01 
     If cGSC == "C"               // Mult Escolha 
          Replace X1_DEF01   With cDef01 
          Replace X1_DEFSPA1 With cDefSpa1 
          Replace X1_DEFENG1 With cDefEng1 

          Replace X1_DEF02   With cDef02 
          Replace X1_DEFSPA2 With cDefSpa2 
          Replace X1_DEFENG2 With cDefEng2 

          Replace X1_DEF03   With cDef03 
          Replace X1_DEFSPA3 With cDefSpa3 
          Replace X1_DEFENG3 With cDefEng3 

          Replace X1_DEF04   With cDef04 
          Replace X1_DEFSPA4 With cDefSpa4 
          Replace X1_DEFENG4 With cDefEng4 

          Replace X1_DEF05   With cDef05 
          Replace X1_DEFSPA5 With cDefSpa5 
          Replace X1_DEFENG5 With cDefEng5 
     Endif 

     Replace X1_HELP With cHelp 

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 
Else 

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

   If lPort .Or. lSpa .Or. lIngl 
          RecLock("SX1",.F.) 
          If lPort 
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
          EndIf 
          If lSpa 
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
          EndIf 
          If lIngl 
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
          EndIf 
          SX1->(MsUnLock()) 
     EndIf 
Endif 

RestArea( aArea ) 

Return