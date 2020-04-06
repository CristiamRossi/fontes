#Include "Protheus.ch"

// Ponto de entrada para gravar o valor total do pedido de venda no SC5

User Function MTA410()       
Local nTotal := 0
Local nValor := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_VALOR"}) //busca a posição do campo C6_VALOR
Local nI     := 0

//peccore os itens de venda para somar o valor
For nI:=1 To Len(aCols)
     //verifica se a linha não esta deletada
     If !aCols[nI][Len(aHeader)+1]
          nTotal := nTotal + aCols[nI][nValor]     
     EndIf
Next nI

//Grava na memória do campo o total
M->C5_XTOTAL := nTotal

Return .T.