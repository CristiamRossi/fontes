#INCLUDE "Protheus.ch"	
#DEFINE _CRLF	Chr(13) + Chr(10)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪履哪哪哪哪目北
北矲un噮o    ?UPDFSW  矨utor ?FSW                   矰ata ?25.Jun.09潮?
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪聊哪哪哪哪拇北
北矰escri噭o ?Compatibilizador de tabelas e campos                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       ?Bardella                                             潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
User Function UPDFSW()
Local oDlgUpd
Local oListUpd
Local aTitulos   := {' ', 'Id.', 'Update', 'Status', 'Projeto' }
Local aListUpd   := {}
Local oOk        := LoadBitMap(GetResources(),"LBOK")
Local oNo        := LoadBitMap(GetResources(),"LBNO")
Local cTxtIntro  := ''
Local aEmpresas  := {}
Local lMarcaItem := .T.

Private aDados   := {}

cTxtIntro := "<table width='100%' border='1'>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='2'><font face='Tahoma' size='+1'>Este programa tem por objetivo compatibilizar o ambiente do cliente "
cTxtIntro += "conforme as atualizacoes selecionadas na lista abaixo:</font></td>"
cTxtIntro += "</tr>
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='2'><font face='Tahoma' color='#FF0000' size='+1'>Estas atualizacoes somente poderao ser realizadas em modo <b>exclusivo!</b><br>"
cTxtIntro += "Faca um backup dos dicion醨ios e da Base de Dados antes da atualiza玢o para eventuais falhas na atualiza玢o."
cTxtIntro += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>
cTxtIntro += "</table>

