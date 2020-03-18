#include "totvs.ch"
/*/{Protheus.doc} impXML
Rotina de importação de documentos fiscais de entrada e saída por meio de
carga de arquivos XML
@author Cristiam Rossi
@since 18/02/2020
@version 1.0
@type function
/*/
user function impXML2()
local   aArea   := getArea()
local   cFolder := ""
local   aXmlTmp := {}
local   nImport := 0
local   nI
private aTES     := {"FS_TSENNOR" /*Entr Norm*/, "FS_TSENDEV" /*Entr Dev*/, "FS_TSSANOR" /*Sai Norm*/, "FS_TSSADEV" /*Sai Dev*/ }
private cTitulo := "Importação NF via XML"
private aXMLs   := {}
private nTotArq := 0
Private _aDir	:= {}	//Array com as pastas aonde estão localizados os arquivos XML (árvore completa com sub-pastas)
								//	1 C Pasta
								//	2 L Se já varreu a pasta a procura de arquivos
Private _aXML	:= {}	//Array com as informações referêntes aos arquivos .XML
								//	1 C Nome do Arquivo XML
								//	2 N Tamanho do Arquivo em bytes
								//	3 D Data do Arquivo
								//	4 C Hora do Arquivo (hh:mm:ss)
								//	5 C Atributos do Arquivo
								//	6 C Pasta aonde o Arquivo está salvo
								//	7 C Caminho completo aonde o arquivo está salvo (Pasta + Nome do Arquivo)

	fCriaMV()

    if ! msgYesNo( "Esta rotina é responsável pela importação das Notas Fiscais de Entrada e Saída por meio dos arquivos XML. Deseja continua?", cTitulo )
        return nil
    endif

	SF4->( dbSetOrder(1) )
	for nI := 1 to len( aTES )
		cMV := aTES[nI]
		aTES[nI] := getMV( cMV )
		if len( aTES[nI] ) != 3 .or. ! SF4->( dbSeek(xFilial("SF4") + aTES[nI]) )
			msgAlert("Favor informar o parâmetro "+cMV, "Informar parâmetro de TES")
			return nil
		endif
	next

	cFolder := cGetFile('Arquivos (*.xml)|*.xml' , 'Selecione a pasta com os XMLs a serem importados',1, "C:\",.T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ), .T., .T. )

    if Empty(cFolder)
    	Return .F.
    endif

	aXmlTmp := DIRECTORY( cFolder + "\*.xml", "D" )

	For nI := 1 to Len( aXmlTmp )
		aadd( aXMLs, aXmlTmp[nI,1] )
	next

	nTotArq := CountDir( cFolder )

	if nTotArq == 0
		msgStop( "Não foram encontrados arquivos *.xml na pasta informada", cTitulo )
		restArea( aArea )
		return nil
	endif

	Processa( {|| nImport := fPrincipal()}, "Aguarde, carregando arquivos da pasta", "Iniciando processo...")

	Aviso( "Importação concluída", "Foram importados "+alltrim( Transform(nImport, "@E 999,999,999,999" ) )+" de "+Alltrim(Transform(nTotArq, "@E 999,999,999,999"))+" arquivo"+iif(nTotArq==1,"","s"), {"Ok"} )

    restArea( aArea )
return nil


//------------------------------------------------------
static function fPrincipal()
local nI
local nImport := 0
local dDtAtu  := dDatabase

	ProcRegua( nTotArq )

	for nI := 1 to nTotArq

		IncProc( "arquivo "+Alltrim( Str( nI ) )+" de "+Alltrim( Str( nTotArq ) ) )
		ProcessMessages()

		cXml := LeXml( _aXML[nI, 7] )		// Lê XML e retorna conteúdo

		if Empty( cXml )

            makeDir( _aXML[nI, 6] + "\ERRO")
           	if __CopyFile( _aXML[nI, 7], _aXML[nI, 6] + "\ERRO\" + _aXML[nI, 1] )
                fErase( _aXML[nI, 7] )
            endif
			loop
		endif

		dDatabase := dDtAtu
		cRet      := trataXML( cXML, _aXML[nI, 1] )

		if cRet == "OK"
			nImport++

            makeDir( _aXML[nI, 6] + "\OK")
           	if __CopyFile( _aXML[nI, 7], _aXML[nI, 6] + "\OK\" + _aXML[nI, 1] )
                fErase( _aXML[nI, 7] )
            endif
		Endif
		if cRet == "FALHA"
           	if __CopyFile( _aXML[nI, 7], _aXML[nI, 6] + "\ERRO\" + _aXML[nI, 1] )
                fErase( _aXML[nI, 7] )
            endif
		endif
	next
	dDatabase := dDtAtu

	removeLF()

return nImport


//--------------------------------------------------------------
Static Function LeXML( cFile )
Local aArea := GetArea()
Local cXml  := ""

	if FT_FUSE(cFile) == -1
	  	RestArea( aArea )
  		Return ""
  	endif

	while !FT_FEOF()
		cXml += FT_FREADLN()
		FT_FSKIP()
  	end

  	FT_FUSE()

  	RestArea( aArea )
Return cXml


//--------------------------------------------------------------
Static Function CountDir( cPasta )
Local   cXml						// variável com o conteúdo XML
Local   aAreaSM0    := SM0->( GetArea() )
Local   nImport     := 0		// Nº de arquivos XML importados
Local   nI
Local   cRet
Local   _cTipoA	:= "*.*"
private _aDir := {}

	LeDiretorio(cPasta, _cTipoA)				//Leio a pasta raiz

	While len( _aDir ) > 0 .and. ! _aDir[1][2]						//Repito a leitura das pastas até só encontrar arquivos
		_nTam := Len(_aDir)

		For nI := 1 To _nTam
			If _aDir[nI][2]
				nI := _nTam + 1
			Else
				LeDiretorio(_aDir[nI][1], _cTipoA)
				_aDir[nI][2] := .T.
			EndIf
		Next
		
		ASort(_aDir,,,{|x,y| x[2] < y[2]})		//Ordeno os diretórios para identificar os que não foram varridos ainda
	EndDo

	nTotArq := len( _aXML )

return nTotArq


//--------------------------------------------------------------
static function LeDiretorio(_cPasta, _cTipoA)
local _aFiles := Directory(_cPasta + _cTipoA, "D")
local _nX

	for _nX := 1 To Len(_aFiles)
		if _aFiles[_nX][5] == "D" .And. AllTrim(_aFiles[_nX][1]) <> "." .And. AllTrim(_aFiles[_nX][1]) <> ".."
			aAdd(_aDir, {_cPasta + AllTrim(_aFiles[_nX][1]) + "\", .F.})
		elseif (empty(_aFiles[_nX][5]) .or. _aFiles[_nX][5] == "A") .And. Upper(Right(AllTrim(_aFiles[_nX][1]), 3)) == "XML"
			aAdd(_aXML, _aFiles[_nX])
			aAdd(_aXML[Len(_aXML)], _cPasta)
			aAdd(_aXML[Len(_aXML)], _cPasta + AllTrim(_aFiles[_nX][1]))
		endif
	next

return .T.


//----------------------------------------------------
static function trataXML( cXML, cArquivo )
local   cTipo    := ""
local   aTotDet  := {}
local   aCab     := {}
local   nI
private oXml							// Objeto XML após parse
private oInfNFe						// Objeto auxiliar, parte do XML
private aItens
private nD
private lMsErroAuto := .F.

	oXml := cXML2oXML( cXml )		// Carrega XML no Objeto
	If ValType(oXml) != "O"			// ver log -  Problema na carga do XML
		oXml := nil
		DelClassIntf()	// Exclui todas classes de interface da thread - Orientado uso pelo Marcos Feijó
		Return "FALHA"
	Endif

	if Type('oXml:_NfeProc') == "O"

		cTipo    := "DANFE"
		oInfNFe  := iif( Type('oXml:_NFEPROC:_NFE:_INFNFE') == "O", oXml:_NfeProc:_Nfe:_InfNfe, "" )

		if Empty( oInfNFe )
			oInfNFe  := iif( Type('oXml:_Nfe:_InfNfe') == "O", oXml:_Nfe:_InfNfe, "" )
		endif

		if Empty( oInfNFe )
			oXml := nil
			DelClassIntf()	// Exclui todas classes de interface da thread - Orientado uso pelo Marcos Feijó
			Return "FALHA"
		endif

		cChave   := Substr(oInfNFe:_ID:Text, 4)		// Chave da DANFE
		cProto   := iif( Type('oXml:_NFEPROC:_PROTNFE:_INFPROT:_NPROT')	== 'U', "", oXml:_NFEPROC:_PROTNFE:_INFPROT:_NPROT:TEXT)

		cCgcDest := iif( Type('oInfNFe:_Dest:_Cnpj:Text') == 'U', "", oInfNFe:_Dest:_Cnpj:Text)
		if empty( cCgcDest )
			cCgcDest := iif( Type('oInfNFe:_Dest:_Cpf:Text') == 'U', "", oInfNFe:_Dest:_Cpf:Text)
		endif

		cNomEmit := iif( Type('oInfNFe:_Emit:_xNome:Text') == 'U', "", oInfNFe:_Emit:_xNome:Text)
		cCGCEmit := oInfNFe:_Emit:_CNPJ:TEXT

		aDest := {;
					iif(Type("oInfNFe:_DEST:_IE:TEXT")					== 'U',	"", oInfNFe:_DEST:_IE:TEXT ),;
					iif(Type("oInfNFe:_DEST:_XNOME:TEXT")				== 'U',	"", oInfNFe:_DEST:_XNOME:TEXT ),;
					iif(Type("oInfNFe:_DEST:_EMAIL:TEXT")				== 'U',	"", oInfNFe:_DEST:_EMAIL:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_CEP:TEXT")		== 'U',	"", oInfNFe:_DEST:ENDERDEST:_CEP:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_UF:TEXT")		== 'U',	"", oInfNFe:_DEST:ENDERDEST:_UF:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_xBAIRRO:TEXT")	== 'U',	"", oInfNFe:_DEST:ENDERDEST:_xBAIRRO:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_xMUN:TEXT")		== 'U',	"", oInfNFe:_DEST:ENDERDEST:_xMUN:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_cMUN:TEXT")		== 'U',	"", oInfNFe:_DEST:ENDERDEST:_cMUN:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_xLGR:TEXT")		== 'U',	"", oInfNFe:_DEST:ENDERDEST:_xLGR:TEXT ),;
					iif(Type("oInfNFe:_DEST:ENDERDEST:_NRO:TEXT")		== 'U', "", oInfNFe:_DEST:ENDERDEST:_NRO:TEXT );
		}

		aEmit := {;
					iif(Type("oInfNFe:_EMIT:_IE:TEXT")					== 'U',	"", oInfNFe:_EMIT:_IE:TEXT ),;
					iif(Type("oInfNFe:_EMIT:_XNOME:TEXT")				== 'U',	"", oInfNFe:_EMIT:_XNOME:TEXT ),;
					iif(Type("oInfNFe:_EMIT:_EMAIL:TEXT")				== 'U',	"", oInfNFe:_EMIT:_EMAIL:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_CEP:TEXT")		== 'U',	"", oInfNFe:_EMIT:ENDEREMIT:_CEP:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_UF:TEXT")		== 'U',	"", oInfNFe:_EMIT:ENDEREMIT:_UF:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_xBAIRRO:TEXT")	== 'U',	"", oInfNFe:_EMIT:ENDEREMIT:_xBAIRRO:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_xMUN:TEXT")		== 'U',	"", oInfNFe:_EMIT:ENDEREMIT:_xMUN:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_cMUN:TEXT")		== 'U',	"", oInfNFe:_EMIT:ENDEREMIT:_cMUN:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_xLGR:TEXT")		== 'U',	"", oInfNFe:_EMIT:ENDEREMIT:_xLGR:TEXT ),;
					iif(Type("oInfNFe:_EMIT:ENDEREMIT:_NRO:TEXT")		== 'U', "", oInfNFe:_EMIT:ENDEREMIT:_NRO:TEXT );
		}

		if SM0->M0_CGC != cCgcDest .and. SM0->M0_CGC != cCGCEmit
			oXml := nil
			DelClassIntf()
			Return "NAO PERTENCE A EMPRESA"
		endif

		cSerie   := iIf(Type("oInfNFe:_IDE:_SERIE:TEXT")	== 'U',	"", PadR(oInfNFe:_IDE:_SERIE:TEXT, TamSX3("F2_SERIE")[1]))
		cDoc     := iIf(Type("oInfNFe:_IDE:_NNF:TEXT")		== 'U',	"", StrZero(Val(PadR(oInfNFe:_IDE:_NNF:TEXT, TamSX3("F2_DOC")[1])),9))
		cObs     := iIf(Type("oInfNFe:_INFADIC:_INFCPL:TEXT")== "U", "", oInfNFe:_INFADIC:_INFCPL:TEXT)
		dDtEmis  := iIf(Type("oInfNFe:_IDE:_dEmi:TEXT")		== 'U',	CtoD("//"), StoD(StrTran(oInfNFe:_IDE:_dEmi:TEXT, "-","")))
		if Empty(dDtEmis)
			dDtEmis	:= iIf(Type("oInfNFe:_IDE:_dhEmi:TEXT")	== 'U',	CtoD("//"), StoD(StrTran(Left(oInfNFe:_IDE:_dhEmi:TEXT, 10), "-","")))
		endif

		dhAutSef  := iif( Type('oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO')	== 'U', "", oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT )
		cTpNF     := iif( Type('oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPNF')	== 'U', "1", oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPNF:TEXT )
		cAmb      := iif( Type('oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPAMB')	== 'U', "1", oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPAMB:TEXT )
		cTpEmis   := iif( Type('oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPEMIS')	== 'U', "1", oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT )
		cfinNFe   := iif( Type('oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_finNFe')	== 'U', "1", oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_finNFe:TEXT )
		nVDesc    := iif( Type('oInfNFe:_total:_ICMSTot:_vDesc') == 'U', 0, val(oInfNFe:_total:_ICMSTot:_vDesc:TEXT) )

		dDatabase := dDtEmis
		cDoc      := padR( cDoc  , len( SF1->F1_DOC  ) )
		cSerie    := padR( cSerie, len( SF1->F1_SERIE) )

		if cTpNF == "0"
			cMov := "ENTRADA"
			if cfinNFe == "4"	// devolução compra
				if SM0->M0_CGC == cCgcDest
					posiCLI( cCGCEmit, aEmit )
				else
					posiCLI( cCgcDest, aDest )
				endif
			else
				if SM0->M0_CGC == cCgcDest
					posiFORN( cCGCEmit, aEmit )
				else
					posiFORN( cCgcDest, aDest )
				endif
			endif
		else
			cMov := "SAIDA"
			if cfinNFe == "4"	// devolução compra
				posiFORN( cCgcDest, aDest )
			else
				posiCLI( cCgcDest, aDest )
			endif
		endif

		if cMov == "SAIDA"

			SF2->( dbSetOrder(1) )
			if SF2->( dbSeek( xFilial("SF2") + cDoc + cSerie, .T. ) ) .or. SF2->( dbSeek( xFilial("SF2") + cDoc + right("0000"+alltrim(cSerie),3), .T. ) )
				oXml := nil
				DelClassIntf()
				conout("NF Saída ja lancada: " + cDoc + "-" + cSerie)
				Return "OK"		// NF já lançada
			endif

			aadd(aCab,{"F2_TIPO"    , iif(cfinNFe=="4", "B", "N"), nil } )
			aadd(aCab,{"F2_FORMUL"  , "N"          , nil } )
			aadd(aCab,{"F2_DOC"     , cDoc         , nil } )
			aadd(aCab,{"F2_SERIE"   , cSerie       , nil } )
			aadd(aCab,{"F2_EMISSAO" , dDataBase    , nil } )
			aadd(aCab,{"F2_CLIENTE" , iif(cfinNFe=="4", SA2->A2_COD  , SA1->A1_COD ), nil } )
			aadd(aCab,{"F2_LOJA"    , iif(cfinNFe=="4", SA2->A2_LOJA , SA1->A1_LOJA ), nil } )
			aadd(aCab,{"F2_ESPECIE" , "SPED"       , nil } )
			aadd(aCab,{"F2_CHVNFE"  , cChave       , Nil})
