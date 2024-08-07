*&---------------------------------------------------------------------*
*& Report ZRLA_CRIA_COLAB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrla_cria_colab.

"tabela z de candidatos
TABLES: znn_candidatos.

"estrutura para ajuda de pesquisa
TYPES: BEGIN OF ty_cdt,
         id_candidato TYPE znn_candidatos-id_candidato,
         nome type znn_candidatos-nome,
       END OF ty_cdt.

"tabela para receber o id do candidato
DATA: it_cdt TYPE TABLE OF ty_cdt.

"tabela interna  e estrutura de candidatos
DATA: it_candidatos TYPE TABLE OF znn_candidatos,
      wa_candidatos TYPE znn_candidatos.

"tabela para receber o retorno da funcao F4IF_INT_TABLE_VALUE_REQUEST
DATA: it_return TYPE TABLE OF ddshretval,
      ls_return TYPE ddshretval.

"tela de selecao
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-005.
PARAMETERS: p_id TYPE znn_candidatos-id_candidato OBLIGATORY. "id do candidato
SELECTION-SCREEN: END OF BLOCK b1.
SELECTION-SCREEN: BEGIN OF BLOCK c1 WITH FRAME TITLE TEXT-002.
PARAMETERS: rb1 RADIOBUTTON GROUP gp1 DEFAULT 'X', "tipos de contratos
            rb2 RADIOBUTTON GROUP gp1,
            rb3 RADIOBUTTON GROUP gp1.
SELECTION-SCREEN: END OF BLOCK c1.
SELECTION-SCREEN: BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-004.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS: p_user TYPE znn_username-username. "username a ser gerado
SELECTION-SCREEN: POSITION 40.
SELECTION-SCREEN: PUSHBUTTON 40(20) TEXT-003 USER-COMMAND press.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: END OF BLOCK d1.
SELECTION-SCREEN: END OF BLOCK a1.

*adicionar ajuda de pesquisa (F4) ao select-options
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_id.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ID_CANDIDATO'
      value_org       = 'S'
    TABLES
      value_tab       = it_cdt
      return_tab      = it_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  "leitura dos dados para funcao enquanto menu de selecao
  READ TABLE it_return INTO ls_return INDEX 1.
  p_id = ls_return-fieldval.

INITIALIZATION.
  "preenche a tabela de candidatos com os candidatos aprovados
  SELECT id_candidato
         nome
         FROM znn_candidatos
         INTO CORRESPONDING FIELDS OF table it_cdt
         WHERE estado = 1.
  SORT it_candidatos BY id_candidato ASCENDING.

  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível encontrar um Candidato aprovado na base de dados' TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

START-OF-SELECTION.