If ( lOpen := MyOpenSm0(.T.) )

	//-- Obtem as Empresas para processamento...
	SM0->(dbGotop())
	While !SM0->(Eof())
  		If Ascan(aEmpresas,{ |x| x[2] == SM0->M0_CODIGO}) == 0 .And. !Empty(SM0->M0_CODIGO) //--So adiciona no array se a empresa for diferente
			Aadd(aEmpresas,{.T.,;
							SM0->M0_CODIGO,;
							SM0->M0_CODFIL,;
							SM0->M0_FILIAL,;
							SM0->(Recno()) })
		EndIf			
		SM0->(dbSkip())
	EndDo	

	SM0->(DbGoTop())
	RpcSetType(3) 
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	nModulo := 43 //SIGATMS
	lMsFinalAuto := .F.
	
	//-- Obtem a lista de Updates disponiveis para execucao:
	aListUpd   := GetListUpd()

	DEFINE MSDIALOG oDlgUpd; 
	TITLE 'Update Compatibilizador' ;
	FROM 00,00 TO 500,700 PIXEL
	
	TSay():New(002,005,{|| cTxtIntro },oDlgUpd,,,,,,.T.,,,340,200,,,,.T.,,.T.)
	
	oListUpd := TWBrowse():New(	53,10,330,140,,aTitulos,,oDlgUpd,,,,,,,,,,,,,"ARRAY",.T.)
	oListUpd:bLDblClick := {|| aListUpd[oListUpd:nAt,1] := !aListUpd[oListUpd:nAt,1], oListUpd:Refresh()}
	oListUpd:SetArray( aListUpd )
	oListUpd:bLine      := {|| {	If(aListUpd[oListUpd:nAt,1], oOk, oNo),;
							   		aListUpd[oListUpd:nAT,2],;
									aListUpd[oListUpd:nAT,3],;
									aListUpd[oListUpd:nAT,4],;
									aListUpd[oListUpd:nAT,5] } }

	TButton():New( 210,140, 'Marca/Desmarca Pendentes', oDlgUpd,;
					{|| Aeval(aListUpd,{|aElem| aElem[1] := If(aElem[4] == 'Pendente', lMarcaItem, .F.)}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },; 
					075,015,,,,.T.,,,,,,)

	TButton():New( 210,270, 'Marca/Desmarca Todos', oDlgUpd,;
					{|| Aeval(aListUpd,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem, oListUpd:Refresh() },; 
					075,015,,,,.T.,,,,,,)


	TButton():New( 230,005, 'Selecionar Empresas', oDlgUpd,;
					{|| aEmpresas := UPDSelectSM0(@aEmpresas) },; 
					075,015,,,,.T.,,,,,,)


	TButton():New( 230,140, 'Processar...', oDlgUpd,;
					{|| RpcClearEnv(), MsgRun('Aguarde o termino do Processamento',,{||UPDProcUpd( aListUpd, aEmpresas )}), oDlgUpd:End()},; 
					075,015,,,,.T.,,,,,,)

	TButton():New( 230,270, 'Cancelar', oDlgUpd,;
					{|| RpcClearEnv(), oDlgUpd:End()},; 
					075,015,,,,.T.,,,,,,)	
	
	ACTIVATE MSDIALOG oDlgUpd CENTERED
EndIf
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砋PDPROCUPD?Autor ?Fabrica de Software   ?Data ?13.Nov.06潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?PROCESSA A ATUALIZACAO DO AMBIENTE                         潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDProcUpd( aListUpd, aEmpresas )
Local nAux       := 0
Local nEmpresa   := 0

Local aEstrutSIX := {}
Local aEstrutSX2 := {}
Local aEstrutSX3 := {}
Local aEstrutSX5 := {}
Local aEstrutSX6 := {}
Local aEstrutSX7 := {}
Local aEstrutSXA := {}
Local aEstrutSXB := {}

Local   cTCBuild  := "TCGetBuild"
Local   cTopBuild := ""

Local aTarefas   := {}
Local aSX2       := {}
Local aSIX       := {}
Local aSX3       := {}
Local aSX5       := {}
Local aSX6       := {}
Local aSX7       := {}
Local aSXA       := {}
Local aSXB       := {}
Local aAtualiza  := {{},{},{},{},{},{},{},{}}
Local aResumo    := {}

Local aArqUpd    := {}
Local lDelInd    := .F.

Local i          := 0
Local j          := 0

aEstrutSX2 := {"X2_CHAVE"	,"X2_PATH"		,"X2_ARQUIVO"	,"X2_NOME"		,"X2_NOMESPA"	,;
				   "X2_NOMEENG","X2_DELET"		,"X2_MODO"		,"X2_TTS"		,"X2_ROTINA"	,"X2_PYME", "X2_UNICO", "X2_MODULO"	}

aEstrutSIX := {"INDICE"	,"ORDEM"		,"CHAVE"		,"DESCRICAO"	,"DESCSPA"	,;
				   "DESCENG"	,"PROPRI"		,"F3"			,"NICKNAME"		,"SHOWPESQ"}

aEstrutSX3 := {"X3_ARQUIVO","X3_ORDEM"		,"X3_CAMPO"		,"X3_TIPO"		,"X3_TAMANHO"	,"X3_DECIMAL"	,"X3_TITULO"	,"X3_TITSPA"	,;
		  		   "X3_TITENG" ,"X3_DESCRIC"	,"X3_DESCSPA"	,"X3_DESCENG"	,"X3_PICTURE"	,"X3_VALID"		,"X3_USADO"		,"X3_RELACAO"	,;
				   "X3_F3"		,"X3_NIVEL"		,"X3_RESERV"	,"X3_CHECK"		,"X3_TRIGGER"	,"X3_PROPRI"	,"X3_BROWSE"	,"X3_VISUAL"	,;
				   "X3_CONTEXT","X3_OBRIGAT"	,"X3_VLDUSER"	,"X3_CBOX"		,"X3_CBOXSPA"	,"X3_CBOXENG"	,"X3_PICTVAR"	,"X3_WHEN"		,;
				   "X3_INIBRW"	,"X3_GRPSXG"	,"X3_FOLDER"	,"X3_PYME"	}

aEstrutSX5 := {'X5_FILIAL' , 'X5_TABELA'  ,'X5_CHAVE'		, 'X5_DESCRI'  ,'X5_DESCSPA' ,'X5_DESCENG'}

aEstrutSX6 := {'X6_FIL'    , 'X6_VAR'     , 'X6_TIPO'    , 'X6_DESCRIC', 'X6_DSCSPA' , 'X6_DSCENG' , 'X6_DESC1'  , 'X6_DSCSPA1',;
           		'X6_DSCENG1', 'X6_DESC2'   , 'X6_DSCSPA2' , 'X6_DSCENG2', 'X6_CONTEUD', 'X6_CONTSPA', 'X6_CONTENG', 'X6_PROPRI' }

aEstrutSX7 := {"X7_CAMPO"	, "X7_SEQUENC"	,"X7_REGRA"		, "X7_CDOMIN" ,"X7_TIPO"	 ,"X7_SEEK"		,"X7_ALIAS"	  ,"X7_ORDEM"		,;
				   "X7_CHAVE"	, "X7_PROPRI"	,"X7_CONDIC" }

aEstrutSXA := {'XA_ALIAS'	,'XA_ORDEM'		,'XA_DESCRIC'	, 'XA_DESCSPA','XA_DESCENG' ,'XA_PROPRI'	}

aEstrutSXB := {'XB_ALIAS'	,'XB_TIPO'		,'XB_SEQ'		, 'XB_COLUNA' ,'XB_DESCRI'	 ,'XB_DESCSPA'	,'XB_DESCENG' ,'XB_CONTEM'	,;
					'XB_WCONTEM' }

For nEmpresa := 1 To Len(aEmpresas)
	If aEmpresas[nEmpresa,1]
		lOpen := MyOpenSm0(.F.)
		If lOpen
			SM0->(DbGoTo(aEmpresas[nEmpresa,5]))
			RpcSetType(3) 
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
			nModulo := 43 //SIGATMS
			lMsFinalAuto := .F.

			aTarefas   := {}
			aSX2       := {}
			aSIX       := {}
			aSX3       := {}
			aSX5       := {}
			aSX6       := {}
			aSX7       := {}
			aSXB       := {}
			aAtualiza  := {{},{},{},{},{},{},{},{}}

			//谀哪哪哪哪哪哪哪哪哪哪哪?
			//矷NICIO DAS ATUALIZACOES?
			//滥哪哪哪哪哪哪哪哪哪哪哪?
			For nAux := 1 To Len(aListUpd)
				If aListUpd[nAux,1]
			
					//-- Obtem a lista de tarefas conforme updates selecionados na lista
					aTarefas := &( 'U_' + aListUpd[nAux,2] + '()' )
			
			      For i := 1 To Len(aTarefas[1]) //-- SX2
			        	AAdd( aSX2, aTarefas[1,i] )
			      Next
			
			      For i := 1 To Len(aTarefas[2]) //-- SIX
			        	AAdd( aSIX, aTarefas[2,i] )
			      Next
			
					For i := 1 To Len(aTarefas[3]) //-- SX3
						AAdd( aSX3, aTarefas[3,i] )
					Next
			
			      For i := 1 To Len(aTarefas[4]) //-- SX5
			        	AAdd( aSX5, aTarefas[4,i] )
			      Next
			        
					For i := 1 To Len(aTarefas[5]) //-- SX7
			        	AAdd( aSX7, aTarefas[5,i] )
			      Next
			        
					For i := 1 To Len(aTarefas[6]) //-- SXA
			        	AAdd( aSXA, aTarefas[6,i] )
			        Next
					
					For i := 1 To Len(aTarefas[7]) //-- SXB
			        	AAdd( aSXB, aTarefas[7,i] )
			      Next
			
			      For i := 1 To Len(aTarefas[8]) //-- SX6
			        	AAdd( aSX6, aTarefas[8,i] )
			      Next
				EndIf
			Next
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//砅ROCESSA ATUALIZACOES - SX2?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪?
			SX2->(DbSetOrder(1))
			For i := 1 To Len(aSX2)
				If !SX2->(MsSeek(aSX2[i,1]))
					RecLock("SX2",.T.)
				Else
					RecLock('SX2',.F.)
				EndIf
				For j:=1 To Len(aSX2[i])
					If SX2->(FieldPos(aEstrutSX2[j])) > 0
						SX2->(FieldPut(FieldPos(aEstrutSX2[j]),aSX2[i,j]))
					EndIf
				Next j

				SX2->(dbCommit())
				SX2->(MsUnLock())
				AAdd(aAtualiza[1], aSX2[i] )
					
			Next i

			//谀哪哪哪哪哪哪哪哪哪?
			//?ATUALIZANDO O SX3 ?
			//滥哪哪哪哪哪哪哪哪哪?
			SX3->(DbSetOrder(2))	
			For i := 1 To Len(aSX3)
				If !Empty(aSX3[i,1])
					If AScan(aArqUpd, aSX3[i,1]) == 0
						aAdd(aArqUpd,aSX3[i,1])
					EndIf
					If !SX3->(dbSeek(aSX3[i,3]))
						RecLock("SX3",.T.)
					Else
						RecLock("SX3",.F.)
					EndIf
					For j:=1 To Len(aSX3[i])
						If SX3->(FieldPos(aEstrutSX3[j])) > 0 .And. aSX3[i,j] != NIL
							SX3->(FieldPut(FieldPos(aEstrutSX3[j]),aSX3[i,j]))
						EndIf
					Next j
					SX3->(dbCommit())
					SX3->(MsUnLock())

					AAdd( aAtualiza[3], aSX3[i] )
					
				EndIf
			Next i
			
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪?
			//砅ROCESSA ATUALIZACOES - SIX?
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪?
			SIX->(DbSetOrder(1))	
			For i := 1 To Len(aSIX)
				If !Empty(aSIX[i,1])
					If !SIX->(MsSeek(aSIX[i,1]+aSIX[i,2]))
						RecLock("SIX",.T.)
						lDelInd := .F.
					Else
						RecLock("SIX",.F.)
						lDelInd := .T. //Se for alteracao precisa apagar o indice do banco
					EndIf
					
					If UPPER(AllTrim(SIX->CHAVE)) != UPPER(Alltrim(aSIX[i,3]))
						If AScan( aArqUpd, aSIX[i,1] ) == 0
							aAdd(aArqUpd,aSIX[i,1])
						EndIf
						For j := 1 To Len(aSIX[i])
							If SIX->(FieldPos(aEstrutSIX[j])) > 0
								SIX->(FieldPut(FieldPos(aEstrutSIX[j]),aSIX[i,j]))
							EndIf
						Next j
						SIX->(dbCommit())
						SIX->(MsUnLock())
			
						If lDelInd
							TcInternal(60,RetSqlName(aSix[i,1]) + "|" + RetSqlName(aSix[i,1]) + aSix[i,2]) //Exclui sem precisar baixar o TOP
						Endif	

						AAdd( aAtualiza[2], aSIX[i] )

					EndIf
				EndIf
			Next i

			__SetX31Mode(.F.)

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf


			For i := 1 To Len(aArqUpd)
				If Select(aArqUpd[i]) > 0
					DbSelectArea(aArqUpd[i])
					dbCloseArea()
				EndIf
	
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[i] >= "NQ " .AND. aArqUpd[i] <= "NZZ" ) .OR. ( aArqUpd[i] >= "O0 " .AND. aArqUpd[i] <= "NZZ" ) ) .AND.;
						!aArqUpd[i] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[i] ) > 0
					dbSelectArea( aArqUpd[i] )
					dbCloseArea()
				EndIf

				X31UpdTable(aArqUpd[i])
				
				If __GetX31Error()
					MsgAlert(__GetX31Trace())
					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[i] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
				EndIf
				
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf
			
			Next i

			//谀哪哪哪哪哪哪哪哪哪?
			//?ATUALIZANDO O SX5 ?
			//滥哪哪哪哪哪哪哪哪哪?
			SX5->(DbSetOrder(1)) //--X5_FILIAL+X5_TABELA+X5_CHAVE
			For i := 1 To Len(aSX5)
				If !Empty(aSX5[i,2])
					If !SX5->(MsSeek(PadR(aSX5[i,1],Len(SX5->X5_FILIAL)) + PadR(aSX5[i,2],Len(SX5->X5_TABELA)) + PadR(aSX5[i,3],Len(SX5->X5_CHAVE))))
						RecLock("SX5",.T.)
						SX5->X5_FILIAL := xFilial('SX5')
					Else	
						RecLock("SX5",.F.)
					Endif	
					For j :=1 To Len(aSX5[i])
						If SX5->(FieldPos(aEstrutSX5[j])) > 0
						   SX5->(FieldPut(FieldPos(aEstrutSX5[j]),aSX5[i,j]))
						EndIf
					Next j
					SX5->(dbCommit())
					SX5->(MsUnLock())
					
					AAdd( aAtualiza[4], aSX5[i] )					
					
				EndIf
			Next i
			
			//谀哪哪哪哪哪哪哪哪哪?
			//?ATUALIZANDO O SX7 ?
			//滥哪哪哪哪哪哪哪哪哪?
			SX7->(DbSetOrder(1))	
			For i := 1 To Len(aSX7)
				If !Empty(aSX7[i][1])
					If !SX7->(Msseek( PadR(aSX7[i,1],Len(SX7->X7_CAMPO)) + aSX7[i,2] ))
						RecLock("SX7",.T.)
					Else	
						RecLock("SX7",.F.)
					Endif	
					For j :=1 To Len(aSX7[i])
						If !Empty(SX7->(FieldName(FieldPos(aEstrutSX7[j]))))
							SX7->(FieldPut(FieldPos(aEstrutSX7[j]),aSX7[i,j]))
						EndIf
					Next j
					SX7->(dbCommit())
					SX7->(MsUnLock())
					
					AAdd( aAtualiza[5], aSX7[i] )
					
				EndIf
			Next i
			
			//谀哪哪哪哪哪哪哪哪哪?
			//?ATUALIZANDO O SXA ?
			//滥哪哪哪哪哪哪哪哪哪?
			SXA->(DbSetOrder(1))
			For i := 1 To Len(aSXA)
				If !Empty(aSXA[i,1])
					If !SXA->(Msseek( aSXA[i,1] + aSXA[i,2]))
						RecLock("SXA",.T.)
					Else	
						RecLock("SXA",.F.)
					Endif	
					For j :=1 To Len(aSXA[i])
						If !Empty(SXA->(FieldName(FieldPos(aEstrutSXA[j]))))
							SXA->(FieldPut(FieldPos(aEstrutSXA[j]),aSXA[i,j]))
						EndIf
					Next j
					SXA->(dbCommit())
					SXA->(MsUnLock())
					
					AAdd( aAtualiza[6], aSXA[i] )
					
				EndIf
			Next i	

			//谀哪哪哪哪哪哪哪哪哪?
			//?ATUALIZANDO O SXB ?
			//滥哪哪哪哪哪哪哪哪哪?
			SXB->(DbSetOrder(1)) //--XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA
			For i := 1 To Len(aSXB)
				If !Empty(aSXB[i,1])
					If !SXB->(Msseek( PadR(aSXB[i,1],Len(SXB->XB_ALIAS)) + aSXB[i,2] + aSXB[i,3] + aSXB[i,4] ))
						RecLock("SXB",.T.)
					Else	
						RecLock("SXB",.F.)
					Endif	
					For j :=1 To Len(aSXB[i])
						If !Empty(SXB->(FieldName(FieldPos(aEstrutSXB[j]))))
							SXB->(FieldPut(FieldPos(aEstrutSXB[j]),aSXB[i,j]))
						EndIf
					Next j
					SXB->(dbCommit())
					SXB->(MsUnLock())
					
					AAdd( aAtualiza[7], aSXB[i] )
					
				EndIf
			Next i	
			
			//谀哪哪哪哪哪哪哪哪哪?
			//?ATUALIZANDO O SX6 ?
			//滥哪哪哪哪哪哪哪哪哪?
			SX6->(dbSetOrder(1))
			For i := 1 To Len( aSX6 )
				If !SX6->( dbSeek( PadR( aSX6[i][1], 2 ) + PadR( aSX6[i][2], Len( SX6->X6_VAR) ) ) )
					RecLock( 'SX6', .T. )   
				Else
					RecLock( 'SX6', .F. )
				EndIf												
				For j := 1 To Len( aSX6[i] )
					If SX6->( FieldPos( aEstrutSX6[j] ) ) > 0
						SX6->( FieldPut( FieldPos( aEstrutSX6[j] ), aSX6[i][j] ) )
					EndIf
				Next j
				dbCommit()
				MsUnLock()
	
				AAdd( aAtualiza[8], aSX6[i] )

			Next i
		
			RpcClearEnv()			
			AAdd(aResumo, {aEmpresas[nEmpresa,2] + ' - ' + aEmpresas[nEmpresa,3] + ': ' + aEmpresas[nEmpresa,4], aAtualiza} )
			
		EndIf
	EndIf