//			aadd(aCab,{"F2_DESCONT" , 0})
		else

			SF1->( dbSetOrder(1) )

			if cfinNFe == "4"		// Devolução
				cKey := xFilial("SF1") + cDoc + cSerie + SA1->A1_COD + SA1->A1_LOJA
			else
				cKey := xFilial("SF1") + cDoc + cSerie + SA2->A2_COD + SA2->A2_LOJA
			endif

			if SF1->( dbSeek( cKey, .T. ) )
				oXml := nil
				DelClassIntf()
				Return "OK"		// NF já lançada
			endif

			aadd(aCab,{"F1_TIPO"    ,iif(cfinNFe=="4", "B", "N"), NIL})
			aadd(aCab,{"F1_FORMUL"  ,"N"           , NIL})
			aadd(aCab,{"F1_DOC"     , cDoc         , NIL})
			aadd(aCab,{"F1_SERIE"   , cSerie       , NIL})
			aadd(aCab,{"F1_EMISSAO" , dDatabase    , NIL})
			aadd(aCab,{"F1_DTDIGIT" , dDatabase    , NIL})
			aadd(aCab,{"F1_FORNECE" , iif(cfinNFe=="4", SA1->A1_COD  , SA2->A2_COD  ), nil } )
			aadd(aCab,{"F1_LOJA"    , iif(cfinNFe=="4", SA1->A1_LOJA , SA2->A2_LOJA ), nil } )
			aadd(aCab,{"F1_ESPECIE" ,"SPED"        , NIL})
			aadd(aCab,{"F1_DESCONT" , nVDesc       , Nil})
			aadd(aCab,{"F1_STATUS"  , "A"          , Nil})
			aadd(aCab,{"F1_CHVNFE"  , cChave       , Nil})
		endif

		aItens := iif( Type("oXml:_NFEPROC:_NFE:_INFNFE:_det") == "A", aClone(oXml:_NFEPROC:_NFE:_INFNFE:_det), {oXml:_NFEPROC:_NFE:_INFNFE:_det} )

		for nI := 1 to len( aItens )
			nD      := nI
			aTmpDet := {}
			xCodBar := ""
			xProd   := ""

			if Type("aItens[nD]:_Prod:_cProd:TEXT") != "U"
				xProd := aItens[nD]:_Prod:_cProd:TEXT				
				if len( xProd ) > len( SB1->B1_COD )
					xProd := right( alltrim( xProd ), len( SB1->B1_COD ) )
				endif
			endif

			if Type("aItens[nD]:_Prod:_cEAN:TEXT") != "U"
				xCodBar := aItens[nD]:_Prod:_cEAN:TEXT
			endif

			if Empty(xCodBar) .and. Type("aItens[nD]:_Prod:_cEANtrib:TEXT") != "U"
				xCodBar := aItens[nD]:_Prod:_cEANtrib:TEXT
			endif

			posiProd( xProd, xCodBar, cMov, cfinNFe )

			if Type("aItens[nD]:_Prod:_CFOP:TEXT") != "U"
				xCFOP := PadR(aItens[nD]:_Prod:_CFOP:TEXT, len( SF4->F4_CF ) )
			endif

			xQtd := 0
			if Type("aItens[nD]:_Prod:_qCom:TEXT") != "U"
				xQtd := Val( aItens[nD]:_Prod:_qCom:TEXT )
			endif

			if xQtd == 0 .and. Type("aItens[nD]:_Prod:_qTrib:TEXT") != "U"
				xQtd := Val( aItens[nD]:_Prod:_qTrib:TEXT )
			endif

			xVunit := 0
			if Type("aItens[nD]:_Prod:_vUnCom:TEXT") != "U"
				xVunit := Val( aItens[nD]:_Prod:_vUnCom:TEXT )
			endif

			if xVunit == 0 .and. Type("aItens[nD]:_Prod:_vUnTrib:TEXT") != "U"
				xVunit := Val( aItens[nD]:_Prod:_vUnTrib:TEXT )
			endif

			xVdesc := 0
			if Type("aItens[nD]:_Prod:_vDesc:TEXT") != "U"
				xVdesc := Val( aItens[nD]:_Prod:_vDesc:TEXT )
			endif

			xVtotal := 0
			if Type("aItens[nD]:_Prod:_vProd:TEXT") != "U"
				xVtotal := Val( aItens[nD]:_Prod:_vProd:TEXT )
			endif

			if xVtotal == 0
				xVtotal := xQtd * xVunit - xVdesc
			endif

			if cMov == "ENTRADA"
				aadd(aTmpDet, { "D1_ITEM"   , strZero(nD, len(SD1->D1_ITEM)), nil } )
				aadd(aTmpDet, { "D1_COD"    , SB1->B1_COD                   , nil } )
				aadd(aTmpDet, { "D1_QUANT"  , xQtd                          , nil } )
				aadd(aTmpDet, { "D1_VUNIT"  , xVunit                        , nil } )
				aadd(aTmpDet, { "D1_TOTAL"  , xVtotal                       , nil } )
				aadd(aTmpDet, { "D1_TES"    , aTES[iif(cfinNFe=="4",2,1)]   , nil } )
			else
				aadd(aTmpDet, { "D2_ITEM"   , strZero(nD, len(SD2->D2_ITEM)), nil } )
				aadd(aTmpDet, { "D2_COD"    , SB1->B1_COD                   , nil } )
				aadd(aTmpDet, { "D2_QUANT"  , xQtd                          , nil } )
				aadd(aTmpDet, { "D2_PRCVEN" , xVunit                        , nil } )
				aadd(aTmpDet, { "D2_TOTAL"  , xVtotal                       , nil } )
				aadd(aTmpDet, { "D2_TES"    , aTES[iif(cfinNFe=="4",4,3)]   , nil } )
			endif

			aadd( aTotDet, aClone(aTmpDet) )
		next

		if cMov == "SAIDA"
			MSExecAuto({|x,y,z| MATA920(x,y,z)},aCab,aTotDet,3)
		else
			MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aTotDet,3)
		endif

		If ! lMsErroAuto
			cRet := "OK"
		Else
			MostraErro()
			cRet := "FALHA"
		EndIf
	endif

	oXml := nil
	DelClassIntf()

