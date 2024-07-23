<SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>INSERT_FILE_DATASET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_STRINGTABLE                 TYPE        STRING_TABLE
* | [--->] PATH_DATASET                   TYPE        STRING
* | [--->] ID_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_file_dataset.

    "variaveis para receber os ids em tipos diferentes de formatos
    DATA: id_str  TYPE string,
          id_char TYPE char10,
          id_num  TYPE znn_candidatos-id_candidato.

    id_num = zcl_rla_candidato=>get_next_user( ). "metodo da propria classe que retorna o proximo id disponivel

    " Verifica se o id foi retornado corretamente
    IF id_num IS INITIAL.
      MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
    ENDIF.

    zcl_rla_candidato=>get_id_strchar( "metodo da propria classe que exporta o proximo id disponivel convertido no tipo string e char10
      IMPORTING
        id_char   =  id_char         " char10 com zeros à esquerda
        id_string =  id_str          " string comum
    ).

    " Verifica se o id foi retornado corretamente
    IF id_char IS INITIAL OR id_str IS INITIAL.
      MESSAGE 'Faltam IDs convertido em string ou char10.' TYPE 'E'.
    ENDIF.

    id_str = id_char. "casting char10 >> str

    DATA: v_dir_dataset TYPE string. "cria a string para receber todo o texto concatenado
    "concatena o caminho, o id  e a extensao do arquivo dentro da string
    CONCATENATE path_dataset '\' id_str '.txt' INTO v_dir_dataset.
    CONDENSE v_dir_dataset.

    "converte toda string concatenada em tipo char
    DATA: v_dataset_final(30) TYPE c.
    v_dataset_final = v_dir_dataset. "casting str >> char

    " Verifica se o casting aconteceu antes de servir como referencia ao dataset
    IF v_dataset_final NE v_dir_dataset.
      MESSAGE 'Caminho para o Dataset inconsistente' TYPE 'E'.
    ENDIF.

    "gravacao do ficheiro no servidor.
    OPEN DATASET v_dataset_final FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      LOOP AT it_stringtable INTO DATA(wa_text).
        TRANSFER wa_text TO v_dataset_final.
        CLEAR wa_text.
      ENDLOOP.
      CLOSE DATASET v_dataset_final.
      MESSAGE 'Arquivo gravado com sucesso' TYPE 'S'.
    ELSE.
      MESSAGE 'Erro ao gravar o ficheiro no servidor.' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
