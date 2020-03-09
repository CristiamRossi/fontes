#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDPRD
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDPRD( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram em formato ISAM (" + GetDbExtension() + ") e este update está preparado " + ;
				"para atualizar apenas ambientes com dicionários no Banco de Dados."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		/*
		If !FWAuthAdmin()
			Final( "Atualização não Realizada." )
		EndIf
		*/
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDPRD" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDPRD" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela SZR
//
aAdd( aSX2, { ;
	'SZR'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZR'+cEmpr																, ; //X2_ARQUIVO
	'ROTAS TRANSPORTE'														, ; //X2_NOME
	'ROTAS TRANSPORTE'														, ; //X2_NOMESPA
	'ROTAS TRANSPORTE'														, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'A1_NOME'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome'																	, ; //X3_TITULO
	'Nombre'																, ; //X3_TITSPA
	'Name'																	, ; //X3_TITENG
	'Nome do cliente'														, ; //X3_DESCRIC
	'Nombre del cliente'													, ; //X3_DESCSPA
	'Client Name'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'FatVldStr()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x  xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'texto()'																, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'S'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'001'																	, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'A1_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo'																	, ; //X3_TITULO
	'Tipo'																	, ; //X3_TITSPA
	'Type'																	, ; //X3_TITENG
	'Tipo do Cliente'														, ; //X3_DESCRIC
	'Tipo de Cliente'														, ; //X3_DESCSPA
	'Type of Customer'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xxx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("FLRSX")'														, ; //X3_VLDUSER
	'F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao'		, ; //X3_CBOX
	'F=Cons.Final;L=Productor Rural;R=Revendedor;S=Solidario;X=Exportacion'		, ; //X3_CBOXSPA
	'F=Final Consumer;L=Rural Producer;R=Reseller;S=Solidary;X=Export'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'001'																	, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'A1_NATUREZ'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Natureza'																, ; //X3_TITULO
	'Modalidad'																, ; //X3_TITSPA
	'Class'																	, ; //X3_TITENG
	'Codigo da Nat Financeira'												, ; //X3_DESCRIC
	'Cod de la Mod Financiera'												, ; //X3_DESCSPA
	'Financ.Class Code'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'FinVldNat( .T., , 1 )'													, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xx  x      xx       x   x xxxxxx    x       x    x  x     x x  x    x       x x x   x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SED'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'ExistCpo("SED")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'A1_ENDCOB'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'End.Cobranca'															, ; //X3_TITULO
	'Dir.Cobranza'															, ; //X3_TITSPA
	'Collec.Addr.'															, ; //X3_TITENG
	'End.de cobr. do cliente'												, ; //X3_DESCRIC
	'Dir. de cobr. del cliente'												, ; //X3_DESCSPA
	'Custm.Collec.Address'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio().Or.texto()'													, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'002'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'A1_ENDENT'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'End.Entrega'															, ; //X3_TITULO
	'Direcc.Entre'															, ; //X3_TITSPA
	'Dil.Address'															, ; //X3_TITENG
	'End.de entr. do cliente'												, ; //X3_DESCRIC
	'Dir.de entr. del cliente'												, ; //X3_DESCSPA
	'Customer del.address'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xx  x       x       x   x xxxxxx    x       x    x  x       x  x    x       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio() .or. Texto()'													, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'002'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'A1_ENDREC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'End.Recebto'															, ; //X3_TITULO
	'Dir.Cobro'																, ; //X3_TITSPA
	'Receiv.Addr.'															, ; //X3_TITENG
	'End.de Receb. do cliente'												, ; //X3_DESCRIC
	'Dir. de cobr. del cliente'												, ; //X3_DESCSPA
	'Custm.Receiv.Address'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xx  x       x       x   x xxxxxx    x       x    x  x       x  x    x       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio().Or.texto()'													, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'002'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'37'																	, ; //X3_ORDEM
	'A1_COMIS'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'% Comissao'															, ; //X3_TITULO
	'% Comision'															, ; //X3_TITSPA
	'Commission %'															, ; //X3_TITENG
	'Aliquota de Comissao'													, ; //X3_DESCRIC
	'Alicuota de Comision'													, ; //X3_DESCSPA
	'Commission Rate'														, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'006'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'45'																	, ; //X3_ORDEM
	'A1_TPFRET'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Frete'															, ; //X3_TITULO
	'Tipo Flete'															, ; //X3_TITSPA
	'Freight Type'															, ; //X3_TITENG
	'Tipo de Frete do cliente'												, ; //X3_DESCRIC
	'Tipo de Flete del cliente'												, ; //X3_DESCSPA
	'Freight Type'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx       x   x xxxxxx    x       x    x  x       x  x  xxx       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("CF")'														, ; //X3_VLDUSER
	'C=CIF;F=FOB'															, ; //X3_CBOX
	'C=CIF;F=FOB'															, ; //X3_CBOXSPA
	'C=CIF;F=FOB'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'008'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'47'																	, ; //X3_ORDEM
	'A1_DESC'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desconto'																, ; //X3_TITULO
	'Descuento'																, ; //X3_TITSPA
	'Discount'																, ; //X3_TITENG
	'Desconto ao cliente'													, ; //X3_DESCRIC
	'Descuento al Cliente'													, ; //X3_DESCSPA
	'Discount to Customer'													, ; //X3_DESCENG
	'99'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx   xxxxxxxxxxxxxxxx    x       x    x  x       x  x    x       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'006'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'48'																	, ; //X3_ORDEM
	'A1_PRIOR'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prioridade'															, ; //X3_TITULO
	'Prioridad'																, ; //X3_TITSPA
	'Priority'																, ; //X3_TITENG
	'Prioridade do cliente'													, ; //X3_DESCRIC
	'Prioridad del Cliente'													, ; //X3_DESCSPA
	'Customer Priority'														, ; //X3_DESCENG
	'9'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx       x   x xxxxxx    x       x    x  x       x  x    x       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'entre("1","5")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'006'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'49'																	, ; //X3_ORDEM
	'A1_RISCO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Risco'																	, ; //X3_TITULO
	'Riesgo'																, ; //X3_TITSPA
	'Risk'																	, ; //X3_TITENG
	'Grau de Risco do cliente'												, ; //X3_DESCRIC
	'Grado de Riesgo do client'												, ; //X3_DESCSPA
	'Customer Risk Level'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("ABCDE ")'													, ; //X3_VLDUSER
	'A=Risco A;B=Risco B;C=Risco C;D=Risco D;E=Risco E'						, ; //X3_CBOX
	'A=Riesgo A;B=Riesgo B;C=Riesgo C;D=Riesgo D;E=Riesgo E'				, ; //X3_CBOXSPA
	'A=Risk A;B=Risk B;C=Risk C;D=Risk D;E=Risk E'							, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'006'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'50'																	, ; //X3_ORDEM
	'A1_LC'																	, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Lim. Credito'															, ; //X3_TITULO
	'Lim. Credito'															, ; //X3_TITSPA
	'Credit Limit'															, ; //X3_TITENG
	'Limite de Cred.do cliente'												, ; //X3_DESCRIC
	'Lim. de Cred. del Cliente'												, ; //X3_DESCSPA
	'Customer Credit Limit'													, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'53'																	, ; //X3_ORDEM
	'A1_LCFIN'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Lim Cred Sec'															, ; //X3_TITULO
	'Lim Cred Sec'															, ; //X3_TITSPA
	'Sec.Cred.Lim'															, ; //X3_TITENG
	'Lim Credito Secundario'												, ; //X3_DESCRIC
	'Lim Credito Secundario'												, ; //X3_DESCSPA
	'Secondary Credit Limit'												, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'74'																	, ; //X3_ORDEM
	'A1_ATR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Atrasados'																, ; //X3_TITULO
	'Retrasos'																, ; //X3_TITSPA
	'Delayed'																, ; //X3_TITENG
	'Valor dos Atrasos'														, ; //X3_DESCRIC
	'Valor de los Retrasos'													, ; //X3_DESCSPA
	'Value of Delays'														, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx       x   x xxxxxx    x       x    x  x       x  x  xxx       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'003'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'77'																	, ; //X3_ORDEM
	'A1_TITPROT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tit.Protest.'															, ; //X3_TITULO
	'Tit.Protest.'															, ; //X3_TITSPA
	'Bill Protest'															, ; //X3_TITENG
	'Titulos Protestados'													, ; //X3_DESCRIC
	'Titulos Protestados'													, ; //X3_DESCSPA
	'Bills Protested'														, ; //X3_DESCENG
	'999'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx   xxxxxxxxxxxxxxxx    x       x    x  x       x  x  xxx       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'003'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'78'																	, ; //X3_ORDEM
	'A1_CHQDEVO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cheques Dev.'															, ; //X3_TITULO
	'Cheques Dev.'															, ; //X3_TITSPA
	'Ret. Checks'															, ; //X3_TITENG
	'Numero de Cheques Devolv.'												, ; //X3_DESCRIC
	'Nº de cheques devueltos'												, ; //X3_DESCSPA
	'Number of Returned Checks'												, ; //X3_DESCENG
	'999'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx   xxxxxxxxxxxxxxxx    x       x    x  x       x  x  xxx       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'003'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'84'																	, ; //X3_ORDEM
	'A1_INCISS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ISS no Preco'															, ; //X3_TITULO
	'Imp.Servicio'															, ; //X3_TITSPA
	'ISS Included'															, ; //X3_TITENG
	'ISS incluso no preço'													, ; //X3_DESCRIC
	'Imp.Servicio en el Precio'												, ; //X3_DESCSPA
	'Price including ISS'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx       x   x xxxxxx    x       x    x  x       x     xxx       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("SN")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	'S=Si;N=No'																, ; //X3_CBOXSPA
	'S=Yes;N=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'005'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'92'																	, ; //X3_ORDEM
	'A1_ALIQIR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. IRRF'															, ; //X3_TITULO
	'Alic. IRRF'															, ; //X3_TITSPA
	'IRRF TaxRate'															, ; //X3_TITENG
	'Aliquota IRRF'															, ; //X3_DESCRIC
	'Alicuota Imp. Ganancias'												, ; //X3_DESCSPA
	'IRRF Tax Rate'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'0'																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Entre(0,99.99)'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'005'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'97'																	, ; //X3_ORDEM
	'A1_CALCSUF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.p/Sufr.'															, ; //X3_TITULO
	'Desc.p/Sufr.'															, ; //X3_TITSPA
	'Disc Sufr.'															, ; //X3_TITENG
	'Calcula Desc. p/ Suframa'												, ; //X3_DESCRIC
	'Calcula Desc. p/ Suframa'												, ; //X3_DESCSPA
	'Calculate Disc. Suframa'												, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'xxxxxxxxxxxxxxxxxxx xxxxxxxxxx xx   xxxxxxxxxxxxxxxx    x       x    x  x       x     xxx       x x     x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("SNI")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao;I=ICMS'													, ; //X3_CBOX
	'S=Si;N=No;I=ICMS'														, ; //X3_CBOXSPA
	'S=Yes;N=No;I=ICMS'														, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'005'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'I0'																	, ; //X3_ORDEM
	'A1_TIPOCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Cliente'															, ; //X3_TITULO
	'Tipo Cliente'															, ; //X3_TITSPA
	'CustomerType'															, ; //X3_TITENG
	'Tipo do Cliente'														, ; //X3_DESCRIC
	'Tipo de Cliente'														, ; //X3_DESCSPA
	'Customer Type'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	' FG_STRZERO("M->A1_TIPOCLI",2).and. naovazio() .and. EXISTCPO("SX5","TC"+M->A1_TIPOCLI)', ; //X3_VALID
	'x       x   x  xx       x       x       x     x x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'TC'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'FG_STRZERO("M->A1_TIPOCLI",2) .AND. naovazio() .and. EXISTCPO("SX5","TC"+M->A1_TIPOCLI)', ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	'008'																	, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'PA'																	, ; //X3_ORDEM
	'A1_XEANPAO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	13																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'EAN Pao Acuc'															, ; //X3_TITULO
	'EAN Pao Acuc'															, ; //X3_TITSPA
	'EAN Pao Acuc'															, ; //X3_TITENG
	'EAN Pao Acucar'														, ; //X3_DESCRIC
	'EAN Pao Acucar'														, ; //X3_DESCSPA
	'EAN Pao Acucar'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'PB'																	, ; //X3_ORDEM
	'A1_XROTA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Rota Entrega'															, ; //X3_TITULO
	'Rota Entrega'															, ; //X3_TITSPA
	'Rota Entrega'															, ; //X3_TITENG
	'Rota Entrega'															, ; //X3_DESCRIC
	'Rota Entrega'															, ; //X3_DESCSPA
	'Rota Entrega'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ROTAS'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'vazio().or.existcpo("SZR",M->A1_XROTA)'								, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SA1'																	, ; //X3_ARQUIVO
	'PC'																	, ; //X3_ORDEM
	'A1_XDESC'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Desconto M'															, ; //X3_TITULO
	'Desconto M'															, ; //X3_TITSPA
	'Desconto M'															, ; //X3_TITENG
	'Percentual de Desconto Ma'												, ; //X3_DESCRIC
	'Percentual de Desconto Ma'												, ; //X3_DESCSPA
	'Percentual de Desconto Ma'												, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'4'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'B1_XSIGLA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sigla Prod.'															, ; //X3_TITULO
	'Sigla Prod.'															, ; //X3_TITSPA
	'Sigla Prod.'															, ; //X3_TITENG
	'Sigla Produto Cod Intelig'												, ; //X3_DESCRIC
	'Sigla Produto Cod Intelig'												, ; //X3_DESCSPA
	'Sigla Produto Cod Intelig'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'len( alltrim( M->B1_XSIGLA ) ) == 2'									, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'B1_XSTATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status Cod Inteligente'												, ; //X3_DESCRIC
	'Status Cod Inteligente'												, ; //X3_DESCSPA
	'Status Cod Inteligente'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Natura Nac;2=Higienizado;3=Natura Imp;4=Manuseado'					, ; //X3_CBOX
	'1=Natura Nac;2=Higienizado;3=Natura Imp;4=Manuseado'					, ; //X3_CBOXSPA
	'1=Natura Nac;2=Higienizado;3=Natura Imp;4=Manuseado'					, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'B1_XAPRES'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Apresentacao'															, ; //X3_TITULO
	'Apresentacao'															, ; //X3_TITSPA
	'Apresentacao'															, ; //X3_TITENG
	'Apresentacao Cod Intelig'												, ; //X3_DESCRIC
	'Apresentacao Cod Intelig'												, ; //X3_DESCSPA
	'Apresentacao Cod Intelig'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'B1_XCODINT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Interno'															, ; //X3_TITULO
	'Cod Interno'															, ; //X3_TITSPA
	'Cod Interno'															, ; //X3_TITENG
	'Codigo Interno (antigo)'												, ; //X3_DESCRIC
	'Codigo Interno (antigo)'												, ; //X3_DESCSPA
	'Codigo Interno (antigo)'												, ; //X3_DESCENG
	'9999'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'LEN( ALLTRIM( M->B1_XCODINT ) ) == 4'									, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'B1_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descripcion'															, ; //X3_TITSPA
	'Description'															, ; //X3_TITENG
	'Descricao do Produto'													, ; //X3_DESCRIC
	'Descripcion del Producto'												, ; //X3_DESCSPA
	'Description of Product'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xxx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'texto()'																, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'S'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'B1_IPI'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. IPI'																, ; //X3_TITULO
	'Alic. IPI'																, ; //X3_TITSPA
	'IPI Tax Rate'															, ; //X3_TITENG
	'Alíquota de IPI'														, ; //X3_DESCRIC
	'Alicuota de IPI'														, ; //X3_DESCSPA
	'IPI Tax Rate'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x xxxx  xxxxxxxxx       x      xx       x   x xxxxxx    x       x       x       x  x    x       x       x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'   xxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'B1_CODISS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Serv.ISS'															, ; //X3_TITULO
	'Cod.Serv.ISS'															, ; //X3_TITSPA
	'ISS Sev.Cd.'															, ; //X3_TITENG
	'Código de Serviço do ISS'												, ; //X3_DESCRIC
	'Codigo de Servicio de ISS'												, ; //X3_DESCSPA
	'ISS Service Code'														, ; //X3_DESCENG
	'@9'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x xxxx  xxxx xxxx       x x    xx       x   x xxxxxx    x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'60'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x  x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'vazio() .or. existcpo("SX5","60"+M->B1_CODISS)'						, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'023'																	, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'B1_PICMRET'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Solid. Saida'															, ; //X3_TITULO
	'Solid.Salida'															, ; //X3_TITSPA
	'Solid. Outfl'															, ; //X3_TITENG
	'% Lucro Calc. Solid.Saida'												, ; //X3_DESCRIC
	'%Ganc.Calc. Solid.Salida'												, ; //X3_DESCSPA
	'Solid. Outf. Prof.Calc. %'												, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'B1_PICMENT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Solid. Entr.'															, ; //X3_TITULO
	'Solid.Entrad'															, ; //X3_TITSPA
	'Solid. Infl.'															, ; //X3_TITENG
	'% Lucro Calc. Solid.Entr.'												, ; //X3_DESCRIC
	'%Ganc.Calc. Solid.Entrada'												, ; //X3_DESCSPA
	'Solid. Infl. Prof. Cal. %'												, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'29'																	, ; //X3_ORDEM
	'B1_CONV'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	7																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Fator Conv.'															, ; //X3_TITULO
	'Factor Conv.'															, ; //X3_TITSPA
	'Conv. Factor'															, ; //X3_TITENG
	'Fator de Conversao de UM'												, ; //X3_DESCRIC
	'Factor Conversion de UM'												, ; //X3_DESCSPA
	'Convers.Factor Un.Measure'												, ; //X3_DESCENG
	'@E 9,999.99'															, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'32'																	, ; //X3_ORDEM
	'B1_QE'																	, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Qtd.Embalag.'															, ; //X3_TITULO
	'Ctd.Embalaje'															, ; //X3_TITSPA
	'Qty.Package'															, ; //X3_TITENG
	'Qtde por Embalagem'													, ; //X3_DESCRIC
	'Cantidad por Embalaje'													, ; //X3_DESCSPA
	'Quantity per Package'													, ; //X3_DESCENG
	'@E 999,999,999'														, ; //X3_PICTURE
	'A010Mult()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'33'																	, ; //X3_ORDEM
	'B1_PRV1'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Preco Venda'															, ; //X3_TITULO
	'Precio Venta'															, ; //X3_TITSPA
	'Sales Price'															, ; //X3_TITENG
	'Preco de Venda'														, ; //X3_DESCRIC
	'Precio de Venta'														, ; //X3_DESCSPA
	'Sales Price'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'A010Preco()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'34'																	, ; //X3_ORDEM
	'B1_EMIN'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Ponto Pedido'															, ; //X3_TITULO
	'Punto Pedido'															, ; //X3_TITSPA
	'Order Point'															, ; //X3_TITENG
	'Ponto de Pedido'														, ; //X3_DESCRIC
	'Punto de Pedido'														, ; //X3_DESCSPA
	'Order Point'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'42'																	, ; //X3_ORDEM
	'B1_ESTSEG'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Seguranca'																, ; //X3_TITULO
	'Seguridad'																, ; //X3_TITSPA
	'Safety Inv.'															, ; //X3_TITENG
	'Estoque de Seguranca'													, ; //X3_DESCRIC
	'Stock de Seguridad'													, ; //X3_DESCSPA
	'Security Inventory'													, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'44'																	, ; //X3_ORDEM
	'B1_PE'																	, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Entrega'																, ; //X3_TITULO
	'Entrega'																, ; //X3_TITSPA
	'Deliv.Term'															, ; //X3_TITENG
	'Prazo de Entrega'														, ; //X3_DESCRIC
	'Plazo de Entrega'														, ; //X3_DESCSPA
	'Delivery Term'															, ; //X3_DESCENG
	'@E 99999'																, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'45'																	, ; //X3_ORDEM
	'B1_TIPE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Prazo'															, ; //X3_TITULO
	'Tipo Plazo'															, ; //X3_TITSPA
	'Type of Term'															, ; //X3_TITENG
	'Tipo Prazo entrega(D/M/A)'												, ; //X3_DESCRIC
	'Tipo Plazo Entrega(D/M/A)'												, ; //X3_DESCSPA
	'Type of Deliv.Term(D/M/Y)'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("HDSMA")'														, ; //X3_VLDUSER
	'H=Horas;D=Dias;S=Semana;M=Mes;A=Ano'									, ; //X3_CBOX
	'H=Horas;D=Dias;S=Semana;M=Mes;A=A±o'									, ; //X3_CBOXSPA
	'H=Hours;D=Days;S=Week;M=Month;A=Year'									, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'46'																	, ; //X3_ORDEM
	'B1_LE'																	, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Lote Econom.'															, ; //X3_TITULO
	'Lote Econom.'															, ; //X3_TITSPA
	'Economic Lot'															, ; //X3_TITENG
	'Lote Economico'														, ; //X3_DESCRIC
	'Lote Economico'														, ; //X3_DESCSPA
	'Economic Lot'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'A010Mult()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'47'																	, ; //X3_ORDEM
	'B1_LM'																	, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Lote Minimo'															, ; //X3_TITULO
	'Lote Minimo'															, ; //X3_TITSPA
	'Minimum Lot'															, ; //X3_TITENG
	'Lote Minimo'															, ; //X3_DESCRIC
	'Lote Minimo'															, ; //X3_DESCSPA
	'Minimum Lot'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'56'																	, ; //X3_ORDEM
	'B1_APROPRI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Apropriacao'															, ; //X3_TITULO
	'Asignación'															, ; //X3_TITSPA
	'Appropriat.'															, ; //X3_TITENG
	'Apropr.Direta ou Indireta'												, ; //X3_DESCRIC
	'Asigna. Directa o Indirec'												, ; //X3_DESCSPA
	'Dir./Indir. Appropriation'												, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("DI ")'														, ; //X3_VLDUSER
	'D=Direto;I=Indireto'													, ; //X3_CBOX
	'D=Directo;I=Indirecto'													, ; //X3_CBOXSPA
	'D=Direct;I=Indirect'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'62'																	, ; //X3_ORDEM
	'B1_FANTASM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fantasma'																, ; //X3_TITULO
	'Fantasma'																, ; //X3_TITSPA
	'Phantom'																, ; //X3_TITENG
	"Informa 'S' se e' fantasm"												, ; //X3_DESCRIC
	"Informe 'S'si es Fantasma"												, ; //X3_DESCSPA
	"Type 'S' if it's Phantom"												, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("SN ")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	'S=Sí;N=No'																, ; //X3_CBOXSPA
	'Y=Yes;N=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'65'																	, ; //X3_ORDEM
	'B1_FORAEST'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fora estado'															, ; //X3_TITULO
	'Fuera E/P/R'															, ; //X3_TITSPA
	'Out state'																, ; //X3_TITENG
	'S-se comprado fora estado'												, ; //X3_DESCRIC
	'S-compra fuera del E/P/R'												, ; //X3_DESCSPA
	'S-if bought out state'													, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x xxxx  xxxxxxxxx       x      xx       x   x xxxxxx    x       x       x       x       x       x       x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("SN")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	'S=Sí;N=No'																, ; //X3_CBOXSPA
	'Y=Yes;N=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'71'																	, ; //X3_ORDEM
	'B1_CONTSOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cont.Seg.Soc'															, ; //X3_TITULO
	'Cont.Seg.Soc'															, ; //X3_TITSPA
	'Soc.Sec.Cont'															, ; //X3_TITENG
	'Incide Contr.Seg.Social'												, ; //X3_DESCRIC
	'Incide Contr.Seg.Social'												, ; //X3_DESCSPA
	'Incise Social Sec. Contr.'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x    x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence("SN")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	'S=Si;N=No'																, ; //X3_CBOXSPA
	'S=Yes;N=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'72'																	, ; //X3_ORDEM
	'B1_MRP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Entra MRP'																, ; //X3_TITULO
	'Entra MRP'																, ; //X3_TITSPA
	'Enter MRP'																, ; //X3_TITENG
	'Entra no Mrp?'															, ; //X3_DESCRIC
	'¿Entra en el Mrp?'														, ; //X3_DESCSPA
	'Enters in MRP?'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"S"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence(" SNE")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao;E=Especial'												, ; //X3_CBOX
	'S=Sí;N=No;E=Especial'													, ; //X3_CBOXSPA
	'S=Yes;N=No;E=Special'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'3'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'74'																	, ; //X3_ORDEM
	'B1_XCODDUN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. DUN'																, ; //X3_TITULO
	'Cod. DUN'																, ; //X3_TITSPA
	'Cod. DUN'																, ; //X3_TITENG
	'Cod. Barras DUN'														, ; //X3_DESCRIC
	'Cod. Barras DUN'														, ; //X3_DESCSPA
	'Cod. Barras DUN'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'1'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'85'																	, ; //X3_ORDEM
	'B1_IRRF'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Impos.Renda'															, ; //X3_TITULO
	'Imp.Ganancia'															, ; //X3_TITSPA
	'Income Tax'															, ; //X3_TITENG
	'Incide imposto renda'													, ; //X3_DESCRIC
	'Incide Imp. a las Gananc.'												, ; //X3_DESCSPA
	'Income Tax Incidence'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x xxxx  xxxxxxxxx       x      xx       x   x xxxxxx    x       x       x       x       x       x       x     xxx', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence("SN")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	'S=Si;N=No'																, ; //X3_CBOXSPA
	'S=Yes;N=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'A0'																	, ; //X3_ORDEM
	'B1_PCSLL'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Perc. CSLL'															, ; //X3_TITULO
	'Pord. CSLL'															, ; //X3_TITSPA
	'CSLL %'																, ; //X3_TITENG
	'Percentual CSLL'														, ; //X3_DESCRIC
	'Porcentaje CSLL'														, ; //X3_DESCSPA
	'CSLL Percentage'														, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'A1'																	, ; //X3_ORDEM
	'B1_PCOFINS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Perc. COFINS'															, ; //X3_TITULO
	'Porc. COFINS'															, ; //X3_TITSPA
	'COFINS %'																, ; //X3_TITENG
	'Percentual COFINS'														, ; //X3_DESCRIC
	'Porcentaje COFINS'														, ; //X3_DESCSPA
	'COFFINS Percentage'													, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'A2'																	, ; //X3_ORDEM
	'B1_PPIS'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Perc. PIS'																, ; //X3_TITULO
	'Porc. PIS'																, ; //X3_TITSPA
	'PIS %'																	, ; //X3_TITENG
	'Percentual PIS'														, ; //X3_DESCRIC
	'Porcentaje PIS'														, ; //X3_DESCSPA
	'PIS Percentage'														, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'AN'																	, ; //X3_ORDEM
	'B1_PESBRU'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Peso Bruto'															, ; //X3_TITULO
	'Peso Bruto'															, ; //X3_TITSPA
	'Gross Weight'															, ; //X3_TITENG
	'Peso Bruto'															, ; //X3_DESCRIC
	'Peso Bruto'															, ; //X3_DESCSPA
	'Gross Weight'															, ; //X3_DESCENG
	'@E 999,999.9999'														, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'CF'																	, ; //X3_ORDEM
	'B1_CRDEST'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Crd Estímulo'															, ; //X3_TITULO
	'Crd Estímulo'															, ; //X3_TITSPA
	'Crd Incentiv'															, ; //X3_TITENG
	'Crédito Estímulo'														, ; //X3_DESCRIC
	'Crédito Estímulo'														, ; //X3_DESCSPA
	'Credit Incentive'														, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'Positivo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'x   xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	'2'																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'EQ'																	, ; //X3_ORDEM
	'B1_XQE'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd Embalage'															, ; //X3_TITULO
	'Qtd Embalage'															, ; //X3_TITSPA
	'Qtd Embalage'															, ; //X3_TITENG
	'Qtd Embalagem'															, ; //X3_DESCRIC
	'Qtd Embalagem'															, ; //X3_DESCSPA
	'Qtd Embalagem'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'S9'																	, ; //X3_ORDEM
	'B1_XEMB'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Embalagem'																, ; //X3_TITULO
	'Embalagem'																, ; //X3_TITSPA
	'Embalagem'																, ; //X3_TITENG
	'Embalagem Retornavel'													, ; //X3_DESCRIC
	'Embalagem Retornavel'													, ; //X3_DESCSPA
	'Embalagem Retornavel'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SZE'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'vazio().or.existcpo("SZE", M->B1_XEMB )'								, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC5
//
aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'C5_XNOMCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Cliente'															, ; //X3_TITULO
	'Nome Cliente'															, ; //X3_TITSPA
	'Nome Cliente'															, ; //X3_TITENG
	'Nome Fantasia Cliente'													, ; //X3_DESCRIC
	'Nome Fantasia Cliente'													, ; //X3_DESCSPA
	'Nome Fantasia Cliente'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'U_BROWSE()'															, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'C5_XREPOSI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Reposicao?'															, ; //X3_TITULO
	'Reposicao?'															, ; //X3_TITSPA
	'Reposicao?'															, ; //X3_TITENG
	'Pedido de Reposicao?'													, ; //X3_DESCRIC
	'Pedido de Reposicao?'													, ; //X3_DESCSPA
	'Pedido de Reposicao?'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	'"2"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio()'																, ; //X3_VLDUSER
	'1=Sim;2=Não'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'C5_XDTREPO'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Reposicao'															, ; //X3_TITULO
	'Dt Reposicao'															, ; //X3_TITSPA
	'Dt Reposicao'															, ; //X3_TITENG
	'Dt Reposicao'															, ; //X3_DESCRIC
	'Dt Reposicao'															, ; //X3_DESCSPA
	'Dt Reposicao'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'C5_TIPOCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Cliente'															, ; //X3_TITULO
	'Tipo Cliente'															, ; //X3_TITSPA
	'Customer Ty.'															, ; //X3_TITENG
	'Tipo do Cliente'														, ; //X3_DESCRIC
	'Tipo de Cliente'														, ; //X3_DESCSPA
	'Type of Customer'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("FLRSX")'														, ; //X3_VLDUSER
	'F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacao/Importacao', ; //X3_CBOX
	'F=Cons.Final;L=Prod.Rural;R=Revendedor;S=Solidario;X=Exportacion/Importacion', ; //X3_CBOXSPA
	'F=Final Cons.;L=Rural Prod.;R=Reseller;S=Solidary;X=Export/Import'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'42'																	, ; //X3_ORDEM
	'C5_TPFRETE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Frete'															, ; //X3_TITULO
	'Tipo Flete'															, ; //X3_TITSPA
	'Tipo Freight'															, ; //X3_TITENG
	'Tipo do Frete Utilizado'												, ; //X3_DESCRIC
	'Tipo del flete utilizado'												, ; //X3_DESCSPA
	'Tp of Used Freight'													, ; //X3_DESCENG
	'X'																		, ; //X3_PICTURE
	'pertence("CFTRDS")'													, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("CFTRDS")'													, ; //X3_VLDUSER
	'C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete', ; //X3_CBOX
	'C=CIF;F=FOB;T=Por cuenta terceros;R=Por cuenta remitente;D=Por cuenta destinatario;S=Sin flete', ; //X3_CBOXSPA
	'C=CIF;F=FOB;T=By third pary;R=By sender account;D=By recipient account;S=No Freight', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'61'																	, ; //X3_ORDEM
	'C5_INCISS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ISS Incluso'															, ; //X3_TITULO
	'Incl. ISS'																, ; //X3_TITSPA
	'ISS Included'															, ; //X3_TITENG
	'ISS incluso no Preço'													, ; //X3_DESCRIC
	'ISS Incluido en Precio'												, ; //X3_DESCSPA
	'Price including ISS'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x    x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence("SN")'														, ; //X3_VLDUSER
	'S=Sim;N=Nao'															, ; //X3_CBOX
	'S=Si;N=No'																, ; //X3_CBOXSPA
	'S=Yes;N=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'62'																	, ; //X3_ORDEM
	'C5_LIBEROK'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Liber. Total'															, ; //X3_TITULO
	'Liber. Total'															, ; //X3_TITSPA
	'Total Releas'															, ; //X3_TITENG
	'Pedido Liberado Total'													, ; //X3_DESCRIC
	'Pedido Liberado Total'													, ; //X3_DESCSPA
	'Total Released Order'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x    x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'pertence("S ")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'97'																	, ; //X3_ORDEM
	'C5_RECFAUT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pag.Fret.Aut'															, ; //X3_TITULO
	'Pag.Flet.Aut'															, ; //X3_TITSPA
	'Free Freight'															, ; //X3_TITENG
	'Pagto do frete autonomo'												, ; //X3_DESCRIC
	'Pago del flete autónomo'												, ; //X3_DESCSPA
	'Pagto do Indep Freight'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Pertence("12") .And. MaFisGet("NF_RECFAUT")'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'MaFisGet("NF_RECFAUT")'												, ; //X3_VLDUSER
	'1=Emitente;2=Transportador'											, ; //X3_CBOX
	'1=Emisor;2=Transportador'												, ; //X3_CBOXSPA
	'1=Issuer;2=Carrier'													, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'9Q'																	, ; //X3_ORDEM
	'C5_XPEDCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ped. Cliente'															, ; //X3_TITULO
	'Ped. Cliente'															, ; //X3_TITSPA
	'Ped. Cliente'															, ; //X3_TITENG
	'Pedido do Cliente'														, ; //X3_DESCRIC
	'Pedido do Cliente'														, ; //X3_DESCSPA
	'Pedido do Cliente'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC5'																	, ; //X3_ARQUIVO
	'9W'																	, ; //X3_ORDEM
	'C5_XROTA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Rota Entrega'															, ; //X3_TITULO
	'Rota Entrega'															, ; //X3_TITSPA
	'Rota Entrega'															, ; //X3_TITENG
	'Rota Entrega'															, ; //X3_DESCRIC
	'Rota Entrega'															, ; //X3_DESCSPA
	'Rota Entrega'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'ROTAS'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'vazio().or.existcpo("SZR",M->C5_XROTA)'								, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC6
//
aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'C6_DESCRI'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descripcion'															, ; //X3_TITSPA
	'Description'															, ; //X3_TITENG
	'Descricao Auxiliar'													, ; //X3_DESCRIC
	'Descripcion Auxiliar'													, ; //X3_DESCSPA
	'Support Description'													, ; //X3_DESCENG
	'@X'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x  x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Texto()'																, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'C6_QTDVEN'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Cantidad'																, ; //X3_TITSPA
	'Quantity'																, ; //X3_TITENG
	'Quantidade Vendida'													, ; //X3_DESCRIC
	'Cantidad vendida'														, ; //X3_DESCSPA
	'Sold Quantity'															, ; //X3_DESCENG
	'@E 999999.99'															, ; //X3_PICTURE
	'A410QTDGRA() .AND. A410SegUm().and.A410MultT().and.a410Refr("C6_QTDVEN")'	, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'C6_PRCVEN'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Prc Unitario'															, ; //X3_TITULO
	'Prc Unitario'															, ; //X3_TITSPA
	'Unitary Pric'															, ; //X3_TITENG
	'Preco Unitario Liquido'												, ; //X3_DESCRIC
	'Precio unitario neto'													, ; //X3_DESCSPA
	'Net Unitary Price'														, ; //X3_DESCENG
	'@E 99,999,999.99'														, ; //X3_PICTURE
	'A410QtdGra() .And. A410MultT() .And. A410Zera() .And. MTA410TROP(n)'		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'C6_VALOR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Total'																, ; //X3_TITULO
	'Vlr.Total'																, ; //X3_TITSPA
	'Total Vl'																, ; //X3_TITENG
	'Valor Total do Item'													, ; //X3_DESCRIC
	'Valor total del ítem'													, ; //X3_DESCSPA
	'Item Total Value'														, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'A410MultT()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'C6_QTDLIB'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd.Liberada'															, ; //X3_TITULO
	'Ctd Aprobada'															, ; //X3_TITSPA
	'Amt Approved'															, ; //X3_TITENG
	'Quantidade Liberada'													, ; //X3_DESCRIC
	'Cantidad Aprobada'														, ; //X3_DESCSPA
	'Amount Approved'														, ; //X3_DESCENG
	'@E 999999.99'															, ; //X3_PICTURE
	'A410QTDGRA() .AND. A440Qtdl() .and. a410MultT().and.a410Refr("C6_QTDLIB")'	, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xxxx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'C6_QTDLIB2'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd.Lib 2aUM'															, ; //X3_TITULO
	'Ctd.Lib 2aUM'															, ; //X3_TITSPA
	'Qt.Rls.2UoM'															, ; //X3_TITENG
	'Quantidade Liberada 2a UM'												, ; //X3_DESCRIC
	'Cantidad Aprobada 2a UM'												, ; //X3_DESCSPA
	'Quantity Released 2nd UOM'												, ; //X3_DESCENG
	'@E 999999.99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'39'																	, ; //X3_ORDEM
	'C6_OP'																	, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'OP Gerada'																, ; //X3_TITULO
	'OP Generada'															, ; //X3_TITSPA
	'Prod.Or.Gen.'															, ; //X3_TITENG
	'Flag de geracao de OP'													, ; //X3_DESCRIC
	'Flag de Generacion de OP'												, ; //X3_DESCSPA
	'Flag of Production Order'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence("S ")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'A1'																	, ; //X3_ORDEM
	'C6_CODROM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Romaneio'															, ; //X3_TITULO
	'Cod List Emb'															, ; //X3_TITSPA
	'Pack List Cd'															, ; //X3_TITENG
	'Codigo do Romaneio'													, ; //X3_DESCRIC
	'Cod de Lista de Embarque'												, ; //X3_DESCSPA
	'Packing List Code'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	''																		, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("NPR")'											, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'B8'																	, ; //X3_ORDEM
	'C6_CCUSTO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'C. de Custo'															, ; //X3_TITULO
	'C. de Costo'															, ; //X3_TITSPA
	'Cost Center'															, ; //X3_TITENG
	'Centro de Custo'														, ; //X3_DESCRIC
	'Centro de Costo'														, ; //X3_DESCSPA
	'Cost Center'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTT'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'    x'																	, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Vazio() .Or. ExistCpo("CTT")'											, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'004'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC6'																	, ; //X3_ARQUIVO
	'GA'																	, ; //X3_ORDEM
	'C6_XQTDORI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd.Original'															, ; //X3_TITULO
	'Qtd.Original'															, ; //X3_TITSPA
	'Qtd.Original'															, ; //X3_TITENG
	'Qtd.Original'															, ; //X3_DESCRIC
	'Qtd.Original'															, ; //X3_DESCSPA
	'Qtd.Original'															, ; //X3_DESCENG
	'@E 999,999.99'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SC7
//
aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'C7_DESCRI'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descripcion'															, ; //X3_TITSPA
	'Description'															, ; //X3_TITENG
	'Descricao do Produto'													, ; //X3_DESCRIC
	'Descripcion del Producto'												, ; //X3_DESCSPA
	'Description of Product'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x  x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'texto()'																, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'C7_IPI'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. IPI'																, ; //X3_TITULO
	'Alic. IPI'																, ; //X3_TITSPA
	'IPI Tx Rate'															, ; //X3_TITENG
	'Alíquota de IPI'														, ; //X3_DESCRIC
	'Alicuota de IPI'														, ; //X3_DESCSPA
	'IPI Tax Rate'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIPI","MT120",M->C7_IPI)'								, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'33'																	, ; //X3_ORDEM
	'C7_DESC1'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Desconto 1'															, ; //X3_TITULO
	'Descuento 1'															, ; //X3_TITSPA
	'Discount 1'															, ; //X3_TITENG
	'Desconto 1 em cascata'													, ; //X3_DESCRIC
	'Descuento 1 en Cascada'												, ; //X3_DESCSPA
	'Discount 1 in Cascade'													, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'C7_DESC2'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Desconto 2'															, ; //X3_TITULO
	'Descuento 2'															, ; //X3_TITSPA
	'Discount 2'															, ; //X3_TITENG
	'Desconto 2 em cascata'													, ; //X3_DESCRIC
	'Descuento 2 en Cascada'												, ; //X3_DESCSPA
	'Discount 2 in Cascade'													, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'37'																	, ; //X3_ORDEM
	'C7_DESC3'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Desconto 3'															, ; //X3_TITULO
	'Descuento 3'															, ; //X3_TITSPA
	'Discount 3'															, ; //X3_TITENG
	'Desconto 3 em cascata'													, ; //X3_DESCRIC
	'Descuento 3 en Cascada'												, ; //X3_DESCSPA
	'Discount 3 in Cascade'													, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'86'																	, ; //X3_ORDEM
	'C7_ICMCOMP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'ICMS Compl.'															, ; //X3_TITULO
	'ICMS Compl.'															, ; //X3_TITSPA
	'Comp. ICMS'															, ; //X3_TITENG
	'Valor Icms Complementar'												, ; //X3_DESCRIC
	'Valor ICMS Complementario'												, ; //X3_DESCSPA
	'ICMS Compl. Value'														, ; //X3_DESCENG
	'@e 999,999,999.99'														, ; //X3_PICTURE
	'MAFISREF("IT_VALCMP","MT120",M->C7_ICMCOMP)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'88'																	, ; //X3_ORDEM
	'C7_ICMSRET'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'ICMS Retido'															, ; //X3_TITULO
	'ICMS Retenid'															, ; //X3_TITSPA
	'With. ICMS'															, ; //X3_TITENG
	'Valor do ICMS Solidario'												, ; //X3_DESCRIC
	'Valor del ICMS Solidario'												, ; //X3_DESCSPA
	'Solidary ICMS Value'													, ; //X3_DESCENG
	'@e 999,999,999.99'														, ; //X3_PICTURE
	'MAFISREF("IT_VALSOL","MT120",M->C7_ICMSRET)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

//
// Campos Tabela SC9
//
aAdd( aSX3, { ;
	'SC9'																	, ; //X3_ARQUIVO
	'67'																	, ; //X3_ORDEM
	'C9_XNOMCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Cliente'															, ; //X3_TITULO
	'Nome Cliente'															, ; //X3_TITSPA
	'Nome Cliente'															, ; //X3_TITENG
	'Nome Fantasia Cliente'													, ; //X3_DESCRIC
	'Nome Fantasia Cliente'													, ; //X3_DESCSPA
	'Nome Fantasia Cliente'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'U_BROWSE()'															, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SD1
//
aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'D1_TOTAL'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Total'																, ; //X3_TITULO
	'Valor Total'															, ; //X3_TITSPA
	'Grand Total'															, ; //X3_TITENG
	'Valor Total'															, ; //X3_DESCRIC
	'Valor Total'															, ; //X3_DESCSPA
	'Grand Total'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'A103Total(M->D1_TOTAL) .and. MaFisRef("IT_VALMERC","MT100",M->D1_TOTAL) .And. MTA103TROP(n)', ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'D1_VALIPI'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.IPI'																, ; //X3_TITULO
	'Vlr. IPI'																, ; //X3_TITSPA
	'IPI Value'																, ; //X3_TITENG
	'Valor do IPI do Item'													, ; //X3_DESCRIC
	'Valor del IPI del Item'												, ; //X3_DESCSPA
	'Item IPI Value'														, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_VALIPI","MT100",M->D1_VALIPI)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'D1_VALICM'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.ICMS'																, ; //X3_TITULO
	'Vlr. ICMS'																, ; //X3_TITSPA
	'ICMS Vl.'																, ; //X3_TITENG
	'Valor do ICM do Item'													, ; //X3_DESCRIC
	'Valor del ICMS del Item'												, ; //X3_DESCSPA
	'Item ICM Value'														, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_VALICM","MT100",M->D1_VALICM)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'D1_XDESCR'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	60																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao do Produto'													, ; //X3_DESCRIC
	'Descricao do Produto'													, ; //X3_DESCSPA
	'Descricao do Produto'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'D1_DESC'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Desc.Item'																, ; //X3_TITULO
	'Dsct.Item'																, ; //X3_TITSPA
	'Item Disc.'															, ; //X3_TITENG
	'Desconto no Item'														, ; //X3_DESCRIC
	'Descuento en el Item'													, ; //X3_DESCSPA
	'Discount in Item'														, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'A103VLDDSC()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'D1_IPI'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. IPI'																, ; //X3_TITULO
	'Alic. IPI'																, ; //X3_TITSPA
	'IPI Tax Rate'															, ; //X3_TITENG
	'Alíquota de IPI'														, ; //X3_DESCRIC
	'Alicuota de IPI'														, ; //X3_DESCSPA
	'IPI Tax Rate'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIPI","MT100",M->D1_IPI)'								, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx xx'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'D1_PESO'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	3																		, ; //X3_DECIMAL
	'Peso total'															, ; //X3_TITULO
	'Peso total'															, ; //X3_TITSPA
	'Total Influ.'															, ; //X3_TITENG
	'Peso do produto rateio'												, ; //X3_DESCRIC
	'Peso Producto Prorrateo'												, ; //X3_DESCSPA
	'Apport. Product Influence'												, ; //X3_DESCENG
	'@E 999999.999'															, ; //X3_PICTURE
	'MaFisRef("IT_PESO","MT100",M->D1_PESO)'								, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'50'																	, ; //X3_ORDEM
	'D1_ICMSRET'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'ICMS Solid.'															, ; //X3_TITULO
	'ICMS Solid.'															, ; //X3_TITSPA
	'ICMS Solid.'															, ; //X3_TITENG
	'Valor do ICMS Solidario'												, ; //X3_DESCRIC
	'Valor del ICMS Solidario'												, ; //X3_DESCSPA
	'Value of ICMS Solidario'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALSOL","MT100",M->D1_ICMSRET)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'54'																	, ; //X3_ORDEM
	'D1_BASEICM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Icms'																, ; //X3_TITULO
	'Base Icms'																, ; //X3_TITSPA
	'ICMS Base'																, ; //X3_TITENG
	'Valor Base do Icms'													, ; //X3_DESCRIC
	'Valor Base del Icms'													, ; //X3_DESCSPA
	'ICMS Base Value'														, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEICM","MT100",M->D1_BASEICM)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'56'																	, ; //X3_ORDEM
	'D1_VALDESC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Desconto'																, ; //X3_TITULO
	'Descuento'																, ; //X3_TITSPA
	'Discount'																, ; //X3_TITENG
	'Valor do Desconto no Item'												, ; //X3_DESCRIC
	'Valor del Descuento Item'												, ; //X3_DESCSPA
	'Item Discount Value'													, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_DESCONTO","MT100",M->D1_VALDESC)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'A103VLDDSC()'															, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'57'																	, ; //X3_ORDEM
	'D1_SKIPLOT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Skip Lote'																, ; //X3_TITULO
	'Skip-Lote'																, ; //X3_TITSPA
	'Skip-Lot'																, ; //X3_TITENG
	'Controle do Skip Lote'													, ; //X3_DESCRIC
	'Control de Seleccion-Lote'												, ; //X3_DESCSPA
	'Skip-Lot Control'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  x    x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Pertence("SN")'														, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'60'																	, ; //X3_ORDEM
	'D1_BASEIPI'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Base IPI'															, ; //X3_TITULO
	'Vlr.Base IPI'															, ; //X3_TITSPA
	'IPI Basis Vl'															, ; //X3_TITENG
	'Valor Base de Calc. IPI'												, ; //X3_DESCRIC
	'Valor Base de Calc. IPI'												, ; //X3_DESCSPA
	'IPI Calculation Basis Val'												, ; //X3_DESCENG
	'@E 999,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIPI","MT100",M->D1_BASEIPI)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'B6'																	, ; //X3_ORDEM
	'D1_SEGURO'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr. Seguro'															, ; //X3_TITULO
	'Val. Seguro'															, ; //X3_TITSPA
	'Insur. Val.'															, ; //X3_TITENG
	'Valor do Seguro do item'												, ; //X3_DESCRIC
	'Valor de seguro del ítem'												, ; //X3_DESCSPA
	'Item Insurance Value'													, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_SEGURO","MT100",M->D1_SEGURO)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'  xx x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'B8'																	, ; //X3_ORDEM
	'D1_BASEIRR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base de IRRF'															, ; //X3_TITULO
	'Base de IRRF'															, ; //X3_TITSPA
	'IRRF Basis'															, ; //X3_TITENG
	'Base de calculo do IRRF'												, ; //X3_DESCRIC
	'Base de calculo de IRRF'												, ; //X3_DESCSPA
	'IRRF Calculation Basis'												, ; //X3_DESCENG
	'@E 99,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_BASEIRR","MT100",M->D1_BASEIRR)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'B9'																	, ; //X3_ORDEM
	'D1_ALIQIRR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. IRRF'															, ; //X3_TITULO
	'Alic. IRRF'															, ; //X3_TITSPA
	'IRRF Tax Rt.'															, ; //X3_TITENG
	'Aliquota de IRRF'														, ; //X3_DESCRIC
	'Alicuota de IRRF'														, ; //X3_DESCSPA
	'IRRF Tax Rate'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MafisRef("IT_ALIQIRR","MT100",M->D1_ALIQIRR)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C0'																	, ; //X3_ORDEM
	'D1_VALIRR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor IRRF'															, ; //X3_TITULO
	'Valor IRRF'															, ; //X3_TITSPA
	'IRRF Value'															, ; //X3_TITENG
	'Valor do IRRF'															, ; //X3_DESCRIC
	'Valor de IRRF'															, ; //X3_DESCSPA
	'IRRF Value'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_VALIRR","MT100",M->D1_VALIRR)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C1'																	, ; //X3_ORDEM
	'D1_BASEISS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base de ISS'															, ; //X3_TITULO
	'Base de ISS'															, ; //X3_TITSPA
	'ISS Base'																, ; //X3_TITENG
	'Base de calculo do ISS'												, ; //X3_DESCRIC
	'Base de calculo del ISS'												, ; //X3_DESCSPA
	'ISS Calculation Basis'													, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEISS","MT100",M->D1_BASEISS)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C2'																	, ; //X3_ORDEM
	'D1_ALIQISS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. ISS'																, ; //X3_TITULO
	'Alic. ISS'																, ; //X3_TITSPA
	'ISS Tax Rate'															, ; //X3_TITENG
	'Aliquota de ISS'														, ; //X3_DESCRIC
	'Alicuota de ISS'														, ; //X3_DESCSPA
	'ISS Tax Rate'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQISS","MT100",M->D1_ALIQISS)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C3'																	, ; //X3_ORDEM
	'D1_VALISS'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor do ISS'															, ; //X3_TITULO
	'Valor de ISS'															, ; //X3_TITSPA
	'ISS Value'																, ; //X3_TITENG
	'Valor do ISS'															, ; //X3_DESCRIC
	'Valor de ISS'															, ; //X3_DESCSPA
	'ISS Value'																, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALISS","MT100",M->D1_VALISS)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C4'																	, ; //X3_ORDEM
	'D1_BASEINS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base de INSS'															, ; //X3_TITULO
	'Base Seg.Soc'															, ; //X3_TITSPA
	'INSS Basis'															, ; //X3_TITENG
	'Base de calculo do INSS'												, ; //X3_DESCRIC
	'Base de calculo Seg. Soc.'												, ; //X3_DESCSPA
	'INSS Calculation Basis'												, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_BASEINS","MT100",M->D1_BASEINS)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C5'																	, ; //X3_ORDEM
	'D1_ALIQINS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Aliq. INSS'															, ; //X3_TITULO
	'Alic.Seg.Soc'															, ; //X3_TITSPA
	'INSS Tax Rt.'															, ; //X3_TITENG
	'Aliquota de INSS'														, ; //X3_DESCRIC
	'Alicuota de Seguro Social'												, ; //X3_DESCSPA
	'INSS Tax Rate'															, ; //X3_DESCENG
	'@E 99.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQINS","MT100",M->D1_ALIQINS)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'C6'																	, ; //X3_ORDEM
	'D1_VALINS'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr. do INSS'															, ; //X3_TITULO
	'Vlr. Seg.Soc'															, ; //X3_TITSPA
	'INSS Value'															, ; //X3_TITENG
	'Valor do INSS'															, ; //X3_DESCRIC
	'Valor del Seguro Social'												, ; //X3_DESCSPA
	'INSS Value'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	'MaFisRef("IT_VALINS","MT100",M->D1_VALINS)'							, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	''																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	'Positivo()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

//
// Campos Tabela SF1
//
aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'F1_XNOMFOR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Fornece'															, ; //X3_TITULO
	'Nome Fornece'															, ; //X3_TITSPA
	'Nome Fornece'															, ; //X3_TITENG
	'Nome Fornecedor'														, ; //X3_DESCRIC
	'Nome Fornecedor'														, ; //X3_DESCSPA
	'Nome Fornecedor'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'U_BROWSE()'															, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SZR
//
aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'ZR_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'ZR_CODIGO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Código'																, ; //X3_TITULO
	'Código'																, ; //X3_TITSPA
	'Código'																, ; //X3_TITENG
	'Código'																, ; //X3_DESCRIC
	'Código'																, ; //X3_DESCSPA
	'Código'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'GETSXENUM("SZR","ZR_CODIGO")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	'INCLUI'																, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'ZR_DESCR'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descrição'																, ; //X3_TITULO
	'Descrição'																, ; //X3_TITSPA
	'Descrição'																, ; //X3_TITENG
	'Descrição'																, ; //X3_DESCRIC
	'Descrição'																, ; //X3_DESCSPA
	'Descrição'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'ZR_TRANSP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cód.Transp'															, ; //X3_TITULO
	'Cód.Transp'															, ; //X3_TITSPA
	'Cód.Transp'															, ; //X3_TITENG
	'Cód.Transp'															, ; //X3_DESCRIC
	'Cód.Transp'															, ; //X3_DESCSPA
	'Cód.Transp'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SA4'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	'VAZIO().OR.EXISTCPO("SA4",M->ZR_TRANSP)'								, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'ZR_NTRANSP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Transp.'															, ; //X3_TITULO
	'Nome Transp.'															, ; //X3_TITSPA
	'Nome Transp.'															, ; //X3_TITENG
	'Nome Transp.'															, ; //X3_DESCRIC
	'Nome Transp.'															, ; //X3_DESCSPA
	'Nome Transp.'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'ZR_FRETE'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Val. Frete'															, ; //X3_TITULO
	'Val. Frete'															, ; //X3_TITSPA
	'Val. Frete'															, ; //X3_TITENG
	'Val. Frete'															, ; //X3_DESCRIC
	'Val. Frete'															, ; //X3_DESCSPA
	'Val. Frete'															, ; //X3_DESCENG
	'@E 999,999,999.99'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'ZR_OBS'																, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Observações'															, ; //X3_TITULO
	'Observações'															, ; //X3_TITSPA
	'Observações'															, ; //X3_TITENG
	'Observações'															, ; //X3_DESCRIC
	'Observações'															, ; //X3_DESCSPA
	'Observações'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZR'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'ZR_MSBLQL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bloqueado?'															, ; //X3_TITULO
	'Bloqueado?'															, ; //X3_TITSPA
	'Bloqueado?'															, ; //X3_TITENG
	'Registro bloqueado'													, ; //X3_DESCRIC
	'Registro bloqueado'													, ; //X3_DESCSPA
	'Registro bloqueado'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	"'2'"																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Não'															, ; //X3_CBOX
	'1=Si;2=No'																, ; //X3_CBOXSPA
	'1=Yes;2=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SA1
//
aAdd( aSIX, { ;
	'SA1'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'A1_FILIAL+A1_XEANPAO'													, ; //CHAVE
	'EAN Pao Acuc'															, ; //DESCRICAO
	'EAN Pao Acuc'															, ; //DESCSPA
	'EAN Pao Acuc'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'A1XEANPAO'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SB1
//
aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'B1_FILIAL+B1_XCODINT'													, ; //CHAVE
	'Cod Interno'															, ; //DESCRICAO
	'Cod Interno'															, ; //DESCSPA
	'Cod Interno'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'B1XCODINT'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SB1'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'B1_FILIAL+B1_XCODDUN'													, ; //CHAVE
	'Cod. DUN'																, ; //DESCRICAO
	'Cod. DUN'																, ; //DESCSPA
	'Cod. DUN'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'B1XDUN'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SC5
//
aAdd( aSIX, { ;
	'SC5'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'C5_FILIAL+C5_XPEDCLI'													, ; //CHAVE
	'Ped. Cliente'															, ; //DESCRICAO
	'Ped. Cliente'															, ; //DESCSPA
	'Ped. Cliente'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'C5PEDCLI'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SZR
//
aAdd( aSIX, { ;
	'SZR'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZR_FILIAL+ZR_CODIGO'													, ; //CHAVE
	'Código'																, ; //DESCRICAO
	'Código'																, ; //DESCSPA
	'Código'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'<INFORMAR O TES>'														, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_PORSMTP'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Porta do Servidor SMTP'												, ; //X6_DESCRIC
	'Puerto del Servidor SMTP'												, ; //X6_DSCSPA
	'SMTP Server Port'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'465'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELACNT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta a ser utilizada no envio de E-Mail para os'						, ; //X6_DESCRIC
	'Cuenta a ser utilizada en el envio de E-Mail para'						, ; //X6_DSCSPA
	'Account to be used to send e-mail to'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	'nayumi@nayumi.com.br'													, ; //X6_CONTSPA
	'nayumi@nayumi.com.br'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELAPSW'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para autenticacäo no servidor de e-mail'							, ; //X6_DESCRIC
	'Contrasena para autenticacion en servidor de e-mai'					, ; //X6_DSCSPA
	'Password used to authenticate the e-mail in server'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELAUTH'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DESCRIC
	'+El servidor de EMAIL requiere Autenticacion?'							, ; //X6_DSCSPA
	'Does the e-mail Server need Authentication'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Determina se o Servidor necessita de Autenticacão.'					, ; //X6_DESC2
	'Determina si el servidor requiere Autenticacion.'						, ; //X6_DSCSPA2
	'Determine if the Server needs Authentication.'							, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELFROM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'E-mail utilizado no campo FROM no envio de'							, ; //X6_DESCRIC
	'E-mail utilizado en el campo FROM para envio de'						, ; //X6_DSCSPA
	'E-mail used in the "FROM" field when sending'							, ; //X6_DSCENG
	'relatorios por e-mail'													, ; //X6_DESC1
	'informes por e-mail.'													, ; //X6_DSCSPA1
	'reports by e-mail.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	'nayumi@nayumi.com.br'													, ; //X6_CONTSPA
	'nayumi@nayumi.com.br'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELSERV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do Servidor de Envio de E-mail utilizado nos'						, ; //X6_DESCRIC
	'Nombre de Servidor de Envio de E-mail utilizado en'					, ; //X6_DSCSPA
	'E-mail Sending Server Name used in'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	'email-ssl.com.br:465'													, ; //X6_CONTSPA
	'email-ssl.com.br:465'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELSSL'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Define se o envio e recebimento de e-mails na'							, ; //X6_DESCRIC
	'Define si debe habilitarse el SSL en el envio y'						, ; //X6_DSCSPA
	'Define whether SSL is enabled when'									, ; //X6_DSCENG
	'rotina SPED utilizará conexão segura (SSL).'							, ; //X6_DESC1
	'recepcion de e-mails'													, ; //X6_DSCSPA1
	'receiving e-mails.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_RELTLS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Informe se o servidor de SMTP possui conexão do'						, ; //X6_DESCRIC
	'Informe si el servidor de SMTP tiene conexion del'						, ; //X6_DSCSPA
	'Enter if SMTP server has a safe-type connection'						, ; //X6_DSCENG
	'tipo segura ( SSL/TLS ).'												, ; //X6_DESC1
	'tipo segura ( SSL/TLS ).'												, ; //X6_DSCSPA1
	'(SSL/TLS).'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'FS_TSENDEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Entrada Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'491'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'FS_TSENNOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Entrada Normal'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'490'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'591'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'FS_TSSANOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Normal'														, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'590'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_PORSMTP'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Porta do Servidor SMTP'												, ; //X6_DESCRIC
	'Puerto del Servidor SMTP'												, ; //X6_DSCSPA
	'SMTP Server Port'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'465'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELACNT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta a ser utilizada no envio de E-Mail para os'						, ; //X6_DESCRIC
	'Cuenta a ser utilizada en el envio de E-Mail para'						, ; //X6_DSCSPA
	'Account to be used to send e-mail to'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'nayumi@nayumi.com.br'													, ; //X6_CONTEUD
	'nayumi@nayumi.com.br'													, ; //X6_CONTSPA
	'nayumi@nayumi.com.br'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELAPSW'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para autenticacäo no servidor de e-mail'							, ; //X6_DESCRIC
	'Contrasena para autenticacion en servidor de e-mai'					, ; //X6_DSCSPA
	'Password used to authenticate the e-mail in server'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'Loca@#nayu'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELAUTH'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DESCRIC
	'+El servidor de EMAIL requiere Autenticacion?'							, ; //X6_DSCSPA
	'Does the e-mail Server need Authentication'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Determina se o Servidor necessita de Autenticacão.'					, ; //X6_DESC2
	'Determina si el servidor requiere Autenticacion.'						, ; //X6_DSCSPA2
	'Determine if the Server needs Authentication.'							, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELFROM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'E-mail utilizado no campo FROM no envio de'							, ; //X6_DESCRIC
	'E-mail utilizado en el campo FROM para envio de'						, ; //X6_DSCSPA
	'E-mail used in the "FROM" field when sending'							, ; //X6_DSCENG
	'relatorios por e-mail'													, ; //X6_DESC1
	'informes por e-mail.'													, ; //X6_DSCSPA1
	'reports by e-mail.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'nayumi@nayumi.com.br'													, ; //X6_CONTEUD
	'nayumi@nayumi.com.br'													, ; //X6_CONTSPA
	'nayumi@nayumi.com.br'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELSERV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do Servidor de Envio de E-mail utilizado nos'						, ; //X6_DESCRIC
	'Nombre de Servidor de Envio de E-mail utilizado en'					, ; //X6_DSCSPA
	'E-mail Sending Server Name used in'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'email-ssl.com.br'														, ; //X6_CONTEUD
	'email-ssl.com.br:465'													, ; //X6_CONTSPA
	'email-ssl.com.br:465'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELSSL'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Define se o envio e recebimento de e-mails na'							, ; //X6_DESCRIC
	'Define si debe habilitarse el SSL en el envio y'						, ; //X6_DSCSPA
	'Define whether SSL is enabled when'									, ; //X6_DSCENG
	'rotina SPED utilizará conexão segura (SSL).'							, ; //X6_DESC1
	'recepcion de e-mails'													, ; //X6_DSCSPA1
	'receiving e-mails.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'MV_RELTLS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Informe se o servidor de SMTP possui conexão do'						, ; //X6_DESCRIC
	'Informe si el servidor de SMTP tiene conexion del'						, ; //X6_DSCSPA
	'Enter if SMTP server has a safe-type connection'						, ; //X6_DSCENG
	'tipo segura ( SSL/TLS ).'												, ; //X6_DESC1
	'tipo segura ( SSL/TLS ).'												, ; //X6_DSCSPA1
	'(SSL/TLS).'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'FS_TSENDEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Entrada Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'491'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'FS_TSENNOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Entrada Normal'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'490'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'FS_TSSADEV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Devolucao'													, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'591'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'FS_TSSANOR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'TES Saida Normal'														, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'590'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_PORSMTP'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Porta do Servidor SMTP'												, ; //X6_DESCRIC
	'Puerto del Servidor SMTP'												, ; //X6_DSCSPA
	'SMTP Server Port'														, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'465'																	, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELACNT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Conta a ser utilizada no envio de E-Mail para os'						, ; //X6_DESCRIC
	'Cuenta a ser utilizada en el envio de E-Mail para'						, ; //X6_DSCSPA
	'Account to be used to send e-mail to'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'nfe@diretodaserra.com.br'												, ; //X6_CONTEUD
	'nayumi@nayumi.com.br'													, ; //X6_CONTSPA
	'nayumi@nayumi.com.br'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELAPSW'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Senha para autenticacäo no servidor de e-mail'							, ; //X6_DESCRIC
	'Contrasena para autenticacion en servidor de e-mai'					, ; //X6_DSCSPA
	'Password used to authenticate the e-mail in server'					, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'nfedds2015'															, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELAUTH'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Servidor de EMAIL necessita de Autenticacão?'							, ; //X6_DESCRIC
	'+El servidor de EMAIL requiere Autenticacion?'							, ; //X6_DSCSPA
	'Does the e-mail Server need Authentication'							, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'Determina se o Servidor necessita de Autenticacão.'					, ; //X6_DESC2
	'Determina si el servidor requiere Autenticacion.'						, ; //X6_DSCSPA2
	'Determine if the Server needs Authentication.'							, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELFROM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'E-mail utilizado no campo FROM no envio de'							, ; //X6_DESCRIC
	'E-mail utilizado en el campo FROM para envio de'						, ; //X6_DSCSPA
	'E-mail used in the "FROM" field when sending'							, ; //X6_DSCENG
	'relatorios por e-mail'													, ; //X6_DESC1
	'informes por e-mail.'													, ; //X6_DSCSPA1
	'reports by e-mail.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'nfe@diretodaserra.com.br'												, ; //X6_CONTEUD
	'nayumi@nayumi.com.br'													, ; //X6_CONTSPA
	'nayumi@nayumi.com.br'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELSERV'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Nome do Servidor de Envio de E-mail utilizado nos'						, ; //X6_DESCRIC
	'Nombre de Servidor de Envio de E-mail utilizado en'					, ; //X6_DSCSPA
	'E-mail Sending Server Name used in'									, ; //X6_DSCENG
	'relatorios'															, ; //X6_DESC1
	'los informes.'															, ; //X6_DSCSPA1
	'reports.'																, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'mail.diretodaserra.com.br'												, ; //X6_CONTEUD
	'email-ssl.com.br:465'													, ; //X6_CONTSPA
	'email-ssl.com.br:465'													, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELSSL'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Define se o envio e recebimento de e-mails na'							, ; //X6_DESCRIC
	'Define si debe habilitarse el SSL en el envio y'						, ; //X6_DSCSPA
	'Define whether SSL is enabled when'									, ; //X6_DSCENG
	'rotina SPED utilizará conexão segura (SSL).'							, ; //X6_DESC1
	'recepcion de e-mails'													, ; //X6_DSCSPA1
	'receiving e-mails.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'MV_RELTLS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Informe se o servidor de SMTP possui conexão do'						, ; //X6_DESCRIC
	'Informe si el servidor de SMTP tiene conexion del'						, ; //X6_DSCSPA
	'Enter if SMTP server has a safe-type connection'						, ; //X6_DSCENG
	'tipo segura ( SSL/TLS ).'												, ; //X6_DESC1
	'tipo segura ( SSL/TLS ).'												, ; //X6_DSCSPA1
	'(SSL/TLS).'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'.F.'																	, ; //X6_DEFPOR
	'.F.'																	, ; //X6_DEFSPA
	'.F.'																	, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo D1_COD
//
aAdd( aSX7, { ;
	'D1_COD'																, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	"Posicione('SB1',1,xFilial('SB1')+M->D1_COD, 'B1_DESC')"				, ; //X7_REGRA
	'D1_XDESCR'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta ROTAS
//
aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Rotas - Especifico'													, ; //XB_DESCRI
	'Rotas - Especifico'													, ; //XB_DESCSPA
	'Rotas - Especifico'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SZR'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Código'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Código'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZR_CODIGO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descrição'																, ; //XB_DESCSPA
	'Descrição'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZR_DESCR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome Transp.'															, ; //XB_DESCRI
	'Nome Transp.'															, ; //XB_DESCSPA
	'Nome Transp.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ZR_NTRANSP'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ROTAS'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SZR->ZR_CODIGO'														} ) //XB_CONTEM

//
// Consulta SA4
//
aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Transportadora'														, ; //XB_DESCRI
	'Transportista'															, ; //XB_DESCSPA
	'Carrier'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA4'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A4_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA4->A4_COD'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome ou razão social do cliente.' )

PutHelp( "PA1_NOME   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_NOME" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Cliente :' )
aAdd( aHlpPor, 'Opções Brasil (L,F,R,S,X):' )
aAdd( aHlpPor, 'L - Produtor Rural; F - Cons.Final;' )
aAdd( aHlpPor, 'R - Revendedor; S - ICMS Solidário sem' )
aAdd( aHlpPor, 'IPI na base; X - Exportação.' )
aAdd( aHlpPor, 'Outros Países :' )
aAdd( aHlpPor, 'Verificar opções disponíveis' )

PutHelp( "PA1_TIPO   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Deve ser preenchido apenas com L,F,R,S' )
aAdd( aHlpPor, 'ou X (Brasil) ou com opções diponiveis' )
aAdd( aHlpPor, 'para o pais em uso' )

PutHelp( "SA1_TIPO   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado a solução do campo " + "A1_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar a natureza' )
aAdd( aHlpPor, 'do título, quando gerado, para o módulo' )
aAdd( aHlpPor, 'financeiro.' )

PutHelp( "PA1_NATUREZ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_NATUREZ" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de cobrança do cliente.' )

PutHelp( "PA1_ENDCOB ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDCOB" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço de entrega do cliente.' )

PutHelp( "PA1_ENDENT ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Endereço da central de compras do' )
aAdd( aHlpPor, 'cliente.' )

PutHelp( "PA1_ENDREC ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ENDREC" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual apresentado  como  default na' )
aAdd( aHlpPor, 'tela do pedido para cálculo de comissão.' )
aAdd( aHlpPor, 'Tem  prioridade  sobre  o % informado no' )
aAdd( aHlpPor, 'cadastro de  vendedor, porém não sobre o' )
aAdd( aHlpPor, '% informado no produto.' )

PutHelp( "PA1_COMIS  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_COMIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de frete do cliente.' )
aAdd( aHlpPor, 'C = CIF   F = FOB' )
aAdd( aHlpPor, 'Campo Informativo.' )

PutHelp( "PA1_TPFRET ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TPFRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de desconto padrão  concedido' )
aAdd( aHlpPor, 'ao cliente como sugestão a cada' )
aAdd( aHlpPor, 'faturamento.' )

PutHelp( "PA1_DESC   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Prioridade de atendimento do cliente' )
aAdd( aHlpPor, 'face sua contribuição com a empresa.' )

PutHelp( "PA1_PRIOR  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_PRIOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Grau de Risco na aprovação do Crédito do' )
aAdd( aHlpPor, 'Cliente em Pedidos de Venda (A,B,C,D,E):' )
aAdd( aHlpPor, 'A: Crédito Ok;' )
aAdd( aHlpPor, 'B,C e D: Liberação definida através dos' )
aAdd( aHlpPor, 'parâmetros: MV_RISCO(B,C,D);' )
aAdd( aHlpPor, 'E: Liberação manual;' )
aAdd( aHlpPor, 'Z: Liberação através de integração com' )
aAdd( aHlpPor, 'software de terceiro.' )

PutHelp( "PA1_RISCO  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_RISCO" )

aHlpPor := {}
aAdd( aHlpPor, 'Limite de crédito estabelecido para o' )
aAdd( aHlpPor, 'cliente. Valor armazenado na moeda forte' )
aAdd( aHlpPor, 'definida no campo A1_MOEDALC. Default' )
aAdd( aHlpPor, 'moeda 2.' )

PutHelp( "PA1_LC     ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_LC" )

aHlpPor := {}
aAdd( aHlpPor, 'Limite de credito secundario.' )

PutHelp( "PA1_LCFIN  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_LCFIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Somatória dos valores em atraso  levando' )
aAdd( aHlpPor, 'em consideração o número de dias' )
aAdd( aHlpPor, 'definidos no risco do cliente.' )

PutHelp( "PA1_ATR    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ATR" )

aHlpPor := {}
aAdd( aHlpPor, 'Número de títulos protestados  do' )
aAdd( aHlpPor, 'cliente. Campo informativo.' )

PutHelp( "PA1_TITPROT", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TITPROT" )

aHlpPor := {}
aAdd( aHlpPor, 'Número de cheques devolvidos do cliente.' )
aAdd( aHlpPor, 'Deve ser informado pelo usuário. É' )
aAdd( aHlpPor, 'apresentado por ocasião da liberação de' )
aAdd( aHlpPor, 'crédito. Campo informativo.' )

PutHelp( "PA1_CHQDEVO", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CHQDEVO" )

aHlpPor := {}
aAdd( aHlpPor, 'Se o ISS estiver embutido no preço,' )
aAdd( aHlpPor, 'informar "S", se desejar incluir o ISS' )
aAdd( aHlpPor, 'no total da NF, informar "N".' )

PutHelp( "PA1_INCISS ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_INCISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Alíquota de Imposto de Renda Retido  na' )
aAdd( aHlpPor, 'Fonte.' )

PutHelp( "PA1_ALIQIR ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_ALIQIR" )

aHlpPor := {}
aAdd( aHlpPor, 'Informar  se  deve  calcular  ou  não o' )
aAdd( aHlpPor, 'desconto de 7% para clientes com código' )
aAdd( aHlpPor, 'SUFRAMA.' )
aAdd( aHlpPor, 'VALIDAÇÄO:' )
aAdd( aHlpPor, '(N) - Não efetua o cálculo do desconto' )
aAdd( aHlpPor, 'SUFRAMA' )
aAdd( aHlpPor, '(Branco),(S) - Calcula o Desconto de' )
aAdd( aHlpPor, 'Pis, Cofins e ICMS, dependendo da' )
aAdd( aHlpPor, 'configuração no cadastro do produto.' )
aAdd( aHlpPor, '(I) - Calcula o desconto apenas' )
aAdd( aHlpPor, 'referente ao ICMS, não calculando o' )
aAdd( aHlpPor, 'desconto para Pis e Cofins, também' )
aAdd( aHlpPor, 'dependendo da configuração no cadastro' )
aAdd( aHlpPor, 'do produto para permitir o cálculo.' )

PutHelp( "PA1_CALCSUF", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_CALCSUF" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Cliente.' )

PutHelp( "PA1_TIPOCLI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'EAN Pao Acucar' )

PutHelp( "PA1_XEANPAO", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XEANPAO" )

aHlpPor := {}
aAdd( aHlpPor, 'Rota Entrega' )

PutHelp( "PA1_XROTA  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XROTA" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de Desconto Marketing' )

PutHelp( "PA1_XDESC  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "A1_XDESC" )

//
// Helps Tabela SB1
//
aHlpPor := {}
aAdd( aHlpPor, 'Sigla Produto Cod Inteligente' )

PutHelp( "PB1_XSIGLA ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XSIGLA" )

aHlpPor := {}
aAdd( aHlpPor, 'Status Cod Inteligente' )

PutHelp( "PB1_XSTATUS", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XSTATUS" )

aHlpPor := {}
aAdd( aHlpPor, 'Apresentacao Cod Inteligente' )

PutHelp( "PB1_XAPRES ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XAPRES" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo Interno (antigo)  - Codigo' )
aAdd( aHlpPor, 'Inteligente' )
aAdd( aHlpPor, 'Preencher com Zeros antes' )
aAdd( aHlpPor, 'formato: 0005' )

PutHelp( "PB1_XCODINT", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XCODINT" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição do produto.' )

PutHelp( "PB1_DESC   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de IPI a ser aplicado sobre o' )
aAdd( aHlpPor, 'produto, de acordo com a posição do IPI.' )

PutHelp( "PB1_IPI    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_IPI" )

aHlpPor := {}
aAdd( aHlpPor, 'Código de Serviço do ISS, utilizado para' )
aAdd( aHlpPor, 'discriminar a operação perante o' )
aAdd( aHlpPor, 'município tributador.' )
aAdd( aHlpPor, 'Tecla [F3] Disponível.' )

PutHelp( "PB1_CODISS ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CODISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Margem de Lucro para cálculo do ICMS' )
aAdd( aHlpPor, 'Solidário ou Retido.' )

PutHelp( "PB1_PICMRET", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PICMRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Porcentual que define o lucro para' )
aAdd( aHlpPor, 'cálculo do ICMS Solidario na entrada.' )

PutHelp( "PB1_PICMENT", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PICMENT" )

aHlpPor := {}
aAdd( aHlpPor, 'Fator de Conversao da 1aUM para a 2aUM.' )
aAdd( aHlpPor, 'Todas as Rotinas de Entrada, Saida e' )
aAdd( aHlpPor, 'Movimentacao interna possuem campos para' )
aAdd( aHlpPor, 'a digitacao nas 2 unidades de Medida. Se' )
aAdd( aHlpPor, 'um Fator de Conversao for cadastrado,' )
aAdd( aHlpPor, 'somente um deles precisa ser digitado, o' )
aAdd( aHlpPor, 'sistema calcula a outra unidade de' )
aAdd( aHlpPor, 'medida com base neste Fator de Conversao' )
aAdd( aHlpPor, 'e preenche o outro campo' )
aAdd( aHlpPor, 'automaticamente.' )
aAdd( aHlpPor, 'Se nenhum Fator se Conversao for' )
aAdd( aHlpPor, 'atribuido os 2 campos deverao ser' )
aAdd( aHlpPor, 'preenchidos manualmente.' )

PutHelp( "PB1_CONV   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CONV" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade padrão inferior ao lote' )
aAdd( aHlpPor, 'econômico a ser considerada para COMPRA,' )
aAdd( aHlpPor, 'de modo que se incorra no custo minimo e' )
aAdd( aHlpPor, 'obtenha-se utilidades maximas. Qdo o' )
aAdd( aHlpPor, 'produto for fabricado utilize o lote' )
aAdd( aHlpPor, 'minimo.' )

PutHelp( "PB1_QE     ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_QE" )

aHlpPor := {}
aAdd( aHlpPor, 'Preço de venda do produto. Existe mais 6' )
aAdd( aHlpPor, 'tabelas no arquivo SB5 (Dados' )
aAdd( aHlpPor, 'Adicionaisdo Produto).' )

PutHelp( "PB1_PRV1   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PRV1" )

aHlpPor := {}
aAdd( aHlpPor, 'Ponto de pedido. Quantidade mínima' )
aAdd( aHlpPor, 'pré-estabelecida que, uma vez atingida,' )
aAdd( aHlpPor, 'gera emissão automática de uma' )
aAdd( aHlpPor, 'solicitação de compras ou ordem de' )
aAdd( aHlpPor, 'produção.' )

PutHelp( "PB1_EMIN   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_EMIN" )

aHlpPor := {}
aAdd( aHlpPor, 'Estoque de segurança. Quantidade' )
aAdd( aHlpPor, 'mínimade produto em estoque para evitar' )
aAdd( aHlpPor, 'a falta do mesmo entre a solicitação de' )
aAdd( aHlpPor, 'compra ou produção e o seu recebimento.' )

PutHelp( "PB1_ESTSEG ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_ESTSEG" )

aHlpPor := {}
aAdd( aHlpPor, 'Prazo de entrega do produto. É o' )
aAdd( aHlpPor, 'númerode dias, meses ou anos que o' )
aAdd( aHlpPor, 'fornecedor ou a fábrica necessita para' )
aAdd( aHlpPor, 'entregar o  produto, a partir do' )
aAdd( aHlpPor, 'recebimento de seu pedido.' )

PutHelp( "PB1_PE     ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PE" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do prazo de entrega. Informar se' )
aAdd( aHlpPor, 'oprazo será em horas (H), dias (D),' )
aAdd( aHlpPor, 'sema-nas (S), meses (M) ou ano (A). Este' )
aAdd( aHlpPor, 'cam-po deve estar em acordo com o campo' )
aAdd( aHlpPor, 'PRAZO DE ENTREGA.' )

PutHelp( "PB1_TIPE   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_TIPE" )

aHlpPor := {}
aAdd( aHlpPor, 'Lote econômico do produto. Quantidade' )
aAdd( aHlpPor, 'padrão a ser comprada de uma só vez ou a' )
aAdd( aHlpPor, 'ser produzida em uma só operação, de' )
aAdd( aHlpPor, 'modo que se incorra no custo mínimo e' )
aAdd( aHlpPor, 'obtenha-se utilidades máximas.' )

PutHelp( "PB1_LE     ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_LE" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade padrão inferior ao lote' )
aAdd( aHlpPor, 'econômico a ser considerada para' )
aAdd( aHlpPor, 'PRODUÇÃO, de modo que se incorra no' )
aAdd( aHlpPor, 'custo minimo e obtenha-se utilidades' )
aAdd( aHlpPor, 'máximas. Quando o produto for comprado' )
aAdd( aHlpPor, 'utilize quantidade por embalagem.' )

PutHelp( "PB1_LM     ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_LM" )

aHlpPor := {}
aAdd( aHlpPor, 'Apropriacao Direta ou Indireta de' )
aAdd( aHlpPor, 'material.' )
aAdd( aHlpPor, 'Produtos de Pequeno Valor Agregado,' )
aAdd( aHlpPor, 'Grande Giro e/ou Dificil Quantificacao' )
aAdd( aHlpPor, 'podem utilizar a Apropriacao indireta.' )
aAdd( aHlpPor, 'Exemplo:' )
aAdd( aHlpPor, '========' )
aAdd( aHlpPor, 'Definimos que na montagem de 1 Cadeira' )
aAdd( aHlpPor, 'utilizam-se 8 Parafusos.' )
aAdd( aHlpPor, 'Parafusos com APROPRIACAO DIRETA:' )
aAdd( aHlpPor, 'Durante o dia cada Ordem de Producao de' )
aAdd( aHlpPor, '1 Cadeira ira Requisitar 8 parafusos do' )
aAdd( aHlpPor, 'Armazem Padrao; na pratica o funcionario' )
aAdd( aHlpPor, 'devera se dirigir ao Almoxarife com uma' )
aAdd( aHlpPor, 'requisicao de 8 parafusos cada vez que' )
aAdd( aHlpPor, 'for montar 1 cadeira.' )
aAdd( aHlpPor, 'Parafusos com APROPRIACAO INDIRETA: No' )
aAdd( aHlpPor, 'inicio do dia é feita uma Requisicao' )
aAdd( aHlpPor, 'Manual de 1 Caixa de Parafusos (1000' )
aAdd( aHlpPor, 'Parafusos). Esta Requisicao ira fazer' )
aAdd( aHlpPor, 'com que estes 1000 parafusos sejam' )
aAdd( aHlpPor, 'transferidos para o Armazem de Processo' )
aAdd( aHlpPor, '(definido no MV_LOCPROC). Cada OP de 1' )
aAdd( aHlpPor, 'Cadeira irá requisitar 8 parafusos do' )
aAdd( aHlpPor, 'Armazem de Processo; na pratica a caixa' )
aAdd( aHlpPor, 'de parafusos ja tera sido requisitada e' )
aAdd( aHlpPor, 'estara disponivel para que o funcionario' )
aAdd( aHlpPor, 'pegue os 8 parafusos.' )

PutHelp( "PB1_APROPRI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_APROPRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Informar "S" se o produto é um' )
aAdd( aHlpPor, 'componente fantasma dentro da estrutura.' )
aAdd( aHlpPor, 'Nas rotinas de explosão serve apenas' )
aAdd( aHlpPor, 'como ponte para montagem das árvores,' )
aAdd( aHlpPor, 'não gerando ordens de produção.' )

PutHelp( "PB1_FANTASM", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_FANTASM" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para  informar se o' )
aAdd( aHlpPor, 'pro-duto  normalmente  é  comprado  fora' )
aAdd( aHlpPor, 'doestado  para  fins  de  cálculo do' )
aAdd( aHlpPor, 'custostandard (ICMS).' )

PutHelp( "PB1_FORAEST", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_FORAEST" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica se o Produto incide a' )
aAdd( aHlpPor, 'Contribuição Seguridade Social' )
aAdd( aHlpPor, '(Funrural)' )

PutHelp( "PB1_CONTSOC", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CONTSOC" )

aHlpPor := {}
aAdd( aHlpPor, 'Indica se este produto entra para' )
aAdd( aHlpPor, 'cálculo do MRP.' )
aAdd( aHlpPor, '(S)im ou (N)ão.' )

PutHelp( "PB1_MRP    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_MRP" )

aHlpPor := {}
aAdd( aHlpPor, 'Cod. Barras DUN (Especifico)' )

PutHelp( "PB1_XCODDUN", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XCODDUN" )

aHlpPor := {}
aAdd( aHlpPor, 'Define se deve ser calculado imposto de' )
aAdd( aHlpPor, 'renda para este produto na nota fiscal.' )

PutHelp( "PB1_IRRF   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_IRRF" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual CSLL.' )

PutHelp( "PB1_PCSLL  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PCSLL" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual a ser aplicado para cálculo' )
aAdd( aHlpPor, 'ddo COFINS quando a alíquota for' )
aAdd( aHlpPor, 'diferente da que estiver informada no' )
aAdd( aHlpPor, 'parâmetro MV_TXCOFIN.' )

PutHelp( "PB1_PCOFINS", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PCOFINS" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual a ser aplicado para cálculo' )
aAdd( aHlpPor, 'do PIS quando a alíquota for diferente' )
aAdd( aHlpPor, 'daque estiver informada no parâmetro' )
aAdd( aHlpPor, 'MV_TXPIS.' )

PutHelp( "PB1_PPIS   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PPIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso Bruto do Produto ( Ex.:  Produto' )
aAdd( aHlpPor, '+Embalagem).' )
aAdd( aHlpPor, 'Atraves  do parâmetro MV_PESOCAR' )
aAdd( aHlpPor, 'pode-seutilizar este peso na Montagem de' )
aAdd( aHlpPor, 'Cargasno Módulo de OMS.' )

PutHelp( "PB1_PESBRU ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_PESBRU" )

aHlpPor := {}
aAdd( aHlpPor, 'Porcentagem que deve ser aplicada para o' )
aAdd( aHlpPor, 'cálculo do Crédito Estímulo. Caso o' )
aAdd( aHlpPor, 'produto não proporcione o crédito, não' )
aAdd( aHlpPor, 'informar este campo.' )

PutHelp( "PB1_CRDEST ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_CRDEST" )

aHlpPor := {}
aAdd( aHlpPor, 'Qtd Embalagem' )

PutHelp( "PB1_XQE    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XQE" )

aHlpPor := {}
aAdd( aHlpPor, 'Embalagem Retornavel' )

PutHelp( "PB1_XEMB   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XEMB" )

//
// Helps Tabela SC5
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome Fantasia Cliente' )

PutHelp( "PC5_XNOMCLI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XNOMCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Pedido de Reposicao?' )

PutHelp( "PC5_XREPOSI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XREPOSI" )

aHlpPor := {}
aAdd( aHlpPor, 'Dt p/ Reposicao' )

PutHelp( "PC5_XDTREPO", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XDTREPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Código do tipo de cliente. (Ver help  do' )
aAdd( aHlpPor, 'programa).' )
aAdd( aHlpPor, 'R = Revendedor' )
aAdd( aHlpPor, 'S = Solidario' )
aAdd( aHlpPor, 'F = Consumidor Final' )

PutHelp( "PC5_TIPOCLI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_TIPOCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do frete utilizado:' )
aAdd( aHlpPor, 'C = CIF' )
aAdd( aHlpPor, 'F = FOB' )
aAdd( aHlpPor, 'T = Por conta de terceiros' )
aAdd( aHlpPor, 'R = Por conta remetente' )
aAdd( aHlpPor, 'D = Por conta destinatário' )
aAdd( aHlpPor, 'S = Sem frete' )

PutHelp( "PC5_TPFRETE", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_TPFRETE" )

aHlpPor := {}
aAdd( aHlpPor, 'Este campo é sugerido através do cadas-' )
aAdd( aHlpPor, 'tro de clientes. Informa ao sistema se' )
aAdd( aHlpPor, 'o valor do ISS está incluso no preço.' )
aAdd( aHlpPor, 'Se o valor não estiver incluso e, ao' )
aAdd( aHlpPor, 'informar "N", o sistema inclui no Total' )

PutHelp( "PC5_INCISS ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_INCISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Utilizado pelo sistema.' )

PutHelp( "PC5_LIBEROK", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_LIBEROK" )

aHlpPor := {}
aAdd( aHlpPor, 'Este campo é utilizado para indicar, no' )
aAdd( aHlpPor, 'lançamento do pedido de venda, se o ICMS' )
aAdd( aHlpPor, 'sobre frete autonomo será pago pelo' )
aAdd( aHlpPor, 'emitente ou pelo transportador.' )

PutHelp( "PC5_RECFAUT", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_RECFAUT" )

aHlpPor := {}
aAdd( aHlpPor, 'Pedido do Cliente' )

PutHelp( "PC5_XPEDCLI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XPEDCLI" )

aHlpPor := {}
aAdd( aHlpPor, 'Rota Entrega' )

PutHelp( "PC5_XROTA  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C5_XROTA" )

//
// Helps Tabela SC6
//
aHlpPor := {}
aAdd( aHlpPor, 'Descrição  do  produto  a ser emitido na' )
aAdd( aHlpPor, 'nota.É apresentado como default o  nome' )
aAdd( aHlpPor, 'que está no cadastro de produto.' )

PutHelp( "PC6_DESCRI ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_DESCRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade original do pedido.' )

PutHelp( "PC6_QTDVEN ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_QTDVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Preço unitário líquido. Preço de  tabela' )
aAdd( aHlpPor, 'com aplicação dos descontos e acréscimos' )
aAdd( aHlpPor, 'financeiros.' )

PutHelp( "PC6_PRCVEN ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_PRCVEN" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor total do ítem líquido, já' )
aAdd( aHlpPor, 'considerado todos os descontos e  com' )
aAdd( aHlpPor, 'base na quantidade.' )

PutHelp( "PC6_VALOR  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_VALOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar a' )
aAdd( aHlpPor, 'quantidade a ser liberada.' )

PutHelp( "PC6_QTDLIB ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_QTDLIB" )

aHlpPor := {}
aAdd( aHlpPor, 'Campo utilizado para informar a' )
aAdd( aHlpPor, 'quantidade a ser liberada na segunda' )
aAdd( aHlpPor, 'unidade de medida.' )

PutHelp( "PC6_QTDLIB2", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_QTDLIB2" )

aHlpPor := {}
aAdd( aHlpPor, 'Flag de geração da ordem de produção.' )

PutHelp( "PC6_OP     ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_OP" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do romaneio.' )

PutHelp( "PC6_CODROM ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_CODROM" )

aHlpPor := {}
aAdd( aHlpPor, 'Centro de Custo.' )

PutHelp( "PC6_CCUSTO ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_CCUSTO" )

aHlpPor := {}
aAdd( aHlpPor, 'Qtd.Original' )

PutHelp( "PC6_XQTDORI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C6_XQTDORI" )

//
// Helps Tabela SC7
//
aHlpPor := {}
aAdd( aHlpPor, 'Informe a descrição do produto. A' )
aAdd( aHlpPor, 'descrição é preenchida automáticamente' )
aAdd( aHlpPor, 'quando informa-se o código do produto.' )

PutHelp( "PC7_DESCRI ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_DESCRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de alíquota de IPI.' )

PutHelp( "PC7_IPI    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_IPI" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o primeiro percentual do' )
aAdd( aHlpPor, 'desconto em cascata.' )

PutHelp( "PC7_DESC1  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_DESC1" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o segundo percentual do desconto' )
aAdd( aHlpPor, 'em cascata.' )

PutHelp( "PC7_DESC2  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_DESC2" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o terceiro percentual do' )
aAdd( aHlpPor, 'desconto em cascata.' )

PutHelp( "PC7_DESC3  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_DESC3" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o valor do ICMS complementar.' )
aAdd( aHlpPor, 'Caso a TES seja informada este campo é' )
aAdd( aHlpPor, 'calculado automaticamente.' )

PutHelp( "PC7_ICMCOMP", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_ICMCOMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o valor do ICMS retido. Caso a' )
aAdd( aHlpPor, 'TES seja informada este campo é' )
aAdd( aHlpPor, 'calculado automaticamente.' )

PutHelp( "PC7_ICMSRET", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C7_ICMSRET" )

//
// Helps Tabela SC9
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome Fantasia Cliente' )

PutHelp( "PC9_XNOMCLI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "C9_XNOMCLI" )

//
// Helps Tabela SD1
//
aHlpPor := {}
aAdd( aHlpPor, 'Valor total da nota fiscal.' )

PutHelp( "PD1_TOTAL  ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_TOTAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do IPI do ítem.' )

PutHelp( "PD1_VALIPI ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_VALIPI" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do ICMS do ítem.' )

PutHelp( "PD1_VALICM ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_VALICM" )

aHlpPor := {}
aAdd( aHlpPor, 'Descricao do Produto' )

PutHelp( "PD1_XDESCR ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_XDESCR" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de desconto a ser aplicado' )
aAdd( aHlpPor, 'sobre o valor unitário da mercadoria.' )

PutHelp( "PD1_DESC   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Percentual de IPI sobre o produto.' )

PutHelp( "PD1_IPI    ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_IPI" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso do produto para rateio do valor' )
aAdd( aHlpPor, 'dofrete entre os diversos produtos da' )
aAdd( aHlpPor, 'notafiscal.' )

PutHelp( "PD1_PESO   ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_PESO" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do ICMS Retido.' )

PutHelp( "PD1_ICMSRET", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_ICMSRET" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor da Base de ICMS para este item.' )

PutHelp( "PD1_BASEICM", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_BASEICM" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor de Desconto do item.' )

PutHelp( "PD1_VALDESC", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_VALDESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Este campo contem o controle do SkipLote' )

PutHelp( "PD1_SKIPLOT", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_SKIPLOT" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor de Base de Cálculo de IPI para o' )
aAdd( aHlpPor, 'Item da Nota Fiscal.' )

PutHelp( "PD1_BASEIPI", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_BASEIPI" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do seguro' )

PutHelp( "PD1_SEGURO ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_SEGURO" )

aHlpPor := {}
aAdd( aHlpPor, 'Base de calculo para o Imposto de Renda' )
aAdd( aHlpPor, 'no item.' )

PutHelp( "PD1_BASEIRR", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_BASEIRR" )

aHlpPor := {}
aAdd( aHlpPor, 'Aliquota de imposto de Renda para o' )
aAdd( aHlpPor, 'item.' )

PutHelp( "PD1_ALIQIRR", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_ALIQIRR" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do imposto de Renda para o item.' )

PutHelp( "PD1_VALIRR ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_VALIRR" )

aHlpPor := {}
aAdd( aHlpPor, 'Base de calculo para o ISS no item.' )

PutHelp( "PD1_BASEISS", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_BASEISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Aliquota para calculo do ISS no item.' )

PutHelp( "PD1_ALIQISS", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_ALIQISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do ISS para o item.' )

PutHelp( "PD1_VALISS ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_VALISS" )

aHlpPor := {}
aAdd( aHlpPor, 'Base de calculo para INSS no item.' )

PutHelp( "PD1_BASEINS", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_BASEINS" )

aHlpPor := {}
aAdd( aHlpPor, 'Aliquota para calculo do INSS do item.' )

PutHelp( "PD1_ALIQINS", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_ALIQINS" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor do INSS para o item.' )

PutHelp( "PD1_VALINS ", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "D1_VALINS" )

//
// Helps Tabela SF1
//
aHlpPor := {}
aAdd( aHlpPor, 'Nome Fornecedor' )

PutHelp( "PF1_XNOMFOR", aHlpPor, {}, {}, .T. )
AutoGrLog( "Atualizado o Help do campo " + "F1_XNOMFOR" )

//
// Helps Tabela SZR
//
AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDPRD" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  05/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
