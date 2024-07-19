*&---------------------------------------------------------------------*
*& Report Z_RLA_CANDIDATOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT z_rla_candidatos.

*&---------------------------------------------------------------------*
"Variáveis - Estruturas - Tabelas

DATA: it_text_cv  TYPE STANDARD TABLE OF string, "Tabela interna que recebe os dados do upload.
      it_text2_cv TYPE STANDARD TABLE OF string. "Tabela interna que recebe os dados do download.

DATA: v_path TYPE string.

"----------------------------------------------------------
"0. Menu de Selecao

SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_nome   TYPE znome,
            p_estado TYPE zestado.
SELECTION-SCREEN: END OF BLOCK a1.
SELECTION-SCREEN: BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-002.
PARAMETERS: rb_up RADIOBUTTON GROUP grp1,
            rb_dl RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: END OF BLOCK a2.
SELECTION-SCREEN: BEGIN OF BLOCK a3 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_path TYPE ibipparms-path.
SELECTION-SCREEN: END OF BLOCK a3.
SELECTION-SCREEN: SKIP 1.

START-OF-SELECTION.

  PERFORM selecionar_candidato.

  IF rb_up EQ 'X'.
    PERFORM import_file_txt.
  ELSEIF rb_dl EQ 'X'.
    PERFORM download_file_txt.
  ENDIF.

END-OF-SELECTION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = ' '
    IMPORTING
      file_name     = p_path.

*&---------------------------------------------------------------------*
*& Form IMPORT_FILE_TXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM import_file_txt .

  "2. Fazer upload do ficheiro em formato txt para uma tabela interna.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_FILE_TXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_file_txt .

  "3. Gravar o conteudo da tabela interna num ficheiro no servidor.

  v_path = p_path.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = v_path
      filetype            = 'ASC'
      has_field_separator = 'X'
      read_by_line        = 'X'
    TABLES
      data_tab            = it_text_cv.

  IF sy-subrc EQ 0.
    it_text2_cv[] = it_text_cv.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = v_path
        filetype              = 'ASC'
        write_field_separator = 'X'
      TABLES
        data_tab              = it_text2_cv.

    IF sy-subrc EQ 0.
      MESSAGE 'Candidato salvo com sucesso' TYPE 'S'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECIONAR_CANDIDATO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM selecionar_candidato .

  "1. Determina o proximo numero de candidato disponivel.

  "Tabela Interna + Estrutura
  DATA: it_candidato TYPE TABLE OF znn_candidatos,
        wa_candidato TYPE znn_candidatos.

  "Busca a posição atual do candidato e a incrementa.
  DATA: v_id TYPE zcandidato. "ID do candidato
  SELECT MAX( id_candidato ) FROM znn_candidatos INTO v_id.
  v_id = v_id + 1.

  "Hora e Data
  DATA: v_data TYPE zdata,
        v_hora TYPE zhora.

  v_data = sy-datum.
  v_hora = sy-uzeit.

ENDFORM.
