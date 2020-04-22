#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³PE01NFESEFAZ ³ Autor ³ Elvis              ³ Data ³16.04.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³PArametro para alteracao das informações NF-ELETRONICA      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Especifico³ Autimpex                                                   ³±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
*-------------------------*
User Function PE01NFESEFAZ
*-------------------------* 
Local aArea  := GetArea()
Local aProd     := PARAMIXB[1]
Local cMensCli  := PARAMIXB[2]
Local cMensFis  := PARAMIXB[3]
Local aDest     := PARAMIXB[4]
Local aNota     := PARAMIXB[5]
Local aInfoItem := PARAMIXB[6]
Local aDupl     := PARAMIXB[7]
Local aTransp   := PARAMIXB[8]
Local aEntrega  := PARAMIXB[9]
Local aRetirada := PARAMIXB[10]
Local aVeiculo  := PARAMIXB[11]
Local aReboque  := PARAMIXB[12]
Local aNfVincRur:= PARAMIXB[13]
Local aEspVol   := PARAMIXB[14]
Local aNfVinc   := PARAMIXB[15]
Local AdetPag   := PARAMIXB[16]
Local aObsCont  := PARAMIXB[17]
Local aProcRef  := PARAMIXB[18]
Local aRetorno      := {}

Private cNumPV	:= aInfoItem[1][01]

//Alimenta Retorno
aadd(aRetorno,aProd)
aadd(aRetorno,cMensCli+" PV: "+cNumPV)
aadd(aRetorno,cMensFis+" Disp. Legal ICMS: ISENTO – ARTIGO 8 – RICMS/SP – DECRETO 45.920/2000 – ANEXO 1 – ARTIGO 36 – INC I"+" / "+;
                        "Disp. Legal PIS/COFINS: ALIQUOTA ZERO – LEI 10.854/2004 – ARTIGO 28 – INC III"+" / "+;
                        "Disp. Legal Lei IPI: NAO TRIBUTADO – DECRETO 8950/2016 – CAPITULO 7 - TIPI")
aadd(aRetorno,aDest)
aadd(aRetorno,aNota)
aadd(aRetorno,aInfoItem)
aadd(aRetorno,aDupl)
aadd(aRetorno,aTransp)
aadd(aRetorno,aEntrega)
aadd(aRetorno,aRetirada)
aadd(aRetorno,aVeiculo)
aadd(aRetorno,aReboque)
aadd(aRetorno,aNfVincRur)
aadd(aRetorno,aEspVol)
aadd(aRetorno,aNfVinc)
aadd(aRetorno,AdetPag)
aadd(aRetorno,aObsCont)
aadd(aRetorno,aProcRef)

RestArea(aArea)

RETURN aRetorno       
