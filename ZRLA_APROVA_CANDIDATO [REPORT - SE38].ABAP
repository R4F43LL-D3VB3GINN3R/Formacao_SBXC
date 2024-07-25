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
  ELSE.
    MESSAGE e_result-mensagem TYPE 'I' DISPLAY LIKE 'S'.
  ENDIF.

  "#CRIAR METODO PARA
  SELECT MAX( id_employee ) FROM ysap_employee INTO wa_emp-id_employee.
  ADD 1 TO wa_emp-id_employee.

  "gera uma funcao random para o funcionario
  DATA(lv_random_num) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                                    min  = 1
                                                    max  = 7 )->get_next( ).

  "para cada numero gerado, uma funcao sap é gerada para o funcionario
  CASE lv_random_num.
    WHEN 1.
      wa_emp-funcao = 'Técnico Abap'.
    WHEN 2.
      wa_emp-funcao = 'Funcional SAP'.
    WHEN 3.
      wa_emp-funcao = 'SAP BASIS'.
    WHEN 4.
      wa_emp-funcao = 'Fiori'.
    WHEN 5.
      wa_emp-funcao = 'FI'.
    WHEN 6.
      wa_emp-funcao = 'HCM'.
    WHEN 7.
      wa_emp-funcao = 'SD'.
  ENDCASE.

  "define a data de admissao para o novo colaborador
  wa_emp-data_entrada = sy-datum.
  wa_emp-data_saida = '00000000'.

  "insere a estrutura na tabela de colaboradores
  MODIFY ysap_employee FROM wa_emp.

  "atualiza a tabela de candidatos com o novo id do colaborador relacionado ao candidato
  UPDATE znn_candidatos
    SET id_employee    = wa_emp-id_employee
    WHERE id_candidato = p_id.

  "tratando o novo nome do user
  DATA: nameuser  TYPE znn_candidatos-nome,
        nameuser2 TYPE string.

  "realiza consulta para buscar o nome do candidato aprovado
  SELECT SINGLE a~nome
  INTO nameuser
  FROM znn_candidatos AS a
  INNER JOIN ysap_employee AS b
  ON a~id_employee = b~id_employee
  WHERE a~id_candidato = p_id.

  "converte o nome para string
  nameuser2 = nameuser.

  "variaveis numericas para guardar o valor numerico da posicao do nome
  DATA: stringnum TYPE i.
  DATA: midstringnum TYPE i.
  DATA: fimstringnum TYPE i.

  "variaveis em string para guardar as letras nas dadas posicoes numericas
  DATA: ini TYPE string.
  DATA: mid TYPE string.
  DATA: fim TYPE string.

  "captura as posicoes dos caracteres na sqtring
  stringnum = strlen( nameuser2 ).
  midstringnum = stringnum / 2.
  fimstringnum = stringnum - 1.

  "as strings recebem as letras nas dadas posicoes
  ini = nameuser2+0(1).
  mid = nameuser2+midstringnum(1).
  fim = nameuser2+fimstringnum(1).

  "variaveis string para prefixo, sufixo e nome de user completo
  DATA: userprefix TYPE string,
        usersufix  TYPE string,
        username   TYPE string.

  "o prefixo recebe as três letras + o S4H que é comum entre todos os users.
  CONCATENATE ini mid fim 'S4H' INTO userprefix.

  "variaveis para receber numeros aleatorios para os sufixos.
  DATA :
    num1 TYPE i,
    num2 TYPE i,
    num3 TYPE i.

  "instancia da classe random do abap
  DATA(lo_rand) = cl_abap_random=>create( ).

  "cada variavel recebe seu numero aleatorio de 1 a 9
  num1 = lo_rand->intinrange( low = 1 high = 9 ).
  num2 = lo_rand->intinrange( low = 1 high = 9 ).
  num3 = lo_rand->intinrange( low = 1 high = 9 ).

  "variaveis string para receber os numeros aleatorios
  DATA: primnum TYPE string,
        midnum  TYPE string,
        ultnum  TYPE string.

  "cast int >> string
  primnum = num1.
  midnum = num2.
  ultnum = num3.

  "concatena ao sufixo os 3 numeros aleatorios convertidos para string
  CONCATENATE primnum midnum ultnum INTO usersufix.

  "remove os espaços em branco no sufixo
  CONDENSE usersufix NO-GAPS.

  "concatena prefixo e sufixo na variavel username, concluindo o nome novo do user
  CONCATENATE userprefix usersufix INTO username.

  "tabela interna e estrutura para a tabela z znn_username
  DATA: it_username TYPE TABLE OF znn_username,
        wa_username TYPE znn_username.

  "recebe o id do user disponivel no sistema
  DATA: userid TYPE znn_username-id_user.
  SELECT MAX( id_user ) FROM znn_username INTO userid.
  add 1 to userid.

  "preenche a estrutura com as informacoes do novo user
  wa_username-id_user = userid.
  wa_username-username = username.
  wa_username-data_entrada = sy-datum.
  wa_username-data_saida = '00000000'.

  "atualiza a tabela transparente do username com a nova estrutura preenchida.
  MODIFY znn_username FROM wa_username.

ENDFORM.
