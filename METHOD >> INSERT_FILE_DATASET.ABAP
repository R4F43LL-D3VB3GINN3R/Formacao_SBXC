METHOD insert_file_dataset.

    DATA: id_str TYPE string,
          id_num TYPE znn_candidatos-id_candidato.

    id_num = zcl_rla_candidato=>get_next_user( ).
    id_str = id_num. "casting int4 >> str

    DATA: v_dir_dataset TYPE string.

    CONCATENATE path_dataset '\' id_str '.txt' INTO v_dir_dataset. "caminho concatenado
    CONDENSE v_dir_dataset.

    DATA: v_dataset_final(30) TYPE c.
    v_dataset_final = v_dir_dataset. "casting str >> char

    "gravacao do ficneiro no servidor.
    OPEN DATASET v_dataset_final FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      LOOP AT it_stringtable INTO DATA(wa_text).
        TRANSFER wa_text TO v_dataset_final.
      ENDLOOP.
      CLOSE DATASET v_dataset_final.
      MESSAGE 'Arquivo gravado com sucesso' TYPE 'S'.
    ELSE.
      MESSAGE 'Erro ao gravar o ficheiro no servidor.' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
