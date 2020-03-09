#include "totvs.ch"
/*/{Protheus.doc} cadSZE
Cadastro de Embalagens Retornáveis
@type function
@author Cristiam Rossi
@since 08/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
user function cadSZE
local   aArea      := getArea()
private bValDelete := {|| fValDelete()}
private cCadastro  := "Cadastro de Embalagem Retornável"

	axCadastro("SZE", cCadastro, "eval(bValDelete)", ".T.")

	restArea( aArea )	
return nil


//---------------------------------
static function fValDelete()
local aArea     := getArea()
local lRet      := .T.
local cQuery
local cAliasQry := getNextAlias()

	cQuery := "select count(*) CNT from "+retSqlName("SB1") + " SB1 "
	cQuery += " join "+retSqlName("SZF")+" SZF on B1_FILIAL=left(ZF_FIL,2) and SZF.D_E_L_E_T_=' '"
	cQuery += " where B1_XEMB='"+SZE->ZE_CODIGO+"'"
	cQuery += " and SB1.D_E_L_E_T_=' '"
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	if ! (cAliasQry)->( eof() ) .and. (cAliasQry)->CNT > 0
		lRet := .F.
		msgStop( "Não é possível excluir pois existem produtos vinculados", cCadastro )
	endif

	(cAliasQry)->( dbCloseArea() )	
	restArea( aArea )
return lRet