Next

UPDViewLog( aResumo )

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    矴etListUpd?Autor 矲SW                    ?Data ?13.Nov.06潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Retorna a Lista com os Updates disponiveis para Realizacao 潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function GetListUpd()
Local aList     := {}
Local nAux      := 0

For nAux := 1 To 99
	cUpdate := StrZero(nAux,2)
	If FindFunction( 'U_FSW' + cUpdate + 'Des' )
	
		aRet := &('U_FSW' + cUpdate + 'Des()' )
		AAdd( aList, {	.F.,;
						aRet[1],;
						aRet[2],;
						IIf(aRet[3], 'Executado', 'Pendente'),;
						aRet[4] } )
	EndIf
Next
Return(aList)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砋PDSelectSM0?Autor 矲SW                  ?Data ?14.Nov.06潮?
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Exibe janela para escolha das empresas que devem ser       潮?
北?         ?processadas                                                潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDSelectSM0(aEmpresas)
Local oDlgSM0
Local oListBox
Local aHList     := {}
Local oOk        := LoadBitMap(GetResources(),"LBOK")
Local oNo        := LoadBitMap(GetResources(),"LBNO")
Local lMarcaItem := .T.

DEFINE MSDIALOG oDlgSM0 TITLE 'Selecione as Empresas para o processamento...' From 9,0 To 30,52