return cRet


//----------------------------------------------------
Static Function cXML2oXML( cXml )
Local   cDelimit := "_"
Local   cError   := ""
Local   cWarning := ""
Local   oXml
Default cXml     := ""  

	Begin Sequence
		oXml := XmlParser( cXml, cDelimit, @cError, @cWarning)
	End Sequence

Return oXml


//----------------------------------------------------
static function posiCLI( cCgcCLI, aDados )
local cNewCod

	SA1->( dbSetOrder(1) )
	SA1->( dbGoBottom() )
	cNewCod := soma1( SA1->A1_COD )

	SA1->( dbSetOrder(3) )
	if ! SA1->( dbSeek( xFilial("SA1") + cCgcCLI) )
		recLock("SA1", .T.)
		SA1->A1_FILIAL  := xFilial("SA1")
		SA1->A1_CGC     := cCgcCLI
		SA1->A1_PESSOA  := iif(len( cCgcCLI ) == 14, "J", "F" )
		SA1->A1_TIPO    := "R"
		SA1->A1_INSCR   := aDados[1]
		SA1->A1_NOME    := aDados[2]
		SA1->A1_NREDUZ  := aDados[2]
		SA1->A1_COD     := cNewCod
		SA1->A1_LOJA    := "00"
		SA1->A1_EMAIL   := aDados[3]
		SA1->A1_CEP     := aDados[4]
		SA1->A1_EST     := aDados[5]
		SA1->A1_BAIRRO  := aDados[6]
		SA1->A1_MUN     := aDados[7]
		SA1->A1_COD_MUN := aDados[8]
		SA1->A1_END     := aDados[9]
		if ! empty( aDados[10] )
			SA1->A1_END := alltrim( SA1->A1_END ) + ", " + aDados[10]
		endif
		SA1->A1_DTCAD   := date()
		SA1->A1_HRCAD   := time()
		SA1->A1_PAIS    := "105"
		msUnlock()
	endif
