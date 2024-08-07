*&---------------------------------------------------------------------*
*& Report ZRLA_CRIA_COLAB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrla_cria_colab.

"icons
TYPE-POOLS: icon.
"tabela z de candidatos
TABLES: znn_candidatos.

"estrutura para ajuda de pesquisa
TYPES: BEGIN OF ty_cdt,
         id_candidato TYPE znn_candidatos-id_candidato,
         nome         TYPE znn_candidatos-nome,
       END OF ty_cdt.

"tabela para receber o id do candidato
DATA: it_cdt TYPE TABLE OF ty_cdt.

"tabela interna  e estrutura de candidatos
DATA: it_candidatos TYPE TABLE OF znn_candidatos,
      wa_candidatos TYPE znn_candidatos.

"tabela para receber o retorno da funcao F4IF_INT_TABLE_VALUE_REQUEST
DATA: it_return TYPE TABLE OF ddshretval,
      ls_return TYPE ddshretval.

"tabela e estrutura de username
DATA: it_username TYPE TABLE OF znn_username,
      wa_username TYPE znn_username.

"tabela e estrutura de employee
DATA: it_employee TYPE TABLE OF ysap_employee,
      wa_employee TYPE ysap_employee.

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
SELECTION-SCREEN: PUSHBUTTON 40(20) button1 USER-COMMAND press.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: END OF BLOCK d1.
SELECTION-SCREEN: END OF BLOCK a1.

"codigo relativo ao click do botao

AT SELECTION-SCREEN.
  "consulta para retornar o valor maximo do id do candidato
  DATA: max_id TYPE znn_candidatos-id_candidato.
  SELECT MAX( id_candidato ) FROM znn_candidatos INTO max_id.

  "se o id nao exceder o id maximo da tabela da base de dados...
  IF p_id LE max_id.
    "recebe a funcao do sistema referente ao botao
    CASE sy-ucomm.
      WHEN 'PRESS'.
        "chama o metodo para gerar um username
        zcl_rla_username=>generate_username2(
          EXPORTING
            id_candidato = p_id                " Candidato
          IMPORTING
            nickname     = p_user              " Char 20
        ).
    ENDCASE.

  ELSE.
    MESSAGE 'Número do Candidato não encontrado' TYPE 'E'.
  ENDIF.

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
  "funcao do sistema para inserir icon e texto no botao
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_okay
      text                  = 'Generate' "texto principal
      info                  = 'Gerar'    "tooltip
    IMPORTING
      result                = button1    "elemento do botao declarado na tela de selecao
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    MESSAGE 'Não foi possível encontrar o elemento do tipo botão na tela de seleção' TYPE 'E'.
  ENDIF.

  "preenche a tabela de candidatos com os candidatos aprovados
  SELECT id_candidato
         nome
         FROM znn_candidatos
         INTO CORRESPONDING FIELDS OF TABLE it_cdt
  WHERE estado = 1.
  SORT it_candidatos BY id_candidato ASCENDING.

  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível encontrar um Candidato aprovado na base de dados' TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

START-OF-SELECTION.

  "verifica se o username gerado já existe
  SELECT * FROM znn_username INTO TABLE it_username.
  LOOP AT it_username INTO wa_username.
    IF p_user EQ wa_username-username.
      MESSAGE 'O username gerado já existe no sistema' TYPE 'E'.
    ENDIF.
  ENDLOOP.

  "verifica se candidato possui um numero de empregado associado a ele.
  SELECT * FROM znn_candidatos INTO TABLE it_candidatos.
  LOOP AT it_candidatos INTO wa_candidatos.
    IF wa_candidatos-id_employee is not initial.
      MESSAGE 'O candidato já possui um número de identificação de funcionário' TYPE 'E'.
    ENDIF.
  ENDLOOP.
