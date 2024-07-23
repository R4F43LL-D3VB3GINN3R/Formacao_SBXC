    DATA: id_temp TYPE znn_candidatos-id_candidato.
    id_temp = get_next_user( ).

    id_char = id_temp.
    id_string = id_temp.

    " Formatar número com zeros à esquerda
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = id_char
      IMPORTING
        output = id_char.