return nil


//----------------------------------------------------
static function posiFORN( cCGCForn, aDados )
local cNewCod

	SA2->( dbSetOrder(1) )
	SA2->( dbGoBottom() )
	cNewCod := soma1( SA2->A2_COD )

	SA2->( dbSetOrder(3) )
	if ! SA2->( dbSeek( xFilial("SA2") + cCGCForn) )
		recLock("SA2", .T.)
		SA2->A2_FILIAL  := xFilial("SA1")
		SA2->A2_CGC     := cCGCForn
		SA2->A2_TIPO    := iif(len( cCGCForn ) == 14, "J", "F" )
		SA2->A2_INSCR   := aDados[1]
		SA2->A2_NOME    := aDados[2]
		SA2->A2_NREDUZ  := aDados[2]
		SA2->A2_COD     := cNewCod
		SA2->A2_LOJA    := "00"
		SA2->A2_EMAIL   := aDados[3]
		SA2->A2_CEP     := aDados[4]
		SA2->A2_EST     := aDados[5]
		SA2->A2_BAIRRO  := aDados[6]
		SA2->A2_MUN     := aDados[7]
		SA2->A2_COD_MUN := aDados[8]
		SA2->A2_END     := aDados[9]
		if ! empty( aDados[10] )
			SA2->A2_END := alltrim( SA1->A1_END ) + ", " + aDados[10]
			SA2->A2_NR_END := aDados[10]
		endif
		SA2->A2_PAIS    := "105"
		msUnlock()
	endif
