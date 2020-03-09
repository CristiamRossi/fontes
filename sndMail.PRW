#include "totvs.ch"
#include "ap5mail.ch"
/*/{Protheus.doc} sndMail
Rotina genérica para envio de e-mail
@type function
@author Cristiam Rossi
@since 24/01/2020
@version 1.0
@return ${return} .T. / .F.
@example
(examples)
@see (links_or_references)
*/
//#include "tbiconn.ch"
//user function xxxMail()
//	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '020101' USER 'Administrador' PASSWORD '' /*TABLES 'EEC,EE9'*/ MODULO 'FAT'
//	xRet := U_sndMail( "aprendiz_cris@yahoo.com.br", "assunto do e-mail", "Corpo do e-mail<br />"+time(),  {"C:\TEMP\pn2000.dtc"}/*aAnexo*/, /*cCopia*/, /*cOculta*/, /*lQuiet*/ )
//	alert( iif(xRet, "Ok", "Falhou") )
//return nil

user function sndMail( cPara, cAssunto, cCorpo,  aAnexo, cCopia, cOculta, lQuiet )
local   oServer
local   oMessage
local   nI
default cPara		:= ""
default cAssunto	:= ""
default cCorpo		:= ""
default aAnexo		:= {}
default cCopia		:= ""
default cOculta		:= ""
default lQuiet		:= .F.

	if empty( cPara )
		if ! lQuiet
			msgAlert("Mensagem não pode ser enviada pois o Destinatário está em branco", "Envio de e-mail automático")
		endif
		return .F.
	endif

	cServerSMTP := GETmv("MV_RELSERV")	// "email-ssl.com.br"
	cUserPop    := getMV("MV_RELACNT")	// "nayumi@nayumi.com.br"
	cSenhaPop   := getMV("MV_RELAPSW")	// "Loca@#nayu"
	nPortaSmtp  := getMV("MV_PORSMTP")	// 465
	lAutentica  := getMV("MV_RELAUTH")	// .T.		// Necessita Autenticação de e-mail

	oServer := TMailMng():New( 0, 0, 2 )

	oServer:cSMTPAddr := cServerSMTP
 	oServer:nSMTPPort := nPortaSmtp
	oServer:cUser     := cUserPop
	oServer:cPass     := cSenhaPop

	conout( "SMTP Addr: " + oServer:cSMTPAddr )
	conout( oServer:nSMTPPort )
	conout( "User: " + oServer:cUser )
	conout( "Pass: " + oServer:cPass )
	conout( oServer:lSMTPConnected )

	nRet := oServer:SmtpConnect()
	conout( "Retorno SMTPCONNECT: " + oServer:GetErrorString( nRet ) )

	conout( oServer:lSMTPConnected )

	If lAutentica
		nRet := oServer:SMTPAuth( oServer:cUser, oServer:cPass )
		conout( "autenticacao: " + cValToChar(nRet) +" - " + oServer:GetErrorString( nRet ) )
	endif

	oMessage := TMailMessage():New()
	oMessage:Clear()
   
	oMessage:cFrom := cUserPop
	oMessage:cTo   := cPara
	if ! empty( cCopia )
		oMessage:cCc := cCopia
	endif

	if ! empty( cOculta )
		oMessage:cBcc := cOculta
	endif

	oMessage:cSubject := cAssunto
	oMessage:cBody    := cCorpo


	for nI := 1 to len( aAnexo )
		if ! file( aAnexo[nI] )
			conout( "arquivo: "+aAnexo[nI]+" nao encontrado, nao foi anexado" )
		else
			cArq := aAnexo[nI]
			if cpyT2S( aAnexo[nI], "\" )
				cArq := strtran( aAnexo[nI], "/", "\" )
				cArq := substr( cArq, rAt( "\", cArq ) )
				if ( nResult := oMessage:AttachFile( cArq ) ) < 0
					conout( "erro ao anexar arquivo: " + cArq + "/" + aAnexo[nI] + " - " + oServer:GetErrorString( nResult ) )
				endif
//				fErase( cArq )
			else
				conout( "arquivo: "+aAnexo[nI]+" nao pode ser copiado para o servidor, nao foi anexado" )
			endif
		endif
	next

	if ( nResult := oMessage:Send2( oServer ) ) != 0
		conout( "Erro ao enviar o e-mail" )
		conout( oServer:GetErrorString( nResult ) )
		oMessage := nil
		oServer  := nil
		return .F.
	endif

	if ( nResult := oServer:SmtpDisconnect() ) != 0
		conout( "Erro ao disconectar do servidor SMTP" )
		conout( oServer:GetErrorString( nResult ) )
		oMessage := nil
		oServer  := nil
		return .T.
	endif

	oMessage := nil
	oServer  := nil
return .T.
