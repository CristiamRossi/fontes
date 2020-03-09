#INCLUDE "PROTHEUS.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ บAutor  ณElvis Kinuta                 บ Data ณ  06/03/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta um arquivo texto de notas fiscais de saida.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EDI Pao de a็ucar                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EDIPAO()
Local    cPerg := "TXTNFS"
Local    cNome 
Local    cCondP     := ""
Local    cTipoP     := ""
Private  nHandle
Private  cEol  := CHR(13)+CHR(10) 

xPutSx1(cPerg,"08","Emissao de?"	 ,"","" ,"mv_ch1","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",,,)
xPutSx1(cPerg,"09","Emissao Ate?"	 ,"","" ,"mv_ch2","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",,,)

If Pergunte(cPerg,.T.)

	cNome   := "\TEMP\"+"PAO_"+DTOS(MV_PAR01)+".TXT"
	nHandle := FCreate(cNome,0)

	Processa( {|| ProcArq() },"Aguarde" ,"Processando...")

	fClose(nHandle)	
	
EndIf

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERATXTNF บAutor  ณMicrosiga           บ Data ณ  03/06/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  PROCESSAMENTO                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcArq()
Local   nContador := 0
Private cTXT 		:= ""
Private nQtdItens := 0                                                  

cQuery := "SELECT * "+cEol
cQuery += "FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("SA1")+" SA1 "+cEol
cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' ' "+cEol
cQuery += "AND F2_EMISSAO between '"+DtoS(mv_par01)+"' and '"+DtoS(mv_par02)+"' "
cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = ' ' "+cEol
cQuery += "AND A1_COD = F2_CLIENTE "+cEol
cQuery += "AND A1_LOJA = F2_LOJA "+cEol
cQuery += "AND A1_XEANPAO <> '' "+cEol
cQuery += "ORDER BY F2_DOC "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TMP", .F., .T.)


dbSelectArea("TMP")
dbEval({||nContador++})
dbGotop()

ProcRegua(nContador)