AAdd( aHList, ' ')
AAdd( aHList, 'Empresa' )
AAdd( aHList, 'Filial' )
AAdd( aHList, 'Nome' )
AAdd( aHList, 'Id.')

oListBox := TWBrowse():New(005,005,155,145,,aHList,,oDlgSM0,,,,,,,,,,,,, "ARRAY", .T. )
oListBox:SetArray( aEmpresas )
oListBox:bLine := {|| {	If(aEmpresas[oListBox:nAT,1], oOk, oNo),;
						aEmpresas[oListBox:nAT,2],;
						aEmpresas[oListBox:nAT,3],;
						aEmpresas[oListBox:nAT,4],;
						aEmpresas[oListBox:nAT,5]}}

oListBox:bLDblClick := {|| aEmpresas[oListBox:nAt,1] := !aEmpresas[oListBox:nAt,1], oListBox:Refresh()}

DEFINE SBUTTON FROM    4,170 TYPE 1 ACTION (oDlgSM0:End())   ENABLE OF oDlgSM0
DEFINE SBUTTON FROM 18.5,170 TYPE 11 ACTION (Aeval(aEmpresas,{|aElem|aElem[1] := lMarcaItem}), lMarcaItem := !lMarcaItem,,oListBox:Refresh()) ONSTOP 'Marca/Desmarca' ENABLE OF oDlgSM0

