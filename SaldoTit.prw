#include "TOTVS.CH"

/*/{Protheus.doc} SaldoTit
Extrir saldo do titulo com SOMAABAT
@type function
@author Vinicius Pereira
@since 01/06/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function SaldoTit()

Local nSaldo    := 0
Local nAbat     := 0

nSaldo  := SE1->E1_SALDO
nAbat   := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)

nSaldo  := nSaldo-nAbat
nSaldo  := STRZERO(nSaldo*100,13)

Return(nSaldo)
