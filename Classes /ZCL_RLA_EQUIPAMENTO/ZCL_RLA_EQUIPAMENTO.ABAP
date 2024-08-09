  method insert_equip.

    "boleana para registrar evento
    data: lv_exist type bool.

    "registros de colaborador
    data: it_employee type table of ysap_employee.
    select * from ysap_employee into table it_employee.

    "verifica se o número do colaborador inserido realmente existe no sistema.
    loop at it_employee into data(ls_employee).
      if id_employee eq ls_employee-id_employee.
        lv_exist = 'True'.
      endif.
    endloop.

    "verificacao de preenchimento de campos
    if id_employee is initial.
      message 'Campo ID está vazio' type 'I' display like 'E'.
    elseif id_ltp is initial or id_tlm is initial.
      message 'Telefone ou Portátil não selecionados' type 'I' display like 'E'.
    elseif lv_exist = 'False'.
      message 'O ID não existe no sistema' type 'I' display like 'E'.
    else.

      "tabela interna e estrutura da relacao entre employee e equipamento

      "entrega de portáteis
      data: ls_atrib_ltp type znn_atrib_equi.

      "montagem da estrutura
      ls_atrib_ltp-id_employee = id_employee.
      ls_atrib_ltp-id_equipamento = id_ltp.
      ls_atrib_ltp-estado = '1'.
      ls_atrib_ltp-data = sy-datum.
      ls_atrib_ltp-hora = sy-uzeit.

      "remove os dados antes da atualizacao
      delete from znn_atrib_equi where id_employee = id_employee.

      "insere ou atualiza a tabela conforme dados enviados.
      modify znn_atrib_equi from ls_atrib_ltp.

      "entrega de telemóveis
      data: ls_atrib_tlm type znn_atrib_equi.

      "montagem da estrutura
      ls_atrib_tlm-id_employee = id_employee.
      ls_atrib_tlm-id_equipamento = id_tlm.
      ls_atrib_tlm-estado = '1'.
      ls_atrib_tlm-data = sy-datum.
      ls_atrib_tlm-hora = sy-uzeit.

      "insere ou atualiza a tabela conforme dados enviados.
      modify znn_atrib_equi from ls_atrib_tlm.

    endif.

  endmethod.
