*&---------------------------------------------------------------------*
*& Report ZRLA_APROVA_CANDIDATO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrla_aprova_candidato.

TABLES: znn_candidatos.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
"Variáveis - Estruturas - Tabelas

"estrutura para ajuda de pesquisa
TYPES: BEGIN OF ty_cdt,
         id_candidato TYPE znn_candidatos-id_candidato,
       END OF ty_cdt.

"tabela para receber o id do candidato
DATA: it_cdt TYPE TABLE OF ty_cdt.

"tabela para receber o retorno da funcao F4IF_INT_TABLE_VALUE_REQUEST
DATA: it_return TYPE TABLE OF ddshretval,
      ls_return TYPE ddshretval.

"variaveis para receber os ids em tipos diferentes de formatos
DATA: id_str  TYPE string,
      id_char TYPE char10,
      id_num  TYPE znn_candidatos-id_candidato.

"variavel para receber o caminho do arquivo concatenado
DATA: path_dataset TYPE string.

"tabela para ler o arquivo
DATA: it_stringtable TYPE STANDARD TABLE OF string.

"estrutura que armazena dados do candidato.
DATA: wa_candidato TYPE znn_candidatos.

"instancia da classe candidato
DATA: lo_rla_candidato TYPE REF TO zcl_rla_candidato.

"estrutura para retorno de erro
DATA: e_result TYPE znn_result.

"id em string.
DATA: v_id_str TYPE string.

"estrutura que representa o candidato aceito como colaborador
DATA: wa_emp TYPE ysap_employee.

"estrutura que representa o username novo que o candidato ganhou
DATA: wa_user TYPE znn_username.

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Tela de Seleção
SELECTION-SCREEN: BEGIN OF BLOCK c1 WITH FRAME title text-003.
    SELECTION-SCREEN: SKIP 1.
    SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
    PARAMETERS: p_id TYPE znn_candidatos-id_candidato.
    SELECTION-SCREEN: END OF BLOCK a1.
  SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
    PARAMETERS: rb_1 RADIOBUTTON GROUP g1 DEFAULT 'X',
                rb_2 RADIOBUTTON GROUP g1,
                rb_3 RADIOBUTTON GROUP g1.
    SELECTION-SCREEN: END OF BLOCK b1.
    SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: END OF BLOCK c1.

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

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
  "Processamento

"ao iniciar F8 a tabela tem de estar populada com os ids para a função retornar informacoes
INITIALIZATION.
  SELECT id_candidato FROM znn_candidatos INTO CORRESPONDING FIELDS OF TABLE it_cdt.
  SORT it_cdt BY id_candidato.

START-OF-SELECTION.

  "verifica qual das opcoes foram selecionados no radiobutton
  IF rb_3 EQ 'X'.
    PERFORM ler_arquivo. "leitura de arquivo dataset referente ao id
  ELSEIF rb_2 EQ 'X'.
    PERFORM rejeitar_candidatura. "rejeita uma candidatura
  ELSEIF rb_1 EQ 'X'.
    PERFORM aceitar_candidatura. "aprova uma candidatura
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form LER_ARQUIVO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ler_arquivo .

  path_dataset = '/tmp'. "caminho para o diretorio dir_temp no servidor
  v_id_str = p_id. "casting string >> int

  "chama o metodo para ler o arquivo do candidato no servidor
  zcl_rla_candidato=>read_file_dataset(
    EXPORTING
      path_dataset    = path_dataset   "caminho para oa arquivo
      id_string       = v_id_str       "id em string
    CHANGING
      it_stringtable2 = it_stringtable "tabela string
  ).

  "verifica se a tabela nao esta vazia
  IF it_stringtable IS NOT INITIAL.
    cl_demo_output=>display( it_stringtable ).
  ELSE.
    MESSAGE 'Dados não foram encontrados no servidor' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REJEITAR_CANDIDATURA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM rejeitar_candidatura .

  "instancia o objeto
  CREATE OBJECT lo_rla_candidato
    EXPORTING
      i_id_candidato = p_id       " Id do Candidato
    EXCEPTIONS
      invalid_cand   = 1          " Candidato inválido
      OTHERS         = 2.

  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível encontrar o candidato' TYPE 'E'.
  ENDIF.

  "chama o metodo para reprovar uma candidatura.
  lo_rla_candidato->rejeitar(
    IMPORTING
      e_result = e_result     " Estrutura de resultados de operações
  ).

  "se o estado do candidato for alterado...
  IF e_result-rc NE 0.
    MESSAGE e_result-mensagem TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    MESSAGE e_result-mensagem TYPE 'I' DISPLAY LIKE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ACEITAR_CANDIDATURA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM aceitar_candidatura .

  "instancia o objeto
  CREATE OBJECT lo_rla_candidato
    EXPORTING
      i_id_candidato = p_id              " Id Candidato
    EXCEPTIONS
      invalid_cand   = 1                " Candidato inválido
      OTHERS         = 2.

  IF sy-subrc NE 0.
    MESSAGE 'Não foi possível encontrar o candidato' TYPE 'E'.
  ENDIF.

  "chama o metodo para aprovar uma candidatura.
  lo_rla_candidato->aprovar(
    IMPORTING
      e_result = e_result                 " Estrutura de resultados de operações
  ).

  "se o estado do candidato for alterado...
  IF e_result-rc NE 0.
    MESSAGE e_result-mensagem TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