While TMP->(!Eof())
	
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
	dbSelectArea("SD2")
	While SD2->(!Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		
		nQtdItens += SD2->D2_QUANT
		Item()
		
		dbSelectArea("SD2")
		SD2->(dbSkip())
		
	EndDo
	
	//Trailler da Nota Fiscal
	FimNF()
	
	dbSelectArea("TMP")
	dbSkip()
	
EndDo
dbCloseArea()

//Trailler do Arquivo
FimArq()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERATXTNF บAutor  ณMicrosiga           บ Data ณ  03/06/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  CABEวALHO                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function CabecNF()
Local aSM0Data1 := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CODFIL" } )  
       
       //REGISTRO HEADER            
cTXT := "01"                                                                   						//tipo do registro
cTXT += "2" 	//1=cancelar, 2=incluir, 9=original																	
cTXT += TMP->F2_DOC																									
cTXT += TMP->F2_SERIE																								
cTXT += TMP->F2_EMISSAO+SubStr(Time(),1,2)+SubStr(Time(),4,2)
cTXT += Replicate(" ",12)
cTXT += Replicate(" ",12)
cTXT += PadL(AllTrim(SD2->D2_CF),04,"0")
cTXT += PadL(AllTrim(SD2->D2_PEDIDO+SubStr(A1_NREDUZ,1,4)),15,"0") 
cTXT += Replicate(" ",15)
cTXT += Replicate(" ",15)
cTXT += Replicate("0",13)	//101-113 
cTXT += "1003190900005"	//114-126
cTXT += Replicate("0",15) //????//cgc 15
cTXT += Replicate(" ",20)
cTXT += Replicate(" ",02)    
cTXT += PadL(AllTrim(TMP->A1_XEANPAO),13,"0") // 164-176     loc entrega-EAN COMPRADOR
cTXT += Replicate("0",13)//177-189 loc cobra - no arquivo modelo esta mandando zeros
cTXT += Replicate(" ",04)
cTXT += Replicate(" ",05)
cTXT += Replicate(" ",11)
cTXT += Replicate(" ",71)

//cTXT := PadR(cTXT,280," ")																								//Filler - espacos ate 200

fWrite(nHandle,cTXT+cEol)

//REGISTRO DE CONDIวีES DE PAGAMENTO           
cTXT := "02"                                                                   						//tipo do registro
cTXT += TMP->F2_DOC																									
cTXT += TMP->F2_SERIE																								
cTXT += "1  "
cTXT += "2"      //18-18
cTXT += "FS"      
If cTipoP == "1"
     cTXT += PadL(AllTrim(cCondP),03,"0")
else
     cTXT += "050"
EndIf     
cTXT += Replicate("0",08) //24-31
cTXT += Replicate(" ",03)
cTXT += "100"       
cTXT += Replicate(" ",238)

fWrite(nHandle,cTXT+cEol)
              
//REGISTRO HEADER 03
cTXT := "03"                                                                   						//tipo do registro
cTXT += TMP->F2_DOC																									
cTXT += TMP->F2_SERIE																								
cTXT += Replicate(" ",04)
cTXT += Replicate(" ",15)
cTXT += Replicate(" ",03)
cTXT += Replicate(" ",25)
cTXT += Replicate(" ",12)  
If SC5->C5_TPFRETE == "F"
	cTXT += "FOB"  //74-76
Else                      
	cTXT += "CIF"  //74-76
EndIf
cTXT += Replicate(" ",13)  
cTXT += Replicate(" ",05)  
cTXT += Replicate(" ",05)  
cTXT += Replicate(" ",181)

fWrite(nHandle,cTXT+cEol)       

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEDIPAO    บAutor  ณMicrosiga           บ Data ณ  03/06/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  ITENS                                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
cTXT += TMP->F2_DOC																									
cTXT += TMP->F2_SERIE
If Empty(SB1->B1_CODBAR)
	cTXT +=	SubStr(B1_XCODDUN,1,14)
Else
	cTXT +=	SubStr(SB1->B1_CODBAR,1,14)
EndIf	
cTXT += Replicate(" ",10)
cTXT += PadL(AllTrim(TransForm(SD2->D2_QUANT  		,"@E 9999999999")),10,"0")				//38-48  //???ELVIS TRATAR OS DECIMAIS
cTXT += PadL(AllTrim(SD2->D2_UM),03,"0")
cTXT += Replicate(" ",10)
cTXT += Replicate(" ",03)
cTXT += Replicate(" ",08)
cTXT += PadL(AllTrim(TransForm(SD2->D2_TOTAL		,"@E 99999999999")),15,"0") 			//73-87
cTXT += PadL(AllTrim(TransForm(SD2->D2_TOTAL		,"@E 99999999999")),15,"0") 
cTXT += PadL(AllTrim(TransForm(SD2->D2_PRCVEN		,"@E 99999999999")),15,"0") 
cTXT += PadL(AllTrim(TransForm(SD2->D2_PRCVEN		,"@E 99999999999")),15,"0")
cTXT += PadL(AllTrim(SF4->F4_SITTRIB),02,"0") //   129-130
cTXT += Replicate(" ",05)
cTXT += Replicate(" ",05)
cTXT += Replicate(" ",05)
cTXT += Replicate(" ",05)
cTXT += Replicate(" ",13)
cTXT += Replicate(" ",05) 
cTXT += PadL(AllTrim(TransForm(SD2->D2_BASEICM		,"@E 99999999999")),15,"0") 			//169-183
cTXT += PadL(AllTrim(TransForm(SD2->D2_VALICM		,"@E 99999999999")),15,"0") 			//		
cTXT += PadL(AllTrim(TransForm(SD2->D2_BRICMS		,"@E 99999999999")),15,"0") 		      
cTXT += PadL(AllTrim(TransForm(SD2->D2_ICMSRET		,"@E 99999999999")),15,"0") 
cTXT += PadL(AllTrim(SB1->B1_POSIPI),08,"0")
cTXT += Replicate(" ",02)
cTXT += PadL(AllTrim(SF4->F4_SITTRIB),02,"0") 
cTXT += PadL(AllTrim(SF4->F4_CTIPI),02,"0") 
cTXT += PadL(AllTrim(SF4->F4_CSTPIS),02,"0") 
cTXT += PadL(AllTrim(SF4->F4_CSTCOF),02,"0") 
cTXT += PadL(AllTrim(SF4->F4_CTIPI),02,"0") 
cTXT += PadL(AllTrim(SF4->F4_SITTRIB),02,"0") 
cTXT += Space(5)
cTXT += Space(5)
cTXT += Space(5)
cTXT += Space(19)

//cTXT := Ponto(cTXT)

fWrite(nHandle,cTXT+cEol)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFimNF     บAutor  ณStanko              บ Data ณ  13/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FimNF 			                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATURAMENTO - Especifico                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FimNF()

cTXT := "09"																			//tipo do registro    
cTXT += TMP->F2_DOC																									
cTXT += TMP->F2_SERIE         
cTXT += Space(04)
cTXT += Space(04)
cTXT += Space(15)         
cTXT += PadL(AllTrim(TMP->F2_PBRUTO),09,"0") //38-46
cTXT += Space(08)         
cTXT += PadL(AllTrim(TransForm(SF2->F2_BASEICM	,"@E 999999999.99")),12,"0") 		//base de calculo do ICMS
cTXT += PadL(AllTrim(TransForm(SF2->F2_VALICM	,"@E 999999999.99")),12,"0") 		//valor do ICMS
cTXT += Space(16)         
cTXT += Space(15)   
cTXT += PadL(AllTrim(TransForm(SF2->F2_VALMERC	,"@E 999999999.99")),15,"0") 	 	//valor total da nota 117-131      
cTXT += Space(13)         
cTXT += Space(13)         
cTXT += Space(13)
cTXT += PadL(AllTrim(TransForm(SF2->F2_BASEIPI	,"@E 999999999.99")),16,"0") 	 	//valor total do IPI
cTXT += PadL(AllTrim(TransForm(SF2->F2_VALIPI	,"@E 999999999.99")),15,"0") 	 	//valor total do IPI
cTXT += Space(15)
cTXT += PadL(AllTrim(TransForm(SF2->F2_VALBRUT	,"@E 999999999.99")),15,"0")
cTXT += Space(13)        
cTXT += Space(36)
/*
cTXT += PadL(AllTrim(TransForm(SF2->F2_BRICMS	,"@E 999999999.99")),12,"0") 		//base de calculo do ICMS de Substituicao
cTXT += PadL(AllTrim(TransForm(SF2->F2_ICMSRET	,"@E 999999999.99")),12,"0") 		//base de calculo do ICMS de Substituicao
cTXT += PadL(AllTrim(TransForm(SF2->F2_VALMERC	,"@E 999999999.99")),12,"0") 		//valor total dos produtos
cTXT += PadL(AllTrim(TransForm(SF2->F2_FRETE		,"@E 999999999.99")),12,"0") 	//valor do frete
cTXT += PadL(AllTrim(TransForm(SF2->F2_SEGURO	,"@E 999999999.99")),12,"0") 		//valor do seguro
cTXT += PadL(AllTrim(TransForm(SF2->F2_DESPESA	,"@E 999999999.99")),12,"0") 	   //valor de despesas acessorias

cTXT += PadL(AllTrim(TransForm(SF2->F2_VALBRUT	,"@E 999999999.99")),12,"0") 	 	//valor total da nota
cTXT += PadL(AllTrim(TransForm(nQtdItens			,"@E 9999999999")),10,"0") 	 	//quantidade de itens
cTXT += PadL(AllTrim(TransForm(SF2->F2_PBRUTO	,"@E 9999999.99")),10,"0") 	 		//peso bruto

cTXT := PadR(cTXT,200," ")																//Filler - espacos ate 200

cTXT := Ponto(cTXT)
*/      
fWrite(nHandle,cTXT+cEol)

Return Nil


/*                                      '
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFimArq    บAutor  ณStanko              บ Data ณ  13/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FimArq 			                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATURAMENTO - Especifico                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FimArq()
   /*
cTXT := "9"										//tipo do registro

cTXT := PadR(cTXT,200," ")						//Filler - espacos ate 200
     */
fWrite(nHandle,cTXT+cEol)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPonto     บAutor  ณStanko              บ Data ณ  13/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para trocar a virgula por ponto                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FATURAMENTO - Especifico                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Ponto(cLinha)
Local cRet := ""           

For nX := 1 To Len(cLinha)

	If Substr(cLinha,nX,1) == ","
		cRet += "."
	Else
		cRet += Substr(cLinha,nX,1)
	EndIf	 	

Next
      
Return cRet

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

// Ajusta o tamanho do grupo. Ajuste emergencial para valida็ใo dos fontes. 
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