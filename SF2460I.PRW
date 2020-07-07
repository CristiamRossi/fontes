#include "protheus.ch"
#include "TOPCONN.ch"

//Ponto de Entrada final do doc de saida
//Cria titulos tipo DM-

User Function SF2460I()
Local aArea  := GetArea()
Local aAreaE2 := SE2->(GetArea()) 
Local 	nValTit   := 0
Private nValDes   := 0

If GetAdvFVal("SF4","F4_DUPLIC",xFilial("SF4")+SD2->D2_TES,1,"Errox") == "N" //Regra para TES s/ Financeiro - VP 30/04/2020
	RETURN()
ENDIF

If !SF2->F2_TIPO $ "DB"
	nValTit	:= SF2->F2_VALBRUT
	If Empty(SA1->A1_XDESC) .or. SA1->A1_XDESC == 0
		DbSelectArea("ACY")
		ACY->(DbSetOrder(1))
		If ACY->(DbSeek(xFilial("ACY")+SA1->A1_GRPVEN))
			nValDes := (nValTit*ACY->ACY_XDESM)/100
		EndIf
	Else 
		nValDes := (nValTit*SA1->A1_XDESC)/100
	EndIf	
	If nValDes > 0
		FGERAE1()
	EndIf	
EndIf

//NF PRODUTOR RURAL
If SC5->C5_TIPO == "D"
	RecLock("SF2",.F.)
	SF2->F2_XNFPROD := SC5->C5_XNFPROD
	SF2->(MsUnlock())

	DbSelectArea("SE2")
	SE2->(DbSetOrder(6)) //FILIAL+FORNECE+LOJA+PREFIXO+NUM
	If DbSeek(xFilial("SE2")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC)
	
		While SE2->(!Eof()) .and. SE2->E2_NUM == SF2->F2_DOC .and. SE2->E2_PREFIXO == SF2->F2_SERIE
			If RecLock("SE2",.F.)
				SE2->E2_XNFPROD := SC5->C5_XNFPROD
				MsUnlock()
			Endif
			SE2->(DbSkip())
			
		Enddo
	EndIf	
EndIf

RestArea(aArea)
RestArea(aAreaE2)
Return()


Static Function FGERAE1()
Local aVetSE1 := {}
lMsErroAuto := .F.
//tratar baixa parcial, tem que criar com a chave prefixo+num diferente
//confirmar as datas de emis e vecto

aAdd(aVetSE1, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})     // testar
aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,       Nil})
aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  	Nil})
If Empty(SE1->E1_PARCELA)
	aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA,  	Nil})
else
	aAdd(aVetSE1, {"E1_PARCELA", "A ",  	Nil})
EndIf		
aAdd(aVetSE1, {"E1_TIPO",    "DM-",             Nil})
aAdd(aVetSE1, {"E1_NATUREZ", "310101009"    ,   Nil})
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

MSExecAuto({|x,y| FINA040(x,y)},aVetSE1,3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

//Se houve erro, mostra o erro ao usuário e desarma a transação
If lMsErroAuto
	MostraErro()
	DisarmTransaction()
EndIf
//Finaliza a transação
End Transaction
Return()
