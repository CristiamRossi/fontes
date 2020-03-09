#include "totvs.ch"
//-------------------------------------------------------
/*/{Protheus.doc} PVxFUN
Dummy - Coletânea de users function p/ suporte ao pedido de vendas

@type function
@author Cristiam Rossi
@since 08/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------
user function PVxFUN()
return .T.


//-------------------------------------------------------
/*/{Protheus.doc} PVxPESO
Rotina - alimenta Peso Bruto e Líquido no cabeçalho do Pedido de Vendas
         conforme peso cadastrado na SB1 * Quantidade Vendida

@type function
@author Cristiam Rossi
@since 08/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------
user function PVxPESO()
local aArea			:= getArea()
local aAreaSB1		:= SB1->( getArea() )
local lOK			:= .T.
local cProd
local nQtd
local nPesBru		:= 0
local nPesLiq		:= 0
local nI

	SB1->( dbSetOrder(1) )

	for nI := 1 to len( aCols )
		if ! gdDeleted( nI )
			cProd := gdFieldGet("C6_PRODUTO", nI)
			nQtd  := gdFieldGet("C6_QTDVEN" , nI)

			if ! empty( cProd ) .and. nQtd > 0
				if SB1->( dbSeek( xFilial("SB1") + cProd ) )
					nPesBru += nQtd * SB1->B1_PESBRU
					nPesLiq += nQtd * SB1->B1_PESO
				endif
			endif
		endif
	next

	M->C5_PBRUTO := nPesBru
	M->C5_PESOL  := nPesLiq

	SB1->( restArea( aAreaSB1 ) )
	restArea( aArea )
return lOk
