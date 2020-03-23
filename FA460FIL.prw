#include "totvs.ch"
/*/{Protheus.doc} FA460FIL
P.E. para seleção dos Clientes de REDE.
@author Cristiam Rossi
@since 22/01/2020
@version 1.0
@param none
@type function
/*/
user function FA460FIL
local cRet     := ""
local aArea    := getArea()
local aAreaSA1 := SA1->( getArea() )

    SA1->( dbSetOrder(1) )
    if SA1->( dbSeek( xFilial("SA1") + cCliente + cLoja ) )
        if ! empty( SA1->A1_GRPVEN ) .and. msgYesNo("Filtra apenas clientes de Rede", "Rede: "+SA1->A1_GRPVEN)
            cRet := getCli( SA1->A1_GRPVEN )
        endif
    endif

    SA1->( restArea( aAreaSA1 ) )
    restArea( aArea )
return cRet


//----------------------------------------
static function getCli( cGrupo )
local cSqlCli   := " and E1_CLIENTE in ("
local cQuery
local cAliasQry := getNextAlias()
local nClientes := 0

    cQuery := "select A1_COD from "+retSqlName("SA1")
    cQuery += " where A1_FILIAL='"+xFilial("SA1")+"'"
    cQuery += " and A1_GRPVEN='"+ cGrupo +"'"
    cQuery += " and D_E_L_E_T_=' '"
    cQuery += " group by A1_COD"
    dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    while ! (cAliasQry)->( eof() )

        cSqlCli += iif( nClientes > 0, ",", "" )
        cSqlCli += "'" + (cAliasQry)->A1_COD + "'"

        nClientes++
        (cAliasQry)->( dbSkip() )
    end
    (cAliasQry)->( dbCloseArea() )

    cSqlCli += ")"
return cSqlCli
