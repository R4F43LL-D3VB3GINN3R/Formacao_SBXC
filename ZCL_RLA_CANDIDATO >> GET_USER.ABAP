"ID1	TYPE ZNN_CANDIDATOS-ID_CANDIDATO	Convertido para INT4
"ID2	TYPE STRING	                      Convertido para String
"ID3	TYPE CHAR10	                      Convertido para Char10

  METHOD get_user.

    "consulta para determinar o proximo numero de candidato disponivel.
    "atributo da classe recebe o resultado da consulta
    SELECT MAX( id_candidato ) FROM znn_candidatos INTO cv_id_candidato.

    "verificacao da consulta
    IF sy-subrc EQ 0.
      ADD 1 TO cv_id_candidato. "incremento do valor da consulta
    ELSE.
      MESSAGE 'Erro ao buscar o número do candidato' TYPE 'E'.
    ENDIF.

    id1 = cv_id_candidato. "atributo     >> parâmetro
    id2 = cv_id_candidato. "casting int4 >> string
    id3 = cv_id_candidato. "casting int4 >> char10

    " Formatar número com zeros à esquerda
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = id3
      IMPORTING
        output = id3.

  ENDMETHOD.
