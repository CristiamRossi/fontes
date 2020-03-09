#include "totvs.ch"
/*/{Protheus.doc} SF2520E
P.E. exclusão documento de saída - exclui embalagens retornáveis
@author Cristiam Rossi
@since 24/01/2020
@version 1.0
@param none
@type function
/*/
user function SF2520E
local aArea := getArea()

	SZC->( dbSetOrder(2) )
	SZC->( dbSeek( xFilial("SZC") + SF2->( F2_TRANSP + F2_DOC + F2_SERIE ), .T. ) )
	while ! SZC->( eof() ) .and. xFilial("SZC") + SF2->( F2_TRANSP + F2_DOC + F2_SERIE ) == SZC->( ZC_FILIAL + ZC_TRANSP + ZC_DOC + ZC_SERIE )
		recLock("SZC", .F.)
		SZC->( dbDelete() )
		msUnlock()
		SZC->( dbSkip() )
	end

	restArea( aArea )
return nil
