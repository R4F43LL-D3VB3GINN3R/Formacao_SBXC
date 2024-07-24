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
