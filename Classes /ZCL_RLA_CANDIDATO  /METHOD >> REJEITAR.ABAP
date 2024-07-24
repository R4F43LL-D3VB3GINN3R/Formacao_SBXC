* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_CANDIDATO->REJEITAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] E_RESULT                       TYPE        ZNN_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD rejeitar.
    "invoca o metodo para alterar os estado do candidato
    me->alterar_estado(
      EXPORTING
        estado   = me->const_rejeitado   " 1 = Aprovado / 2 = Reprovado
      IMPORTING
        e_result = e_result             " Estrutura de resultados de operações
    ).

  ENDMETHOD.
ENDCLASS.
