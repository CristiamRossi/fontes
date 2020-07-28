#include "TOTVS.ch"

User Function FA590AROT()

Local aAux := aClone(ParamIxb[1])

aAdd(aAux,{"Antecip. FIDIC","U_RATEIO",0,5})

Return aAux

////////////////////////////////////////////

User Function RATEIO()

Local oCancel
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oOk

Private nQtdTit := 0
Private nSomaBor := u_SomaBor(cNumBor)
Private nTaxa   := 0
Private nDescPT := 0


If nRadio <> 1 //nRadio = 1 (Receber) # nRadio = 2 (Pagar)
    Return Nil
Endif

Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Dados Rateio" FROM 000, 000  TO 150, 280 COLORS 0, 16777215 PIXEL

    @ 049, 045 MSGET nTaxa SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL picture "@R 9,999.99" Valid (nTaxa > 0)
    @ 050, 010 SAY oSay1 PROMPT "TAXA:" SIZE 015, 008 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 010 SAY oSay2 PROMPT "BORDERÔ:" SIZE 030, 006 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 010 SAY oSay3 PROMPT "TOTAL:" SIZE 025, 006 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 045 SAY oSay4 PROMPT cNumBor  SIZE 050, 010 OF oDlg COLORS 255, 16777215 PIXEL
    @ 032, 045 SAY oSay5 PROMPT nSomaBor SIZE 050, 010 OF oDlg COLORS 255, 16777215 PIXEL PICTURE "@R 999,999.99"

    DEFINE SBUTTON oOk      FROM 016, 100 TYPE 01 OF oDlg ENABLE ACTION u_RegRat(nTaxa, nSomaBor,nQtdTit)
    DEFINE SBUTTON oCancel  FROM 047, 100 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

    ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/////////////////////////////////////////////////////////////////

User Function SomaBor(cNumBor)

local aArea     := getArea()
local cQuery
local cAliasQry := getNextAlias()

	cQuery := "Select Sum(E1_SALDO) As SaldoBor, Count(*) As nCount From "+retSqlName("SE1")+ " "
	cQuery += " where E1_NUMBOR = '"+cNumBor+"'"
	cQuery += " and E1_FILIAL ='"+cFilAnt+"' "
	cQuery += " and D_E_L_E_T_=' ' "
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    nSoma   := (cAliasQry)->SaldoBor
	nQtdTit := (cAliasQry)->nCount

	if (cAliasQry)->( eof() ) .Or. nSoma <= 0
		msgAlert( "Titulos não encontrados ou já baixados, verifique o borderô informado!" )
	endif

	(cAliasQry)->( dbCloseArea() )	
	restArea( aArea )

Return nSoma

User Function RegRat(ntaxa, nSomaBor,nQtdTit)

//Regra de rateio: (Total da taxa de antecipação (nTotDesc) / Dividido pelo total do borderô (nSomaBor) ) * Pelo valor do título
nTotDesc    := 0
nTaxaAnt    := nTaxa
nTotDesc    := nTaxaAnt/nSomaBor
nDescPT     := nTaxaAnt/nQtdTit

If MsgYesNo("O borderô "+AllTrim(cNumBor)+" será baixado, aplicando o DESCONTO (AB-) no valor de R$"+Transform(nDescPT,"@E 9,999.99")+" em cada título, caso seja necessario o estorno dessa operação, deverá ser feita de forma MANUAL, titulo a titulo! DESEJA CONFIRMAR A OPERAÇÃO?", "CONFIRMAÇÃO")
    MsAguarde( {|| GRAVAABAT()}, "Processando...", "Gerando titulos de abatimento..." )
    MsAguarde( {|| BXABAT()}, "Processando...", "Baixando titulos..." )
else
    oDlg:End()
    RETURN
ENDIF

oDlg:End()
RETURN

Static Function GRAVAABAT()
Local aVetSE1 := {}
Local cQuery
Local cAliasQry := getNextAlias()

lMsErroAuto := .F.

cQuery := "Select * From "+retSqlName("SE1")+ " "
cQuery += " where E1_NUMBOR = '"+cNumBor+"'"
cQuery += " and E1_FILIAL ='"+cFilAnt+"' "
cQuery += " and D_E_L_E_T_=' ' and E1_SALDO > 0 "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasQry, .F., .T.)

Begin Transaction

