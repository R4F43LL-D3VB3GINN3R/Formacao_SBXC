*&---------------------------------------------------------------------*
*& Report Z_RLA_CANDIDATOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT z_rla_candidatos.

*&---------------------------------------------------------------------*
"Variáveis - Estruturas - Tabelas

TABLES: znn_candidatos.

DATA: it_text       TYPE STANDARD TABLE OF string,
      it_candidatos TYPE TABLE OF znn_candidatos,
      wa_candidatos TYPE znn_candidatos.

DATA: v_id      TYPE znn_candidatos-id_candidato, "id numerico
      v_id_char TYPE char10,                      "id para conversao em 00000000
      v_id_str  TYPE string.                      "id para concatenacao

DATA: v_path TYPE string.

DATA: v_dir_temp          TYPE string, "caminho dataset
      v_dir_dataset       TYPE string, "caminho dataset concatenado
      v_dataset_final(30) TYPE c.      "caminho final.

"---------------
"Menu de Seleção
"---------------
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_path TYPE ibipparms-path,
            p_nome TYPE znn_candidatos-nome.
SELECTION-SCREEN: END OF BLOCK a1.
SELECTION-SCREEN: SKIP 1.

"-----------------------------------------------------------------------------

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path. "insere o icone de procura
  " chama a funcao para abrir a caixa de selecao do arquivo.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_PATH'
    IMPORTING
      file_name     = p_path.

  "-----------------------------------------------------------------------------

START-OF-SELECTION.

  PERFORM get_id.              "determinar o proximo numero de candidato disponivel
  PERFORM arquivo_upload.      "faz o upload do arquivo txt
  PERFORM enviar_dataset.      "envia arquivo txt para o servidor
  PERFORM cadastrar_candidato. "insere o candidato na tabela z

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form GET_ID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_id .

  "consulta para determinar o proximo numero de candidato disponivel.
  SELECT MAX( id_candidato ) FROM znn_candidatos INTO v_id.

  "verificacao da consulta
  IF sy-subrc EQ 0.
    ADD 1 TO v_id.
  ELSE.
    MESSAGE 'Erro ao buscar o número do candidato' TYPE 'E'.
  ENDIF.

  v_id_char = v_id. "casting int >> char10

  " Formatar número com zeros à esquerda
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = v_id_char
    IMPORTING
      output = v_id_char.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ARQUIVO_UPLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM arquivo_upload .

  v_path = p_path. "casting char >> str

  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename               = v_path            " Name of file
      filetype               = 'ASC'             " File Type (ASCII, Binary)
    CHANGING
      data_tab                = it_text          " Transfer table for file contents
    EXCEPTIONS
      file_open_error         = 1                " File does not exist and cannot be opened
      file_read_error         = 2                " Error when reading file
      no_batch                = 3                " Cannot execute front-end function in background
      gui_refuse_filetransfer = 4                " Incorrect front end or error on front end
      invalid_type            = 5                " Incorrect parameter FILETYPE
      no_authority            = 6                " No upload authorization
      unknown_error           = 7                " Unknown error
      bad_data_format         = 8                " Cannot Interpret Data in File
      header_not_allowed      = 9                " Invalid header
      separator_not_allowed   = 10               " Invalid separator
      header_too_long         = 11               " Header information currently restricted to 1023 bytes
      unknown_dp_error        = 12               " Error when calling data provider
      access_denied           = 13               " Access to file denied.
      dp_out_of_memory        = 14               " Not enough memory in data provider
      disk_full               = 15               " Storage medium is full.
      dp_timeout              = 16               " Data provider timeout
      not_supported_by_gui    = 17               " GUI does not support this
      error_no_gui            = 18               " GUI not available
      OTHERS                  = 19
    ).

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ENVIAR_DATASET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM enviar_dataset .

  v_id_str = v_id_char. "casting char >> str
  v_dir_temp = '.'.  "caminho dataset

  CONCATENATE v_dir_temp '\' v_id_str '.txt' INTO v_dir_dataset. "caminho concatenado
  CONDENSE v_dir_dataset.

  v_dataset_final = v_dir_dataset. "casting str >> char

  "gravacao do ficneiro no servidor.
  OPEN DATASET v_dataset_final FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    LOOP AT it_text INTO DATA(wa_text).
      TRANSFER wa_text TO v_dataset_final.
    ENDLOOP.
    CLOSE DATASET v_dataset_final.
    MESSAGE 'Arquivo gravado com sucesso' TYPE 'S'.
  ELSE.
    MESSAGE 'Erro ao gravar o ficheiro no servidor.' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CADASTRAR_CANDIDATO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM cadastrar_candidato .

  IF p_nome IS NOT INITIAL.

    wa_candidatos-id_candidato = v_id_char.
    wa_candidatos-nome         = p_nome.
    wa_candidatos-estado       = '0'.
    wa_candidatos-data         = sy-datum.
    wa_candidatos-hora         = sy-uzeit.

    APPEND wa_candidatos TO it_candidatos.
    MODIFY znn_candidatos FROM TABLE it_candidatos.

  ENDIF.

ENDFORM.
