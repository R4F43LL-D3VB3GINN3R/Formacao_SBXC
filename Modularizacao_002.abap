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

"Variáveis para Upload
DATA: v_path       TYPE string,
      v_filename   TYPE string,
      v_stringpath TYPE string.

v_path = 'C:\Docs\Candidatos\Curriculum_Vitae'.
v_filename = '1.txt'.

CONCATENATE v_path v_filename INTO v_stringpath SEPARATED BY '\'.

"Variáveis para Download
DATA: v_path2       TYPE string,
      v_filename2   TYPE string,
      v_stringpath2 TYPE string.

v_path2 = 'C:\Docs\Candidaturas_Aceitas\Curriculum_Vitae'.
v_filename2 = '1.txt'.

"----------------------------------------------------------
"0. Menu de Selecao

SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_nome   TYPE znome,
            p_estado TYPE zestado.
SELECTION-SCREEN: END OF BLOCK a1.
SELECTION-SCREEN: BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-002.
PARAMETERS: rb_up RADIOBUTTON GROUP grp1 DEFAULT 'X',
            rb_dl RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: END OF BLOCK a2.
SELECTION-SCREEN: BEGIN OF BLOCK a3 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_path TYPE IBIPPARMS-PATH.
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

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = v_stringpath
      filetype            = 'ASC'
      has_field_separator = 'X'
      read_by_line        = 'X'
    TABLES
      data_tab            = it_text_cv.

  IF sy-subrc EQ 0.
  ENDIF.

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

  CONCATENATE v_path2 v_filename2 INTO v_stringpath2 SEPARATED BY '\'.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename              = v_stringpath2
      filetype              = 'ASC'
      write_field_separator = 'X'
    TABLES
      data_tab              = it_text2_cv.

  IF sy-subrc <> 0.
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

  "----------------------
  "Hora e Data

  DATA: v_data TYPE zdata,
        v_hora TYPE zhora.

  v_data = sy-datum.
  v_hora = sy-uzeit.

ENDFORM.
