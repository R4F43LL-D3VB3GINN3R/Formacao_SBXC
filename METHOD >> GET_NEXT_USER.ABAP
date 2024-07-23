<SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>GET_NEXT_USER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID1                            TYPE        ZNN_CANDIDATOS-ID_CANDIDATO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_next_user.

    "consulta para determinar o proximo numero de candidato disponivel.
    "atributo da classe recebe o resultado da consulta
    SELECT MAX( id_candidato ) FROM znn_candidatos INTO id1.

    "verificacao da consulta
    IF sy-subrc EQ 0.
      ADD 1 TO id1. "incremento do valor da consulta para que se defina o proximno candidato disponivel
    ELSE.
      MESSAGE 'Erro ao buscar o número do candidato' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
