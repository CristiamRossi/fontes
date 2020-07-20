#include "TOTVS.CH"

/*/{Protheus.doc} PesqChvNf
Extrair Chave da NFe para o CNAB do FIDIC
@type function
@author Vinicius Pereira
@since 25/06/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function PesqChvNf()

Local cChvNfe   := ""

cChvNfe     := Posicione("SF2",1,xFilial("SE1")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA,"F2_CHVNFE")
cChvNfe     := AllTrim(cChvNfe)

Return(cChvNfe)