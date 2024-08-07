"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
*&---------------------------------------------------------------------*
*& Report ZRLA_APROVA_CANDIDATO2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT zrla_aprova_candidato2.
"tabela z de candidatos
TABLES znn_candidatos.
"variaveis globais e menu de selecao
INCLUDE ZRLA_TOP.
"classe para manutencao do alv
INCLUDE ZRLA_CL_SALV_EVENTS.
"processamento e rotinas
INCLUDE ZRLA_DOWN.

"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
*&---------------------------------------------------------------------*
*& INCLUDE ZRLA_TOP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
"tabela interna e estrutura da tabela z de candidatos
DATA: it_candidatos TYPE TABLE OF znn_candidatos WITH KEY id_candidato,
      wa_candidatos TYPE znn_candidatos.

"estrutura para retorno de erro
DATA: e_result TYPE znn_result.

"instância da classe de candidatos
DATA: lo_rla_candidato TYPE REF TO zcl_rla_candidato.

"instancias alv
DATA: lo_alv           TYPE REF TO cl_salv_table,
      lo_alv_functions TYPE REF TO cl_salv_functions,
      lo_alv_columns   TYPE REF TO cl_salv_columns,
      lo_alv_column    TYPE REF TO cl_salv_column,
      lo_alv_display   TYPE REF TO cl_salv_display_settings,
      color            TYPE lvc_s_colo.

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

"objetos referentes a coluna de multiselecao
DATA: alv_functions TYPE REF TO cl_salv_functions_list,
      alv_selections TYPE REF TO cl_salv_selections.
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
*&---------------------------------------------------------------------*
*& INCLUDE ZRLA_CL_SALV_EVENTS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      "metodo para detectar mudanças de eventos no alv
      on_user_command
                  FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.

    "instancia de classe e tabela para receber dados
    DATA: lr_selections TYPE REF TO cl_salv_selections,
          lt_rows       TYPE salv_t_row.

    "linhas selecionadas
    lr_selections = lo_alv->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).

    "evento adicionar candidato
    CASE e_salv_function.
      WHEN 'ADD'.

        "percorre as linhas do alv e le os dados da tabela interna referente a linha
        LOOP AT lt_rows INTO DATA(ls_row).
          READ TABLE it_candidatos INTO DATA(ls_data) INDEX ls_row.

          "se houver dado a ser lido...
          IF sy-subrc EQ 0.

            ls_data-estado = 1.
            MODIFY it_candidatos FROM ls_data INDEX ls_row.

*            "instancia o objeto da classe de candidatos
*            CREATE OBJECT lo_rla_candidato
*              EXPORTING
*                i_id_candidato = ls_data-id_candidato " Id Candidato
*              EXCEPTIONS
*                invalid_cand   = 1                    " Candidato inválido
*                OTHERS         = 2.
*
*            "chama o metodo para aprovar uma candidatura.
*            lo_rla_candidato->aprovar(
*              IMPORTING
*                e_result = e_result                 " Estrutura de resultados de operações
*            ).
*
*            "se a aprovacao for bem sucedida
*            IF sy-subrc eq 0.

            "remove o candidato aprovado da tabela
          ENDIF.
          MODIFY znn_candidatos FROM TABLE it_candidatos.
          DELETE it_candidatos WHERE estado = 1.
          "libera o espaco na memoria referente ao objeto criado
          FREE lo_rla_candidato.

          "renderiza novamente o alv
          lo_alv->refresh( ).
*          ENDIF.
        ENDLOOP.
        "evento rejeitar candidato
      WHEN 'RMV'.
        "percorre as linhas do alv e le os dados da tabela interna referente a linha
        LOOP AT lt_rows INTO DATA(ls_row2).
          READ TABLE it_candidatos INTO DATA(ls_data2) INDEX ls_row2.

          "se houver dado a ser lido...
          IF sy-subrc EQ 0.

            ls_data2-estado = 2.
            MODIFY it_candidatos FROM ls_data2 INDEX ls_row2.

*            "instancia o objeto da classe de candidatos
*            CREATE OBJECT lo_rla_candidato
*              EXPORTING
*                i_id_candidato = ls_data2-id_candidato " Id Candidato
*              EXCEPTIONS
*                invalid_cand   = 1                    " Candidato inválido
*                OTHERS         = 2.
*
*            "chama o metodo para rejeitar uma candidatura.
*            lo_rla_candidato->rejeitar(
*              IMPORTING
*                e_result = e_result                 " Estrutura de resultados de operações
*            ).
*
*            "se a rejeicao for bem sucedida
*            IF sy-subrc EQ 0.

           ENDIF.
           MODIFY znn_candidatos FROM TABLE it_candidatos.
           DELETE it_candidatos WHERE estado = 2.

           "libera o espaco na memoria referente ao objeto criado
           FREE lo_rla_candidato.

            "renderiza novamente o alv
            lo_alv->refresh( ).
        ENDLOOP.
      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
    ENDCASE.

    "renderiza o alv novamente independente da funcao chamada
    lo_alv->refresh( ).
  ENDMETHOD.
ENDCLASS.

"instancia das classes referentes a eventos do alv.
DATA: o_handler TYPE REF TO lcl_handle_events.
DATA: o_events TYPE REF TO cl_salv_events_table.
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
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
FORM display_data. "exibe o relatorio alv

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

  "eventos
  o_events = lo_alv->get_event( ).

  "Get the functions
  alv_functions = lo_alv->get_functions( ).
  alv_selections = lo_alv->get_selections( ).
  alv_selections->set_selection_mode( cl_salv_selections=>row_column ).

  "objeto de manutencao de eventos
  CREATE OBJECT o_handler.
  SET HANDLER o_handler->on_user_command FOR o_events.

  "displau do alv
  lo_alv->display( ).

ENDFORM.
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
"------------------------------------------------------------------------------------------------------------------------------------------------------------"
