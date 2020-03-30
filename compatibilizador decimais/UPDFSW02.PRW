#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ UPDFSW01 ³Autor  ³ DLeme                 ³Data  ³ 20.Abr.12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizações Modal Aquaviario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Projeto   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Bardella                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UPDFSW02()
Local aRet      := {{},{},{},{},{},{},{},{}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ESTRUTURA DO ARRAY aRET:                                             ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[01] - Array com os dados SX2                                    ³
//³ aRet[02] - Array com os dados SIX                                    ³
//³ aRet[03] - Array com os dados SX3                                    ³
//³ aRet[04] - Array com os dados SX5                                    ³
//³ aRet[05] - Array com os dados SX7                                    ³
//³ aRet[06] - Array com os dados SXA                                    ³
//³ aRet[07] - Array com os dados SXB                                    ³
//³ aRet[08] - Array com os dados SX6                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRet[1] := TMSAtuSX2()
aRet[2] := TMSAtuSIX()
aRet[3] := TMSAtuSX3()
aRet[5] := TMSAtuSX7()
aRet[6] := TMSAtuSXA()
aRet[7] := TMSAtuSXB()
aRet[8] := TMSAtuSX6()

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSX2 ³ Autor ³ FSW                   ³ Data ³ 20.Mar.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SX2                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuSX2()
Local aSX2      := {}     
Local cPath     := Posicione('SX2',1,'DT6','X2_PATH')
Local cNome     := SubStr(Posicione('SX2',1,'DT6','X2_ARQUIVO'),4,5)

Return(aSX2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSIX ³ Autor ³ FSW                   ³ Data ³ 20.Mar.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SIX                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuSIX()
Local aSIX := {}
			
Return(aSIX)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSX3 ³ Autor ³ DLeme      ³ Data ³ 20.Mar.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SX3                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAtuSX3()

Local aSX3      := {}
Local aPropCpos := {}
Local cOrdem    := "01"
Local aCpos,nI
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VERIFICA AS PROPRIEDADES DOS CAMPOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
nDecimais := 5      
nTam      := 17

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
			cPicture := "@E 99,999,999,999.99999"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSXA ³ Autor ³ DLeme                 ³ Data ³ 07.Ago.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SXA                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuSXA()

Local aSXA := {}

Return(aSXA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSXB ³ Autor ³ DLeme      ³ Data ³ 07.Out.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SXB                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuSXB()

Local aSXB := {}

Return(aSXB)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSX6 ³ Autor ³ FSW                   ³ Data ³ 20.Jul.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SX6                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuSX6()
Local aSX6 := {} 

Return(aSX6)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAtuSX7 ³ Autor ³ DLeme                 ³ Data ³ 05/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os dados para atualizacao do SX7                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAtuSX7()

Local aSX7 := {}


Return(aSX7)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSW01Des ³ Autor ³ FSW                   ³ Data ³ 20.Mar.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Descricao do Update                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FSW02Des()
Local aRet := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ESTRUTURA DO ARRAY aRET:                                             ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aRet[01] - (C) Nome da Function                                      ³
//³ aRet[02] - (C) Descritivo do Update                                  ³
//³ aRet[03] - (L) Situacao para determinar se o Update ja foi executado ³
//³ aRet[04] - (C) Projeto Lógico                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aRet, 'UPDFSW02')
AAdd( aRet, 'Decimais VALOR' )
AAdd( aRet, JaRodou() )
AAdd( aRet, 'GENESIS' )

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ JaRodou  ³ Autor ³ D'Leme                ³ Data ³ 18.Dez.12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se o Update já foi rodado                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RetCpos  ³ Autor ³ D'Leme                ³ Data ³ 18.Dez.12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os campos que deverão sofrer update                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetCpos()
Local aCpos := {}


aAdd(aCpos,'AF2_KVUNIT')
aAdd(aCpos,'AF3_CUSTD')
aAdd(aCpos,'AF4_VALOR')
aAdd(aCpos,'AF8_VALBDI')
aAdd(aCpos,'AFA_CUSTD')
aAdd(aCpos,'A5_PRECO01')
aAdd(aCpos,'A5_PRECO02')
aAdd(aCpos,'A5_PRECO03')
aAdd(aCpos,'A5_PRECO04')
aAdd(aCpos,'A5_PRECO05')
aAdd(aCpos,'A5_PRECO06')
aAdd(aCpos,'A5_PRECO07')
aAdd(aCpos,'A5_PRECO08')
aAdd(aCpos,'A5_PRECO09')
aAdd(aCpos,'A5_PRECO10')
aAdd(aCpos,'A5_PRECO11')
aAdd(aCpos,'A5_PRECO12')
aAdd(aCpos,'B1_CUSTD')
aAdd(aCpos,'B1_UPRC')
aAdd(aCpos,'B1_UVLRC')
aAdd(aCpos,'BZ_CUSTD')
aAdd(aCpos,'BZ_UPRC')
aAdd(aCpos,'B2_VFIM1')
aAdd(aCpos,'B2_VATU1')
aAdd(aCpos,'B2_CM1')
aAdd(aCpos,'B2_VFIM2')
aAdd(aCpos,'B2_VATU2')
aAdd(aCpos,'B2_CM2')
aAdd(aCpos,'B2_VFIM3')
aAdd(aCpos,'B2_VATU3')
aAdd(aCpos,'B2_CM3')
aAdd(aCpos,'B2_VFIM4')
aAdd(aCpos,'B2_VATU4')
aAdd(aCpos,'B2_CM4')
aAdd(aCpos,'B2_VFIM5')
aAdd(aCpos,'B2_VATU5')
aAdd(aCpos,'B2_CM5')
aAdd(aCpos,'B2_CMFF1')
aAdd(aCpos,'B2_CMFF2')
aAdd(aCpos,'B2_CMFF3')
aAdd(aCpos,'B2_CMFF4')
aAdd(aCpos,'B2_CMFF5')
aAdd(aCpos,'B2_VFIMFF1')
aAdd(aCpos,'B2_VFIMFF2')
aAdd(aCpos,'B2_VFIMFF3')
aAdd(aCpos,'B2_VFIMFF4')
aAdd(aCpos,'B2_VFIMFF5')
aAdd(aCpos,'B2_CMRP1')
aAdd(aCpos,'B2_VFRP1')
aAdd(aCpos,'B2_CMRP2')
aAdd(aCpos,'B2_VFRP2')
aAdd(aCpos,'B2_CMRP3')
aAdd(aCpos,'B2_VFRP3')
aAdd(aCpos,'B2_CMRP4')
aAdd(aCpos,'B2_VFRP4')
aAdd(aCpos,'B2_CMRP5')
aAdd(aCpos,'B2_VFRP5')
aAdd(aCpos,'B4_PRV1')
aAdd(aCpos,'B4_PRV2')
aAdd(aCpos,'B4_PRV3')
aAdd(aCpos,'B4_PRV4')
aAdd(aCpos,'B4_PRV5')
aAdd(aCpos,'B4_PRV6')
aAdd(aCpos,'B4_PRV7')
aAdd(aCpos,'B5_PRV1')
aAdd(aCpos,'B5_PRV2')
aAdd(aCpos,'B5_PRV3')
aAdd(aCpos,'B5_PRV4')
aAdd(aCpos,'B5_PRV5')
aAdd(aCpos,'B5_PRV6')
aAdd(aCpos,'B5_PRV7')
aAdd(aCpos,'B6_CUSTO1')
aAdd(aCpos,'B6_CUSTO2')
aAdd(aCpos,'B6_CUSTO3')
aAdd(aCpos,'B6_CUSTO4')
aAdd(aCpos,'B6_CUSTO5')
aAdd(aCpos,'B6_CUSFF1')
aAdd(aCpos,'B6_CUSFF2')
aAdd(aCpos,'B6_CUSFF3')
aAdd(aCpos,'B6_CUSFF4')
aAdd(aCpos,'B6_CUSFF5')
aAdd(aCpos,'B6_CUSRP1')
aAdd(aCpos,'B6_CUSRP2')
aAdd(aCpos,'B6_CUSRP3')
aAdd(aCpos,'B6_CUSRP4')
aAdd(aCpos,'B6_CUSRP5')
aAdd(aCpos,'B6_PRUNIT')
aAdd(aCpos,'B8_PRCLOT')
aAdd(aCpos,'B9_VINI1')
aAdd(aCpos,'B9_VINI2')
aAdd(aCpos,'B9_VINI3')
aAdd(aCpos,'B9_VINI4')
aAdd(aCpos,'B9_VINI5')
aAdd(aCpos,'B9_VINIFF1')
aAdd(aCpos,'B9_VINIFF2')
aAdd(aCpos,'B9_VINIFF3')
aAdd(aCpos,'B9_VINIFF4')
aAdd(aCpos,'B9_VINIFF5')
aAdd(aCpos,'B9_CUSTD')
aAdd(aCpos,'B9_CM1')
aAdd(aCpos,'B9_CM2')
aAdd(aCpos,'B9_CM3')
aAdd(aCpos,'B9_CM4')
aAdd(aCpos,'B9_CM5')
aAdd(aCpos,'B9_CMRP1')
aAdd(aCpos,'B9_VINIRP1')
aAdd(aCpos,'B9_CMRP2')
aAdd(aCpos,'B9_VINIRP2')
aAdd(aCpos,'B9_CMRP3')
aAdd(aCpos,'B9_VINIRP3')
aAdd(aCpos,'B9_CMRP4')
aAdd(aCpos,'B9_VINIRP4')
aAdd(aCpos,'B9_CMRP5')
aAdd(aCpos,'B9_VINIRP5')
aAdd(aCpos,'BB_VALOR')
aAdd(aCpos,'BD_CUSINI1')
aAdd(aCpos,'BD_CUSINI2')
aAdd(aCpos,'BD_CUSINI3')
aAdd(aCpos,'BD_CUSINI4')
aAdd(aCpos,'BD_CUSINI5')
aAdd(aCpos,'BD_CUSFIM1')
aAdd(aCpos,'BD_CUSFIM2')
aAdd(aCpos,'BD_CUSFIM3')
aAdd(aCpos,'BD_CUSFIM4')
aAdd(aCpos,'BD_CUSFIM5')
aAdd(aCpos,'BI_PRV')
aAdd(aCpos,'BI_PRVINFO')
aAdd(aCpos,'BZ_UPRC')
aAdd(aCpos,'C1_PRECO')
aAdd(aCpos,'C1_CUNIT')
aAdd(aCpos,'C2_VATU1')
aAdd(aCpos,'C2_VINI1')
aAdd(aCpos,'C2_VFIM1')
aAdd(aCpos,'C2_VATU2')
aAdd(aCpos,'C2_VINI2')
aAdd(aCpos,'C2_VFIM2')
aAdd(aCpos,'C2_VATU3')
aAdd(aCpos,'C2_VINI3')
aAdd(aCpos,'C2_VFIM3')
aAdd(aCpos,'C2_VATU4')
aAdd(aCpos,'C2_VINI4')
aAdd(aCpos,'C2_VFIM4')
aAdd(aCpos,'C2_VATU5')
aAdd(aCpos,'C2_VINI5')
aAdd(aCpos,'C2_VFIM5')
aAdd(aCpos,'C2_APRATU1')
aAdd(aCpos,'C2_APRINI1')
aAdd(aCpos,'C2_APRFIM1')
aAdd(aCpos,'C2_APRATU2')
aAdd(aCpos,'C2_APRINI2')
aAdd(aCpos,'C2_APRFIM2')
aAdd(aCpos,'C2_APRATU3')
aAdd(aCpos,'C2_APRINI3')
aAdd(aCpos,'C2_APRFIM3')
aAdd(aCpos,'C2_APRATU4')
aAdd(aCpos,'C2_APRINI4')
aAdd(aCpos,'C2_APRFIM4')
aAdd(aCpos,'C2_APRATU5')
aAdd(aCpos,'C2_APRINI5')
aAdd(aCpos,'C2_APRFIM5')
aAdd(aCpos,'C3_PRECO')
aAdd(aCpos,'C3_AVISTA')
aAdd(aCpos,'C6_PRCVEN')
aAdd(aCpos,'C6_PRUNIT')
aAdd(aCpos,'C7_PRECO')
aAdd(aCpos,'C8_PRECO')
aAdd(aCpos,'C8_AVISTA')
aAdd(aCpos,'C9_PRCVEN')
aAdd(aCpos,'CK_PRCVEN')
aAdd(aCpos,'CK_PRUNIT')
aAdd(aCpos,'CI_PRECO')
aAdd(aCpos,'CY_PRECO')
aAdd(aCpos,'D1_VUNIT')
aAdd(aCpos,'D1_CUSTO')
aAdd(aCpos,'D1_CUSTO2')
aAdd(aCpos,'D1_CUSTO3')
aAdd(aCpos,'D1_CUSTO4')
aAdd(aCpos,'D1_CUSTO5')
aAdd(aCpos,'D1_CUSFF1')
aAdd(aCpos,'D1_CUSFF2')
aAdd(aCpos,'D1_CUSFF3')
aAdd(aCpos,'D1_CUSFF4')
aAdd(aCpos,'D1_CUSFF5')
aAdd(aCpos,'D2_PRCVEN')
aAdd(aCpos,'D2_PRUNIT')
aAdd(aCpos,'D2_CUSTO1')
aAdd(aCpos,'D2_CUSTO2')
aAdd(aCpos,'D2_CUSTO3')
aAdd(aCpos,'D2_CUSTO4')
aAdd(aCpos,'D2_CUSTO5')
aAdd(aCpos,'D2_CUSFF1')
aAdd(aCpos,'D2_CUSFF2')
aAdd(aCpos,'D2_CUSFF3')
aAdd(aCpos,'D2_CUSFF4')
aAdd(aCpos,'D2_CUSFF5')
aAdd(aCpos,'D6_VRUNIT')
aAdd(aCpos,'UB_VRUNIT')
aAdd(aCpos,'GA_PRCVEN')
aAdd(aCpos,'L2_VRUNIT')
aAdd(aCpos,'L2_PRCTAB')
aAdd(aCpos,'FT_PRCUNIT')
aAdd(aCpos,'CNB_VLUNIT')
aAdd(aCpos,'CNE_VLUNIT')


Return aCpos