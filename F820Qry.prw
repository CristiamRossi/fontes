#Include "Protheus.ch"
#Include "rwmake.ch"

User Function F820Qry()

Local cCond := ParamIXB // Condição (cláusula WHERE da query) padrão para geração dos movimentos financeiros LCDPR.
Local aRet := {}

cCond := " E5_NATUREZ = 'NTLCDPRESP' "

aAdd(aRet, cCond)
aAdd(aRet, " E5_BENEF + ' - ' + E5_IDORIG ") // Parâmetro que substitui a impressão do histórico do título (campo E5_HISTOR).

Return aRet