While (cAliasQry)->(!EOF())
    lMsErroAuto := .F.
    aVetSE1 := {}

    aAdd(aVetSE1, {"E1_FILIAL",  (cAliasQry)->E1_FILIAL,    Nil})
    aAdd(aVetSE1, {"E1_NUM",     (cAliasQry)->E1_NUM,       Nil})
    aAdd(aVetSE1, {"E1_PREFIXO", (cAliasQry)->E1_PREFIXO,   Nil})
    aAdd(aVetSE1, {"E1_TIPO",    "AB-",                     Nil})
    aAdd(aVetSE1, {"E1_NATUREZ", (cAliasQry)->E1_NATUREZ,   Nil})
    aAdd(aVetSE1, {"E1_CLIENTE", (cAliasQry)->E1_CLIENTE,   Nil})
    aAdd(aVetSE1, {"E1_LOJA",    (cAliasQry)->E1_LOJA,      Nil})
    aAdd(aVetSE1, {"E1_NOMCLI",  (cAliasQry)->E1_NOMCLI,    Nil})
    aAdd(aVetSE1, {"E1_EMISSAO", StoD((cAliasQry)->E1_EMISSAO),   Nil})
    aAdd(aVetSE1, {"E1_VENCTO",  StoD((cAliasQry)->E1_VENCTO),    Nil})
    aAdd(aVetSE1, {"E1_VENCREA", StoD((cAliasQry)->E1_VENCREA),   Nil})
    aAdd(aVetSE1, {"E1_VALOR",   Round(nDescPT,2)   ,		    Nil})
    aAdd(aVetSE1, {"E1_SALDO",   Round(nDescPT,2)   ,		    Nil})
    aAdd(aVetSE1, {"E1_HIST",    "Titulo ABAT",     Nil})
    aAdd(aVetSE1, {"E1_MOEDA",   1,                 Nil})

    If nDescPT <= (cAliasQry)->E1_SALDO 
        MSExecAuto({|x,y| FINA040(x,y)},aVetSE1,3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao
    else
        (cAliasQry)->(DbSkip())
    ENDIF

    If lMsErroAuto
        MostraErro()
        DisarmTransaction()
    Else   	
        (cAliasQry)->(DbSkip())
    EndIf
EndDo
(cAliasQry)->(dbCloseArea())

End Transaction

Return()


//ROTINA DE BAIXA
Static Function BXABAT()
Local aCabec := {}
Local cQuery
Local cAliasQry := GetNextAlias()
Local nVlrAbat  := 0

lMsErroAuto := .F.

cQuery := "Select * From "+retSqlName("SE1")+ " "
cQuery += " where E1_NUMBOR = '"+cNumBor+"'"
cQuery += " and E1_FILIAL ='"+cFilAnt+"' "
cQuery += " and D_E_L_E_T_=' ' and E1_SALDO > 0 "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasQry, .F., .T.)

Begin Transaction

While (cAliasQry)->(!EOF())
    nVlrAbat  := SomaAbat((cAliasQry)->E1_PREFIXO,(cAliasQry)->E1_NUM,(cAliasQry)->E1_PARCELA,"R",1,,(cAliasQry)->E1_CLIENTE,(cAliasQry)->E1_LOJA,(cAliasQry)->E1_FILIAL,,(cAliasQry)->E1_TIPO)
    lMsErroAuto := .F.
    aCabec := {}

    DbSelectArea("SE1")
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSeek((cAliasQry)->E1_FILIAL+(cAliasQry)->E1_PREFIXO+(cAliasQry)->E1_NUM+(cAliasQry)->E1_PARCELA+(cAliasQry)->E1_TIPO))
        
        AADD(aCabec, {"E1_PREFIXO"  , SE1->E1_PREFIXO      		, nil})
        AADD(aCabec, {"E1_NUM"      , SE1->E1_NUM                	, nil})
        AADD(aCabec, {"E1_PARCELA"  , SE1->E1_PARCELA           	, nil})
        AADD(aCabec, {"E1_TIPO"     , SE1->E1_TIPO               	, nil})
        AADD(aCabec, {"E1_CLIENTE"  , SE1->E1_CLIENTE             	, nil})
        AADD(aCabec, {"E1_LOJA"     , SE1->E1_LOJA                	, nil})
        AADD(aCabec, {"AUTVALREC"   , SE1->E1_SALDO-nVlrAbat       	, nil})
        AADD(aCabec, {"AUTMOTBX"    , "NOR"   				  		, nil})
        AADD(aCabec, {"AUTDTBAIXA"  , dDataBase          	  	    , nil})
        AADD(aCabec, {"AUTDTCREDITO", dDataBase		  		        , nil})
        AADD(aCabec, {"AUTBANCO"    , SE1->E1_PORTADO             	, nil})
        AADD(aCabec, {"AUTAGENCIA"  , SE1->E1_AGEDEP   	    		, nil})
        AADD(aCabec, {"AUTCONTA"    , SE1->E1_CONTA                 , nil})
        AADD(aCabec, {"AUTHIST"     , "VALOR RECEBIDO"              , nil})

        MSExecAuto({|a,b| fina070(a,b)}, aCabec, 3)

        If lMsErroAuto
            MostraErro()
            DisarmTransaction()
        Else   	
            (cAliasQry)->(DbSkip())
        EndIf
EndDo
(cAliasQry)->(dbCloseArea())

End Transaction

Return()