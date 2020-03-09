#include "totvs.ch"
#include "FWMVCDEF.CH"
/*/{Protheus.doc} filRomaneio
Cadastro das empresas participantes do Romaneio Compartilhado
@author Cristiam Rossi
@since 21/01/2020
@version 1.0
@param none
@type function
/*/
user function filRomaneio()
local aArea			:= getArea()
local oBrowse		:= FWMarkBrowse():New()
local cTempTab		:= GetNextAlias()
local oTabTemp		:= FWTemporaryTable():New( cTempTab )
local aCampos		:= { {"ZF_SEL","C",2,0}, {"ZF_FIL","C",6,0}, {"ZF_EMPNOME","C",40,0}, {"ZF_FILNOME","C",40,0} }
private cCadastro	:= "Cadastro de Empresa/Filial usuária do Romaneio Compartilhado"
private aRotina		:= Menudef()
private cMarca      := "xx"
private bGravar     := {|| fGravar(cTempTab, oBrowse) }

	oTabTemp:SetFields( aCampos )
	oTabTemp:Create()

	oBrowse:cMark := cMarca
	fCarga(cTempTab)

	oBrowse:SetTemporary()
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetAlias( cTempTab )
	oBrowse:SetFieldMark("ZF_SEL")
	oBrowse:oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
//	oBrowse:oBrowse:SetFilterDefault("")
	oBrowse:DisableDetails()
	oBrowse:SetColumns( fColuna( "ZF_FIL"		,"Código"	,06,"@!",0,010 ) )
	oBrowse:SetColumns( fColuna( "ZF_EMPNOME"	,"Empresa"	,40,"@!",1,080 ) )
	oBrowse:SetColumns( fColuna( "ZF_FILNOME"	,"Filial"	,40,"@!",1,080 ) )
	oBrowse:Activate()

	oTabTemp:Delete()
	restArea( aArea )
return nil


//-----------------------------
static function fCarga(cTempTab)
local aArea    := getArea()
local aAreaSM0 := SM0->( getArea() )

	SM0->( dbSetOrder(1) )	// SM0->M0_CODIGO + SM0->M0_CODFIL
	SM0->( dbGotop() )
	while ! SM0->( eof() )
		(cTempTab)->(dbAppend())
		(cTempTab)->ZF_SEL		:= iif( SZF->( dbSeek( xFilial("SZF") + SM0->M0_CODFIL ) ), cMarca, "" )
		(cTempTab)->ZF_FIL		:= SM0->M0_CODFIL
		(cTempTab)->ZF_EMPNOME	:= SM0->M0_NOME
		(cTempTab)->ZF_FILNOME	:= SM0->M0_FILIAL
		(cTempTab)->(dbCommit())
		SM0->( dbSkip() )
	end
	SM0->( restArea( aAreaSM0 ) )
	restArea( aArea )

	dbSelectArea( cTempTab )
return nil


//-----------------------------
static function menuDef()
local aRotina := {}

	ADD OPTION aRotina TITLE "Gravar" ACTION "eval(bGravar)"  OPERATION 6 ACCESS 0

return aRotina


//-----------------------------
Static Function fColuna(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize)
local aColumn
local bData   := {||}

	if nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	endif

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize, 0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
return {aColumn}


//-----------------------------
Static Function fGravar( cTempTab, oBrowse )
local aArea := getArea()

	(cTempTab)->( dbGotop() )
	while ! (cTempTab)->( eof() )
		if (cTempTab)->ZF_SEL != oBrowse:cMark .and. SZF->( dbSeek( xFilial("SZF") + (cTempTab)->ZF_FIL ) )
			recLock("SZF", .F.)
			SZF->( dbDelete() )
			msUnlock()
		elseif (cTempTab)->ZF_SEL == oBrowse:cMark .and. ! SZF->( dbSeek( xFilial("SZF") + (cTempTab)->ZF_FIL ) )
			recLock("SZF", .T.)
			SZF->ZF_FIL  := (cTempTab)->ZF_FIL
			SZF->ZF_NOME := (cTempTab)->( alltrim(ZF_EMPNOME) + "/" + alltrim(ZF_FILNOME) )
			msUnlock()
		endif

		(cTempTab)->( dbSkip() )
	end

	restArea( aArea )
return nil