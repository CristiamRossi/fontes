#include "TOTVS.CH"
#include "TBICONN.CH"
#define   DMPAPER_A4 9
/*/{Protheus.doc} impBOLz
Rotina - impressão boletos
@type function
@author Cristiam Rossi
@since 02/01/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function impBOL( cParPref, cParNum, lQuiet )
local   oPrint
//local   cFilePrint
local   aDadosEmp  := {}
local   aDatSacado := {}
local   nVlrBol    := 0
local   nAcrescimo := 0
local   nVlrAbat   := 0
local   aBolText   := { "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO", "", "", "", "", "", "", "" }
local   nMulta     := 0
local   nMora      := 0
local   nPosText   := 2

private cTitulo    := "Impressao de Boleto SICREDI"
private lJob       := .F.
private cPrefixo   := ""
private cNumero    := ""
private cParcDe    := ""
private cParcAte   := "Z"
private cPasta     := ""
private _cConvenio := ""
private dVencto

default cParPref   := ""
default cParNum    := ""
default lQuiet     := .F.

	if select("SX2") == 0			// Se via JOB
		lJob := .T.
		ConOut( "Inicio emissão de boletos... - "+DtoC(date())+" "+time() )
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

	if empty( cParNum )		// perguntar p/ usuário
		if lJob
			ConOut( "Para JOB precisa informar Prefixo e Número, encerrando. - "+DtoC(date())+" "+time() )
			return nil
		endif

		Perguntar()
	else
		cPrefixo := padR( cParPref, len(SE1->E1_PREFIXO))
		cNumero  := padR( cParNum , len(SE1->E1_NUM)    )
	endif

	SE1->( dbSetOrder(1) )
	if ! SE1->( dbSeek( xFilial("SE1")+ cPrefixo + cNumero + cParcDe+"NF " ) )
		msgStop( "Título(s) não encontrado(s), verifique!", cTitulo)
	else

		aDadosEmp := {	SM0->M0_NOMECOM																,; //[1]Nome da Empresa
						SM0->M0_ENDCOB																,; //[2]Endereço
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
				Aviso("ATENÇÃO","Banco do Título ("+Alltrim(SE1->E1_PORTADO)+" - "+Alltrim(SE1->E1_AGEDEP)+" - "+Alltrim(SE1->E1_CONTA)+") nao localizado no cadastro de Bancos.",{"OK"})
				SE1->( dbSkip() )
				loop
			endif		

			if ! SEE->( dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA) ) )
				Aviso("ATENÇÃO","Parâmetros Bancários não encontrados ("+Alltrim(SE1->E1_PORTADO)+" - "+Alltrim(SE1->E1_AGEDEP)+" - "+Alltrim(SE1->E1_CONTA)+").",{"OK"})
				SE1->( dbSkip() )
				loop
			endif		

			if alltrim(SA6->A6_NUMBCO) != "748"
				Aviso("ATENÇÃO","Esta rotina só imprime o Boleto para o banco SICREDI. Banco do Título: ["+SE1->E1_PORTADO+"].",{"OK"})
				SE1->( dbSkip() )
				loop
			endif

			SA1->( dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA) ) )

			aDadosBanco := {"748"																,; // [1] Numero do Banco 
							"SICREDI"															,; // [2] Nome do Banco
							Alltrim(SA6->A6_AGENCIA)											,; // [3] Agência
							Alltrim(SA6->A6_NUMCON) 											,; // [4] Conta Corrente
							AllTrim(SA6->A6_DVCTA)												,; // [5] Dígito da conta corrente
							"1"																	,; // [6] Carteira com registro
							"X"																	,; // [7] Digito do banco
							"PAGÁVEL PREFERENCIALMENTE NAS COOPERATIVAS DE CRÉDITO DO SICREDI"	,; // [8] local de pagamento
							""																	,; // [9] Local de Pagamento2
							SA6->A6_DVAGE														,; //[10] Digito Verificador da agencia	
							left( SEE->EE_CODEMP, 5)											,; //[11] Código Cedente fornecido pelo Banco / Código do beneficiário [caracter 5]
							SA6->A6_XPOSTO														}  //[12] Posto [caracter 2]

			if Empty(SA1->A1_ENDCOB)
				aDatSacado := {	AllTrim(SA1->A1_NOME)								,;	// [1]Razão Social
								AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	// [2]Código
								AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)	,;	// [3]Endereço
								AllTrim(SA1->A1_MUN )								,;	// [4]Cidade
								SA1->A1_ESTC										,;	// [5]Estado
								SA1->A1_CEPC										,;	// [6]CEP
								SA1->A1_CGC											,;	// [7]CGC
								SA1->A1_PESSOA										,;	// [8]PESSOA
								SA1->A1_CXPOSTA										,;	// [9]CAIXA POSTAL
								SA1->A1_COMPLEM										}	// [10] COMPLEMENTO
			else
				aDatSacado := {	AllTrim(SA1->A1_NOME)								,;	// [1]Razão Social
								AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	// [2]Código
								AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereço
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
				_cFxAtu := strZero( val(alltrim(SEE->EE_FAXATU))+1 , 6)
				SEE->EE_FAXATU := _cFxAtu
				msUnlock()

				recLock("SE1", .F.)
				SE1->E1_NUMBCO := _cFxAtu + Substr(U_fNossoNum(_cFxAtu),Len(U_fNossoNum(_cFxAtu)),1)
				msUnlock()
			endif

			cNroDoc := alltrim(SE1->E1_NUMBCO)

			aDadosTit := {	SE1->E1_NUM + AllTrim(SE1->E1_PARCELA)		,;	// [1] Número do título
							SE1->E1_EMISSAO								,;	// [2] Data da emissão do título
							dDataBase          							,;	// [3] Data da emissão do boleto
							dVencto										,;	// [4] Data do vencimento
							(nVlrBol - nVlrAbat + nAcrescimo)			,;	// [5] Valor do título
							U_fNossoNum( Substr(cNroDoc,1,6) )			,;	// [6] Nosso número (Ver fórmula para calculo) // de 3 coloquei 9
							SE1->E1_PREFIXO								,;	// [7] Prefixo da NF
							iif(cEmpAnt$"010201;010301;020201","DR","DM"),;	// [8] Tipo do Titulo
							nVlrBol * (SE1->E1_DESCFIN/100) }				// [9] Desconto financeiro

			aCB_RN_NN := Ret_cBarra(	SE1->E1_PREFIXO,;
										SE1->E1_NUM,;
										SE1->E1_PARCELA,;
										SE1->E1_TIPO,;
										Subs(aDadosBanco[1],1,3),;				// banco
										aDadosBanco[3],;						// agencia
										aDadosBanco[4],;						// conta
										aDadosBanco[5],;						// dígito
										cNroDoc,;								// documento
										(nVlrBol - nVlrAbat + nAcrescimo),;		// valor
										aDadosBanco[6],;						// carteira
										"9",;									// moeda
										aDadosTit[6],;							// nosso número
										aDadosBanco[12],;						// Posto
										aDadosBanco[11];						// Cedente / Beneficiario
									)

			if len(aCB_RN_NN) > 0

				if GetMV("MV_LJMULTA") > 0 .OR. nMulta > 0
					IF GetMV("MV_LJMULTA") > 0
						aBolText[nPosText] := "Após Vencimento, Multa de "+ Transform(GetMV("MV_LJMULTA"),"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform(((nVlrBol - nVlrAbat + nAcrescimo)*(GetMV("MV_LJMULTA")/100)),"@E 99,999.99"))
					ELSE
						aBolText[nPosText] := "Após Vencimento, Multa de "+ Transform(nMulta,"@R 99.99%") +" no Valor de R$ "+AllTrim(Transform(((nVlrBol - nVlrAbat + nAcrescimo)*(nMulta/100)),"@E 99,999.99"))
					EndIf	
					nPosText++
				endif

				if GetMV("MV_TXPER") > 0  .OR. nMora > 0
					If GetMV("MV_TXPER") > 0
						aBolText[nPosText] := "Após Vencimento, Mora Diária de "+ Transform(GetMV("MV_TXPER"),"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( (nVlrBol - nVlrAbat + nAcrescimo)*GetMV("MV_TXPER") )/100),"@E 99,999.99"))+"."
					Else
						aBolText[nPosText] := "Após Vencimento, Mora Diária de "+ Transform(nMora,"@R 99.99%") +" no valor de R$ "+AllTrim(Transform(( ( (nVlrBol - nVlrAbat + nAcrescimo)*nMora )/100),"@E 99,999.99"))+"."
					EndIf
					nPosText++
				endif

				if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
					aBolText[nPosText] := "Desconto concedido de R$ "+AllTrim(Transform(aDadosTit[9] ,"@E 99,999.99"))+" para pagamento até a data de vencimento."
					nPosText++
				endif

				if left(cFilAnt, 2) == "01"		// NAYUMI
					aBolText[nPosText] := "Não receber após 30 dias do vencimento"
					nPosText++
					aBolText[nPosText] := "**PROTESTAR APÓS 5 DIAS DO VENCIMENTO**"
					nPosText++
					aBolText[nPosText] := "*O não pagamento causara suspensão das entregas*"
					nPosText++
				else							// DDS
					aBolText[nPosText] := "PROTESTAR APÓS 5 DIAS DO VENCIMENTO."
					nPosText++					
				endif

				Impress( oPrint, aDadosEmp, aDadosTit, aDadosBanco, aDatSacado, aBolText, aCB_RN_NN, cNroDoc )

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
	aAdd(aPergs,{1,"Número"		,MV_PAR02		,"", ,""   ,".T.",0,.F.})
	aAdd(aPergs,{1,"Parcela"	,MV_PAR03		,"", ,""   ,".T.",0,.F.})

	if ParamBox(aPergs,"Selecione o Título para impressão do boleto SICREDI",@aRet,,,,,,,,.F.)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Impress   º                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acelerador                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,aNossoN)
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

	oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/
	nRow1	:= 0
	nRowSay := 035

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	oPrint:SayBitmap(nRow1+0070,100,cStartPath+"sicredi.jpg",350,075)

	oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
	oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

	oPrint:Say(nRowSay+0095,513,aDadosBanco[1]+"-"+aDadosBanco[7] ,oFont20 )	// [1]Numero do Banco   + [7] DV Banco

	oPrint:Say(nRowSay+0084,1900,"Comprovante de Entrega",oFont10n)
	oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

	oPrint:Say(nRowSay+0150,100 ,"Beneficiário",oFont8)
	oPrint:Say(nRowSay+0200,100 ,aDadosEmp[1],oFont10n)				//Nome + CNPJ

	oPrint:Say(nRowSay+0150,1060,"Agência\Codigo do Beneficiário",oFont8)
//	cString := Alltrim(aDadosBanco[3]+iif(!Empty(aDadosBanco[10]),"-"+aDadosBanco[10],"")+"/"+iif(Empty(aDadosBanco[11]),aDadosBanco[4]+"-"+aDadosBanco[5], aDadosBanco[11]))
	cString := aDadosBanco[3] + "." + aDadosBanco[12] + "." + aDadosBanco[11]
//	oPrint:SayAlign(nRowSay+0200,1060, cString,oFont11c, 500, , , 1, 1)
	oPrint:Say(nRowSay+0200,1060,cString,oFont11c)

	oPrint:Say(nRowSay+0150,1510,"Nro.Documento",oFont8)
	oPrint:Say(nRowSay+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say(nRowSay+0250,100 ,"Pagador",oFont8)

	oPrint:Say(nRowSay+0300,100 ,aDatSacado[1],oFont10n)				//Nome

	oPrint:Say(nRowSay+0250,1060,"Vencimento",oFont8)
	oPrint:Say(nRowSay+0300,1060,StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4),oFont10n)

	oPrint:Say(nRowSay+0250,1510,"Valor do Documento",oFont8)
	oPrint:Say(nRowSay+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10n)

	oPrint:Say(nRowSay+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
	oPrint:Say(nRowSay+0430,0100,"com as características acima.",oFont10)

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
	oPrint:Say(nRowSay+0225,1910,"(  )Não existe nº indicado" ,oFont10n)
	oPrint:Say(nRowSay+0255,1910,"(  )Recusado"               ,oFont10n)
	oPrint:Say(nRowSay+0285,1910,"(  )Não procurado"          ,oFont10n)
	oPrint:Say(nRowSay+0315,1910,"(  )Endereço insuficiente"  ,oFont10n)
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
	oPrint:SayBitmap(nRow2+0630,100,cStartPath+"sicredi.jpg",350,075)

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
	oPrint:Say(nRowSay+0750,100 ,aDadosBanco[8] ,oFont10n)

	oPrint:Say(nRowSay+0710,1810,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
	oPrint:SayAlign(nRowSay+0730,1800, cString, oFont12, 500, , , 1, 1)

	oPrint:Say(nRowSay+0805,100 ,"Beneficiário"                                   ,oFont8)

	oPrint:Say(nRowSay+0835,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ
	oPrint:Say(nRowSay+0870,100 ,Alltrim(aDadosEmp[2])+", "+aDadosEmp[4]+" - "+aDadosEmp[3]	,oFont10n) //Endereço + CEP

	oPrint:Say(nRowSay+0810,1810,"Agência\Codigo do Beneficiário",oFont8)
	cString := aDadosBanco[3] + "." + aDadosBanco[12] + "." + aDadosBanco[11]
	oPrint:SayAlign(nRowSay+0830,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+0905,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say(nRowSay+0935,100, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4),oFont10n)

	oPrint:Say(nRowSay+0905,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say(nRowSay+0935,505 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say(nRowSay+0905,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say(nRowSay+0935,1005,aDadosTit[8]									  ,oFont10n) //Tipo do Titulo

	oPrint:Say(nRowSay+0905,1305,"Aceite"                                         ,oFont8)
	oPrint:Say(nRowSay+0935,1305,"NÃO"                                            ,oFont10n)

	oPrint:Say(nRowSay+0905,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say(nRowSay+0935,1485,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4),oFont10n) // Data impressao

	oPrint:Say(nRowSay+0905,1810,"Nosso Número"                                   ,oFont8)
	cString := Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)
//	oPrint:Say(nRowSay+0940,1800,right( cString, 20 ),oFont11c)
	oPrint:SayAlign(nRowSay+0900,1800, cString,oFont11c, 500, , , 1, 1)



	oPrint:Say(nRowSay+0970,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say(nRowSay+0970,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say(nRowSay+1000,505 ,aDadosBanco[6]                                   ,oFont10n)

	oPrint:Say(nRowSay+0970,755 ,"Espécie"                                        ,oFont8) 
	oPrint:Say(nRowSay+1000,755 ,"REAL"                                           ,oFont10n)


	oPrint:Say(nRowSay+0970,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say(nRowSay+0970,1485,"Valor"                                          ,oFont8)

	oPrint:Say(nRowSay+0970,1810,"Valor do Documento"                          	  ,oFont8)

	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
//	oPrint:Say(nRowSay+1010,1800,right( cString, 20 ),oFont11c)
	oPrint:SayAlign(nRowSay+0970,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+1035,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
	oPrint:Say(nRowSay+1080,100 ,"ATENÇÃO SR. CAIXA:",oFont10n)
	oPrint:Say(nRowSay+1110,100 ,aBolText[1],oFont10n)
	oPrint:Say(nRowSay+1140,100 ,aBolText[2],oFont10n)
	oPrint:Say(nRowSay+1170,100 ,aBolText[3],oFont10n)
	oPrint:Say(nRowSay+1200,100 ,aBolText[4],oFont10n)
	oPrint:Say(nRowSay+1230,100 ,aBolText[5],oFont10n)
	oPrint:Say(nRowSay+1260,100 ,aBolText[6],oFont10n)
	oPrint:Say(nRowSay+1290,100 ,aBolText[7],oFont10n)
	oPrint:Say(nRowSay+1320,100 ,aBolText[8],oFont10n)

// MSG dos Parametros
//if !Empty(MV_PAR21)
//	oPrint:Say(nRowSay+1360,100, AllTrim(MV_PAR21) + " - " + AllTrim(MV_PAR22),oFont10n)
//endif

	oPrint:Say(nRowSay+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say(nRowSay+1120,1810,"(-)Outras Deduções"                             ,oFont8)

	oPrint:Say(nRowSay+1190,1810,"(+)Mora/Multa"                                  ,oFont8)

	oPrint:Say(nRowSay+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say(nRowSay+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

	if aDadosTit[9] > 0 .and. aDadosTit[4] >= dDataBase
		cString := Alltrim(Transform( aDadosTit[9],"@E 999,999,999.99"))
		nCol 	 := 1810+(374-(len(cString)*22))
		oPrint:Say(nRowSay+1080,nCol,cString,oFont11c)
	endif

	oPrint:Say(nRowSay+1400,100 ,"Pagador",oFont8)
//	oPrint:Say(nRowSay+1530,100 ,"Caixa Postal",oFont8)

	oPrint:Say(nRowSay+1405,200 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
	oPrint:Say(nRowSay+1438,200 ,aDatSacado[3]                                    ,oFont10n)
	oPrint:Say(nRowSay+1471,200 ,aDatSacado[4]+"    "+aDatSacado[5]+"    "+aDatSacado[6],oFont10n)
	oPrint:Say(nRowSay+1504,200 ,aDatSacado[10]                                   ,oFont10n)
	oPrint:Say(nRowSay+1537,200 ,aDatSacado[9]                                    ,oFont10n) 

	oPrint:Say(nRowSay+1560,100 ,"Sacador/Avalista",oFont8)

	if ! empty(aDatSacado[7])
		if aDatSacado[8] = "J"
			oPrint:Say(nRowSay+1580,300 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10n)
		Else
			oPrint:Say(nRowSay+1580,300 ,"CPF: " +TRANSFORM(aDatSacado[7],"@R 999.999.999-99")    ,oFont10n)
		EndIf
	EndIf

	oPrint:Say(nRowSay+1620,1550,"Autenticação Mecânica",oFont8)

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
	oPrint:SayBitmap(nRow3+1922,100,cStartPath+"sicredi.jpg",350,075)

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
	oPrint:Say(nRowSay+2045,100 ,aDadosBanco[8],oFont10n)
//	oPrint:Say(nRowSay+2055,400 ,aDadosBanco[9],oFont10n)

	oPrint:Say(nRowSay+2000,1810,"Vencimento",oFont8)

	cString := StrZero(Day((aDadosTit[4])),2) +"/"+ StrZero(Month((aDadosTit[4])),2) +"/"+ Right(Str(Year((aDadosTit[4]))),4)
//	oPrint:Say(nRowSay+2045,nCol,cString,oFont12)
	oPrint:SayAlign(nRowSay+2015,1800, cString,oFont12, 500, , , 1, 1)


	oPrint:Say(nRowSay+2100,100 ,"Beneficiário",oFont8)

	oPrint:Say(nRowSay+2150,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10n) //Nome + CNPJ

	oPrint:Say(nRowSay+2100,1810,"Agência\Codigo do Beneficiário",oFont8)
	cString := aDadosBanco[3] + "." + aDadosBanco[12] + "." + aDadosBanco[11]
//	oPrint:Say(nRowSay+2150,nCol,cString ,oFont11c)
	oPrint:SayAlign(nRowSay+2115,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say (nRowSay+2200,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say (nRowSay+2230,100, StrZero(Day((aDadosTit[2])),2) +"/"+ StrZero(Month((aDadosTit[2])),2) +"/"+ Right(Str(Year((aDadosTit[2]))),4), oFont10n)

	oPrint:Say(nRowSay+2200,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say(nRowSay+2230,505 ,aDadosTit[7]+aDadosTit[1]						,oFont10n) //Prefixo +Numero+Parcela

	oPrint:Say(nRowSay+2200,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say(nRowSay+2230,1005,aDadosTit[8]									  ,oFont10n) //Tipo do Titulo

	oPrint:Say(nRowSay+2200,1305,"Aceite"                                         ,oFont8)
	oPrint:Say(nRowSay+2230,1305,"NÃO"                                            ,oFont10n)

	oPrint:Say(nRowSay+2200,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say(nRowSay+2230,1485,StrZero(Day((aDadosTit[3])),2) +"/"+ StrZero(Month((aDadosTit[3])),2) +"/"+ Right(Str(Year((aDadosTit[3]))),4)                               ,oFont10n) // Data impressao

	oPrint:Say(nRowSay+2200,1810,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4))
//	oPrint:Say(nRowSay+2230,nCol,' '+cString,oFont11c)
	oPrint:SayAlign(nRowSay+2195,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+2270,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say(nRowSay+2270,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say(nRowSay+2300,505 ,aDadosBanco[6]                                   ,oFont10n)


	oPrint:Say(nRowSay+2270,755 ,"Espécie"                                        ,oFont8)
	oPrint:Say(nRowSay+2300,755 ,"REAL"                                           ,oFont10n)

	oPrint:Say(nRowSay+2270,1005,"Quantidade"                                     ,oFont8)

	oPrint:Say(nRowSay+2270,1485,"Valor"                                          ,oFont8)

	oPrint:Say(nRowSay+2270,1810,"Valor do Documento"                             ,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
//	oPrint:Say(nRowSay+2300,nCol-20,cString,oFont11c)
	oPrint:SayAlign(nRowSay+2265,1800, cString,oFont11c, 500, , , 1, 1)

	oPrint:Say(nRowSay+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário)",oFont8)
	oPrint:Say(nRowSay+2380,100 ,"ATENÇÃO SR. CAIXA:",oFont10n)
	oPrint:Say(nRowSay+2410,100 ,aBolText[1],oFont10n)
	oPrint:Say(nRowSay+2440,100 ,aBolText[2],oFont10n)
	oPrint:Say(nRowSay+2470,100 ,aBolText[3],oFont10n)
	oPrint:Say(nRowSay+2500,100 ,aBolText[4],oFont10n)
	oPrint:Say(nRowSay+2530,100 ,aBolText[5],oFont10n)
	oPrint:Say(nRowSay+2560,100 ,aBolText[6],oFont10n)
	oPrint:Say(nRowSay+2590,100 ,aBolText[7],oFont10n)
	oPrint:Say(nRowSay+2620,100 ,aBolText[8],oFont10n)

	oPrint:Say(nRowSay+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say(nRowSay+2410,1810,"(-)Outras Deduções"                             ,oFont8)

	oPrint:Say(nRowSay+2480,1810,"(+)Mora/Multa"                                  ,oFont8)

	oPrint:Say(nRowSay+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say(nRowSay+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say(nRowSay+2690,100 ,"Pagador",oFont8)

	oPrint:Say(nRowSay+2700,200 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10n)
	oPrint:Say(nRowSay+2743,200 ,aDatSacado[3]                                    ,oFont10n)
	oPrint:Say(nRowSay+2786,200 ,aDatSacado[4]+"    "+aDatSacado[5]+"    "+aDatSacado[6],oFont10n)

	if aDadosTit[9] > 0  .and. aDadosTit[4] >= dDataBase
		cString := Alltrim(Transform(aDadosTit[9],"@E 999,999,999.99"))
		nCol 	 := 1810+(374-(len(cString)*22))
		oPrint:Say(nRowSay+2370,nCol,cString,oFont11c)
	endif

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

	oPrint:Say(nRowSay+2915,1820,"Autenticação Mecânica - Ficha de Compensação"   ,oFont8)

	oPrint:FwMsBar("INT25" /*cTypeBar*/, 66 /*nRow*/, 2.40 /*nCol*/,;
	aCB_RN_NN[1] /*cCode*/, oPrint, .F. /*Calc6. Digito Verif*/,;
	/*Color*/, /*Imp. na Horz*/, 0.025 /*Tamanho*/, 0.85 /*Altura*/, , , ,.F. )

	oPrint:EndPage() // Finaliza a página
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Ret_cBarraº                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acelerador                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
							cBanco		,cAgencia	,cConta		,cDacCC	,;
							cNroDoc		,nValor		,cCart		,cMoeda ,;
							cNossoNum	,cPosto		,cCedente			)
