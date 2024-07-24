CLASS zcl_rla_candidato DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA id_candidato TYPE zcandidato .
    DATA id_employee TYPE zemployee .

    "metodo para definir o proximo id do candidato disponivel
    CLASS-METHODS get_next_user
      RETURNING
        VALUE(id1) TYPE znn_candidatos-id_candidato .       "retorna o id do candidato da tabela znn_candidatos
    "metodo para inserir o ficheiro txt no dataset
    CLASS-METHODS insert_file_dataset
      IMPORTING
        !it_stringtable TYPE string_table       "tabela preenchida com o texto em formato string
        !path_dataset   TYPE string                   "caminho para o arquivo no servidor
        !id_string      TYPE string .                          "id do candidato em formato string
    "metodo que retorna o id do candidato em tipo string ou char10
    CLASS-METHODS get_id_strchar
      EXPORTING
        !id_char   TYPE char10               "id do candidato em char10 com zeros à esquerda
        !id_string TYPE string .       "id do candidato em string
    "metodo para inserir candidato na tabela z znn_candidatos
    CLASS-METHODS insert_cdt
      IMPORTING
        !id_cdt   TYPE znn_candidatos-id_candidato DEFAULT 0         "id do candidato
        !name_cdt TYPE znn_candidatos-nome OPTIONAL .            "nome do candidato
    "constructor que gera informacoes de um candidato
    METHODS constructor
      IMPORTING
        !i_id_candidato TYPE zcandidato OPTIONAL "recebe um id de um candidato valido como parametro
      EXCEPTIONS
        invalid_cand .
    "metodo para aprovar um candidato existente na tabela
    METHODS aprovar
      EXPORTING
        !e_result TYPE znn_result .
    "metodo para rejeitar um candidato existente na tabela
    METHODS rejeitar
      EXPORTING
        !e_result TYPE znn_result .
    "metodo para ler um curriculo referente a um candidato inserido no servidor
    CLASS-METHODS read_file_dataset
      IMPORTING
        !path_dataset    TYPE string "caminho para diretorio no servidor
        !id_string       TYPE string "id do candidato em formato string
      CHANGING
        !it_stringtable2 TYPE string_table . "tabela interna string
  PROTECTED SECTION.

    "constantes que recebem valor de estados diferente para cada funcionario
    DATA const_aprovado TYPE zestado VALUE 1 ##NO_TEXT.
    DATA const_rejeitado TYPE zestado VALUE 2 ##NO_TEXT.
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



CLASS zcl_rla_candidato IMPLEMENTATION.


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
    UPDATE znn_candidatos SET estado = estado WHERE id_candidato = me->id_candidato.

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

    "recebe o metodo da classe
    me->alterar_estado(
      EXPORTING
        estado   = me->const_aprovado   " 1 = Aprovado / 2 = Reprovado
      IMPORTING
        e_result = e_result             " Estrutura de resultados de operações
    ).

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
