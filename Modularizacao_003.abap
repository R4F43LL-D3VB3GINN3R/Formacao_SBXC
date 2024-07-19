*&---------------------------------------------------------------------*
*& Report Z_RLA_CANDIDATOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT z_rla_candidatos.

*&---------------------------------------------------------------------*
"Variáveis - Estruturas - Tabelas

DATA: it_text_cv  TYPE STANDARD TABLE OF string, "Tabela interna que recebe os dados do upload.
      it_text_cv2 TYPE STANDARD TABLE OF string. "Tabela interna que recebe os dados do upload.
DATA: v_path TYPE string.                        "String << ibipparms-path.

DATA: v_username TYPE sy-uname.
v_username = sy-uname.

*&---------------------------------------------------------------------*
"Hora e Data
DATA: lv_datenow    TYPE char10,   "Data Atual
      lv_hour       TYPE sy-uzeit, "Hora Atual
      lv_hour_str   TYPE string,   "Hora
      lv_minute_str TYPE string,   "Minuto
      lv_second_str TYPE string.   "Segundo

DATA: lv_time_str TYPE string. "String para receber strings de tempo concatenadas

lv_hour = sy-uzeit. "Variável recebe hora atual no sistema.

" Separação da hora, minuto e segundo
lv_hour_str   = lv_hour+0(2).
lv_minute_str = lv_hour+2(2).
lv_second_str = lv_hour+4(2).

"Concatenando-os com ":" para formar o horário completo
CONCATENATE lv_hour_str ':' lv_minute_str ':' lv_second_str INTO lv_time_str.

"Função para formatar a data
CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
  EXPORTING
    date_internal = sy-datum
  IMPORTING
    date_external = lv_datenow.

DATA: v_footer TYPE string.
v_footer = 'Relatório de Candidatos: '.

"Juntando o título, a data e a hora
CONCATENATE v_footer lv_datenow lv_time_str INTO v_footer SEPARATED BY ' / '.

"----------------------------------------------------------
"0. Menu de Selecao

SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK a3 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_path TYPE ibipparms-path.
SELECTION-SCREEN: END OF BLOCK a3.
SELECTION-SCREEN: BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-002.
PARAMETERS: rb_um    RADIOBUTTON GROUP grp1,
            rb_todos RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: END OF BLOCK a2.
SELECTION-SCREEN: SKIP 1.

START-OF-SELECTION.
  IF rb_um EQ 'X'.
    PERFORM import_file_txt.
  ELSEIF rb_todos EQ 'X'.
    PERFORM load_file_txt.
  ENDIF.

END-OF-SELECTION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path. "Chama o icone ao lado do parametro para buscar o caminho até o arquivo.

  "Funcao para abrir a caixa de procura ao apertar o icone.
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

  IF p_path IS NOT INITIAL.
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
      cl_demo_output=>display( it_text_cv ).
    ENDIF.
  ELSE.
    MESSAGE 'Nenhum Arquivo Encontrado' TYPE 'E'.
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
FORM load_file_txt .

  DATA: path2     TYPE string,
        count     TYPE i,
        numdoc    TYPE string,
        extension TYPE string.

  count = 0.
  extension = 'txt'.

  APPEND ' ' TO it_text_cv2.
  APPEND '------------------------------------------------------------' TO it_text_cv2.

  DO 2 TIMES.
    count = count + 1.
    CLEAR numdoc.
    CLEAR path2.

    numdoc = count.
    path2 = 'C:\Docs\Candidatos\Curriculum_Vitae'.
    CONCATENATE path2 numdoc INTO path2 SEPARATED BY '\'.
    CONDENSE path2.
    CONCATENATE path2 extension INTO path2 SEPARATED BY '.'.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename            = path2
        filetype            = 'ASC'
        has_field_separator = 'X'
        read_by_line        = 'X'
      TABLES
        data_tab            = it_text_cv.

    APPEND LINES OF it_text_cv TO it_text_cv2.
    APPEND '------------------------------------------------------------' TO it_text_cv2.
    APPEND ' ' TO it_text_cv2.
    APPEND '------------------------------------------------------------' TO it_text_cv2.
    
  ENDDO.

  APPEND v_footer TO it_text_cv2.
  APPEND v_username TO it_text_cv2.
  APPEND '--------------------' TO it_text_cv2.

  IF sy-subrc EQ 0.
    cl_demo_output=>display( it_text_cv2 ).
  ENDIF.

ENDFORM.
