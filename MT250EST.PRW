#include "totvs.ch"
/*/{Protheus.doc} MT250EST
P.E. - Ponto de Entrada antes do estorno do apontamento da produção
@type function
@author Cristiam Rossi
@since 04/02/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function MT250EST
local aArea    := getArea()
local aAreaSC2 := SC2->( getArea() )
local nPerda   := 0
local nQtdOrig := 0
local cNumOP   := ""

	if SC2->C2_PERDA > 0
		nPerda := SC2->C2_PERDA
		cNumOP := SC2->( C2_FILIAL + C2_NUM + C2_ITEM )
		SC2->( dbSetOrder(1) )
		while ! SC2->( eof() ) .and. cNumOP == SC2->( C2_FILIAL + C2_NUM + C2_ITEM )
			if SC2->C2_QUJE == 0 .and. SC2->C2_PERDA == 0
				nQtdOrig      := SC2->C2_QUANT
				recLock("SC2", .F.)
				SC2->C2_QUANT += nPerda
				msUnlock()

				nAjustEmp( nQtdOrig, nPerda )
			endif
			SC2->( dbSkip() )
		end
	endif

	SC2->( restArea( aAreaSC2 ) )
	restArea( aArea )


	restArea( aArea )
return .T.


//----------------------------------------------------------------------
static function nAjustEmp( nQtdOrig, nPerda )
local   aArea       := getArea()
local   aAreaSD4    := SD4->( getArea() )
local   aVetor      := {}
local   aEmpen      := {}
local   cNumOP      := SC2->( C2_NUM + C2_ITEM + C2_SEQUEN )
private lMsErroAuto := .F.

	SD4->( dbSetOrder(2) )
	SD4->( dbSeek( xFilial("SD4") + cNumOP ) )
	while ! SD4->( eof() ) .and. xFilial("SD4") + cNumOP == SD4->( D4_FILIAL + trim(D4_OP) )

		if SD4->D4_QTDEORI == nQtdOrig

			aVetor := {	{"D4_COD"     ,SD4->D4_COD      ,Nil},;
						{"D4_LOCAL"   ,SD4->D4_LOCAL    ,Nil},;
						{"D4_OP"      ,SD4->D4_OP       ,Nil},;
						{"D4_DATA"    ,SD4->D4_DATA     ,Nil},;
						{"D4_QTDEORI" ,SD4->D4_QTDEORI  ,Nil},;
						{"D4_QUANT"   ,SD4->D4_QUANT    ,Nil},;
						{"D4_TRT"     ,SD4->D4_TRT      ,Nil},;
						{"D4_QTSEGUM" ,SD4->D4_QTSEGUM ,Nil} }

			aEmpen := {	{ SD4->D4_QTDEORI+nPerda,;	// SD4->D4_QUANT
						""                      ,;	// DC_LOCALIZ
						""                      ,;	// DC_NUMSERI
						ConvUM(SD4->D4_COD, SD4->D4_QUANT+nPerda, 0, 2),;  // D4_QTSEGUM
						.F.} }

			MSExecAuto({|x,y,z| mata380(x,y)},aVetor,4,aEmpen) 

			if lMsErroAuto
				Alert("Erro")
				MostraErro()
			endif

		endif

		SD4->( dbSkip() )
	end	

	SD4->( restArea( aAreaSD4 ) )
	restArea( aArea )
return nil
