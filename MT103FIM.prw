#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*  criar *******-- SE1->(dbOrderNickname("INDE1X001"))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA+E1_TIPO
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MT103FIM  ∫Autor  ≥Elvis Kinuta    ∫ Data ≥  20/05/2020     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥   PE final do Doc de Entrada                               ∫±±
±±∫          ≥   Deleta Desconto do SE1                                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function MT103FIM()
Local aArea		:= GetArea()
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local nConfirma	:= PARAMIXB[2]   // Se o usuario confirmou a operaÁ„o de gravaÁ„o da NFE
Local nValTot	:= SF1->F1_VALBRUT
Local cNum		:= SF1->F1_DOC
Local cSerie	:= SF1->F1_SERIE
Local cFornece	:= SF1->F1_FORNECE
Local cLoja		:= SF1->F1_LOJA
Private cNfOrig	:= ""
Private cSerOrig	:= ""
Private nValDes   := 0


If nConfirma == 1    // Se confirmou
	
	If SF1->F1_TIPO == "D"
		DbSelectArea("ACY")
		ACY->(DbSetOrder(1))
		
		
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(DbSeek(xFilial("SD1")+cNum+cSerie+cFornece+cLoja))
		
		DbSelectArea("SE1")
		SE1->(dbOrderNickname("INDE1X001"))	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA+E1_TIPO
		
		While SD1->(!EOF()) .AND. xFilial("SD1")+cNum+cSerie+cFornece+cLoja == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			
			cNfOrig		:= SD1->D1_NFORI
			cSerOrig	:= SD1->D1_SERIORI
			
			
			If Empty(SA1->A1_XDESC) .or. SA1->A1_XDESC == 0
				If ACY->(DbSeek(xFilial("ACY")+SA1->A1_GRPVEN))
					nValDes := (SD1->D1_TOTAL*ACY->ACY_XDESM)/100
				EndIf
			Else
				nValDes := (SD1->D1_TOTAL*SA1->A1_XDESC)/100
			EndIf
						
			If SE1->(DbSeek(xFilial("SE1")+cSerOrig+cNfOrig+cFornece+cLoja+"DM-"))
				
				If  nValDes == SE1->E1_VALOR	//VALOR TOTAL
					
					FGERAE1(5) // EXCLUI
				Else
					FGERAE1(4) // Altera
				EndIf
			EndIf
			SD1->(DbSkip())
			
		EndDo
	EndIf
EndIf
RestArea(aArea)
RestArea(aAreaSD1)
RestArea(aAreaSE1)
Return

Static Function FGERAE1(nOpc)
Local aVetSE1 := {}
lMsErroAuto := .F.

aAdd(aVetSE1, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
aAdd(aVetSE1, {"E1_NUM",     cNfOrig,       Nil})
aAdd(aVetSE1, {"E1_PREFIXO", cSerOrig,  	Nil})
aAdd(aVetSE1, {"E1_TIPO",    "DM-",             Nil})
aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,   Nil})
aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,   Nil})
aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,      Nil})
aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,    Nil})
aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,   Nil})
aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,    Nil})
aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA,   Nil})
aAdd(aVetSE1, {"E1_VALOR",   nValDes  ,		    Nil})
aAdd(aVetSE1, {"E1_HIST",    "Titulo Desconto", Nil})
aAdd(aVetSE1, {"E1_MOEDA",   1,                 Nil})
aAdd(aVetSE1, {"E1_BASEIRF", 0,                 Nil})
aAdd(aVetSE1, {"E1_IRRF", 0,                 Nil})

Begin Transaction

MSExecAuto({|x,y| FINA040(x,y)},aVetSE1,nOpc)  // 3 - Inclusao, 4 - Altera√ß√£o, 5 - Exclus√£o

If lMsErroAuto
	MostraErro()
	DisarmTransaction()
EndIf

End Transaction
Return()
