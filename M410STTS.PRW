#include "totvs.ch"
/*
{Protheus.doc} M410STTS
Ponto de Entrada - Final da gravação do Pedido de Vendas
Cristiam Rossi em 13/12/2019
*/
user function M410STTS()
local aArea    := getArea()
local aAreaSC6 := SC6->( getArea() )

	if INCLUI .or. ALTERA
		SC6->( dbSetOrder(1) )
		SC6->( dbSeek(xFilial("SC6")+SC5->C5_NUM, .T.) )

		while ! SC6->( EOF() ) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM

			if SC6->C6_XQTDORI == 0
				recLock("SC6", .F.)
				SC6->C6_XQTDORI := SC6->C6_QTDVEN
				msUnlock()
			endif

			SC6->( dbSkip() )
		end
	endif

	SC6->( restArea( aAreaSC6 ) )
	restArea( aArea )
return nil