local cCampoL		:= ""
local cFator		:= ""
local cValor		:= ""
local cDigBarra		:= ""
local cBarra		:= ""
local cParte1		:= ""
local cDig1			:= ""
local cParte2		:= ""
local cDig2			:= ""
local cParte3		:= ""
local cDig3			:= ""
local cParte4		:= ""
local cParte5		:= ""
local cDigital		:= ""
local aRet			:= {}

	cAgencia   := StrZero(Val(Right(cAgencia,4)),4)

	//fator
	cFator := cValToChar( dVencto - StoD("19971007") )		// 07/10/1997

	//valor
	cValor  := strzero( iif(nValor > 0, nValor, SE1->E1_SALDO ) * 100, 10 )

	// campo livre
	cCampoL := cCart + "1" + sohDigit(cNossoNum) + cAgencia + cPosto + cCedente + "1" + "0"
	cCampoL += u_fMod11( cCampoL, .T. )

	// campo do digito verificador do codigo de barra
	cBarra := cBanco + cMoeda + "" +  cFator + cValor + cCampoL
	cDigBarra := u_fMod11( cBarra, .F., .T. )

	// campo do codigo de barra
	cBarra    := left(cBarra,4) + cDigBarra + substr(cBarra,5)


	// composicao da linha digitavel
	cParte1  := cBanco + cMoeda + "1" + Substr(cBarra,21,4)		// 74891.1 123(nosso)
	cDig1    := fMod10( cParte1 )		// 
	cParte1  += cDig1

	cParte2  := SUBSTR(cBarra,25,10)
	cDig2    := fMod10( cParte2 )
	cParte2  += cDig2

	cParte3  := SUBSTR(cBarra,35,10)
	cDig3    := fMod10( cParte3 )
	cParte3  += cDig3

	cParte4  := cDigBarra
	cParte5  := cFator + cValor

	cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
				substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
				substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
				cParte4+" "+;
				cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)

	if len(aRet) == 0
		AVISO("Atenção", "Banco ou Convênio invalido, favor revise o cadastro de parametro de bancos!"+CRLF+ "Banco: "+alltrim(cBanco)+" Convênio: "+alltrim(AllTrim(_cConvenio))  , {"Ok"})
		return nil
	endif
