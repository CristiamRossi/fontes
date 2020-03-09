#include "totvs.ch"
/*/{Protheus.doc} cadRotas
Cadastro de Rotas de Entrega
@author Cristiam Rossi
@since 20/01/2020
@version 1.0
@param none
@type function
/*/
user function cadRotas
local   aArea     := getArea()
private cCadastro := "Rotas de Entrega"
private aRotina   := menuDef()
private cString   := "SZR"
private bExcluir  := {|| iif( fExcluir(), axDeleta(cString,recno(),1), nil) }

	dbSelectArea(cString)
	dbGoTop()

	mBrowse( 6,1,22,75,cString)
	restArea( aArea )
return nil


//----------------
static function menuDef()
local aRotina := {}

	aAdd( aRotina, {"Pesquisar"   ,"AxPesqui"      ,0,1} )
	aAdd( aRotina, {"Visualizar"  ,"AxVisual"      ,0,2} )
	aAdd( aRotina, {"Incluir"     ,"AxInclui"      ,0,3} )
	aAdd( aRotina, {"Alterar"     ,"AxAltera"      ,0,4} )
	aAdd( aRotina, {"Excluir"     ,"eval(bExcluir)",0,5} )
return aRotina


//----------------
static function fExcluir()
local aArea     := getArea()
local lRet      := .T.
local cQuery
local cAliasQry := getNextAlias()

	cQuery := "select COUNT(*) NCOUNT from "+retSqlName("SC5")
	cQuery += " where C5_FILIAL='"+xFilial("SC5")+"'"
	cQuery += " and C5_XROTA='"+SZR->ZR_CODIGO+"'"
	cQuery += " and D_E_L_E_T_=' '"
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	if ! eof() .and. NCOUNT > 0
		lRet := .F.
		msgAlert("Esta rota foi utilizada em Pedidos de Vendas e não pode ser excluída."+CRLF+"Sugestão: Bloqueie o cadastro", cCadastro)
	endif

	dbCloseArea()

	restArea( aArea )
return lRet