return nil


//----------------------------------------------------
static function posiProd( xProd, cEAN, cMov, cfinNFe )

	if ( cMov == "ENTRADA" .and. cfinNFe != "4" ) .or. ( cMov == "SAIDA" .and. cFinNFe == "4")
		SA5->( dbSetOrder(14) )
		if SA5->( dbSeek( xFilial("SA5") + SA2->(A2_COD+A2_LOJA) + xProd ) )
			SB1->( dbSetOrder(1))
			if SB1->( dbSeek( xFilial("SB1") + SA5->A5_PRODUTO ) )
				return nil
			endif
		endif
	endif

	if ( cMov == "ENTRADA" .and. cfinNFe == "4" ) .or. ( cMov == "SAIDA" .and. cFinNFe != "4")
		SA7->( dbSetOrder(3) )
		if SA7->( dbSeek( xFilial("SA5") + SA1->(A1_COD+A1_LOJA) + xProd ) )
			SB1->( dbSetOrder(1))
			if SB1->( dbSeek( xFilial("SB1") + SA7->A7_PRODUTO ) )
				return nil
			endif
		endif
	endif

	SB1->( dbSetOrder(1))
	if SB1->( dbSeek( xFilial("SB1") + padR( xProd, len(SB1->B1_COD ) ) ) )
		return nil
	endif

	SB1->( dbSetOrder(5))
	if SB1->( dbSeek( xFilial("SB1") + padR( cEAN, len(SB1->B1_CODBAR ) ) ) )
		SB1->( dbSetOrder(1))
		return nil
	endif

	SB1->( dbSetOrder(1))

	recLock("SB1", .T.)
	SB1->B1_FILIAL  := xFilial("SB1")
	SB1->B1_COD     := xProd
	SB1->B1_CODBAR  := cEAN
	SB1->B1_TIPO    := "PA"
	SB1->B1_LOCPAD  := "01"
	SB1->B1_DESC    := iif( Type("aItens[nD]:_Prod:_xProd:TEXT") != "U", aItens[nD]:_Prod:_xProd:TEXT, "")
	SB1->B1_UM      := iif( Type("aItens[nD]:_Prod:_uCom:TEXT") != "U", aItens[nD]:_Prod:_uCom:TEXT, "")
	if empty( SB1->B1_UM )
		SB1->B1_UM      := iif( Type("aItens[nD]:_Prod:_uTrib:TEXT") != "U", aItens[nD]:_Prod:_uTrib:TEXT, "")
	endif
	SB1->B1_POSIPI  := iif( Type("aItens[nD]:_Prod:_NCM:TEXT") != "U", aItens[nD]:_Prod:_NCM:TEXT, "")
	SB1->B1_MCUSTD  := "1"
	SB1->B1_RASTRO  := "N"
	SB1->B1_DATREF  := date()
	SB1->B1_MRP     := "S"
	SB1->B1_LOCALIZ := "N"
	SB1->B1_CONTRAT := "N"
	SB1->B1_IMPORT  := "N"
	msUnlock()
