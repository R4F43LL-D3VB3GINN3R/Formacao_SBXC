class ZCL_RLA_CANDIDATO definition
  public
  final
  create public .

public section.

  data ID_CANDIDATO type ZCANDIDATO .
  data ID_EMPLOYEE type ZEMPLOYEE .

    "metodo para definir o proximo id do candidato disponivel
  class-methods GET_NEXT_USER
    returning
      value(ID1) type ZNN_CANDIDATOS-ID_CANDIDATO .         "retorna o id do candidato da tabela znn_candidatos
    "metodo para inserir o ficheiro txt no dataset
  class-methods INSERT_FILE_DATASET
    importing
      !IT_STRINGTABLE type STRING_TABLE         "tabela preenchida com o texto em formato string
      !PATH_DATASET type STRING                       "caminho para o arquivo no servidor
      !ID_STRING type STRING .                                 "id do candidato em formato string
    "metodo que retorna o id do candidato em tipo string ou char10
  class-methods GET_ID_STRCHAR
    exporting
      !ID_CHAR type CHAR10                   "id do candidato em char10 com zeros à esquerda
      !ID_STRING type STRING .         "id do candidato em string
    "metodo para inserir candidato na tabela z znn_candidatos
  class-methods INSERT_CDT
    importing
      !ID_CDT type ZNN_CANDIDATOS-ID_CANDIDATO default 0             "id do candidato
      !NAME_CDT type ZNN_CANDIDATOS-NOME optional .              "nome do candidato
    "constructor que gera informacoes de um candidato
  methods CONSTRUCTOR
    importing
      !I_ID_CANDIDATO type ZCANDIDATO optional   "recebe um id de um candidato valido como parametro
    exceptions
      INVALID_CAND .
    "metodo para aprovar um candidato existente na tabela
  methods APROVAR
    exporting
      !E_RESULT type ZNN_RESULT .
    "metodo para rejeitar um candidato existente na tabela
  methods REJEITAR
    exporting
      !E_RESULT type ZNN_RESULT .
    "metodo para ler um curriculo referente a um candidato inserido no servidor
  class-methods READ_FILE_DATASET
    importing
      !PATH_DATASET type STRING      "caminho para diretorio no servidor
      !ID_STRING type STRING         "id do candidato em formato string
    changing
      !IT_STRINGTABLE2 type STRING_TABLE .   "tabela interna string
  methods INSERT_KEY_EMPLOYEE
    importing
      !ID_EMPLOYEE type CHAR8 .
protected section.

    "constantes que recebem valor de estados diferente para cada funcionario
  data CONST_APROVADO type ZESTADO value 1 ##NO_TEXT.
  data CONST_REJEITADO type ZESTADO value 2 ##NO_TEXT.
  PRIVATE SECTION.

    DATA nome TYPE znome .
    DATA estado TYPE zestado .
    DATA data TYPE zdata .
    DATA hora TYPE zhora .
    DATA alterado_por TYPE uname .

    "metodo para alterar o estado do candidato
    METHODS alterar_estado
      IMPORTING
        !estado   TYPE zestado OPTIONAL
      EXPORTING
        !e_result TYPE znn_result .
ENDCLASS.



CLASS ZCL_RLA_CANDIDATO IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_RLA_CANDIDATO->ALTERAR_ESTADO
* +-------------------------------------------------------------------------------------------------+
* | [--->] ESTADO                         TYPE        ZESTADO(optional)
* | [<---] E_RESULT                       TYPE        ZNN_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD alterar_estado.

    "verificacao de existencia de candidato
    IF me->id_candidato IS INITIAL.
      e_result-rc = 1.
      e_result-mensagem = 'Id candidato inválido'.
    ENDIF.

    "atualizacao do estado do candidato
    UPDATE znn_candidatos
     SET estado = estado
     alterado_por = sy-uname
     WHERE id_candidato = me->id_candidato.

    "validacao do estado do candidato
    IF sy-subrc NE 0.
      e_result-rc = 1.
      e_result-mensagem = 'Erro ao atualizar a base de dados'.
    ELSE.
      e_result-mensagem = 'Candidato alterado com Sucesso'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_CANDIDATO->APROVAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] E_RESULT                       TYPE        ZNN_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD aprovar.
    DATA: id_emp TYPE char8.

    "recebe o metodo da classe
    me->alterar_estado(
      EXPORTING
        estado   = me->const_aprovado   " 1 = Aprovado / 2 = Reprovado
      IMPORTING
        e_result = e_result             " Estrutura de resultados de operações
    ).

    IF sy-subrc NE 0.
      MESSAGE 'Não foi possível alterar o estado do candidato' TYPE 'E'.
    ENDIF.

    "metodo para cadastrar um novo colaborador na tabela.
    zcl_rla_employee=>insert_employee(
      IMPORTING
        id_employee = id_emp           " Campo de caracteres do comprimento 8
    ).

    IF id_emp IS NOT INITIAL.

      me->insert_key_employee( id_employee = id_emp ).

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_CANDIDATO->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ID_CANDIDATO                 TYPE        ZCANDIDATO(optional)
* | [EXC!] INVALID_CAND
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    "verifica se o id foi enviado como parametro
    IF i_id_candidato IS INITIAL.
      RETURN.
    ENDIF.

    "seleciona as informacoes do candidato referente ao id enviado como parametro
    SELECT SINGLE id_candidato nome
      FROM znn_candidatos INTO ( me->id_candidato , me->nome )
      WHERE id_candidato = i_id_candidato.

    "verifica se houve valor retornado pela consulta
    IF sy-subrc NE 0.
      RAISE invalid_cand.
      RETURN.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>GET_ID_STRCHAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] ID_CHAR                        TYPE        CHAR10
