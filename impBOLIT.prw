#include "TOTVS.CH"
#include "TBICONN.CH"
#define   DMPAPER_A4 9
/*/{Protheus.doc} impBOLIT
Rotina - impressao boletos
@type function
@author Cristiam Rossi
@since 02/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function impBOLIT( cParPref, cParNum, lQuiet )
local   oPrint
//local   cFilePrint
local   aDadosEmp  := {}
local   aDatSacado := {}
local   nVlrBol    := 0
local   nAcrescimo := 0
local   nVlrAbat   := 0
local   aBolText   := { "PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO", "", "", "", "", "", "", "" }
local   nMulta     := 0
local   nMora      := 0
local   nPosText   := 2

private cTitulo    := "Impressao de Boleto ITAU"
private lJob       := .F.
private cPrefixo   := ""
private cNumero    := ""
private cParcDe    := ""
private cParcAte   := "Z"
private cPasta     := ""
private _cConvenio := ""
private dVencto
private	cNroDoc

default cParPref   := ""
default cParNum    := ""
default lQuiet     := .F.

	if select("SX2") == 0			// Se via JOB
		lJob := .T.
		ConOut( "Inicio emissao de boletos... - "+DtoC(date())+" "+time() )
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" TABLES "SA3","SED","SEE","SE1","SEA"
	endif

	dbSelectArea("SA3")
	dbSelectArea("SED")
	dbSelectArea("SEE")
	dbSelectArea("SE1")
	dbSelectArea("SEA")

	cPasta   := superGetMV("FS_FOLBOL",,"c:\boleto")
	MakeDir( cPasta )
	cPasta   += "\"

	cPrefixo := padR( cPrefixo, len(SE1->E1_PREFIXO))
	cNumero  := padR( cNumero , len(SE1->E1_NUM)    )
	cParcDe  := padR( cParcDe , len(SE1->E1_PARCELA))
	cParcAte := padR( cParcAte, len(SE1->E1_PARCELA))

	if empty( cParNum )		// perguntar p/ usu�rio
		if lJob
			ConOut( "Para JOB precisa informar Prefixo e Numero, encerrando. - "+DtoC(date())+" "+time() )
			return nil
		endif

		Perguntar()
	else
		cPrefixo := padR( cParPref, len(SE1->E1_PREFIXO))
		cNumero  := padR( cParNum , len(SE1->E1_NUM)    )
	endif

	SE1->( dbSetOrder(1) )
	if ! SE1->( dbSeek( xFilial("SE1")+ cPrefixo + cNumero + cParcDe ) )
		msgStop( "Titulo(s) nao encontrado(s), verifique!", cTitulo)
	else

		aDadosEmp := {	SM0->M0_NOMECOM																,; //[1]Nome da Empresa
						SM0->M0_ENDCOB																,; //[2]Endere�o
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB	,; //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)				,; //[4]CEP
						"PABX/FAX: "+SM0->M0_TEL													,; //[5]Telefones
						"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+				;  //[6]
						Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+						;  //[6]
						Subs(SM0->M0_CGC,13,2)														,; //[6]CGC
						"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+				;  //[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)							}  //[7]I.E

		SA1->( DbSetOrder(1) )
		SA6->( DbSetOrder(1) )
		SEE->( DbSetOrder(1) )

		cFilePrint := AllTrim(StrTran("BOLETO_"+ SE1->( E1_FILIAL +"_"+ E1_PREFIXO +"_"+ E1_NUM +"-"+ E1_NOMCLI ),"'",""))
		
		if file( cPasta + cFilePrint + ".pdf" )
			fErase( cPasta + cFilePrint + ".pdf" )
		endif

		oPrint := FWMSPrinter():New(cFilePrint, 6, .T., cPasta,.T.,,,,.T.,.F.,,.F.)
		oPrint:SetDevice(6)  
		oPrint:cPathPDF:= cPasta
		oPrint:SetResolution(78)
		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		oPrint:SetMargin(60,60,60,60)

		while ! SE1->( eof() ) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+ cPrefixo + cNumero .and. SE1->E1_PARCELA <= cParcAte

			if SE1->E1_TIPO $ "CF-;CS-;IN-;IR-;PI-;IS-;NCC;RA ;TX ;AB-;DM-;DE " .or. SE1->E1_SALDO == 0 
				SE1->( dbSkip() )
				loop
			end

			if ! SA6->( dbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA) ) )
				Aviso("ATENCAO","Banco do Titulo ("+Alltrim(SE1->E1_PORTADO)+" - "+Alltrim(SE1->E1_AGEDEP)+" - "+Alltrim(SE1->E1_CONTA)+") nao localizado no cadastro de Bancos.",{"OK"})
				SE1->( dbSkip() )
				loop
			endif		

			if ! SEE->( dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA) ) )
				Aviso("ATENCAO","Parametros Bancarios nao encontrados ("+Alltrim(SE1->E1_PORTADO)+" - "+Alltrim(SE1->E1_AGEDEP)+" - "+Alltrim(SE1->E1_CONTA)+").",{"OK"})
				SE1->( dbSkip() )
				loop
			endif		

			if alltrim(SA6->A6_NUMBCO) != "341"
				Aviso("ATENCAO","Esta rotina so imprime o Boleto para o banco ITAU. Banco do Titulo: ["+SE1->E1_PORTADO+"].",{"OK"})
				SE1->( dbSkip() )
				loop
			endif

			SA1->( dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA) ) )

			aDadosBanco  := {alltrim(SA6->A6_NUMBCO)								,;	// [1]Numero do Banco
							 SA6->A6_NOME											,;	// [2]Nome do Banco
							 SUBSTR(SA6->A6_AGENCIA, 1, 4)							,;	// [3]Agencia
		  					 AllTrim(SA6->A6_NUMCON)								,;	// [4]Conta Corrente
		  					 AllTrim(SA6->A6_DVCTA)									,;	// [5]D�gito da conta corrente
							 AllTrim(SEE->EE_CODCART)								,;	// [6]Codigo da Carteira
							 "7"													}	// [7]D�gito Banco

			if Empty(SA1->A1_ENDCOB)
				aDatSacado := {	AllTrim(SA1->A1_NOME)								,;	// [1]Raz�o Social
								AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	// [2]C�digo
								AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)	,;	// [3]Endere�o
								AllTrim(SA1->A1_MUN )								,;	// [4]Cidade
								SA1->A1_ESTC										,;	// [5]Estado
								SA1->A1_CEPC										,;	// [6]CEP
								SA1->A1_CGC											,;	// [7]CGC
								SA1->A1_PESSOA										,;	// [8]PESSOA
								SA1->A1_CXPOSTA										,;	// [9]CAIXA POSTAL
								SA1->A1_COMPLEM										}	// [10] COMPLEMENTO
			else
				aDatSacado := {	AllTrim(SA1->A1_NOME)								,;	// [1]Raz�o Social
								AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	// [2]C�digo
								AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endere�o
								AllTrim(SA1->A1_MUNC )								,;	// [4]Cidade
								SA1->A1_ESTC										,;	// [5]Estado
								SA1->A1_CEPC										,;	// [6]CEP
								SA1->A1_CGC											,;	// [7]CGC
								SA1->A1_PESSOA										,;	// [8]PESSOA
								SA1->A1_CXPOSTA										,;	// [9]CAIXA POSTAL
								SA1->A1_COMPLEM										}	// [10] COMPLEMENTO
			endif

			dVencto := SE1->E1_VENCREA
			nVlrBol := SE1->E1_SALDO

			if SE1->E1_SDACRES > 0
				nAcrescimo := SE1->E1_SDACRES
			endif

			nVlrAbat := somaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,cFilAnt,,SE1->E1_TIPO)
			If SE1->E1_SDDECRE > 0 
				nVlrAbat += SE1->E1_SDDECRE
			EndIf

			if Empty( SE1->E1_NUMBCO )
				RecLock("SEE",.F.)
				cFxAtu := strZero( val(alltrim(SEE->EE_FAXATU))+1 , 6)
				SEE->EE_FAXATU := cFxAtu
				msUnlock()

				recLock("SE1", .F.)
				SE1->E1_NUMBCO := cFxAtu
				msUnlock()
			endif

			cNroDoc := alltrim(SE1->E1_NUMBCO)

			//CB_RN_NN	:= Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],AllTrim(SE1->E1_NUM),(SE1->E1_VALOR-nVlrAbat),SE1->E1_VENCTO)
			CB_RN_NN	:= U_Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,(SE1->E1_VALOR-nVlrAbat),SE1->E1_VENCTO)

			aDadosTit	:= {AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)						,;  // [1] N�mero do t�tulo
							SE1->E1_EMISSAO                              						,;  // [2] Data da emiss�o do t�tulo
							Date()                                  							,;  // [3] Data da emiss�o do boleto
							SE1->E1_VENCTO                         	      						,;  // [4] Data do vencimento
							(SE1->E1_SALDO - nVlrAbat)                  						,;  // [5] Valor do t�tulo
							CB_RN_NN[3]                             							,;  // [6] Nosso numero (Ver formula para calculo)
							SE1->E1_PREFIXO                               						,;  // [7] Prefixo da NF
							SE1->E1_TIPO	                               						,;  // [8] Tipo do Titulo
							nVlrBol * (SE1->E1_DESCFIN/100) }										// [9] Desconto financeiro


			if len(CB_RN_NN) > 0

				if GetMV("MV_LJMULTA") > 0 .OR. nMulta > 0
					IF GetMV("MV_LJMULTA") > 0
						aBolText[nPosText] := "Apos Vencimento, Multa de "+ Transform(GetMV("MV_LJMULTA"),"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform(((nVlrBol - nVlrAbat + nAcrescimo)*(GetMV("MV_LJMULTA")/100)),"@E 99,999.99"))
					ELSE
						aBolText[nPosText] := "Apos Vencimento, Multa de "+ Transform(nMulta,"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform(((nVlrBol - nVlrAbat + nAcrescimo)*(nMulta/100)),"@E 99,999.99"))
					EndIf	
					nPosText++
				endif

				if GetMV("MV_TXPER") > 0  .OR. nMora > 0
					If GetMV("MV_TXPER") > 0
						aBolText[nPosText] := "Apos Vencimento, Mora Diaria de "+ Transform(GetMV("MV_TXPER"),"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( (nVlrBol - nVlrAbat + nAcrescimo)*GetMV("MV_TXPER") )/100),"@E 99,999.99"))+"."
					Else
						aBolText[nPosText] := "Apos Vencimento, Mora Diaria de "+ Transform(nMora,"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( (nVlrBol - nVlrAbat + nAcrescimo)*nMora )/100),"@E 99,999.99"))+"."
					EndIf
					nPosText++
				endif

				if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
					aBolText[nPosText] := "Desconto concedido de R$ "+AllTrim(Transform(aDadosTit[9] ,"@E 99,999.99"))+" para pagamento at� a data de vencimento."
					nPosText++
				endif

				if left(cFilAnt, 2) == "01"		// NAYUMI
					aBolText[nPosText] := "Nao receber apos 30 dias do vencimento"
					nPosText++
					aBolText[nPosText] := "**PROTESTAR APOS 5 DIAS DO VENCIMENTO**"
					nPosText++
					aBolText[nPosText] := "*O nao pagamento causara suspensao das entregas*"
					nPosText++
				else							// DDS
					aBolText[nPosText] := "PROTESTAR APOS 5 DIAS DO VENCIMENTO."
					nPosText++					
				endif

				Impress( oPrint, aDadosEmp, aDadosTit, aDadosBanco, aDatSacado, aBolText, CB_RN_NN )

			endif
			SE1->( dbSkip() )
		end

		oPrint:endPage()
		oPrint:SetViewPDF( iif( lQuiet, .F., !lJob ) )
		oPrint:Print()
	endif
	FreeObj(oPrint)
return nil


//---------------------------------------
static function perguntar()
local lRet   := .F.
local aPergs := {}
local aRet   := {}

	MV_PAR01 := space(len(SE1->E1_PREFIXO))
	MV_PAR02 := space(len(SE1->E1_NUM    ))
	MV_PAR03 := space(len(SE1->E1_PARCELA))

	aAdd(aPergs,{1,"Prefixo"	,MV_PAR01		,"", ,"SE1",".T.",0,.F.})
	aAdd(aPergs,{1,"N�mero"		,MV_PAR02		,"", ,""   ,".T.",0,.F.})
	aAdd(aPergs,{1,"Parcela"	,MV_PAR03		,"", ,""   ,".T.",0,.F.})

	if ParamBox(aPergs,"Selecione o T�tulo para impress�o do boleto SICREDI",@aRet,,,,,,,,.F.)
		cPrefixo   := aRet[1]
		cNumero    := aRet[2]
		cParcDe    := aRet[3]

		if ! empty( cParcDe )
			cParcAte := cParcDe
		endif

		lRet       := .T.
	endif
return lRet


/*
�����������������������������������������������������������������������������
���Programa  �Impress   �                                                 ���
�������������������������������������������������������������������������͹��
���Desc.     � IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             ���
�������������������������������������������������������������������������͹��
���Uso       � Acelerador                                                 ���
�����������������������������������������������������������������������������
*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)

	oFont8   := TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10n := TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11n := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12n := TFont():New("Arial",9,12,.T.,.f.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont19  := TFont():New("Arial",9,19,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova p�gina

/******************/
/* PRIMEIRA PARTE */
/******************/
	nRow1	:= 0
	nRowSay := 035

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow1+0070,100,cStartPath+"itau.bmp",350,075)

	oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
	oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

	oPrint:Say(nRowSay+0095,513,aDadosBanco[1]+"-"+aDadosBanco[7] ,oFont20 )	// [1]Numero do Banco   + [7] DV Banco

	oPrint:Say(nRowSay+0084,1900,"Comprovante de Entrega",oFont10n)
	oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

	oPrint:Say(nRowSay+0150,100 ,"Cedente",oFont8)
	oPrint:Say(nRowSay+0200,100 ,aDadosEmp[1],oFont10n)				//Nome + CNPJ

	oPrint:Say(nRowSay+0150,1060,"Agencia\Codigo Cedente",oFont8)
	cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])
	oPrint:Say(nRowSay+0200,1060,cString,oFont11c)

	oPrint:Say(nRowSay+0150,1510,"Nro.Documento",oFont8)
	oPrint:Say(nRowSay+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say(nRowSay+0250,100 ,"Sacado",oFont8)
	oPrint:Say(nRowSay+0300,100 ,aDatSacado[1],oFont10n)				//Nome

	oPrint:Say(nRowSay+0250,1060,"Vencimento",oFont8)
	oPrint:Say(nRowSay+0300,1060,StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4),oFont10n)

	oPrint:Say(nRowSay+0250,1510,"Valor do Documento",oFont8)
	oPrint:Say(nRowSay+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10n)

	oPrint:Say(nRowSay+0400,0100,"Recebi(emos) o bloqueto/titulo",oFont10)
	oPrint:Say(nRowSay+0430,0100,"com as caracteristicas acima.",oFont10)

	oPrint:Say(nRowSay+0350,1060,"Data",oFont8)
	oPrint:Say(nRowSay+0350,1410,"Assinatura",oFont8)
	oPrint:Say(nRowSay+0450,1060,"Data",oFont8)
	oPrint:Say(nRowSay+0450,1410,"Entregador",oFont8)

	oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
	oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
	oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 )
	oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

	oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
	oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
	oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 )
	oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

	oPrint:Say(nRowSay+0165,1910,"(  )Mudou-se"               ,oFont10n)
	oPrint:Say(nRowSay+0195,1910,"(  )Ausente"                ,oFont10n)
	oPrint:Say(nRowSay+0225,1910,"(  )Nao existe numero indicado" ,oFont10n)
	oPrint:Say(nRowSay+0255,1910,"(  )Recusado"               ,oFont10n)
	oPrint:Say(nRowSay+0285,1910,"(  )Nao procurado"          ,oFont10n)
	oPrint:Say(nRowSay+0315,1910,"(  )Endereco insuficiente"  ,oFont10n)
	oPrint:Say(nRowSay+0345,1910,"(  )Desconhecido"           ,oFont10n)
	oPrint:Say(nRowSay+0375,1910,"(  )Falecido"               ,oFont10n)
	oPrint:Say(nRowSay+0405,1910,"(  )Outros(anotar no verso)",oFont10n)