ACTIVATE MSDIALOG oDlgSM0 CENTERED

Return( aEmpresas )

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砋PDViewLog ?Autor 矲SW                   ?Data ?16.Nov.06潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Exibe o LOG das atualizacoes realizadas                    潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDViewLog( aResumo )
Local oDlg
Local oTree
Local oFont
Local oPanel
Local lSair := .F.
Private cTxtShow := ''

lOpen := MyOpenSm0(.F.)
If lOpen
	SM0->(DbGoTop())
	RpcSetType(3) 
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	nModulo := 43 //SIGATMS
	lMsFinalAuto := .F.

	DEFINE FONT oFont NAME "Tahoma" SIZE 0, -10

	DEFINE MSDIALOG oDlg TITLE 'LOG das Atualizacoes' PIXEL FROM 00,00 TO 450,650

	oPanel := tPanel():New(005,114,"",oDlg,,,,,CLR_WHITE,210, 202, .T.) 
	oPanel:Hide()

	oTree           := DbTree():New(005,005,220,110,oDlg,,,.T.)
	oTree:LShowHint := .F.
	oTree:oFont     := oFont
	oTree:bChange   := {|| UPDShowItem( oPanel, oTree, aResumo ) }

	DEFINE SBUTTON FROM 210,260 TYPE 13 ACTION (MsFreeObj(@oPanel, .T.), UpdGrvLog( aResumo )) ENABLE OF oDlg
	DEFINE SBUTTON FROM 210,295 TYPE 2 ACTION (MsFreeObj(@oPanel, .T.), oDlg:End()) ENABLE OF oDlg

	//-- Chama a rotina de construcao do Tree
	MsgRun('Aguarde, Montando o Tree com as atualizacoes...',,{|| UPDTreeLog(oTree, aResumo)} )

	ACTIVATE MSDIALOG oDlg CENTERED
	RpcClearEnv()
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砋PDTreeLog ?Autor 矲SW                   ?Data ?16.Nov.06潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Monta o Tree com as atualizacoes realizadas                潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDTreeLog(oTree, aResumo)
Local i,j
Local cQuebra := ''

For i := 1 To Len( aResumo )

	oTree:AddTree(aResumo[i,1] + Space(30),.T.,,,"FOLDER5","FOLDER6",Space(15))
	
		//-- SX2
		oTree:AddTree('SX2 - Arquivos',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,1]) > 0
			For j := 1 To Len( aResumo[i,2,1] )
				oTree:AddTreeItem( 'Arquivo: ' + aResumo[i,2,1,j,4],'',, 'SX2' + StrZero(i,3) + ',2,1,' + StrZero(j,3) )
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

		//-- SIX
		oTree:AddTree('SIX - Indices',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,2]) > 0
			For j := 1 To Len( aResumo[i,2,2] )
				oTree:AddTreeItem( 'Indice: ' + aResumo[i,2,2,j,4],'',,'SIX' + StrZero(i,3) + ',2,2,' + StrZero(j,3) )
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

		//-- SX3
		oTree:AddTree('SX3 - Dicionario de Dados',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,3]) > 0
			For j := 1 To Len( aResumo[i,2,3] )
				If cQuebra <> aResumo[i,2,3,j,1]
					If !Empty(cQuebra)
						oTree:EndTree()
					EndIf
					oTree:AddTree('Tabela: ' + aResumo[i,2,3,j,1],.T.,,,"FOLDER5","FOLDER6",Space(15))						
					cQuebra := aResumo[i,2,3,j,1]
				EndIf
				oTree:AddTreeItem( 'Campo: ' + aResumo[i,2,3,j,3],'',,'SX3' + StrZero(i,3) + ',2,3,' + StrZero(j,3))
			Next j
			oTree:EndTree()
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

		//-- SX5
		oTree:AddTree('SX5 - Tabelas Genericas',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,4]) > 0
			For j := 1 To Len( aResumo[i,2,4] )
				oTree:AddTreeItem( 'Tabela: ' + aResumo[i,2,4,j,3],'',,'SX5' + StrZero(i,3) + ',2,4,' + StrZero(j,3))
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

		//-- SX7
		oTree:AddTree('SX7 - Gatilhos',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,5]) > 0
			For j := 1 To Len( aResumo[i,2,5] )
				oTree:AddTreeItem( 'Gatilho: ' + aResumo[i,2,5,j,1] + '/' + aResumo[i,2,5,j,2],'',,'SX7' + StrZero(i,3) + ',2,5,' + StrZero(j,3))
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()
		
		//-- SXA
		oTree:AddTree('SXA - Pastas (Folders)',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,6]) > 0
			For j := 1 To Len( aResumo[i,2,6] )
				oTree:AddTreeItem( 'Pasta: ' + aResumo[i,2,6,j,3],'',, 'SXA' + StrZero(i,3) + ',2,6,' + StrZero(j,3))
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

		//-- SXB
		oTree:AddTree('SXB - Consultas Padroes',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,7]) > 0
			For j := 1 To Len( aResumo[i,2,7] )
				If aResumo[i,2,7,j,2] == '1'
					oTree:AddTreeItem( 'Consulta: ' + aResumo[i,2,7,j,5],'',, 'SXB' + StrZero(i,3) + ',2,7,' + StrZero(j,3))
				EndIf
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

		//-- SX6
		oTree:AddTree('SX6 - Par鈓etros',.T.,,,"FOLDER5","FOLDER6",Space(15))
		If Len(aResumo[i,2,8]) > 0
			For j := 1 To Len( aResumo[i,2,8] )
				oTree:AddTreeItem( 'Par鈓etro: ' + aResumo[i,2,8,j,2],'',, 'SX6' + StrZero(i,3) + ',2,8,' + StrZero(j,3))
			Next j
		Else
			oTree:AddTreeItem( 'Nenhuma atualizacao realizada','',,Space(15))
		EndIf
		oTree:EndTree()

	oTree:EndTree()
