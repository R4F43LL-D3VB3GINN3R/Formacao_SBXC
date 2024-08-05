class ZCL_RLA_EMPLOYEE definition
  public
  final
  create public .

public section.

  class-data ID_EMPLOYEE type CHAR8 .
  class-data FUNCAO type CHAR20 .
  class-data DATA_ENTRADA type DATS .
  class-data DATA_SAIDA type DATS .

  methods CONSTRUCTOR
    importing
      !I_ID_EMPLOYEE type ZEMPLOYEE .
  class-methods INSERT_EMPLOYEE
    exporting
      !ID_EMPLOYEE type CHAR8 .
protected section.
private section.

  class-methods GET_NEXT
    exporting
      !ID_POS type YSAP_EMPLOYEE-ID_EMPLOYEE .
ENDCLASS.



CLASS ZCL_RLA_EMPLOYEE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_EMPLOYEE->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ID_EMPLOYEE                  TYPE        ZEMPLOYEE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    IF i_id_employee IS INITIAL.
      MESSAGE 'O Método Constructor não conseguiu detectar o parâmetro chave enviado' TYPE 'E'.
    ENDIF.

    "seleciona a linha da tabela relacionado ao id enviado como parametro
    "preenche os atributos da classe com os dados retornados da consulta
    SELECT SINGLE id_employee
                  funcao
                  data_entrada
                  data_saida
      FROM ysap_employee
      INTO ( me->id_employee,
             me->funcao,
             me->data_entrada,
             me->data_saida )
      WHERE id_employee = i_id_employee.

    "verifica se a consulta retornou algo
    IF sy-subrc NE 0.
      MESSAGE 'O Método Constructor não  o conseguiu detectar o parâmetro chave enviado' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_RLA_EMPLOYEE=>GET_NEXT
* +-------------------------------------------------------------------------------------------------+
* | [<---] ID_POS                         TYPE        YSAP_EMPLOYEE-ID_EMPLOYEE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_next.

    SELECT MAX( id_employee ) FROM ysap_employee INTO id_pos.

    IF sy-subrc EQ 0.
      ADD 1 TO id_pos.
    ELSE.
      MESSAGE 'Não houveram dados retornados da consulta' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_EMPLOYEE=>INSERT_EMPLOYEE
* +-------------------------------------------------------------------------------------------------+
* | [<---] ID_EMPLOYEE                    TYPE        CHAR8
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD insert_employee.

    "estrutura a ser preenchida
    DATA: wa_emp TYPE ysap_employee.

    "id retornado do metodo
    DATA: new_id TYPE ysap_employee-id_employee.

    "metodo para receber o proximo id
    zcl_rla_employee=>get_next(
      IMPORTING
        id_pos = new_id " Colaborador
    ).

    wa_emp-id_employee = new_id.

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

    IF sy-subrc eq 0.
      id_employee = new_id.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
