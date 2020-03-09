#include "totvs.ch"
/*/{Protheus.doc} M410LIOK
Ponto de Entrada - Linha OK - Pedido de Vendas
@type function
@author Cristiam Rossi
@since 08/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function M410LIOK()
local aArea			:= getArea()
local lOk			:= .T.

	u_PVxPESO()		// atualiza Peso Bruto e Líquido

	restArea( aArea )
return lOk