Next i

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砋PDShowItem?Autor 矲SW                   ?Data ?7/01/2003潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Visualiza o item selecionado no Tree                       潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDShowItem( oPanel, oTree, aResumo )
Local cTab     := Left( oTree:GetCargo(), 3 )
Local cElem    := SubStr( oTree:GetCargo(), 4, 11)
Local oFont


aDados := aClone(aResumo)

DEFINE FONT oFont NAME 'Arial' SIZE 0, -12 BOLD

MsFreeObj(@oPanel, .T.)
oPanel:Hide()

If !Empty(cTab)
	If cTab == 'SX2'
	
	    @ 005,005 To 020, 205 Label 'Tabela:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',1]') + ' - ' + Posicione('SX2',1,&('aDados[' + cElem +',1]'),'X2_NOME');
					Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
        @ 025,005 To 040,100  Label 'Arquivo:' Of oPanel Pixel
        @ 030,008 Say &('aDados[' + cElem +',3]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
        
        @ 025,105 To 040,205 Label 'Path:' Of oPanel Pixel
        @ 030,108 Say &('aDados[' + cElem +',2]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
        
        @ 045,005 To 060,100 Label 'Descri玢o:' Of oPanel Pixel
        @ 050,008 Say &('aDados[' + cElem +',4]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
       
        @ 045,105 To 060,205 Label 'Modo de Acesso:' Of oPanel Pixel
        @ 050,108 Say IF(Upper(&('aDados[' + cElem +',8]')) ==  'E', 'Exclusivo', 'Compartilhado'); 
        			Of oPanel Pixel COLOR CLR_BLUE FONT oFont
        
		@ 065,005 To 080,205 Label 'Rotina:' Of oPanel Pixel
		@ 070,008 Say &('aDados[' + cElem +',10]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

	ElseIf cTab == 'SIX'

	    @ 005,005 To 020, 205 Label 'Arquivo:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',1]') + ' - ' + Posicione('SX2',1,&('aDados[' + cElem +',1]'),'X2_NOME');
					Of oPanel Pixel COLOR CLR_BLUE FONT oFont	
		
		@ 025,005 To 040,030 Label 'Ordem:' Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',2]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 025,035 To 040,205 Label 'Chave:' Of oPanel Pixel
		@ 030,038 Say &('aDados[' + cElem +',3]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 045,005 To 060,205 Label 'Descri玢o:' Of oPanel Pixel
		@ 050,008 Say &('aDados[' + cElem +',4]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
	
	
	ElseIf cTab == 'SX3'

	    @ 005,005 To 020,205 Label 'Arquivo:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',1]') + ' - ' + Posicione('SX2',1,&('aDados[' + cElem +',1]'),'X2_NOME');
					Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 025,005 To 040,070 Label 'Campo:' Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',3]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 025,075 To 040,170 Label 'Titulo:' Of oPanel Pixel
		@ 030,078 Say &('aDados[' + cElem +',7]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 025,175 To 040,205 Label 'Ordem:' Of oPanel Pixel
		@ 030,178 Say &('aDados[' + cElem +',2]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 045,005 To 060,205 Label 'Descri玢o:' Of oPanel Pixel
		@ 050,008 Say &('aDados[' + cElem +',10]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 065,005 To 080,040 Label 'Tamanho:' Of oPanel Pixel
		@ 070,008 Say &('aDados[' + cElem +',5]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 065,045 To 080,080 Label 'Decimal:' Of oPanel Pixel
		@ 070,048 Say &('aDados[' + cElem +',6]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 065,085 To 080,170 Label 'Picture' Of oPanel Pixel
		@ 070,088 Say &('aDados[' + cElem +',13]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 065,175 To 080,205 Label 'Usado:' Of oPanel Pixel
		@ 070,178 Say If(x3uso(&('aDados[' + cElem +',15]')), 'Sim', 'N鉶') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 085,005 To 100,205 Label 'Valida玢o usu醨io:' Of oPanel Pixel
		@ 090,008 Say Left(&('aDados[' + cElem +',27]'),55) + ;
					If(Len(&('aDados[' + cElem +',27]')) > 55, '...','') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 105,005 To 120,205 Label 'Inicializador Padr鉶:' Of oPanel Pixel
		@ 110,008 Say Left(&('aDados[' + cElem +',16]'),55) + ;
					If(Len(&('aDados[' + cElem +',16]')) > 55, '...','') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 125,005 To 140,205 Label 'Inicializador Padr鉶 (Browse):' Of oPanel Pixel
		@ 130,008 Say Left(&('aDados[' + cElem +',33]'),55) +; 
					If(Len(&('aDados[' + cElem +',33]')) > 55, '...','') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 145,005 To 160,205 Label 'Modo de Edi玢o:' Of oPanel Pixel
		@ 150,008 Say Left(&('aDados[' + cElem +',32]'),55) +;
					If(Len(&('aDados[' + cElem +',32]')) > 55, '...','') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 165,005 To 180,040 Label 'Contexto:' Of oPanel Pixel
		@ 170,008 Say If(Upper(&('aDados[' + cElem +',25]')) == 'V', 'Virtual', 'Real') Of oPanel Pixel COLOR CLR_BLUE FONT oFont 
		
		@ 165,045 To 180,085 Label 'Propriedade:' Of oPanel Pixel
		@ 170,048 Say If(Upper(&('aDados[' + cElem +',24]')) == 'A', 'Alterar', 'Visualizar') Of oPanel Pixel COLOR CLR_BLUE FONT oFont 

		@ 165,090 To 180,125 Label 'Browse:' Of oPanel Pixel
		@ 170,093 Say If(Upper(&('aDados[' + cElem +',23]')) == 'S', 'Sim', 'N鉶') Of oPanel Pixel COLOR CLR_BLUE FONT oFont 
		
		@ 165,130 To 180,175 Label 'Cons. Padr鉶:' Of oPanel Pixel
		@ 170,133 Say &('aDados[' + cElem +',17]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont 
		
		@ 165,180 To 180,205 Label 'Pasta:' Of oPanel Pixel
		@ 170,183 Say &('aDados[' + cElem +',35]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont 
		
		@ 185,005 To 200,205 Label 'Lista de Op珲es:' Of oPanel Pixel
		@ 190,008 Say &('aDados[' + cElem +',28]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont 

	ElseIf cTab == 'SX5'
	    @ 005,005 To 020,040 Label 'Tabela:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',2]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont	
		
		@ 005,045 To 020,085 Label 'Chave:' Of oPanel Pixel
		@ 010,048 Say &('aDados[' + cElem +',3]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont	
		
		@ 025,005 To 040,205 Label 'Descri玢o:' Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',4]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont			

	ElseIf cTab == 'SX7'
	
		@ 005,005 To 020,050 Label 'Origem:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',1]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont	
		
		@ 005,055 To 020,105 Label 'Destino:' Of oPanel Pixel
		@ 010,058 Say &('aDados[' + cElem +',4]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 005,110 To 020,145 Label 'Seq.:' Of oPanel Pixel
		@ 010,113 Say &('aDados[' + cElem +',2]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 005,150 To 020,205 Label 'Tipo:' Of oPanel Pixel
		@ 010,153 Say If(AllTrim(&('aDados[' + cElem +',5]')) == 'P', 'Primario', If(AllTrim(&('aDados[' + cElem +',4]')) == 'E', 'Estrangeiro', 'Posicionamento')); 
					Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 025,005 To 040,205 Label 'Regra:' Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',3]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 045,005 To 060,035 Label 'Posiciona?' Of oPanel Pixel
		@ 050,008 Say If(Upper(&('aDados[' + cElem +',6]')) == 'S', 'Sim', 'N鉶') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 045,040 To 060,070 Label 'Alias:' Of oPanel Pixel
		@ 050,043 Say &('aDados[' + cElem +',7]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 045,075 To 060,105 Label 'Ordem:' Of oPanel Pixel
		@ 050,078 Say &('aDados[' + cElem +',8]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 065,005 To 080,205 Label 'Chave:' Of oPanel Pixel
		@ 070,008 Say Left(&('aDados[' + cElem +',9]'),55) + IF(Len(&('aDados[' + cElem +',9]')) > 55, '...', '') ;
					Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 085,005 To 100,205 Label 'Condicao:' Of oPanel Pixel
		@ 090,008 Say &('aDados[' + cElem +',11]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
	
	ElseIf cTab == 'SXA'
	
		@ 005,005 To 020,045 Label 'Alias:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',1]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 005,050 To 020,090 Label 'Ordem:' Of oPanel Pixel
		@ 010,053 Say &('aDados[' + cElem +',02]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont
		
		@ 025,005 To 040,205 Label 'Descri玢o' Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',3]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

	ElseIf cTab == 'SXB'
		@ 005,005 To 020,045 Label 'Alias:' Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',1]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 025,005 To 040,205 Label 'Descri玢o' Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',5]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

	ElseIf cTab == 'SX6'
		@ 005,005 To 020,065 Label 'Par鈓etro:'    Of oPanel Pixel
		@ 010,008 Say &('aDados[' + cElem +',02]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 025,005 To 040,205 Label 'Descri玢o'     Of oPanel Pixel
		@ 030,008 Say &('aDados[' + cElem +',04]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 045,005 To 060,205 Label 'Descri玢o1'    Of oPanel Pixel
		@ 050,008 Say &('aDados[' + cElem +',07]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 065,005 To 080,205 Label 'Descri玢o2'    Of oPanel Pixel
		@ 070,008 Say &('aDados[' + cElem +',10]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

		@ 085,005 To 100,205 Label 'Conte鷇o'      Of oPanel Pixel
		@ 090,008 Say &('aDados[' + cElem +',13]') Of oPanel Pixel COLOR CLR_BLUE FONT oFont

	EndIf

	oPanel:Refresh(.T.)
	oPanel:Show()
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砋PDGrvLog  ?Autor 矲SW                   ?Data ?20.Nov.06潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Grava os Dados da Execucao do LOG                          潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function UPDGrvLog( aResumo )
Local cTexto := ''
Local i      := 0
Local j      := 0
Local cFile  := ''         
Local cMask  := "Arquivos Texto (*.TXT) |*.txt|"

cFile := cGetFile(cMask,"")

If !Empty(cFile)
	For i := 1 To Len(aResumo)
		
		cTexto += Repl('=',220)
		cTexto += _CRLF		
		cTexto += 'Empresa: ' + aResumo[i,1] + _CRLF
		cTexto += Repl('=',220)
	
		cTexto += _CRLF
		cTexto += 'Atualizacoes - SX2: Tabelas' + _CRLF
		If Len(aResumo[i,2,1]) > 0
			cTexto += 'Alias  Path                                      Arquivo   Descricao                       Modo Acesso' + _CRLF
			For j := 1 To Len( aResumo[i,2,1] )
			cTexto += aResumo[i,2,1,j,1] + Space(04) +;
						aResumo[i,2,1,j,2] + Space(02) +;
						aResumo[i,2,1,j,3] + Space(02) +;
						PadR(aResumo[i,2,1,j,4],30) + Space(02) +;
						If(Upper(aResumo[i,2,1,j,8]) == 'E', 'Exclusivo', 'Compartilhado') + _CRLF 
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
		EndIf
	
		cTexto +=  _CRLF
		cTexto += 'Atualizacoes - SIX: Indices' + _CRLF
		If Len(aResumo[i,2,2]) > 0
			cTexto += 'Indice  Ordem  Chave                                               Descricao' + _CRLF
			For j := 1 To Len( aResumo[i,2,2] )
				cTexto += aResumo[i,2,2,j,1] + Space(09) +;
							aResumo[i,2,2,j,2] + Space(02) +;
							PadR(Left(aResumo[i,2,2,j,3],50),50) + Space(02) +;
							Left(aResumo[i,2,2,j,4],50) + _CRLF
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
		EndIf
	    
		cTexto += _CRLF
		cTexto += 'Atualizacoes - SX3: Dicionario de Dados' + _CRLF
		If Len(aResumo[i,2,3]) > 0
			cTexto += 'Arquivo  Ordem  Campo       Tipo  Tamanho  Decimais  Titulo        Descricao' + _CRLF
			For j := 1 To Len( aResumo[i,2,3] )
				cTexto += aResumo[i,2,3,j,1] + Space(09) +;
							aResumo[i,2,3,j,2] + Space(02) +;
							PadR(aResumo[i,2,3,j,3],10) + Space(05) +;
							aResumo[i,2,3,j,4] + Space(06) +;
							Str(aResumo[i,2,3,j,5],3) + Space(09) +;
							Str(aResumo[i,2,3,j,6],1) + Space(02) +;
							PadR(aResumo[i,2,3,j,7],12) + Space(02) +;
							aResumo[i,2,3,j,10] + _CRLF
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
		EndIf
	
		cTexto +=  _CRLF
		cTexto += 'Atualizacoes - SX5: Tabelas Genericas' + _CRLF
		If Len(aResumo[i,2,4]) > 0
			cTexto += 'Tabela  Chave   Descricao' + _CRLF
			For j := 1 To Len( aResumo[i,2,4] )
				cTexto += aResumo[i,2,4,j,1] + Space(06) +;
							aResumo[i,2,4,j,2] + Space(02) +;
							aResumo[i,2,4,j,3] + _CRLF
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
		EndIf
	
		cTexto += _CRLF
		cTexto += 'Atualizacoes - SX7: Gatilhos' + _CRLF
		If Len(aResumo[i,2,5]) > 0
			cTexto += 'Origem      Destino     Seq  Regra' + _CRLF
			For j := 1 To Len( aResumo[i,2,5] )
				cTexto += PadR(aResumo[i,2,5,j,1],10) + Space(02) +;
							PadR(aResumo[i,2,5,j,4],10) + Space(02) +;
							aResumo[i,2,5,j,2] + Space(02) +;
							aResumo[i,2,5,j,3] + _CRLF
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
		EndIf
	
		cTexto +=  _CRLF
		cTexto += 'Atualizacoes - SXA: Pastas' + _CRLF
		If Len(aResumo[i,2,6]) > 0
			cTexto += 'Arquivo  Ordem  Descricao' + _CRLF
			For j := 1 To Len( aResumo[i,2,6] )
				cTexto += aResumo[i,2,6,j,1] + Space(10) +;
							aResumo[i,2,6,j,2] + Space(02) +;
							aResumo[i,2,6,j,3] + _CRLF
				
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
		EndIf
	
		cTexto +=  _CRLF
		cTexto += 'Atualizacoes - SXB: Consultas Padroes' + _CRLF
		If Len(aResumo[i,2,7]) > 0
			cTexto += 'Arquivo  Tipo  Sq  Coluna  Descricao             Conteudo' + _CRLF
			For j := 1 To Len( aResumo[i,2,7] )
				cTexto += PadR(aResumo[i,2,7,j,1],6) + Space(06) +;
							aResumo[i,2,7,j,2] + Space(02) +;
							aResumo[i,2,7,j,3] + Space(06) +;
							PadR(aResumo[i,2,7,j,4],2) + Space(02) +;
							PadR(aResumo[i,2,7,j,5],20) + Space(06) +;
							Left(aResumo[i,2,7,j,8],160) + _CRLF
			Next j
		Else
			cTexto += 'Nenhuma atualizacao realizada.' + _CRLF
	    EndIf
	Next

	MemoWrite(cFile,cTexto)
	
	MsgInfo('Arquivo de LOG salvo com sucesso!')
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    矼yOpenSM0Ex?Autor 矲SW                   ?Data ?7/01/2003潮?
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Efetua a abertura do SM0 exclusivo                         潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function MyOpenSM0(lShared)
Local   lOpen   := .F.
Local   nLoop   := 0
default lShared := .F.

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
	MsgStop( "N?o foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATEN??O" )
EndIf

Return lOpen


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    砎erIndice ?Autor 矲SW                    ?Data ?6/01/2009潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o 矨tualiza a ordem dos indices                                潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?/
User Function UPDIndex(aSIX)
Local nTmp
Local cOrdem

cTab := ""

// verifica se o indice ja existe no SIX
SIX->(dBsetOrder(1))
For nTmp := 1 to Len(aSIX)  
	if cTab <> aSIX[nTmp,1]
		cTab := aSIX[nTmp,1]
		// localiza a ultima ordem
		SIX->(dbSeek(cTab+"z",.T.))
		SIX->(dbskip(-1))
		If SIX->(!Eof()) .and. SIX->INDICE == cTab
			cOrdem := SIX->ORDEM
		Else
			cOrdem := "0"
		EndIf
	Endif	

	if ! Empty(aSIX[nTmp,9])
		SIX->(dbSeek(cTab))
		Do While SIX->(!Eof()) .And. SIX->INDICE == cTab
			If Alltrim(SIX->NICKNAME) == Alltrim(aSIX[nTmp,9])
				aSIX[nTmp,2] := SIX->ORDEM
			Endif	
			SIX->(dbskip())
		EndDo
		if Empty(aSIX[nTmp,2])
			cOrdem 			:= Soma1(cOrdem)
			aSIX[nTmp,2]	:= cOrdem
		Endif	
	Endif	
Next

Return Nil
