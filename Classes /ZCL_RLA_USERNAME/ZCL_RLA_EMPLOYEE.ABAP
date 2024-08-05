CLASS zcl_rla_username DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-DATA id_user TYPE char8 .
    CLASS-DATA id_employee TYPE zemployee .
    CLASS-DATA username TYPE char20 .
    CLASS-DATA data_entrada TYPE dats .
    CLASS-DATA data_saida TYPE dats .

    METHODS constructor
      IMPORTING
        !i_id_username TYPE char8 .
    CLASS-METHODS insert_username
      IMPORTING
        !id_candidato TYPE zcandidato .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS generate_username
      IMPORTING
        !id_candidato TYPE zcandidato
      EXPORTING
        !nickname     TYPE char20 .
    CLASS-METHODS get_next_username
      RETURNING
        VALUE(id_pos) TYPE znn_username-id_user .
ENDCLASS.



CLASS ZCL_RLA_USERNAME IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_USERNAME->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ID_USERNAME                  TYPE        CHAR8
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    IF i_id_username IS INITIAL.
      MESSAGE 'O Método Construtor foi incapaz de realizar a operação devido a ausência do parâmetro ID' TYPE 'E'.
    ENDIF.

    "seleciona a linha da tabela relacionado ao id enviado como parametro
    "preenche os atributos da classe com os dados retornados da consulta
    SELECT SINGLE id_user
                  id_employee
                  username
                  data_entrada
                  data_saida
      FROM znn_username
      INTO ( me->id_user,
             me->id_employee,
             me->username,
             me->data_entrada,
             me->data_saida )
      WHERE id_user = i_id_username.

    "verifica se a consulta retornou dados.
    IF sy-subrc NE 0.
      MESSAGE 'Não houveram dados retornados da consulta à base de dados' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_RLA_USERNAME=>GENERATE_USERNAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CANDIDATO                   TYPE        ZCANDIDATO
* | [<---] NICKNAME                       TYPE        CHAR20
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD generate_username.

    "tratando o novo nome do user
    DATA: nameuser  TYPE znn_candidatos-nome,
          nameuser2 TYPE string.

    "realiza consulta para buscar o nome do candidato aprovado
    SELECT SINGLE a~nome
    INTO nameuser
    FROM znn_candidatos AS a
    INNER JOIN ysap_employee AS b
    ON a~id_employee = b~id_employee
    WHERE a~id_candidato = id_candidato.

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
    DATA: userprefix  TYPE string,
          userprefix2 TYPE string,
          usersufix   TYPE string.

    "o prefixo recebe as três letras + o S4H que é comum entre todos os users.
    CONCATENATE ini mid fim 'S4H' INTO userprefix.

    "realiza consulta para buscar o id do colaborador aprovado
    SELECT SINGLE b~id_employee
    INTO usersufix
    FROM znn_candidatos AS a
    INNER JOIN ysap_employee AS b
    ON a~id_employee = b~id_employee
    WHERE a~id_candidato = id_candidato.

    "chamada da funcao para remover acentos da string de prefixo
    CALL FUNCTION 'HR_BR_CONVERT_ACCENTS'
      EXPORTING
        in_text             = userprefix
      IMPORTING
        out_text            = userprefix2
      EXCEPTIONS
        cannot_convert      = 1
        langu_not_supported = 2
        OTHERS              = 3.
    IF sy-subrc <> 0.
      MESSAGE 'Erro na remoção de acentos da string' TYPE 'E'.
    ENDIF.

    "concatena prefixo e sufixo na variavel username, concluindo o nome novo do user
    CONCATENATE userprefix2 usersufix INTO nickname.
    CONDENSE nickname NO-GAPS.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_RLA_USERNAME=>GET_NEXT_USERNAME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] ID_POS                         TYPE        ZNN_USERNAME-ID_USER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_next_username.

    SELECT MAX( id_user ) FROM znn_username INTO id_pos.

    IF sy-subrc EQ 0.
      ADD 1 TO id_pos.
    ELSE.
      MESSAGE 'Não houveram dados retornados da consulta' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_USERNAME=>INSERT_USERNAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CANDIDATO                   TYPE        ZCANDIDATO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_username.

    "consulta que recebe o id do user disponivel no sistema
    "usando metodo da propria classe
    DATA: userid TYPE znn_username-id_user.
    userid = get_next_username( ).

    "variavel para receber o nickname
    DATA: lv_nickname TYPE char20.

    "invoca o metodo da propria classe para gerar um novo nickname
    generate_username(
      EXPORTING
        id_candidato = id_candidato                 " Candidato
      IMPORTING
        nickname     = lv_nickname                 " Char 20
    ).

    IF sy-subrc NE 0.
      MESSAGE | Impossível gerar um novo nickname para o candidato: { id_candidato } | TYPE 'E'.
    ENDIF.

    "id do colaborador.
    DATA: id_emp TYPE zemployee.

    "realiza consulta para buscar o id do colaborador aprovado
    SELECT SINGLE b~id_employee
    INTO id_emp
    FROM znn_candidatos AS a
    INNER JOIN ysap_employee AS b
    ON a~id_employee = b~id_employee
    WHERE a~id_candidato = id_candidato.

    if sy-subrc ne 0.
      MESSAGE | Não há dados retornados do colaborador relacionado ao candidato: { id_candidato } | TYPE 'E'.
    endif.

    data: wa_username type znn_username.

    "preenche a estrutura com as informacoes do novo user
    wa_username-id_user = userid.
    wa_username-id_employee = id_emp.
    wa_username-username = lv_nickname.
    wa_username-data_entrada = sy-datum.
    wa_username-data_saida = '00000000'.

    "atualiza a tabela transparente do username com a nova estrutura preenchida.
    MODIFY znn_username FROM wa_username.

  ENDMETHOD.
ENDCLASS.
