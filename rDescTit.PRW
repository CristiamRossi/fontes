#include "totvs.ch"
/*/{Protheus.doc} rDescTit
rotina - função que retorna o desconto do título posicionado
@type function
@author Cristiam Rossi
@since 05/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function rDescTit()
local nValor := 0
	nValor := SE1->E1_VALOR * SE1->E1_DESCFIN / 100
	nValor += SE1->E1_DECRESC
return nValor
