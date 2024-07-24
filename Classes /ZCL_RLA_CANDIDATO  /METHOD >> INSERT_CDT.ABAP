<SIGNATURE>---------------------------------------------------------------------------------------+
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
