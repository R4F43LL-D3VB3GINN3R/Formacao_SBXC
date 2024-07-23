*&---------------------------------------------------------------------*
*& Report ZRLA_APROVA_CANDIDATO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRLA_APROVA_CANDIDATO.

TABLES: znn_candidatos.

TYPES: BEGIN OF ty_cdt,
         nome TYPE znn_candidatos-nome,
       END OF ty_cdt.

DATA: it_cdt TYPE TABLE OF ty_cdt,
      ls_cdt TYPE ty_cdt.

data: it_return type table of DDSHRETVAL,
      ls_return type DDSHRETVAL.

* Tela de Seleção
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_nome TYPE znn_candidatos-nome.
SELECTION-SCREEN: END OF BLOCK a1.
SELECTION-SCREEN: SKIP 1.

* Adicionar ajuda de pesquisa (F4) ao select-options
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_nome.
   SELECT nome FROM znn_candidatos INTO CORRESPONDING FIELDS OF TABLE it_cdt.

     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
         retfield               = 'NOME'
         VALUE_ORG              = 'S'
       tables
         value_tab              = it_cdt
         RETURN_TAB             = it_return

      EXCEPTIONS
        PARAMETER_ERROR        = 1
        NO_VALUES_FOUND        = 2
        OTHERS                 = 3
               .

read table it_return into ls_return index 1.
p_nome = ls_return-fieldval.

*"variaveis para receber os ids em tipos diferentes de formatos
*DATA: id_str       TYPE string,
*      id_char      TYPE char10,
*      id_num       TYPE znn_candidatos-id_candidato,
*      path_dataset TYPE string.
*
*DATA: it_stringtable TYPE STANDARD TABLE OF string.
*
*SELECT MAX( id_candidato ) FROM znn_candidatos INTO id_num.
*id_num = id_num.
*
*" Verifica se o id foi retornado corretamente
*IF id_num IS INITIAL.
*  MESSAGE 'Id do Candidato não encontrado.' TYPE 'E'.
*ENDIF.
*
*id_str = id_num.
*id_char = id_num.
*
*" Formatar número com zeros à esquerda
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*  EXPORTING
*    input  = id_char
*  IMPORTING
*    output = id_char.
*
*" Verifica se o id foi retornado corretamente
*IF id_char IS INITIAL OR id_str IS INITIAL.
*  MESSAGE 'Faltam IDs convertido em string ou char10.' TYPE 'E'.
*ENDIF.
*
*id_str = id_char. "casting char10 >> str
*path_dataset = '/tmp'.
*
*DATA: v_dir_dataset TYPE string. "cria a string para receber todo o texto concatenado
*"concatena o caminho, o id  e a extensao do arquivo dentro da string
*CONCATENATE path_dataset '/' id_str '.txt' INTO v_dir_dataset.
*CONDENSE v_dir_dataset.
*
*"converte toda string concatenada em tipo char
*DATA: v_dataset_final(30) TYPE c.
*v_dataset_final = v_dir_dataset. "casting str >> char
*
*" Verifica se o casting aconteceu antes de servir como referencia ao dataset
*IF v_dataset_final NE v_dir_dataset.
*  MESSAGE 'Caminho para o Dataset inconsistente' TYPE 'E'.
*ENDIF.
*
*DATA: lv_line type string.
*
*OPEN DATASET v_dataset_final FOR INPUT IN TEXT MODE ENCODING DEFAULT.
*  IF sy-subrc EQ 0.
*    " Ler o conteúdo do dataset linha por linha
*    DO.
*      READ DATASET v_dataset_final INTO lv_line.
*      IF sy-subrc <> 0.
*        EXIT.
*      ENDIF.
*      " Armazenar a linha na tabela interna
*      APPEND lv_line TO it_stringtable.
*      CLEAR lv_line.
*    ENDDO.
*    " Fechar o dataset
*    CLOSE DATASET v_dataset_final.
*    MESSAGE 'Arquivo lido com sucesso' TYPE 'S'.
*  ELSE.
*    MESSAGE 'Erro ao abrir o arquivo para leitura' TYPE 'E'.
*  ENDIF.
*
*IF it_stringtable IS NOT INITIAL.
*  cl_demo_output=>display( it_stringtable ).
*ELSE.
*  WRITE: / 'Tabela Vazia'.
*ENDIF.
