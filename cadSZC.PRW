#include "totvs.ch"
/*/{Protheus.doc} cadSZC
Controle de Embalagens Retornáveis por Transportadora
@type function
@author Cristiam Rossi
@since 08/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function cadSZC
local   aArea     := getArea()
private aRotina   := menuDef()
private cCadastro := "Controle de Embalagem Retornável"
private bRetNF    := {|| fRetNF()}
private bRetQq    := {|| fRetQq()}

	dbSelectArea("SZC")
	mBrowse(,,,,"SZC")
	restArea( aArea )
return nil


//----------------------------------
static function menuDef()
local aRotina := {}
	aAdd( aRotina, {"Pesquisar"   ,"AxPesqui"      ,0,1} )
	aAdd( aRotina, {"Visualizar"  ,"AxVisual"      ,0,2} )
	aAdd( aRotina, {"Incluir"     ,"AxInclui"      ,0,3} )
	aAdd( aRotina, {"Alterar"     ,"AxAltera"      ,0,4} )
	aAdd( aRotina, {"Excluir"     ,"AxDeleta"      ,0,5} )
	aadd( aRotina, {"Retorno NF"  ,"eval(bRetNF)"  ,0,6} )
	aadd( aRotina, {"Retorno Qq"  ,"eval(bRetQQ)"  ,0,6} )
return aRotina


//---------------------------------
static function fRetNF()
	if msgYesNo( "Deseja retornar Embalagem: "+alltrim(SZC->ZC_MODELO)+" qtd: "+ cValToChar(SZC->( ZC_QTDE - ZC_QTDR ))+" do registro posicionado?", cCadastro )
		recLock("SZC", .F.)
		SZC->ZC_QTDR := SZC->ZC_QTDE
		SZC->( dbDelete() )
		msUnlock()
	endif
return nil


//---------------------------------
static function fRetQq()
local aPergs := {}
local aRet   := {}

	if ! msgYesNo( "Deseja retornar as embalagens mais antigas?", cCadastro )
		return nil
	endif

	aAdd(aPergs,{1,"Transportador"	,space( len(SA4->A4_COD) )		,""   , ,"SA4",".T.",0,.T.})
	aAdd(aPergs,{1,"Embalagem"		,space( len(SZE->ZE_CODIGO) )	,""   , ,"SZE",".T.",0,.T.})
	aAdd(aPergs,{1,"Quantidade"		,0								,"999", ,""   ,".T.",0,.T.})

	if ParamBox(aPergs,"Informe os dados para dar baixa nas embalagens",@aRet,,,,,,,,.F.)
		cTransp := aRet[1]
		cEmb    := aRet[2]
		nQtde   := aRet[3]

		nSaldo  := fGetQtd( cTransp, cEmb )
		
		if nSaldo == 0
			msgStop( "Não foram encontradas embalagens com esta transportadora", cCadastro)
			return nil
		endif
		
		if nQtde > nSaldo
			if ! msgYesNo( "A quantidade informada é maior que a quantidade em trânsito, continua assim mesmo?", cCadastro)
				return nil
			endif
		endif

		SZC->( dbSetOrder(1) )
		SZC->( dbSeek( xFilial("SZC") + cTransp + cEmb, .T. ) )
		while ! SZC->( eof() ) .and. SZC->(ZC_FILIAL+ZC_TRANSP+ZC_MODELO) == xFilial("SZC") + cTransp + cEmb .and. nQtde > 0

			nSaldo := SZC->( ZC_QTDE-ZC_QTDR )

			recLock("SZC", .F.)
			SZC->ZC_QTDR += min( nSaldo, nQtde )
			if SZC->ZC_QTDR == SZC->ZC_QTDE
				SZC->( dbDelete() )
			endif
			msUnlock()

			nQtde -= nSaldo

			SZC->( dbSkip() )
		end

	endif
return nil


//---------------------------------------------
static function fGetQtd( cTransp, cEmb )
local aArea     := getArea()
local cQuery
local cAliasQry := getNextAlias()
local nQtde     := 0

	cQuery := "select sum(ZC_QTDE-ZC_QTDR) QTDE from "+retSqlName("SZC")
	cQuery += " where ZC_FILIAL='"+xFilial("SZC")+"'"
	cQuery += " and ZC_TRANSP='"+cTransp+"'"
	cQuery += " and ZC_MODELO='"+cEmb+"'"
	cQuery += " and D_E_L_E_T_=' '"
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	if ! (cAliasQry)->( eof() ) 
		nQtde := (cAliasQry)->QTDE
	endif
	(cAliasQry)->( dbCloseArea() )
	restArea(aArea)
return nQtde