Return aRet


//-----------------------------
user function fNossoNum( cParNosso )
local cRet := Right( DtoC( date() ), 2)
local cString := SA6->( alltrim( A6_AGENCIA ) + A6_XPOSTO + A6_NUMCON )
	If FunName() $ "MATA461" .Or. FunName() $ "MATA460A"
		cString := alltrim( SEE->EE_AGENCIA ) + Posicione("SA6",1,xFilial("SEE")+SEE->(EE_CODIGO+EE_AGENCIA+EE_CONTA),"A6_XPOSTO") + SEE->EE_CONTA
		cString += cRet + StrZero( val( cParNosso ), 6 )
	Else
		cString += cRet + StrZero( val( cParNosso ), 6 )
	Endif

	cRet += "/"
	cRet += StrZero( val( cParNosso ), 6 )
	cRet += "-"
	cRet += u_fMod11( cString )
return cRet

//-----------------------------
static function fMod10( cParte )
local nAcm  := 0
local nTemp
local nI
local nVez  := 2

	for nI := len( cParte ) to 1 step -1
		nTemp := val( substr( cParte, nI, 1) ) * nVez

		if nTemp > 9		// se maior que 9, somar os dígitos
			nTemp := val( left( cValToChar(nTemp), 1 ) ) + val( right( cValToChar(nTemp), 1 ) )
		endif

		nVez  := iif( nVez == 2, 1, 2)
		nAcm  += nTemp
	next

	if nAcm % 10 == 0
		nRet := 0
	else
		nMultiplo := ( val( left( strZero(nAcm,2), 1 ) ) + 1 ) * 10
		nRet      := nMultiplo - nAcm
	endif

return cValToChar(nRet)


//-----------------------------
user function fMod11( cParte, lCpoLivre, lCodBar )
local   cRet      := ""
local   nAcm      := 0
local   nVez      := 2
local   nI
default lCpoLivre := .F.
default lCodBar   := .F.

	for nI := len( cParte ) to 1 step -1
		nAcm += val( substr( cParte, nI, 1) ) * nVez
		nVez++
		if nVez > 9
			nVez := 2
		endif
	next

	nParte1 := int( nAcm / 11 )
	nParte2 := nParte1 * 11
	nParte3 := nAcm - nParte2
	nRet    := 11 - nParte3

	cRet    := iif( nRet > 9 , "0", cValToChar(nRet))

//	if lCpoLivre .and. cRet == "1"
//		cRet := "0"
//	endif

	if lCodBar .and. cRet == "0"
		cRet := "1"
	endif

return cRet


//-----------------------------
static function sohDigit( cEntrada )
local cRet := ""
local nI
local cDig

	for nI := 1 to len( cEntrada )
		cDig := substr( cEntrada, nI, 1 )
		if cDig $ "1234567890"
			cRet += cDig
		endif
	next

return cRet
