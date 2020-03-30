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
User Function UPDFSW01()
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
nDecimais := 3      
nTam      := 13

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
			cPicture := "@E 999,999,999.999"
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
User Function FSW01Des()
Local aRet := {}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ ESTRUTURA DO ARRAY aRET:                                             ≥
//√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
//≥ aRet[01] - (C) Nome da Function                                      ≥
//≥ aRet[02] - (C) Descritivo do Update                                  ≥
//≥ aRet[03] - (L) Situacao para determinar se o Update ja foi executado ≥
//≥ aRet[04] - (C) Projeto LÛgico                                        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
AAdd( aRet, 'UPDFSW01')
AAdd( aRet, 'Decimais QTDE' )
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


aAdd(aCpos,'ACQ_QUANT') 
aAdd(aCpos,'ACQ_LOTE') 
aAdd(aCpos,'ACR_LOTE')
aAdd(aCpos,'AD6_QUANT') 
aAdd(aCpos,'ADB_QUANT') 
aAdd(aCpos,'ADB_UNSVEN')
aAdd(aCpos,'ADB_QTDENT')
aAdd(aCpos,'ADB_QTDEMP')
aAdd(aCpos,'ADU_QUANT') 
aAdd(aCpos,'ADV_QUANT') 
aAdd(aCpos,'ADX_QTDORI')
aAdd(aCpos,'ADX_QUANT') 
aAdd(aCpos,'ADZ_QTDVEN')
aAdd(aCpos,'AI2_QUANTC')
aAdd(aCpos,'AIE_EMAX')  
aAdd(aCpos,'AIE_NECESS')
aAdd(aCpos,'AIE_NECDIG')   
aAdd(aCpos,'AIE_SLDCEN')
aAdd(aCpos,'AIE_SLDNEC')
aAdd(aCpos,'AIE_QE')    
aAdd(aCpos,'AIE_MEDVEN')
aAdd(aCpos,'AIE_EMIN')  
aAdd(aCpos,'AIE_ESTSEG')
aAdd(aCpos,'AIE_LE')    
aAdd(aCpos,'AIE_LM')    
aAdd(aCpos,'ALX_QTDTOT')
aAdd(aCpos,'ALY_QUANT') 
aAdd(aCpos,'CNB_QUANT') 
aAdd(aCpos,'CNB_QTDMED')
aAdd(aCpos,'CNB_QTDORI')
aAdd(aCpos,'CNB_QTRDAC')
aAdd(aCpos,'CNB_QTRDRZ')
aAdd(aCpos,'CNB_QTREAD')
aAdd(aCpos,'CNB_QTDSOL')   
aAdd(aCpos,'CNE_QTDSOL')
aAdd(aCpos,'CNE_QTAMED')
aAdd(aCpos,'CNE_QUANT') 
aAdd(aCpos,'CNE_QTRETI')
aAdd(aCpos,'CNE_QTDORI')
aAdd(aCpos,'CNS_PRVQTD')
aAdd(aCpos,'CNS_RLZQTD')
aAdd(aCpos,'CNS_SLDQTD')
aAdd(aCpos,'CNS_DISTSL')
aAdd(aCpos,'CNS_TOTQTD')
aAdd(aCpos,'CO2_QUANT') 
aAdd(aCpos,'DB3_QUANT') 
aAdd(aCpos,'DBC_QUANT') 
aAdd(aCpos,'DBC_QTSEGU')
aAdd(aCpos,'DBH_CONTOT')
aAdd(aCpos,'DBH_ABATOT')
aAdd(aCpos,'DBH_NECTOT')
aAdd(aCpos,'DBI_CONSUM')
aAdd(aCpos,'DBI_SLDABA')
aAdd(aCpos,'DBI_NECALC')
aAdd(aCpos,'DBI_NECINF')
aAdd(aCpos,'DBI_SLDFIS')
aAdd(aCpos,'DBI_SLDDIS')
aAdd(aCpos,'DBI_SLDTRA')
aAdd(aCpos,'DBI_QTDCOM')
aAdd(aCpos,'A5_QUANT01')
aAdd(aCpos,'A5_QUANT02')
aAdd(aCpos,'A5_QUANT03')
aAdd(aCpos,'A5_QUANT04')
aAdd(aCpos,'A5_QUANT05')
aAdd(aCpos,'A5_QUANT06')
aAdd(aCpos,'A5_QUANT07')
aAdd(aCpos,'A5_QUANT08')
aAdd(aCpos,'A5_QUANT09')
aAdd(aCpos,'A5_QUANT010')
aAdd(aCpos,'A5_QUANT011')
aAdd(aCpos,'A5_QUANT012') 
aAdd(aCpos,'A5_QT_COT') 
aAdd(aCpos,'A5_LOTEMIN')
aAdd(aCpos,'A5_LOTEMUL')
aAdd(aCpos,'AI_QUANT')  
aAdd(aCpos,'AS_QTDCURV')
aAdd(aCpos,'AT_QTDCOL') 
aAdd(aCpos,'B1_QE')     
aAdd(aCpos,'B1_EMIN')   
aAdd(aCpos,'B1_ESTSEG') 
aAdd(aCpos,'B1_LE')     
aAdd(aCpos,'B1_LM')     
aAdd(aCpos,'B1_QTMIDIA')
aAdd(aCpos,'B1_EMAX')   
aAdd(aCpos,'B1_QTDACUM') 
aAdd(aCpos,'B1_QTDINIC') 
aAdd(aCpos,'B1_LOTVEN')  
aAdd(aCpos,'B1_LOTESBP') 
aAdd(aCpos,'B2_QFIM')   
aAdd(aCpos,'B2_QATU')   
aAdd(aCpos,'B2_QEMP')   
aAdd(aCpos,'B2_QEMPN')  
aAdd(aCpos,'B2_QTSEGUM')
aAdd(aCpos,'B2_RESERVA')
aAdd(aCpos,'B2_QPEDVEN')
aAdd(aCpos,'B2_NAOCLAS')
aAdd(aCpos,'B2_SALPEDI')
aAdd(aCpos,'B2_QTNP')   
aAdd(aCpos,'B2_QNPT')   
aAdd(aCpos,'B2_QTER')   
aAdd(aCpos,'B2_QFIM2')  
aAdd(aCpos,'B2_QACLASS')
aAdd(aCpos,'B2_QEMPSA') 
aAdd(aCpos,'B2_QEMPPRE')
aAdd(aCpos,'B2_SALPPRE')
aAdd(aCpos,'B2_QEMP2')  
aAdd(aCpos,'B2_QEMPN2')
aAdd(aCpos,'B2_RESERV2')
aAdd(aCpos,'B2_QPEDVE2')
aAdd(aCpos,'B2_QEPRE2') 
aAdd(aCpos,'B2_QFIMFF') 
aAdd(aCpos,'B2_SALPED2')
aAdd(aCpos,'B2_QEMPPRJ')
aAdd(aCpos,'B2_QEMPPR2')
aAdd(aCpos,'B2_QULT')   
aAdd(aCpos,'B3_Q01')    
aAdd(aCpos,'B3_Q02')  
aAdd(aCpos,'B3_Q03')    
aAdd(aCpos,'B3_Q04')    
aAdd(aCpos,'B3_Q05')    
aAdd(aCpos,'B3_Q06')    
aAdd(aCpos,'B3_Q07')    
aAdd(aCpos,'B3_Q08')    
aAdd(aCpos,'B3_Q09')    
aAdd(aCpos,'B3_Q10')    
aAdd(aCpos,'B3_Q11')    
aAdd(aCpos,'B3_Q12')
aAdd(aCpos,'B3_MEDIA')  
aAdd(aCpos,'B6_QUANT')
aAdd(aCpos,'B6_QTSEGUM')
aAdd(aCpos,'B6_QULIB')  
aAdd(aCpos,'B6_SALDO')  
aAdd(aCpos,'B7_QUANT')  
aAdd(aCpos,'B7_QTSEGUM')
aAdd(aCpos,'B8_QTDORI') 
aAdd(aCpos,'B8_SALDO')  
aAdd(aCpos,'B8_EMPENHO')
aAdd(aCpos,'B8_QEMPPRE')
aAdd(aCpos,'B8_QACLASS')
aAdd(aCpos,'B8_SALDO2') 
aAdd(aCpos,'B8_QTDORI2')
aAdd(aCpos,'B8_EMPENH2')
aAdd(aCpos,'B8_QEPRE2') 
aAdd(aCpos,'B8_QACLAS2')
aAdd(aCpos,'B9_QINI')   
aAdd(aCpos,'B9_QISEGUM')
aAdd(aCpos,'BC_QUANT')  
aAdd(aCpos,'BC_QTSEGUM')
aAdd(aCpos,'BC_QTDDEST')
aAdd(aCpos,'BC_QTDDES2')
aAdd(aCpos,'BD_QUANT')  
aAdd(aCpos,'BD_QT2UM')  
aAdd(aCpos,'BD_QINI')   
aAdd(aCpos,'BD_QINI2UM')
aAdd(aCpos,'BD_QFIM')   
aAdd(aCpos,'BD_QFIM2UM')
aAdd(aCpos,'BE_CAPACID')
aAdd(aCpos,'BF_QUANT')  
aAdd(aCpos,'BF_EMPENHO')
aAdd(aCpos,'BF_QEMPPRE')
aAdd(aCpos,'BF_QTSEGUM')
aAdd(aCpos,'BF_EMPEN2') 
aAdd(aCpos,'BF_QEPRE2') 
aAdd(aCpos,'BH_QUANT')      
aAdd(aCpos,'BJ_QINI')   
aAdd(aCpos,'BJ_QISEGUM')
aAdd(aCpos,'BK_QINI')   
aAdd(aCpos,'BK_QISEGUM')
aAdd(aCpos,'BL_DEMANDA')
aAdd(aCpos,'BL_TOTDEM') 
aAdd(aCpos,'BL_TOTCUST')
aAdd(aCpos,'BL_QTDFOR1')
aAdd(aCpos,'BL_QTDFOR2')
aAdd(aCpos,'BL_QTDFOR3')
aAdd(aCpos,'BL_QTDFOR4')
aAdd(aCpos,'BP_LM')     
aAdd(aCpos,'BU_QUANT')  
aAdd(aCpos,'BZ_EMIN')   
aAdd(aCpos,'BZ_ESTSEG') 
aAdd(aCpos,'BZ_LE')     
aAdd(aCpos,'BZ_LM')     
aAdd(aCpos,'BZ_EMAX')   
aAdd(aCpos,'C0_QUANT')  
aAdd(aCpos,'C0_QTDORIG')
aAdd(aCpos,'C0_QTDPED') 
aAdd(aCpos,'C0_QTDELIM')
aAdd(aCpos,'C1_QUANT')  
aAdd(aCpos,'C1_QTSEGUM')
aAdd(aCpos,'C1_QUJE')   
aAdd(aCpos,'C1_QUJE2')  
aAdd(aCpos,'C1_QTDORIG')
aAdd(aCpos,'C2_QUANT')  
aAdd(aCpos,'C2_QUJE')   
aAdd(aCpos,'C2_QTSEGUM')
aAdd(aCpos,'C3_QUANT')  
aAdd(aCpos,'C3_QUJE')   
aAdd(aCpos,'C3_QTSEGUM')
aAdd(aCpos,'C3_QTIMP')  
aAdd(aCpos,'C4_QUANT')  
aAdd(aCpos,'C6_QTDVEN') 
aAdd(aCpos,'C6_QTDLIB') 
aAdd(aCpos,'C6_QTDLIB2')
aAdd(aCpos,'C6_SLDALIB')
aAdd(aCpos,'C6_QTDENT2')
aAdd(aCpos,'C6_QTDENT') 
aAdd(aCpos,'C6_UNSVEN') 
aAdd(aCpos,'C6_QTDRESE')
aAdd(aCpos,'C6_QTDEMP') 
aAdd(aCpos,'C6_QTDEMP2')
aAdd(aCpos,'C7_QUANT')  
aAdd(aCpos,'C7_QTSEGUM')
aAdd(aCpos,'C7_QUJE')   
aAdd(aCpos,'C7_QTDACLA')
aAdd(aCpos,'C7_QTDSOL') 
aAdd(aCpos,'C8_QUANT')  
aAdd(aCpos,'C8_QTDCTR') 
aAdd(aCpos,'C8_QTSEGUM')
aAdd(aCpos,'C9_QTDLIB') 
aAdd(aCpos,'C9_QTDRESE')
aAdd(aCpos,'C9_QTDLIB2')
aAdd(aCpos,'CC_QINI')   
aAdd(aCpos,'CC_QINI2UM')
aAdd(aCpos,'CC_QFIM')   
aAdd(aCpos,'CC_QFIM2UM')
aAdd(aCpos,'CE_QUANT')  
aAdd(aCpos,'CK_QTDVEN') 
aAdd(aCpos,'CL_QUANT')  
aAdd(aCpos,'CL_QTDVEN') 
aAdd(aCpos,'CO_QUANT')  
aAdd(aCpos,'CP_QUANT')  
aAdd(aCpos,'CP_QTSEGUM')
aAdd(aCpos,'CP_QUJE')   
aAdd(aCpos,'CP_SALBLQ')    
aAdd(aCpos,'CQ_QUANT')  
aAdd(aCpos,'CQ_QTSEGUM')
aAdd(aCpos,'CQ_QTDISP') 
aAdd(aCpos,'CT_QUANT')  
aAdd(aCpos,'CY_QUANT')  
aAdd(aCpos,'CY_QTSEGUM')
aAdd(aCpos,'CY_QUJE')   
aAdd(aCpos,'CY_QTDACLA')
aAdd(aCpos,'CY_QTDSOL')                 
aAdd(aCpos,'D1_QUANT')  
aAdd(aCpos,'D1_QTSEGUMT')
aAdd(aCpos,'D1_QTDEDEV')
aAdd(aCpos,'D1_QTDPEDI')
aAdd(aCpos,'D1_QTPCCEN')
aAdd(aCpos,'D2_QUANT')  
aAdd(aCpos,'D2_QTSEGUM')
aAdd(aCpos,'D2_QTDEDEV')
aAdd(aCpos,'D2_QTDEFAT')
aAdd(aCpos,'D2_QTDAFAT')
aAdd(aCpos,'D3_QUANT')  
aAdd(aCpos,'D3_QTSEGUM')
aAdd(aCpos,'D3_PERDA')  
aAdd(aCpos,'D3_QTGANHO')
aAdd(aCpos,'D3_QTMAIOR')
aAdd(aCpos,'D4_QSUSP')  
aAdd(aCpos,'D4_QTDEORI')
aAdd(aCpos,'D4_QUANT')  
aAdd(aCpos,'D4_QTSEGUM')
aAdd(aCpos,'D4_SLDEMP') 
aAdd(aCpos,'D4_SLDEMP2')
aAdd(aCpos,'D4_EMPROC') 
aAdd(aCpos,'D5_QUANT')  
aAdd(aCpos,'D5_QTSEGUM')
aAdd(aCpos,'D6_QUANT')  
aAdd(aCpos,'D7_QTDE')   
aAdd(aCpos,'D7_SALDO')  
aAdd(aCpos,'D7_QTSEGUM')
aAdd(aCpos,'D7_SALDO2') 
aAdd(aCpos,'D8_QUANT')  
aAdd(aCpos,'D8_QT2UM')  
aAdd(aCpos,'D8_QTDDEV') 
aAdd(aCpos,'D8_QFIMDEV')
aAdd(aCpos,'DA_QTDORI') 
aAdd(aCpos,'DA_SALDO')  
aAdd(aCpos,'DA_EMPENHO')
aAdd(aCpos,'DA_QTSEGUM')
aAdd(aCpos,'DA_QTDORI2')
aAdd(aCpos,'DA_EMP2')       
aAdd(aCpos,'DB_QUANT')  
aAdd(aCpos,'DB_EMPENHO')
aAdd(aCpos,'DB_QTSEGUM')
aAdd(aCpos,'DB_EMP2')   
aAdd(aCpos,'DB_QTDORI') 
aAdd(aCpos,'DC_QUANT')  
aAdd(aCpos,'DC_QTDORIG')
aAdd(aCpos,'DC_QTSEGUM')
aAdd(aCpos,'DD_QUANT')  
aAdd(aCpos,'DD_SALDO')  
aAdd(aCpos,'DD_QTDORIG')
aAdd(aCpos,'DD_QTSEGUM')
aAdd(aCpos,'DD_SALDO2') 
aAdd(aCpos,'FK_QTDE')   
aAdd(aCpos,'FT_QUANT')  
aAdd(aCpos,'DH_QUANT')† 
aAdd(aCpos,'DH_QTDNF')† 
aAdd(aCpos,'CYQ_QTOR')
aAdd(aCpos,'CYQ_QTORMI')
aAdd(aCpos,'CYQ_QTORMX')
aAdd(aCpos,'CYQ_QTORRP')
aAdd(aCpos,'CYQ_QTORAP')
aAdd(aCpos,'CYQ_QTORRT')
aAdd(aCpos,'CYQ_QTORRF')
aAdd(aCpos,'CYV_QTATRP')
aAdd(aCpos,'CYV_QTATAP')
aAdd(aCpos,'CYV_QTATRF')
aAdd(aCpos,'CYV_QTATRT')
aAdd(aCpos,'CYY_QTATAP')
aAdd(aCpos,'CYY_QTATRF')
aAdd(aCpos,'CYY_QTAT')
aAdd(aCpos,'CYY_QTATRT')
aAdd(aCpos,'CYY_QTATRP')
aAdd(aCpos,'AF9_QUANT')
aAdd(aCpos,'AFC_QUANT')
aAdd(aCpos,'AFG_QUANT')
aAdd(aCpos,'AFH_QUANT')
aAdd(aCpos,'AFI_QUANT')
aAdd(aCpos,'AFM_QUANT')
aAdd(aCpos,'AFN_QUANT')
aAdd(aCpos,'AFS_QUANT')
aAdd(aCpos,'AFU_HQUANT')
aAdd(aCpos,'AJ7_QUANT')
aAdd(aCpos,'AJC_QUANT')



Return aCpos