/*****************/
/* SEGUNDA PARTE */
/*****************/
	nRow2  := 000
	nRowSay:= 035

	For nI := 100 to 2300 step 50	//Pontilhado separador
		oPrint:Line(nRow2+0590, nI,nRow2+0590, nI+30)
	Next nI

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow2+0630,100,cStartPath+"itau.bmp",350,075)

	oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
	oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
	oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

	oPrint:Say(nRowSay+0660,518,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// [1]Numero do Banco

	oPrint:Say(nRowSay+0644,1800,"Recibo do Pagador",oFont10n)

	oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
	oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
	oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
	oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

	oPrint:Line (nRow2+0910,500,nRow2+1050,500)
	oPrint:Line (nRow2+0980,750,nRow2+1050,750)
	oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
	oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
	oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

	oPrint:Say(nRowSay+0710,100 ,"Local de Pagamento",oFont8)
	oPrint:Say(nRowSay+0750,100 ,"QUALQUER BANCO ATE A DATA DO VENCIMENTO",oFont10n)

	oPrint:Say(nRowSay+0710,1810,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
	oPrint:SayAlign(nRowSay+0730,1800, cString, oFont12, 500, , , 1, 1)

	oPrint:Say(nRowSay+0805,100 ,"Cedente"                                   ,oFont8)

	oPrint:Say(nRowSay+0835,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

	oPrint:Say(nRowSay+0810,1810,"Agencia\Codigo Cedente",oFont8)
	cString := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
	oPrint:SayAlign(nRowSay+0830,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+0905,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say(nRowSay+0935,100, DTOC(aDadosTit[2]),oFont10n)

	oPrint:Say(nRowSay+0905,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say(nRowSay+0935,505 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say(nRowSay+0905,1005,"Especie Doc."                                   ,oFont8)
	oPrint:Say(nRowSay+0935,1005,aDadosTit[8]										,oFont10n) //Tipo do Titulo

	oPrint:Say(nRowSay+0905,1305,"Aceite"                                         ,oFont8)
	oPrint:Say(nRowSay+0935,1305,"N"                                            ,oFont10n)

	oPrint:Say(nRowSay+0905,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say(nRowSay+0935,1485,DTOC(aDadosTit[3]),oFont10n) // Data impressao

	oPrint:Say(nRowSay+0905,1810,"Nosso Numero"                                   ,oFont8)
	cString := Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4)
	oPrint:SayAlign(nRowSay+0900,1800, cString,oFont11c, 500, , , 1, 1)



	oPrint:Say(nRowSay+0970,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say(nRowSay+0970,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say(nRowSay+1000,505 ,aDadosBanco[6]                                   ,oFont10n)

	oPrint:Say(nRowSay+0970,755 ,"Especie"                                        ,oFont8) 
	oPrint:Say(nRowSay+1000,755 ,"R$"                                             ,oFont10n)


	oPrint:Say(nRowSay+0970,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say(nRowSay+0970,1485,"Valor"                                          ,oFont8)

	oPrint:Say(nRowSay+0970,1810,"Valor do Documento"                          	  ,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	oPrint:SayAlign(nRowSay+0970,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+1035,100 ,"Instrucoes (Todas informacoes deste bloqueto sao de exclusiva responsabilidade do Beneficiario)",oFont8)
	oPrint:Say(nRowSay+1080,100 ,"ATENCAO SR. CAIXA:",oFont10n)
	oPrint:Say(nRowSay+1110,100 ,aBolText[1],oFont10n)
	oPrint:Say(nRowSay+1140,100 ,aBolText[2],oFont10n)
	oPrint:Say(nRowSay+1170,100 ,aBolText[3],oFont10n)
	oPrint:Say(nRowSay+1200,100 ,aBolText[4],oFont10n)
	oPrint:Say(nRowSay+1230,100 ,aBolText[5],oFont10n)
	oPrint:Say(nRowSay+1260,100 ,aBolText[6],oFont10n)
	oPrint:Say(nRowSay+1300,100 ,aBolText[8],oFont10n)

	oPrint:Say(nRowSay+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say(nRowSay+1120,1810,"(-)Outras Deducoes"                             ,oFont8)

	oPrint:Say(nRowSay+1190,1810,"(+)Mora/Multa"                                  ,oFont8)

	oPrint:Say(nRowSay+1260,1810,"(+)Outros Acrescimos"                           ,oFont8)
	oPrint:Say(nRowSay+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say(nRowSay+1400,100 ,"Sacado",oFont8)

	oPrint:Say(nRowSay+1405,200 ,aDatSacado[1]+" ("+aDatSacado[2]+")"                     ,oFont10n)
	oPrint:Say(nRowSay+1438,200 ,aDatSacado[3]                                            ,oFont10n)
	oPrint:Say(nRowSay+1471,200 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5]   ,oFont10n)
	oPrint:Say(nRowSay+1504,200 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n)
	oPrint:Say(nRowSay+1537,200 ,Substr(aDadosTit[6],1,3)+"/00"+Substr(aDadosTit[6],4,8)  ,oFont10n) 

	oPrint:Say(nRowSay+1560,100 ,"Sacador/Avalista",oFont8)

	if ! empty(aDatSacado[7])
		if aDatSacado[8] = "J"
			oPrint:Say(nRowSay+1580,300 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n)
		Else
			oPrint:Say(nRowSay+1580,300 ,"CPF: " +TRANSFORM(aDatSacado[7],"@R 999.999.999-99")    ,oFont10n)
		EndIf
	EndIf

	oPrint:Say(nRowSay+1620,1550,"Autenticacao Mecanica",oFont8)

	oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
	oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
	oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
	oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
	oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
	oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
	oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )


/******************/
/* TERCEIRA PARTE */
/******************/

	nRow3   := -80

	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3+1860, nI, nRow3+1860, nI+30)
	Next nI

	nRowSay := -85
	nRow3   := -110

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow3+1922,100,cStartPath+"itau.bmp",350,075)

	oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
	oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
	oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

	oPrint:Say(nRowSay+1945,518,aDadosBanco[1]+"-"+aDadosBanco[7],oFont20 )	// 	[1]Numero do Banco
	oPrint:Say(nRowSay+1945,730,aCB_RN_NN[2],oFont19)			//	Linha Digitavel do Codigo de Barras 

	oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
	oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
	oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
	oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

	oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
	oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
	oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
	oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
	oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

	oPrint:Say(nRowSay+2000,100 ,"Local de Pagamento",oFont8)
	oPrint:Say(nRowSay+2045,100 ,"QUALQUER BANCO ATE A DATA DO VENCIMENTO",oFont10n)

	oPrint:Say(nRowSay+2000,1810,"Vencimento",oFont8)

	cString := StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
	oPrint:SayAlign(nRowSay+2015,1800, cString,oFont12, 500, , , 1, 1)


	oPrint:Say(nRowSay+2100,100 ,"Cedente",oFont8)
	oPrint:Say(nRowSay+2150,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

	oPrint:Say(nRowSay+2100,1810,"Agencia\Codigo do Benefici�rio",oFont8)
	cString := aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
	oPrint:SayAlign(nRowSay+2115,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say (nRowSay+2200,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say (nRowSay+2230,100, DTOC(aDadosTit[2]), oFont10n)

	oPrint:Say(nRowSay+2200,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say(nRowSay+2230,505 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say(nRowSay+2200,1005,"Especie Doc."                                   ,oFont8)
	oPrint:Say(nRowSay+2230,1005,aDadosTit[8]										,oFont10n) //Tipo do Titulo

	oPrint:Say(nRowSay+2200,1305,"Aceite"                                         ,oFont8)
	oPrint:Say(nRowSay+2230,1305,"N"                                            ,oFont10n)

	oPrint:Say(nRowSay+2200,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say(nRowSay+2230,1485,DTOC(aDadosTit[3])                               ,oFont10n) // Data impressao

	oPrint:Say(nRowSay+2200,1810,"Nosso Numero"                                   ,oFont8)
	cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4))
	oPrint:SayAlign(nRowSay+2195,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+2270,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say(nRowSay+2270,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say(nRowSay+2300,505 ,aDadosBanco[6]                                   ,oFont10n)

	oPrint:Say(nRowSay+2270,755 ,"Especie"                                        ,oFont8)
	oPrint:Say(nRowSay+2300,755 ,"R$"                                             ,oFont10n)

	oPrint:Say(nRowSay+2270,1005,"Quantidade"                                     ,oFont8)

	oPrint:Say(nRowSay+2270,1485,"Valor"                                          ,oFont8)

	oPrint:Say(nRowSay+2270,1810,"Valor do Documento"                             ,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	oPrint:SayAlign(nRowSay+2265,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+2340,100 ,"Instrucoes (Todas informacoes deste bloqueto sao de exclusiva responsabilidade do Beneficiario)",oFont8)
	oPrint:Say(nRowSay+2380,100 ,"ATENCAO SR. CAIXA:",oFont10n)
	oPrint:Say(nRowSay+2410,100 ,aBolText[1],oFont10n)
	oPrint:Say(nRowSay+2440,100 ,aBolText[2],oFont10n)
	oPrint:Say(nRowSay+2470,100 ,aBolText[3],oFont10n)
	oPrint:Say(nRowSay+2500,100 ,aBolText[4],oFont10n)
	oPrint:Say(nRowSay+2530,100 ,aBolText[5],oFont10n)
	oPrint:Say(nRowSay+2560,100 ,aBolText[6],oFont10n)
	oPrint:Say(nRowSay+2590,100 ,aBolText[8],oFont10n)

	oPrint:Say(nRowSay+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say(nRowSay+2410,1810,"(-)Outras Deducoes"                             ,oFont8)

	oPrint:Say(nRowSay+2480,1810,"(+)Mora/Multa"                                  ,oFont8)

	oPrint:Say(nRowSay+2550,1810,"(+)Outros Acrescimos"                           ,oFont8)
	oPrint:Say(nRowSay+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say(nRowSay+2690,100 ,"Sacado",oFont8)

	oPrint:Say(nRowSay+2700,200 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
	oPrint:Say(nRowSay+2743,200 ,aDatSacado[3]                                    ,oFont10n)
	oPrint:Say(nRowSay+2786,200 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10n)

	oPrint:Say  (nRow3+2875,100 ,"Sacador/Avalista"                               ,oFont8) 

	if ! empty( aDatSacado[7] )
		if aDatSacado[8] = "J"
			oPrint:Say(nRowSay+2870,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n) // CGC
		Else
			oPrint:Say(nRowSay+2870,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10n) 	// CPF
		EndIf
	EndIf

	oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
	oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
	oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
	oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
	oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
	oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )
	oPrint:Line (nRow3+2920,100,nRow3+2920,2300  )

	oPrint:Say(nRowSay+2915,1820,"Autenticacao Mecanica - Ficha de Compensacao"   ,oFont8)

	oPrint:FwMsBar("INT25" /*cTypeBar*/, 66 /*nRow*/, 2.40 /*nCol*/,;
	aCB_RN_NN[1] /*cCode*/, oPrint, .F. /*Calc6. Digito Verif*/,;
	/*Color*/, /*Imp. na Horz*/, 0.025 /*Tamanho*/, 0.85 /*Altura*/, , , ,.F. )

	oPrint:EndPage() // Finaliza a p�gina
Return .T.

//Retorna os strings para inpress�o do Boleto
//CB = String para o c�d.barras, RN = String com o n�mero digit�vel
//Cobran�a n�o identificada, n�mero do boleto = T�tulo + Parcela

//mj Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

//					    		   Codigo Banco            Agencia		  C.Corrente     Digito C/C
//					               1-cBancoc               2-Agencia      3-cConta       4-cDacCC       5-cNroDoc              6-nValor
//	CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],"175"+AllTrim(E1_NUM),(E1_VALOR-_nVlrAbat) )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Ret_cBarra� Autor � RAIMUNDO PEREIRA      � Data � 01/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Clientes Microsiga                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)
//LOCAL bldocnufinal := strzero(val(cNroDoc),8)
LOCAL bldocnufinal := right("00000000"+alltrim(cNroDoc),8)
LOCAL blvalorfinal := strzero(int(nValor*100),10)
LOCAL dvnn         := 0
LOCAL dvcb         := 0
LOCAL dv           := 0
LOCAL NN           := ''
LOCAL RN           := ''
LOCAL CB           := ''
LOCAL s            := ''
LOCAL _cfator      := strzero(dVencto - ctod("07/10/97"),4)
LOCAL _cCart		:= "109"

//-------- Definicao do NOSSO NUMERO
s    :=  cAgencia + cConta + _cCart + bldocnufinal
dvnn := modulo10(s) // digito verifacador Agencia + Conta + Carteira + Nosso Num
NN   := _cCart + bldocnufinal + '-' + AllTrim(dvnn)

//	-------- Definicao do CODIGO DE BARRAS
s    := cBanco + _cfator + blvalorfinal + _cCart + bldocnufinal + AllTrim(dvnn) + cAgencia + cConta + cDacCC + '000'
dvcb := modulo11(s)
CB   := SubStr(s, 1, 4) + AllTrim(dvcb) + SubStr(s,5)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	CCC = Codigo da Carteira de Cobranca
//	 DD = Dois primeiros digitos no nosso numero
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

s    := cBanco + _cCart + SubStr(bldocnufinal,1,2)
dv   := modulo10(s)
RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(dv) + '  '
                
// 	CAMPO 2:
//	DDDDDD = Restante do Nosso Numero
//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	   FFF = Tres primeiros numeros que identificam a agencia
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

s    := SubStr(bldocnufinal, 3, 6) + AllTrim(dvnn) + SubStr(cAgencia, 1, 3)
dv   := modulo10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(dv) + '  '

// 	CAMPO 3:
//	     F = Restante do numero que identifica a agencia
//	GGGGGG = Numero da Conta + DAC da mesma
//	   HHH = Zeros (Nao utilizado)
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
s    := SubStr(cAgencia, 4, 1) + cConta + cDacCC + '000'
dv   := modulo10(s)
RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(dv) + '  '

// 	CAMPO 4:
//	     K = DAC do Codigo de Barras
RN   := RN + AllTrim(dvcb) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
RN   := RN + _cfator + StrZero(Int(nValor * 100),14-Len(_cfator))

Return({CB,RN,NN})
