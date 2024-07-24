* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>READ_FILE_DATASET
* +-------------------------------------------------------------------------------------------------+
* | [--->] PATH_DATASET                   TYPE        STRING
* | [--->] ID_STRING                      TYPE        STRING
* | [<-->] IT_STRINGTABLE2                TYPE        STRING_TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD read_file_dataset.

    "variaveis para receber os ids em tipos diferentes de formatos
    DATA: id_str  TYPE string,
          id_char TYPE char10.

    id_str = id_string. "variavel recebe parametro

    " Verifica se o id foi retornado corretamente
    IF id_str IS INITIAL.
      MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
    ENDIF.

    id_char = id_str. "casting char >> str

    "formatar número com zeros à esquerda
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = id_char
      IMPORTING
        output = id_char.

    "verifica se o id foi retornado corretamente
    IF id_char IS INITIAL.
      MESSAGE 'Faltam IDs convertido em string ou char10.' TYPE 'E'.
    ENDIF.

    id_str = id_char. "casting char10 >> str

    DATA: v_dir_dataset TYPE string. "cria a string para receber todo o texto concatenado
    "concatena o caminho, o id  e a extensao do arquivo dentro da string
    CONCATENATE path_dataset '/' id_str '.txt' INTO v_dir_dataset.
    CONDENSE v_dir_dataset.

    "converte toda string concatenada em tipo char
    DATA: v_dataset_final(30) TYPE c.
    v_dataset_final = v_dir_dataset. "casting str >> char

    " Verifica se o casting aconteceu antes de servir como referencia ao dataset
    IF v_dataset_final NE v_dir_dataset.
      MESSAGE 'Caminho para o Dataset inconsistente' TYPE 'E'.
    ENDIF.

    "linha para percorrer tabela interna
    DATA: lv_line TYPE string.

    "abre o dataset no formato leitura
    OPEN DATASET v_dataset_final FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      "repeticao para ler linha a linha da tabela string
      DO.
        READ DATASET v_dataset_final INTO lv_line.
        IF sy-subrc <> 0.
          EXIT. "sai do ciclo se nao houver mais linhas para serem lidas
        ENDIF.
        " Armazenar a linha na tabela interna
        APPEND lv_line TO it_stringtable2.
        CLEAR lv_line.
      ENDDO.
      "fechar o dataset
      CLOSE DATASET v_dataset_final.
      MESSAGE 'Arquivo lido com sucesso' TYPE 'S'.
    ELSE.
      MESSAGE 'Erro ao abrir o arquivo para leitura' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
