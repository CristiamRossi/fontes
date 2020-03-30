#INCLUDE "Protheus.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ UPDFSW01 ≥Autor  ≥ DLeme                 ≥Data  ≥ 20.Abr.12≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ AtualizaÁıes Modal Aquaviario                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Projeto   ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Bardella                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function UPDFSW03()
Local aRet      := {{},{},{},{},{},{},{},{}}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ ESTRUTURA DO ARRAY aRET:                                             ≥
//√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
//≥ aRet[01] - Array com os dados SX2                                    ≥
//≥ aRet[02] - Array com os dados SIX                                    ≥
//≥ aRet[03] - Array com os dados SX3                                    ≥
//≥ aRet[04] - Array com os dados SX5                                    ≥
//≥ aRet[05] - Array com os dados SX7                                    ≥
//≥ aRet[06] - Array com os dados SXA                                    ≥
//≥ aRet[07] - Array com os dados SXB                                    ≥
//≥ aRet[08] - Array com os dados SX6                                    ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

aRet[1] := TMSAtuSX2()
aRet[2] := TMSAtuSIX()
aRet[3] := TMSAtuSX3()
aRet[5] := TMSAtuSX7()
aRet[6] := TMSAtuSXA()
aRet[7] := TMSAtuSXB()
aRet[8] := TMSAtuSX6()

