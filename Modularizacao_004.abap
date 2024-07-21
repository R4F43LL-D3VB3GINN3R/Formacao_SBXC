*&---------------------------------------------------------------------*
*& Report Z_RLA_CANDIDATOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_rla_candidatos.

TABLES: znn_candidatos.

DATA: lt_text        TYPE TABLE OF string,
      lv_path        TYPE string,
      lv_num         TYPE string,
      lv_filename    TYPE string,
      lv_cand_id     TYPE znn_candidatos-id_candidato,
      lv_nome        TYPE znn_candidatos-nome,
      lv_estado      TYPE znn_candidatos-estado,
      lv_date        TYPE sy-datum,
      lv_time        TYPE sy-uzeit,
      lv_datetime    TYPE string,
      lv_dir         TYPE string.

" Tela de seleção
PARAMETERS: p_path TYPE ibipparms-path,
            p_nome TYPE znn_candidatos-nome.

START-OF-SELECTION.
  PERFORM get_user.
  PERFORM upload_file.
  PERFORM submeter_candidato.
END-OF-SELECTION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  " Chama a função para abrir a caixa de seleção de arquivo
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_PATH'
    IMPORTING
      file_name     = p_path.

*&---------------------------------------------------------------------*
*& Form get_user
*&---------------------------------------------------------------------*
FORM get_user .
  " 1. Determinar o próximo número de candidato disponível
  SELECT MAX( id_candidato ) INTO lv_cand_id FROM znn_candidatos.
  IF sy-subrc = 0 AND lv_cand_id IS INITIAL.
    lv_cand_id = 0.
  ELSEIF sy-subrc = 0.
    lv_cand_id = lv_cand_id + 1.
  ELSE.
    MESSAGE 'Erro ao buscar o próximo número de candidato' TYPE 'E'.
  ENDIF.
  lv_num = lv_cand_id.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form upload_file
*&---------------------------------------------------------------------*
FORM upload_file .

  DATA: lv_path TYPE string.
  lv_path = p_path.

  " 2. Fazer upload do ficheiro em formato TXT para uma tabela interna
  IF p_path IS NOT INITIAL.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename            = lv_path
        filetype            = 'ASC'
      TABLES
        data_tab            = lt_text
      EXCEPTIONS
        file_read_error     = 1
        no_batch            = 2
        gui_refuse_filetransfer = 3
        OTHERS              = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Erro ao carregar o ficheiro' TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Nenhum caminho especificado' TYPE 'E'.
  ENDIF.

  DATA: lv_temp_dir TYPE string.
  lv_temp_dir = '.'.

  CONCATENATE lv_temp_dir '\' lv_num '.txt' INTO lv_filename.
  CONDENSE lv_filename.

  DATA: finalpath(30) TYPE c.
  finalpath = lv_filename.

  " 5. Tentar criar o arquivo no caminho definido
  OPEN DATASET finalpath FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    LOOP AT lt_text INTO DATA(ls_text).
      TRANSFER ls_text TO finalpath.
    ENDLOOP.
    CLOSE DATASET finalpath.
    MESSAGE 'Arquivo gravado com sucesso' TYPE 'S'.
  ELSE.
    WRITE: lv_filename.
    MESSAGE 'Erro ao gravar o ficheiro no servidor' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form submeter_candidato
*&---------------------------------------------------------------------*
FORM submeter_candidato .
*  DATA: ls_candidato TYPE znn_candidatos.
*
*  " Formatar número com zeros à esquerda, se necessário
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = lv_num
*    IMPORTING
*      output = lv_num.
*
*  ls_candidato-id_candidato = lv_num.
*  ls_candidato-nome         = p_nome.
*  ls_candidato-estado       = '0'. " Status '0' para Submetido
*  ls_candidato-data         = sy-datum.
*  ls_candidato-hora         = sy-uzeit.
*
*  INSERT znn_candidatos FROM ls_candidato.
*  IF sy-subrc = 0.
*    MESSAGE 'Candidato submetido com sucesso' TYPE 'S'.
*  ELSE.
*    MESSAGE 'Erro ao inserir registro na tabela de candidatos' TYPE 'E'.
*  ENDIF.
ENDFORM.
