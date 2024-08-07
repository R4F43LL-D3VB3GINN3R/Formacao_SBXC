*&---------------------------------------------------------------------*
*& Include          ZRLA_CL_SALV_EVENTS
*&---------------------------------------------------------------------*
"classe de eventos

TYPES: BEGIN OF ty_candidatos,
         id_candidato TYPE znn_candidatos-id_candidato,
         nome         TYPE znn_candidatos-nome,
         estado       TYPE znn_candidatos-estado,
         data         TYPE znn_candidatos-data,
         hora         TYPE znn_candidatos-hora,
         alterado_por TYPE znn_candidatos-alterado_por,
       END OF ty_candidatos.

DATA: it_candidatos TYPE TABLE OF znn_candidatos WITH KEY id_candidato,
      wa_candidatos TYPE znn_candidatos.

DATA: lv_rangelow  TYPE znn_candidatos-estado,
      lv_rangehigh TYPE znn_candidatos-estado.

"estrutura para retorno de erro
DATA: e_result TYPE znn_result.

DATA: lo_rla_candidato TYPE REF TO zcl_rla_candidato.

"tela de menu de selecao
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS: p_estado TYPE znn_candidatos-estado AS LISTBOX VISIBLE LENGTH 20 OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b1.
SELECTION-SCREEN: BEGIN OF BLOCK c1 WITH FRAME.
SELECT-OPTIONS: s_id FOR znn_candidatos-id_candidato DEFAULT 1 TO 100. "range implementado na se11
SELECTION-SCREEN: END OF BLOCK c1.
SELECTION-SCREEN: END OF BLOCK a1.

"funcoes do alv.
DATA: lo_alv_functions TYPE REF TO cl_salv_functions.

"colunas do alv.
DATA: lo_alv_columns TYPE REF TO cl_salv_columns,
      lo_alv_column  TYPE REF TO cl_salv_column.

"cores do alv
DATA: color TYPE lvc_s_colo.

"display do alv
DATA: lo_alv_display TYPE REF TO cl_salv_display_settings.

DATA: lo_alv TYPE REF TO cl_salv_table.



CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command
                  FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.

    DATA: lr_selections TYPE REF TO cl_salv_selections,
          lt_rows       TYPE salv_t_row.

    "linhas selecionadas
    lr_selections = lo_alv->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).

    CASE e_salv_function.
      WHEN 'MYFUNCTION'.
        LOOP AT lt_rows INTO DATA(ls_row).
          READ TABLE it_candidatos INTO DATA(ls_data) INDEX ls_row.
          IF sy-subrc EQ 0.

            "instancia o objeto
            CREATE OBJECT lo_rla_candidato
              EXPORTING
                i_id_candidato = ls_data-id_candidato " Id Candidato
              EXCEPTIONS
                invalid_cand   = 1                " Candidato inválido
                OTHERS         = 2.

            "chama o metodo para aprovar uma candidatura.
            lo_rla_candidato->aprovar(
              IMPORTING
                e_result = e_result                 " Estrutura de resultados de operações
            ).
*            DELETE FROM it_candidatos WHERE id_candidato EQ ls_data-id_candidato.
          ENDIF.
          FREE lo_rla_candidato.
          MODIFY TABLE it_candidatos FROM ls_data.
          lo_alv->refresh( ).
        ENDLOOP.
      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
    ENDCASE.

    lo_alv->refresh( ).

  ENDMETHOD.
ENDCLASS.

DATA: o_handler TYPE REF TO lcl_handle_events.
DATA: o_events TYPE REF TO cl_salv_events_table.

*&---------------------------------------------------------------------*
*& Include          ZRLA_DOWN
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM fill_data.    "preenche a tabela interna através da consulta do menu de selecao.
  PERFORM display_data. "exibe o relatorio alv"

END-OF-SELECTION.

FORM fill_data. "preenche a tabela interna através da consulta do menu de selecao.

  SELECT *
         FROM znn_candidatos
         INTO CORRESPONDING FIELDS OF TABLE @it_candidatos
         WHERE id_candidato IN @s_id
         AND estado EQ @p_estado.

  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível obter dados através da consulta do menu de seleção' TYPE 'E'.
  ENDIF.

  SORT it_candidatos BY id_candidato ASCENDING.

ENDFORM.
FORM display_data.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = lo_alv                           " Basis Class Simple ALV Tables
        CHANGING
          t_table        = it_candidatos
      ).
    CATCH cx_salv_msg.
  ENDTRY.

  "funcoes
  lo_alv_functions = lo_alv->get_functions( ).
  lo_alv_functions->set_all( abap_true ).

  "opcoes de display
  lo_alv_display = lo_alv->get_display_settings( ).
  lo_alv_display->set_striped_pattern( cl_salv_display_settings=>true ).
  lo_alv_display->set_list_header( 'Relatório de Candidatos' ).

  "status gui
  lo_alv->set_screen_status(
    EXPORTING
      report        = sy-cprog                " ABAP Program: Current Master Program
      pfstatus      = 'SALV_STANDARD'         " Screens, Current GUI Status
      set_functions = lo_alv->c_functions_all " ALV: Data Element for Constants
  ).

  o_events = lo_alv->get_event( ).

  CREATE OBJECT o_handler.
  SET HANDLER o_handler->on_user_command FOR o_events.
  lo_alv->display( ).

ENDFORM.