Return(aRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSX2 ≥ Autor ≥ FSW                   ≥ Data ≥ 20.Mar.11≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SX2                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSAtuSX2()
Local aSX2      := {}     
Local cPath     := Posicione('SX2',1,'DT6','X2_PATH')
Local cNome     := SubStr(Posicione('SX2',1,'DT6','X2_ARQUIVO'),4,5)

Return(aSX2)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSIX ≥ Autor ≥ FSW                   ≥ Data ≥ 20.Mar.11≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SIX                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSAtuSIX()
Local aSIX := {}
			
Return(aSIX)


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSX3 ≥ Autor ≥ DLeme      ≥ Data ≥ 20.Mar.11≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SX3                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function TMSAtuSX3()

Local aSX3      := {}
Local aPropCpos := {}
Local cOrdem    := "01"
Local aCpos,nI
Local aArea := GetArea()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥VERIFICA AS PROPRIEDADES DOS CAMPOS≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea("SX3")
SX3->(DbSetOrder(2))

AAdd( aPropCpos, {'FILIAL'} )
AAdd( aPropCpos, {'OBRIGATORIO-NAO ALTERAVEL'} )
AAdd( aPropCpos, {'VIRTUAL'} )
AAdd( aPropCpos, {'NORMAL'} )
AAdd( aPropCpos, {'OBRIGATORIO-ALTERAVEL'})
AAdd( aPropCpos, {'NORMAL-TODOS OS MODULOS'})

//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Filial)
If SX3->( MsSeek( "DTC_FILIAL" ) )
	AAdd( aPropCpos[1], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Obrigatorio - Nao Alteravel)
If SX3->( MsSeek( "A1_COD    " ) )
	AAdd( aPropCpos[2], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Virtual)
If SX3->( MsSeek( "DTY_NOMFOR" ) )
	AAdd( aPropCpos[3], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo existente para gravar o Reserv e o Usado (Campo Normal, sem obrigatoriedade)
If SX3->( MsSeek( "A1_BAIRRO"  ) )
	AAdd( aPropCpos[4], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf
//--Pesquisa um campo OBRIGATORIO existente para gravar o Reserv e o Usado (Campo Obrigatorio - Alteravel)
If SX3->( MsSeek( "A1_NOME   " ) )
	AAdd( aPropCpos[5], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf 
//--Pesquisa um campo Normal - todos os modulos (Campo Normal - sem obrigatoriedade)
If SX3->( MsSeek( "A1_BAIRRO" ) )
	AAdd( aPropCpos[6], {SX3->X3_USADO, SX3->X3_RESERV} )
EndIf

aCpos := RetCpos()
nDecimais := 0      
nTam      := 5

DbSelectArea("SX3")
For nI := 1 To Len(aCpos)
	//-- Somente atualiza se o campo existir e a qtde de decimais for Menor que a definida
	If SX3->( MsSeek( aCpos[nI] ) ) .And. SX3->X3_DECIMAL <= nDecimais 
		//If !Empty(X3_PICTURE) .And. !("!"$X3_PICTURE)
			//cPicture := Iif( Len(AllTrim( Substr(X3_PICTURE,1,At(".9",X3_PICTURE))+Repl("9",nDecimais) )) > Len(AllTrim(X3_PICTURE)),;
			//			     Substr(X3_PICTURE,1,At(".9",X3_PICTURE))+Repl("9",nDecimais),;
			//			     X3_PICTURE)      
			//cPicture := "@E 99,999,999.99999"
		//Else
			//cPicture := "@E " + Repl("9",Min(18,X3_TAMANHO+nDecimais-X3_DECIMAL)-nDecimais-1)+"."+Repl("9",nDecimais)
			cPicture := "@!"
		//EndIf

		Aadd(aSX3,{X3_ARQUIVO,;		//Arquivo
					X3_ORDEM,;		//Ordem
					X3_CAMPO,;		//Campo
					X3_TIPO,;		//Tipo
					nTam,;          //Min(18,X3_TAMANHO+nDecimais-X3_DECIMAL),;                   //Tamanho
					nDecimais,;		//Decimal                               
					X3_TITULO,;		//Titulo
					X3_TITSPA,;		//Titulo SPA
					X3_TITENG,;		//Titulo ENG
					X3_DESCRIC,;	//Descricao
					X3_DESCSPA,;	//Descricao SPA
					X3_DESCENG,;	//Descricao ENG
					cPicture,;  	//Picture
					X3_VALID,;					//VALID
					X3_USADO,;	//USADO
					X3_RELACAO,;				//RELACAO
					X3_F3,;					//F3
					X3_NIVEL,;						//NIVEL
					X3_RESERV,;	//RESERV
					X3_CHECK,;					//CHECK
					X3_TRIGGER,;					//TRIGGER
					X3_PROPRI,;					//PROPRI
					X3_BROWSE,;					//BROWSE
					X3_VISUAL,;					//VISUAL
					X3_CONTEXT,;					//CONTEXT
					X3_OBRIGAT,;					//OBRIGAT
					X3_VLDUSER,;//VLDUSER
					X3_CBOX,;	//CBOX
					X3_CBOXSPA,;	//CBOX SPA
					X3_CBOXENG,;	//CBOX ENG
					X3_PICTVAR,;					//PICTVAR
					X3_WHEN,;//WHEN
					X3_INIBRW,;					//INIBRW
					X3_GRPSXG,;					//SXG
					X3_FOLDER,;					//FOLDER
					X3_PYME})					//PYME
	EndIf				
Next nI
RestArea(aArea)
			
Return(aSX3)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSXA ≥ Autor ≥ DLeme                 ≥ Data ≥ 07.Ago.09≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SXA                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSAtuSXA()

Local aSXA := {}

Return(aSXA)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSXB ≥ Autor ≥ DLeme      ≥ Data ≥ 07.Out.09≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SXB                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSAtuSXB()

Local aSXB := {}

Return(aSXB)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSX6 ≥ Autor ≥ FSW                   ≥ Data ≥ 20.Jul.09≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SX6                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSAtuSX6()
Local aSX6 := {} 

Return(aSX6)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥TMSAtuSX7 ≥ Autor ≥ DLeme                 ≥ Data ≥ 05/01/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os dados para atualizacao do SX7                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSAtuSX7()

Local aSX7 := {}


Return(aSX7)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ FSW01Des ≥ Autor ≥ FSW                   ≥ Data ≥ 20.Mar.11≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna a Descricao do Update                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function FSW03Des()
Local aRet := {}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ ESTRUTURA DO ARRAY aRET:                                             ≥
//√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
//≥ aRet[01] - (C) Nome da Function                                      ≥
//≥ aRet[02] - (C) Descritivo do Update                                  ≥
//≥ aRet[03] - (L) Situacao para determinar se o Update ja foi executado ≥
//≥ aRet[04] - (C) Projeto LÛgico                                        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
AAdd( aRet, 'UPDFSW03')
AAdd( aRet, 'Unidade de Medida' )
AAdd( aRet, JaRodou() )
AAdd( aRet, 'GENESIS' )

Return( aRet )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ JaRodou  ≥ Autor ≥ D'Leme                ≥ Data ≥ 18.Dez.12≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna se o Update j· foi rodado                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function JaRodou()
Local lRet := .T.
Local aCpos := RetCpos()
Local nI
Local aArea := GetArea()

nDecimais := 5
DbSelectArea("SX3")
DbSetOrder(2)
For nI := 1 To Len(aCpos)
	If SX3->( MsSeek( aCpos[nI] ) ) .And. SX3->X3_DECIMAL != nDecimais 
		lRet := .F.
		Exit
	EndIf
Next nI

RestArea(aArea)
Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ RetCpos  ≥ Autor ≥ D'Leme                ≥ Data ≥ 18.Dez.12≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Retorna os campos que dever„o sofrer update                ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function RetCpos()
Local aCpos := {}


aAdd(aCpos,'ABG_UM')
aAdd(aCpos,'ABG_SEGUM')
aAdd(aCpos,'ADB_UM')
aAdd(aCpos,'ADB_SEGUM')
aAdd(aCpos,'AE1_UM')
aAdd(aCpos,'AE2_SEGUM')
aAdd(aCpos,'AF2_UM')
aAdd(aCpos,'AF3_SEGUM')
aAdd(aCpos,'AF5_UM')
aAdd(aCpos,'AF9_UM')
aAdd(aCpos,'AFA_SEGUM')
aAdd(aCpos,'AFC_UM')
aAdd(aCpos,'AJT_UM')
aAdd(aCpos,'AJU_SEGUM')
aAdd(aCpos,'AJZ_UM')
aAdd(aCpos,'AJZ_SEGUM')
aAdd(aCpos,'AK2_UM')
aAdd(aCpos,'AMZ_UM')
aAdd(aCpos,'BIT_UNIMED')
aAdd(aCpos,'CNB_UM')
aAdd(aCpos,'CON_UM')
aAdd(aCpos,'CTQ_UM')
aAdd(aCpos,'CV9_UM')
aAdd(aCpos,'CW3_UM')
aAdd(aCpos,'CZB_UNMD')
aAdd(aCpos,'DBC_UM')
aAdd(aCpos,'DBC_SEGUM')
aAdd(aCpos,'DY3_UN')
aAdd(aCpos,'ED1_UMPROD')
aAdd(aCpos,'ED1_UMNCM')
aAdd(aCpos,'ED1_UMANEX')
aAdd(aCpos,'ED2_UMITEM')
aAdd(aCpos,'ED2_UMNCM')
aAdd(aCpos,'ED2_UMANEX')
aAdd(aCpos,'ED3_UMPROD')
aAdd(aCpos,'ED4_UMITEM')
aAdd(aCpos,'ED8_UM')
aAdd(aCpos,'ED8_UMNCM')
aAdd(aCpos,'ED9_UM')
aAdd(aCpos,'ED9_UMNCM')
aAdd(aCpos,'EDH_UMNCM')
aAdd(aCpos,'EDH_UMPROC')
aAdd(aCpos,'EE7_UNIDAD')
aAdd(aCpos,'EE8_UNIDAD')
aAdd(aCpos,'EE8_UNPRC')
aAdd(aCpos,'EE8_UNPES')
aAdd(aCpos,'EE9_UNIDAD')
aAdd(aCpos,'EE9_UNPRC')
aAdd(aCpos,'EE9_UNPES')
aAdd(aCpos,'EEC_UNIDAD')
aAdd(aCpos,'EIJ_UM_EST')
aAdd(aCpos,'EJX_UM')
aAdd(aCpos,'EJZ_UM')
aAdd(aCpos,'EXR_UNIDAD')
aAdd(aCpos,'EXS_UNIDAD')
aAdd(aCpos,'EY6_UNIDAD')
aAdd(aCpos,'EYU_NCM_UM')
aAdd(aCpos,'EYU_UMPROD')
aAdd(aCpos,'GBI_UNICON')
aAdd(aCpos,'GGW_UNICON')
aAdd(aCpos,'GIM_UM')
aAdd(aCpos,'GIO_UM')
aAdd(aCpos,'GNS_UNPRES')
aAdd(aCpos,'GNS_UNFATU')
aAdd(aCpos,'GUD_UNIMED')
aAdd(aCpos,'GUV_UNIDE')
aAdd(aCpos,'GUV_UNIPAR')
aAdd(aCpos,'GV7_UNICAL')
aAdd(aCpos,'GV9_UNIFAI')
aAdd(aCpos,'ME2_UM')
aAdd(aCpos,'NJB_UM1PRO')
aAdd(aCpos,'NJF_UM1PRO')
aAdd(aCpos,'NJF_UNIDAD')
aAdd(aCpos,'NJJ_UM1PRO')
aAdd(aCpos,'NJM_UM1PRO')
aAdd(aCpos,'NJR_UM1PRO')
aAdd(aCpos,'NJR_UMPRC')
aAdd(aCpos,'NJV_UM1PRO')
aAdd(aCpos,'NJV_UM1SPD')
aAdd(aCpos,'NJX_UM1PRO')
aAdd(aCpos,'NJX_UMPRC')
aAdd(aCpos,'NK0_UM1PRO')
aAdd(aCpos,'NK8_UM1PRO')
aAdd(aCpos,'NKG_UM1PRO')
aAdd(aCpos,'NKG_UMTAR')
aAdd(aCpos,'NKQ_UMTAR')
aAdd(aCpos,'NM1_UM')
aAdd(aCpos,'NM5_UM')
aAdd(aCpos,'NM6_UM')
aAdd(aCpos,'NNF_UNIMED')
aAdd(aCpos,'NNH_UM1PRO')
aAdd(aCpos,'NNX_UMORIG')
aAdd(aCpos,'NNX_UMDEST')
aAdd(aCpos,'NO1_UM1PRO')
aAdd(aCpos,'NO2_UM')
aAdd(aCpos,'NOA_UM')
aAdd(aCpos,'NP2_UM')
aAdd(aCpos,'NP6_UM')
aAdd(aCpos,'NP9_2UM')
aAdd(aCpos,'NPE_UM')
aAdd(aCpos,'NPE_2UM')
aAdd(aCpos,'NPF_UM')
aAdd(aCpos,'NPF_2UM')
aAdd(aCpos,'NPH_UM')
aAdd(aCpos,'NPH_SEGUM')
aAdd(aCpos,'QE6_UNMED1')
aAdd(aCpos,'QE6_UNAMO1')
aAdd(aCpos,'QE6_UNMED2')
aAdd(aCpos,'QE6_UNAMO2')
aAdd(aCpos,'QE7_UNIMED')
aAdd(aCpos,'QI2_UNIMED')
aAdd(aCpos,'QK2_UM')
aAdd(aCpos,'QM3_UNIMED')
aAdd(aCpos,'QM4_UM')
aAdd(aCpos,'QM9_UNIMED')
aAdd(aCpos,'QMG_UNIMED')
aAdd(aCpos,'QP6_UNMED1')
aAdd(aCpos,'QP6_UNAMO1')
aAdd(aCpos,'QP6_UNMED2')
aAdd(aCpos,'QP6_UNAMO2')
aAdd(aCpos,'QP7_UNIMED')
aAdd(aCpos,'A5_UNID')
aAdd(aCpos,'AP_DE')
aAdd(aCpos,'AP_PARA')
aAdd(aCpos,'B1_UM')
aAdd(aCpos,'B1_SEGUM')
aAdd(aCpos,'B4_UM')
aAdd(aCpos,'B4_SEGUM')
aAdd(aCpos,'B5_UMDIPI')
aAdd(aCpos,'BI_UM')
aAdd(aCpos,'BI_SEGUM')
aAdd(aCpos,'BR_UM')
aAdd(aCpos,'C1_UM')
aAdd(aCpos,'C1_SEGUM')
aAdd(aCpos,'C2_UM')
aAdd(aCpos,'C3_SEGUM')
aAdd(aCpos,'C6_UM')
aAdd(aCpos,'C6_SEGUM')
aAdd(aCpos,'C7_UM')
aAdd(aCpos,'C7_SEGUM')
aAdd(aCpos,'C8_UM')
aAdd(aCpos,'C8_SEGUM')
aAdd(aCpos,'CK_UM')
aAdd(aCpos,'CP_UM')
aAdd(aCpos,'CP_SEGUM')
aAdd(aCpos,'CQ_UM')
aAdd(aCpos,'CQ_SEGUM')
aAdd(aCpos,'CY_UM')
aAdd(aCpos,'CY_SEGUM')
aAdd(aCpos,'D1_UM')
aAdd(aCpos,'D1_SEGUM')
aAdd(aCpos,'D2_SEGUM')
aAdd(aCpos,'D2_UM')
aAdd(aCpos,'D3_UM')
aAdd(aCpos,'D3_SEGUM')
aAdd(aCpos,'D6_UM')
aAdd(aCpos,'J5_DE')
aAdd(aCpos,'J5_PARA')
aAdd(aCpos,'L2_UM')
aAdd(aCpos,'L2_SEGUM')
aAdd(aCpos,'LN_UM')
aAdd(aCpos,'LN_SEGUM')
aAdd(aCpos,'LR_UM')
aAdd(aCpos,'LR_SEGUM')
aAdd(aCpos,'S4_UM')
aAdd(aCpos,'S4_SEGUM')
aAdd(aCpos,'S5_UMDIPI')
aAdd(aCpos,'T6_UNIDAD1')
aAdd(aCpos,'T6_UNIDAD2')
aAdd(aCpos,'TB_UNIDADE')
aAdd(aCpos,'UB_UM')
aAdd(aCpos,'W1_UM')
aAdd(aCpos,'W3_UM')
aAdd(aCpos,'W3_SEGUM')
aAdd(aCpos,'WT_UM')
aAdd(aCpos,'YD_UNID')
aAdd(aCpos,'YD_UM')
aAdd(aCpos,'TAA_UNIMET')
aAdd(aCpos,'TAA_UNIMED')
aAdd(aCpos,'TAS_UM')
aAdd(aCpos,'TAZ_UNIMED')
aAdd(aCpos,'TB2_UNIMED')
aAdd(aCpos,'TB4_UNIMED')
aAdd(aCpos,'TB6_UM')
aAdd(aCpos,'TC8_UM')
aAdd(aCpos,'TCC_UNIMED')
aAdd(aCpos,'TCI_UNIMED')
aAdd(aCpos,'TD0_UNIMED')
aAdd(aCpos,'TDN_UM')
aAdd(aCpos,'TEI_UNIDAD')
aAdd(aCpos,'TEV_UM')
aAdd(aCpos,'TF1_UNIDAD')
aAdd(aCpos,'TG1_UNIMED')
aAdd(aCpos,'TJ7_UNIDAD')
aAdd(aCpos,'TJZ_UNIMED')
aAdd(aCpos,'TLA_PESOUN')
aAdd(aCpos,'TM1_UNIDAD')
aAdd(aCpos,'TM8_UNIDAD')
aAdd(aCpos,'TMB_UNIDAD')
aAdd(aCpos,'TN0_UNIMED')
aAdd(aCpos,'TNC_DISTUN')
aAdd(aCpos,'TNE_UNIPAR')
aAdd(aCpos,'TNE_UNIPIS')
aAdd(aCpos,'TNE_UNITET')
aAdd(aCpos,'TNE_UNIPOR')
aAdd(aCpos,'TNE_UNIVIS')
aAdd(aCpos,'TNI_UNIMED')
aAdd(aCpos,'TO5_UNIME1')
aAdd(aCpos,'TO5_UNIME2')
aAdd(aCpos,'TPB_UNIDAD')
aAdd(aCpos,'TQM_UM')
aAdd(aCpos,'TQR_UNPROD')
aAdd(aCpos,'TV5_UMELO')
aAdd(aCpos,'TV5_UMBUC')
aAdd(aCpos,'TV5_UMSAP')
aAdd(aCpos,'TV5_UMRDD')
aAdd(aCpos,'TV5_UMRDT')
aAdd(aCpos,'TV5_UMRS1')
aAdd(aCpos,'TV5_UMRS2')
aAdd(aCpos,'TV5_UMRE1')
aAdd(aCpos,'TV5_UMRE2')
aAdd(aCpos,'TV5_UMRE3')
aAdd(aCpos,'TV5_UMRE4')
aAdd(aCpos,'TV5_UMRE5')
aAdd(aCpos,'TV5_UMRE6')
aAdd(aCpos,'TV5_UMRE7')
aAdd(aCpos,'TV5_UMRE8')
aAdd(aCpos,'TV5_UMRDM')
aAdd(aCpos,'TVH_UMELO')
aAdd(aCpos,'TVH_UMBUC')
aAdd(aCpos,'TVH_UMSAP')
aAdd(aCpos,'TVH_UMRDD')
aAdd(aCpos,'TVH_UMRDT')
aAdd(aCpos,'TVH_UMRS1')
aAdd(aCpos,'TVH_UMRS2')
aAdd(aCpos,'TVH_UMRE1')
aAdd(aCpos,'TVH_UMRE2')
aAdd(aCpos,'TVH_UMRE3')
aAdd(aCpos,'TVH_UMRE4')
aAdd(aCpos,'TVH_UMRE5')
aAdd(aCpos,'TVH_UMRE6')
aAdd(aCpos,'TVH_UMRE7')
aAdd(aCpos,'TVH_UMRE8')
aAdd(aCpos,'TVH_UMRDM')
aAdd(aCpos,'TZ5_UNIMED')
aAdd(aCpos,'NKT_UMPAR')
aAdd(aCpos,'B5_UMPRC')
aAdd(aCpos,'AH_UNIMED')


Return aCpos