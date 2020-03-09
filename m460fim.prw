#include "totvs.ch"
//-------------------------------------------------------
/*/{Protheus.doc} M460FIM
Ponto de Entrada - Gravação da NF saida

@type function
@author Cristiam Rossi
@since 02/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------
user function M460FIM()
local aArea    := getArea()
local aAreaSA1 := SA1->( getArea() )
local aAreaSE1 := SE1->( getArea() )
local aAreaSEE := SEE->( getArea() )

	if ! SF2->F2_TIPO $ "DB" .and. ! empty(SF2->F2_DUPL)	// Diferente de Devolução e Beneficiamento
		SA1->( dbSetOrder(1) )
		if SA1->( dbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ) ) .and. SA1->A1_BLEMAIL=="1"

			SEE->( dbSetOrder(1) )
			if empty(SA1->A1_BCO1) .or. ! SEE->( dbSeek(xFilial("SEE")+SA1->A1_BCO1) )
				return nil
			endif

			SE1->( dbSetOrder(1))
			SE1->( dbSeek(xFilial("SE1")+SF2->(F2_PREFIXO+F2_DUPL)))
			while ! SE1->(eof()) .and. xFilial("SF2")+SF2->(F2_PREFIXO+F2_DUPL) == SE1->(E1_FILIAL+E1_SERIE+E1_NUM)

				RecLock("SEE",.F.)
				cFxAtu := strZero( val(alltrim(SEE->EE_FAXATU))+1 , 6)
				SEE->EE_FAXATU := cFxAtu
				msUnlock()

				RecLock("SE1",.F.)
				SE1->E1_PORTADO := SEE->EE_CODIGO
				SE1->E1_AGEDEP  := SEE->EE_AGENCIA
				SE1->E1_CONTA   := SEE->EE_CONTA
				SE1->E1_NUMBCO  := cFxAtu
				MsUnLock()
				SE1->( DbSkip() )
			enddo
		endif
	endif

// controle de embalagens
	if ! SF2->F2_TIPO $ "DB" .and. ! empty(SF2->F2_TRANSP)	// Diferente de Devolução e Beneficiamento
		fCtrEmb()	// controle de embalagens
	endif

	SEE->( restArea( aAreaSEE ) )
	SE1->( restArea( aAreaSE1 ) )
	SA1->( restArea( aAreaSA1 ) )
	restArea( aArea )
return nil


//-------------------------------------
static function fCtrEmb()
local aArea     := getArea()
local cQuery
local cAliasQry := getNextAlias()
local aEmbal    := {}
local nI

	cQuery := "select B1_XEMB, D2_QUANT, B1_XQE "
	cQuery += " from "+retSqlName("SD2")+" SD2 "
	cQuery += " join "+retSqlName("SB1")+" SB1 on B1_FILIAL='"+xFilial("SB1")+"' and B1_COD=D2_COD and SB1.D_E_L_E_T_=' '"
	cQuery += " join "+retSqlName("SZE")+" SZE on ZE_FILIAL='"+xFilial("SZE")+"' and ZE_CODIGO=B1_XEMB and SZE.D_E_L_E_T_=' '"
	cQuery += " where D2_FILIAL='"+SF2->F2_FILIAL+"'"
	cQuery += " and D2_DOC='"+SF2->F2_DOC+"'"
	cQuery += " and D2_SERIE='"+SF2->F2_SERIE+"'"
	cQuery += " and B1_XEMB <> ' '"
	cQuery += " and B1_XQE > 0"
	cQuery += " and ZE_MSBLQL <> '1'"
	cQuery += " and SD2.D_E_L_E_T_=' '"
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	while ! (cAliasQry)->( eof() )

		if (nPos := aScan( aEmbal, {|it| it[1] == (cAliasQry)->B1_XEMB} ) ) == 0
			aAdd( aEmbal, { (cAliasQry)->B1_XEMB, 0 } )
			nPos := len( aEmbal )
		endif

		aEmbal[nPos,2] += int( (cAliasQry)->( D2_QUANT / B1_XQE ) )

		(cAliasQry)->( dbSkip() )
	end
	(cAliasQry)->( dbCloseArea() )

	for nI := 1 to len( aEmbal )	// temos embalagens retornáveis
		recLock("SZC", .T.)
		SZC->ZC_FILIAL	:= xFilial("SZC")
		SZC->ZC_DATFAT	:= SF2->F2_EMISSAO
		SZC->ZC_DOC		:= SF2->F2_DOC
		SZC->ZC_SERIE	:= SF2->F2_SERIE
		SZC->ZC_TRANSP	:= SF2->F2_TRANSP
		SZC->ZC_NTRANSP	:= posicione("SA4", 1, xFilial("SA4") + SF2->F2_TRANSP, "A4_NOME" )
		SZC->ZC_MODELO	:= aEmbal[nI,1]
		SZC->ZC_QTDE	:= aEmbal[nI,2]
		SZC->ZC_FIL		:= cFilAnt
		SZC->ZC_NFIL	:= fwFilialName( cEmpAnt, cFilAnt, 1 )
		msUnlock()
	next

	restArea( aArea )
return nil
