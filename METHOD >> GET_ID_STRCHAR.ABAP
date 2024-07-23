<SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>GET_ID_STRCHAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] ID_CHAR                        TYPE        CHAR10
* | [<---] ID_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_id_strchar.

    TRY.
        "chama o metodo de classe para pegar o proximo id disponivel
        DATA: id_temp TYPE znn_candidatos-id_candidato.
        id_temp = get_next_user( ).

        " Verifica se o id foi retornado corretamente
        IF id_temp IS INITIAL.
          MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
        ENDIF.

        "variaveis recebem o valor do id
        id_char = id_temp.   "casting int4 >> char10
        id_string = id_temp. "casting int4 >> char10

        " Formatar número com zeros à esquerda
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = id_char
          IMPORTING
            output = id_char.
      CATCH cx_static_check INTO DATA(ex).
        " tratamento de erro estático
        MESSAGE ex TYPE 'E'.
      CATCH cx_sy_open_sql_db INTO DATA(ex2).
        " tratamento de erro de banco de dados
        MESSAGE ex2 TYPE 'E'.
      CATCH cx_root INTO DATA(ex3).
        " tratamento de erro genérico
        MESSAGE ex3 TYPE 'E'.
    ENDTRY.

  ENDMETHOD.
