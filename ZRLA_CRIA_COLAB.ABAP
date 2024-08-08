"----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Include          Z_RLA_TOP2
*&---------------------------------------------------------------------*
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

"tipo de contrato
DATA: lv_tipocontrato TYPE c LENGTH 1.
"----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Include          Z_RLA_SCREEN2
*&---------------------------------------------------------------------*
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

AT SELECTION-SCREEN.
  "codigo relativo ao click do botao
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
  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível encontrar o elemento do tipo botão na tela de seleção' TYPE 'E'.
  ENDIF.

  "preenche a tabela de candidatos com os candidatos aprovados
  SELECT id_candidato
         nome
         FROM znn_candidatos
         INTO CORRESPONDING FIELDS OF TABLE it_cdt
  WHERE estado = 1
  AND id_employee = 0.

  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível encontras candidatos aprovados' TYPE 'E'.
  ENDIF.

  "organiza a tabela para o search help
  SORT it_cdt BY id_candidato ASCENDING.
"----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Include          Z_RLA_DOWN2
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM verifica_ids.       "verifica existência do user e da chave do candidato como colaborador
  PERFORM verifica_contrato.  "verifica o tipo de contrato estabelecido
  PERFORM cadastra_empregado. "insere o empregado e o relaciona com o candidato
  PERFORM cadastra_user.      "insere o user e o relaciona com o candidato

END-OF-SELECTION.
  "-----------------------------------------------------------------------------------------------
  "verifica existência do user e da chave do candidato como colaborador
FORM verifica_ids.
  "verifica se o campo com o nome do username foi gerado
  IF p_user IS INITIAL.
    MESSAGE 'É necessário gerar um nome para o user.' TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

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
    IF wa_candidatos-id_employee IS INITIAL.
      MESSAGE 'O candidato já possui um número de identificação de funcionário' TYPE 'E'.
    ENDIF.
  ENDLOOP.
ENDFORM.
"-----------------------------------------------------------------------------------------------
"verifica o tipo de contrato estabelecido
FORM verifica_contrato.
  "verifica o tiipo de contrato
  CASE 'X'.
    WHEN rb1.
      lv_tipocontrato = 'A'. "3 meses de contrato
    WHEN rb2.
      lv_tipocontrato = 'B'. "1 ano de contrato
    WHEN rb3.
      lv_tipocontrato = 'C'. "2 anos de contrato
  ENDCASE.
ENDFORM.
"-----------------------------------------------------------------------------------------------
"insere o empregado e o relaciona com o candidato
FORM cadastra_empregado.
  "chama o metodo para analisar o tipo de contrato
  "o metodo retorna a data final do contrato
  zcl_rla_employee=>insert_employee2(
    EXPORTING
      id_candidato  = p_id
      tipo_contrato = lv_tipocontrato
  ).

  IF sy-subrc NE 0.
    MESSAGE 'Impossível cadastrar um novo colaborador.' TYPE 'E'.
  ENDIF.
ENDFORM.
"-----------------------------------------------------------------------------------------------
"insere o user e o relaciona com o candidato
FORM cadastra_user.
  "chama o metodo para inserir um novo user
  zcl_rla_username=>insert_username2(
    EXPORTING
      id_candidato = p_id
      nickname     = p_user
  ).
  IF sy-subrc NE 0.
    MESSAGE 'Impossível cadastrar um novo user' TYPE 'E'.
  ELSE.
    CLEAR p_id.
    CLEAR p_user.
    MESSAGE 'Novo Colaborador cadastrado com sucesso' TYPE 'I' DISPLAY LIKE 'S'.
  ENDIF.
ENDFORM.
"----------------------------------------------------------------------------------------------------------------------------------------------------------------------
