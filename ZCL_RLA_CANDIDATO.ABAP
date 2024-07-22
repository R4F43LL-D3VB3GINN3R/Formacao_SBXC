CLASS zcl_rla_candidato DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_next_user
      RETURNING
        VALUE(id1) TYPE znn_candidatos-id_candidato .

    CLASS-METHODS insert_file_dataset
      IMPORTING
        !it_stringtable TYPE table
        !path_dataset   TYPE string
        !id_string      TYPE string .

    CLASS-METHODS get_id_strchar
      EXPORTING
        !id_char   TYPE char10
        !id_string TYPE string .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA cv_id_candidato TYPE znn_candidatos-id_candidato VALUE 0 ##NO_TEXT.
    CLASS-DATA:
      it_stringtable   TYPE STANDARD TABLE OF string .

ENDCLASS.



CLASS zcl_rla_candidato IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>GET_ID_STRCHAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] ID_CHAR                        TYPE        CHAR10
* | [<---] ID_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_id_strchar.

    DATA: id_temp TYPE znn_candidatos-id_candidato.
    id_temp = get_next_user( ).

    id_char = id_temp.
    id_string = id_temp.

    " Formatar número com zeros à esquerda
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = id_char
      IMPORTING
        output = id_char.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
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
      ADD 1 TO id1. "incremento do valor da consulta
    ELSE.
      MESSAGE 'Erro ao buscar o número do candidato' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>INSERT_FILE_DATASET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_STRINGTABLE                 TYPE        TABLE
* | [--->] PATH_DATASET                   TYPE        STRING
* | [--->] ID_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_file_dataset.

    DATA: id_str TYPE string,
          id_num TYPE znn_candidatos-id_candidato.

    id_num = zcl_rla_candidato=>get_next_user( ).
    id_str = id_num. "casting int4 >> str

    DATA: v_dir_dataset TYPE string.

    CONCATENATE path_dataset '\' id_str '.txt' INTO v_dir_dataset. "caminho concatenado
    CONDENSE v_dir_dataset.
    
    data: v_dataset_final(30) type c.
    v_dataset_final = v_dir_dataset. "casting str >> char
    
    "gravacao do ficneiro no servidor.
    OPEN DATASET v_dataset_final FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      LOOP AT it_stringtable INTO DATA(wa_text).
        TRANSFER wa_text TO v_dataset_final.
      ENDLOOP.
      CLOSE DATASET v_dataset_final.
      MESSAGE 'Arquivo gravado com sucesso' TYPE 'S'.
    ELSE.
      MESSAGE 'Erro ao gravar o ficheiro no servidor.' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
