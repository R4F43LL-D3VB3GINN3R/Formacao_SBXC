* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_CANDIDATO->APROVAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] E_RESULT                       TYPE        ZNN_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD aprovar.

    "recebe o metodo da classe
    me->alterar_estado(
      EXPORTING
        estado   = me->const_aprovado   " 1 = Aprovado / 2 = Reprovado
      IMPORTING
        e_result = e_result             " Estrutura de resultados de operações
    ).

  ENDMETHOD.