* | [<---] ID_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_id_strchar.

    TRY.
        "chama o metodo de classe para pegar o proximo id disponivel
        DATA: id_temp TYPE znn_candidatos-id_candidato.
        id_temp = get_next_user( ).

        " Verifica se o id foi retornado corretamente
        IF id_temp IS INITIAL.
          MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
        ENDIF.

        "variaveis recebem o valor do id
        id_char = id_temp.   "casting int4 >> char10
        id_string = id_temp. "casting int4 >> char10

        " Formatar número com zeros à esquerda
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = id_char
          IMPORTING
            output = id_char.
      CATCH cx_static_check INTO DATA(ex).
        " Tratamento de erro estático
        MESSAGE ex TYPE 'E'.
      CATCH cx_sy_open_sql_db INTO DATA(ex2).
        " Tratamento de erro de banco de dados
        MESSAGE ex2 TYPE 'E'.
      CATCH cx_root INTO DATA(ex3).
        " Tratamento de erro genérico
        MESSAGE ex3 TYPE 'E'.
    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>GET_NEXT_USER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID1                            TYPE        ZNN_CANDIDATOS-ID_CANDIDATO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_next_user.

    "consulta para determinar o proximo numero de candidato disponivel.
    "atributo da classe recebe o resultado da consulta
    SELECT MAX( id_candidato ) FROM znn_candidatos INTO id1.

    "verificacao da consulta
    IF sy-subrc EQ 0.
      ADD 1 TO id1. "incremento do valor da consulta para que se defina o proximno candidato disponivel
    ELSE.
      MESSAGE 'Erro ao buscar o número do candidato' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>INSERT_CDT
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CDT                         TYPE        ZNN_CANDIDATOS-ID_CANDIDATO (default =0)
* | [--->] NAME_CDT                       TYPE        ZNN_CANDIDATOS-NOME(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_cdt.

    "tabela interna e estrutura.
    DATA: it_cdt TYPE TABLE OF znn_candidatos,
          wa_cdt TYPE znn_candidatos.

    IF id_cdt IS NOT INITIAL OR name_cdt IS NOT INITIAL.

      "preenche a estrutura com as informacoes do candidato
      wa_cdt-id_candidato = id_cdt.   "parametro recebido
      wa_cdt-nome         = name_cdt. "parametro recebido
      wa_cdt-estado       = '0'.      "candidato ja é inserido no sistema como submetido = 0
      wa_cdt-data         = sy-datum. "data atual
      wa_cdt-hora         = sy-uzeit. "hora atual

      "insere estrutura na tabela e os dados na tabela z
      APPEND wa_cdt TO it_cdt.
      MODIFY znn_candidatos FROM TABLE it_cdt.

    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>INSERT_FILE_DATASET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_STRINGTABLE                 TYPE        STRING_TABLE
* | [--->] PATH_DATASET                   TYPE        STRING
* | [--->] ID_STRING                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_file_dataset.

    "variaveis para receber os ids em tipos diferentes de formatos
    DATA: id_str  TYPE string,
          id_char TYPE char10,
          id_num  TYPE znn_candidatos-id_candidato.

    id_num = zcl_rla_candidato=>get_next_user( ). "metodo da propria classe que retorna o proximo id disponivel

    " Verifica se o id foi retornado corretamente
    IF id_num IS INITIAL.
      MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
    ENDIF.

    zcl_rla_candidato=>get_id_strchar( "metodo da propria classe que exporta o proximo id disponivel convertido no tipo string e char10
      IMPORTING
        id_char   =  id_char         " char10 com zeros à esquerda
        id_string =  id_str          " string comum
    ).

    " Verifica se o id foi retornado corretamente
    IF id_char IS INITIAL OR id_str IS INITIAL.
      MESSAGE 'Faltam IDs convertido em string ou char10.' TYPE 'E'.
    ENDIF.

    id_str = id_char. "casting char10 >> str

    DATA: v_dir_dataset TYPE string. "cria a string para receber todo o texto concatenado
    "concatena o caminho, o id  e a extensao do arquivo dentro da string
    CONCATENATE path_dataset '/' id_str '.txt' INTO v_dir_dataset.
    CONDENSE v_dir_dataset.

    "converte toda string concatenada em tipo char
    DATA: v_dataset_final(30) TYPE c.
    v_dataset_final = v_dir_dataset. "casting str >> char

    " Verifica se o casting aconteceu antes de servir como referencia ao dataset
    IF v_dataset_final NE v_dir_dataset.
      MESSAGE 'Caminho para o Dataset inconsistente' TYPE 'E'.
    ENDIF.

    "gravacao do ficheiro no servidor.
    OPEN DATASET v_dataset_final FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      LOOP AT it_stringtable INTO DATA(wa_text).
        TRANSFER wa_text TO v_dataset_final.
        CLEAR wa_text.
      ENDLOOP.
      CLOSE DATASET v_dataset_final.
      MESSAGE 'Arquivo gravado com sucesso' TYPE 'S'.
    ELSE.
      MESSAGE 'Erro ao gravar o ficheiro no servidor.' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_CANDIDATO->INSERT_KEY_EMPLOYEE
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_EMPLOYEE                    TYPE        CHAR8
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_key_employee.

    "atualiza a tabela de candidatos inserindo a nova chave ao sistema
    UPDATE znn_candidatos
    SET id_employee = id_employee
    WHERE id_candidato = me->id_candidato.

    IF sy-subrc NE 0.
      MESSAGE 'Não foi possível atualizar os dados do candidato.' TYPE 'E'.
    ELSE.
      zcl_rla_username=>insert_username( id_candidato =  id_candidato ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_CANDIDATO=>READ_FILE_DATASET
* +-------------------------------------------------------------------------------------------------+
* | [--->] PATH_DATASET                   TYPE        STRING
* | [--->] ID_STRING                      TYPE        STRING
* | [<-->] IT_STRINGTABLE2                TYPE        STRING_TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD read_file_dataset.

    "variaveis para receber os ids em tipos diferentes de formatos
    DATA: id_str  TYPE string,
          id_char TYPE char10.

    id_str = id_string. "variavel recebe parametro

    " Verifica se o id foi retornado corretamente
    IF id_str IS INITIAL.
      MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
    ENDIF.

    id_char = id_str. "casting char >> str

    "formatar número com zeros à esquerda
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = id_char
      IMPORTING
        output = id_char.

    "verifica se o id foi retornado corretamente
    IF id_char IS INITIAL.
      MESSAGE 'Faltam IDs convertido em string ou char10.' TYPE 'E'.
    ENDIF.

    id_str = id_char. "casting char10 >> str

    DATA: v_dir_dataset TYPE string. "cria a string para receber todo o texto concatenado
    "concatena o caminho, o id  e a extensao do arquivo dentro da string
    CONCATENATE path_dataset '/' id_str '.txt' INTO v_dir_dataset.
    CONDENSE v_dir_dataset.

    "converte toda string concatenada em tipo char
    DATA: v_dataset_final(30) TYPE c.
    v_dataset_final = v_dir_dataset. "casting str >> char

    " Verifica se o casting aconteceu antes de servir como referencia ao dataset
    IF v_dataset_final NE v_dir_dataset.
      MESSAGE 'Caminho para o Dataset inconsistente' TYPE 'E'.
    ENDIF.

    "linha para percorrer tabela interna
    DATA: lv_line TYPE string.

    "abre o dataset no formato leitura
    OPEN DATASET v_dataset_final FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      "repeticao para ler linha a linha da tabela string
      DO.
        READ DATASET v_dataset_final INTO lv_line.
        IF sy-subrc <> 0.
          EXIT. "sai do ciclo se nao houver mais linhas para serem lidas
        ENDIF.
        " Armazenar a linha na tabela interna
        APPEND lv_line TO it_stringtable2.
        CLEAR lv_line.
      ENDDO.
      "fechar o dataset
      CLOSE DATASET v_dataset_final.
      MESSAGE 'Arquivo lido com sucesso' TYPE 'S'.
    ELSE.
      MESSAGE 'Erro ao abrir o arquivo para leitura' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_CANDIDATO->REJEITAR
* +-------------------------------------------------------------------------------------------------+
* | [<---] E_RESULT                       TYPE        ZNN_RESULT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD rejeitar.
    "invoca o metodo para alterar os estado do candidato
    me->alterar_estado(
      EXPORTING
        estado   = me->const_rejeitado   " 1 = Aprovado / 2 = Reprovado
      IMPORTING
        e_result = e_result             " Estrutura de resultados de operações
    ).

  ENDMETHOD.
ENDCLASS.
