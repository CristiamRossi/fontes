#include "totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA60FIL   �Autor  �Andr�a Martins      � Data �  27/11/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FA60FIL()
local cRetFil  := ""
local cAxBanco := padR( paramIxb[1], len(SE1->E1_PORTADO) )

	if MsgYesNo("Filtra somente titulos a receber do portador/banco "+cAxBanco+" ? ","Aten��o")
//		cRetFil := " E1_PORTADO=='"+cAxBanco+"' .and. !empty(E1_NUMBCO) "
		cRetFil := " E1_PORTADO=='"+cAxBanco+"' "
	else
		MsgAlert("Ser� considerado somente portador em branco!","Aten��o")
		cRetFil := " empty(E1_PORTADO) "  		
	endif

return cRetFil