return nil


//----------------------------------------------------
static function removeLF()
local aArea := getArea()
local aQry  := {}
local nI

	aadd( aQry, "update "+retSqlName("SD2")+" set D2_ORIGLAN='' where D_E_L_E_T_=' '" )
	aadd( aQry, "update "+retSqlName("SF2")+" set F2_ORIGLAN='' where D_E_L_E_T_=' '" )

	for nI := 1 to len( aQry )
		TCSqlExec( aQry[nI] )
	next

	restArea( aArea )
return nil


//----------------------------------------------------
static function fCriaMV()
local aArea := getArea()

	if superGetMV("FS_TSENNOR",,"NADA") == "NADA"
		recLock("SX6", .T.)
		SX6->X6_VAR     := "FS_TSENNOR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "TES Entrada Normal"
		SX6->X6_PROPRI  := "U"
		SX6->X6_CONTEUD := "<INFORMAR O TES>"
		SX6->X6_EXPDEST := "1"
		msUnlock()
	endif

	if superGetMV("FS_TSENDEV",,"NADA") == "NADA"
		recLock("SX6", .T.)
		SX6->X6_VAR     := "FS_TSENDEV"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "TES Entrada Devolucao"
		SX6->X6_PROPRI  := "U"
		SX6->X6_CONTEUD := "<INFORMAR O TES>"
		SX6->X6_EXPDEST := "1"
		msUnlock()
	endif

	if superGetMV("FS_TSSANOR",,"NADA") == "NADA"
		recLock("SX6", .T.)
		SX6->X6_VAR     := "FS_TSSANOR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "TES Saida Normal"
		SX6->X6_CONTEUD := "<INFORMAR O TES>"
		SX6->X6_PROPRI  := "U"
		SX6->X6_EXPDEST := "1"
		msUnlock()
	endif

	if superGetMV("",,"NADA") == "NADA"
		recLock("SX6", .T.)
		SX6->X6_VAR     := "FS_TSSADEV"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "TES Saida Devolucao"
		SX6->X6_PROPRI  := "U"
		SX6->X6_CONTEUD := "<INFORMAR O TES>"
		SX6->X6_EXPDEST := "1"
		msUnlock()
	endif

	restArea( aArea )
return nil
