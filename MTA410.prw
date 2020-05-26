#Include "Protheus.ch"

// Ponto de entrada para gravar o valor total do pedido de venda no SC5

User Function MTA410()   
Local aArea  := GetArea()
Local aAreaF1 := SF1->(GetArea())      
Local nTotal := 0
Local nValor := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_VALOR"}) //busca a posição do campo C6_VALOR
Local nI     := 0
Local nNfOri := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_NFORI"})
Local nSerOr := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_SERIORI"})
Local lNfOri := .F.   
Local cNfOri := "" 
Local cSerOr := ""  


//peccore os itens de venda para somar o valor
For nI:=1 To Len(aCols)
     If nI == 1
          If ! Empty(aCols[1][nNfOri])
               lNfOri    := .T.
               cNfOri    := aCols[1][nNfOri]
               cSerOr    := aCols[1][nSerOr]
          EndIf     
     EndIf
     //verifica se a linha não esta deletada
     If !aCols[nI][Len(aHeader)+1]
          nTotal := nTotal + aCols[nI][nValor]     
     EndIf
Next nI

//Grava na memória do campo o total
M->C5_XTOTAL := nTotal

//NUMERO DA NF FISCAL DO PRODUTOR RURAL
If SubStr(cFilAnt,1,2) $ SuperGetMV("MV_XNFPROD",,"02")
     If M->C5_TIPO == "D" .and. lNfOri
          DbSelectArea("SF1")
          //SF1->(dbOrderNickname("NFPRODR"))
          DbSetOrder(1)  //FILIAL+DOC+SERIE+FORNECE+LOJA
          If SF1->(DbSeek(xFilial("SF1")+cNfOri+cSerOr+M->C5_CLIENTE+M->C5_LOJACLI))
               M->C5_XNFPROD	:= SF1->F1_XNFPROD
          EndIf
     EndIf	
EndIf
RestArea(aArea)
RestArea(aAreaF1)
Return .T.