class ZCL_RLA_EQUIPAMENTO definition
  public
  final
  create public .

public section.

  data ID_EQUIPAMENTO type ZEQUIPAMENTO .
  data DESCRICAO type ZDESCRICAO .
  data TIPO_EQUIP_ID type CHAR3 .
  data MARCA type CHAR15 .
  data MODELO type CHAR15 .

  methods CONSTRUCTOR
    importing
      !I_ID_EQUIPAMENTO type CHAR8 .
  class-methods GENERATE_CATALOG .
  class-methods INSERT_EQUIP
    importing
      !ID_EMPLOYEE type ZNN_ATRIB_EQUI-ID_EMPLOYEE
      !ID_LTP type ZNN_EQUIPAMENTOS-DESCRICAO
      !ID_TLM type ZNN_EQUIPAMENTOS-DESCRICAO .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RLA_EQUIPAMENTO IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_RLA_EQUIPAMENTO->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ID_EQUIPAMENTO               TYPE        CHAR8
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method constructor.

    "verifica se o parametro foi enviado
    if i_id_equipamento is initial.
      message 'O Método Construtor foi incapaz de realizar a operação devido a ausência do parâmetro ID' type 'E'.
    endif.

    "seleciona a linha da tabela relacionado ao id enviado como parametro
    "preenche os atributos da classe com os dados retornados da consulta
    SELECT SINGLE id_equipamento
                  descricao
                  tipo_equip_id
                  marca
                  modelo
      FROM znn_equipamentos
      INTO ( me->id_equipamento,
             me->descricao,
             me->tipo_equip_id,
             me->marca,
             me->modelo )
      WHERE id_equipamento = i_id_equipamento.

      "verifica se a consulta retornou dados.
      IF sy-subrc NE 0.
        MESSAGE 'Não existe um equipamento com este ID no catálogo3' TYPE 'E'.
      ENDIF.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_EQUIPAMENTO=>GENERATE_CATALOG
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method generate_catalog.

    "preenche a tabela interna para haver se vai haver dados
    data: it_equipamentos type table of znn_equipamentos.
    select * from znn_equipamentos into table it_equipamentos.
    "se houver dados...
    if sy-subrc eq 0.
      "limpa todos os equipamentos da tabela respectivamente com materiais dados a colaboradores
      delete from znn_atrib_equi.
      delete from znn_equipamentos.
    else.

    "contador >> id_equipamento auto_increment
    data: lv_count type i.
    lv_count = 0.

    "estrutura para receber dados dos portáteis
    data: ls_equipamentos type znn_equipamentos.

    do 50 times.

      "gera uma funcao random para o funcionario
      data(lv_random_num) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                                             min  = 1
                                                             max  = 15 )->get_next( ).

      "incrementa o contador
      add 1 to lv_count.

      case lv_random_num.

        when 1.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Ultrabook'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Várias Marcas'.
          ls_equipamentos-modelo = 'Dell XPS 13'. " Um exemplo de Ultrabook popular
        when 2.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Laptop'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Várias Marcas'.
          ls_equipamentos-modelo = 'HP Envy 13'. " Exemplo de um laptop popular
        when 3.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'MacBook'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Apple'.
          ls_equipamentos-modelo = 'MacBook Air M2'. " Um modelo recente de MacBook
        when 4.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Chromebook'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Google'.
          ls_equipamentos-modelo = 'Pixelbook Go'. " Modelo de Chromebook da Google
        when 5.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Tablet PC'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Várias Marcas'.
          ls_equipamentos-modelo = 'Microsoft Surface Go'. " Exemplo de um Tablet PC
        when 6.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Netbook'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Várias Marcas'.
          ls_equipamentos-modelo = 'ASUS Eee PC'. " Um dos Netbooks mais conhecidos
        when 7.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Surface Pro'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Microsoft'.
          ls_equipamentos-modelo = 'Surface Pro 9'. " Modelo mais recente da série Surface Pro
        when 8.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'ThinkPad'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Lenovo'.
          ls_equipamentos-modelo = 'ThinkPad X1 Carbon'. " Modelo de destaque da série ThinkPad
        when 9.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'EliteBook'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'HP'.
          ls_equipamentos-modelo = 'EliteBook 840 G9'. " Um modelo recente da série EliteBook
        when 10.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'ZenBook'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'ASUS'.
          ls_equipamentos-modelo = 'ZenBook 14'. " Um dos modelos mais populares da série ZenBook
        when 11.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Spectre x360'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'HP'.
          ls_equipamentos-modelo = 'Spectre x360 14'. " Um modelo conversível da série Spectre
        when 12.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Yoga'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Lenovo'.
          ls_equipamentos-modelo = 'Yoga 9i'. " Um modelo popular da série Yoga
        when 13.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'XPS'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Dell'.
          ls_equipamentos-modelo = 'XPS 15'. " Um modelo de destaque da série XPS
        when 14.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Pavilion'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'HP'.
          ls_equipamentos-modelo = 'Pavilion 15'. " Um modelo popular da série Pavilion
        when 15.
          ls_equipamentos-id_equipamento = lv_count.
          ls_equipamentos-descricao = 'Aspire'.
          ls_equipamentos-tipo_equip_id = 'LPT'.
          ls_equipamentos-marca = 'Acer'.
          ls_equipamentos-modelo = 'Aspire 5'. " Um modelo popular da série Aspire
      endcase.

      "insere os portáteis
      modify znn_equipamentos from ls_equipamentos.

    enddo.

    "estrutura para telemóveis
    data: ls_telemoveis type znn_equipamentos.

    do 50 times.

      "gera uma funcao random para o funcionario
      data(lv_random_num2) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                                             min  = 1
                                                             max  = 15 )->get_next( ).

      "incrementa o contador
      add 1 to lv_count.

      case lv_random_num2.

        when 1.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Apple'.
          ls_telemoveis-modelo = 'iPhone 14 Pro Max'. " Modelo popular da Apple

        when 2.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Samsung'.
          ls_telemoveis-modelo = 'Galaxy S23 Ultra'. " Modelo topo de linha da Samsung

        when 3.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Google'.
          ls_telemoveis-modelo = 'Pixel 7 Pro'. " Modelo popular do Google

        when 4.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Xiaomi'.
          ls_telemoveis-modelo = 'Mi 13 Pro'. " Modelo premium da Xiaomi

        when 5.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'OnePlus'.
          ls_telemoveis-modelo = 'OnePlus 11'. " Modelo recente da OnePlus

        when 6.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Huawei'.
          ls_telemoveis-modelo = 'P60 Pro'. " Modelo flagship da Huawei

        when 7.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Sony'.
          ls_telemoveis-modelo = 'Xperia 1 IV'. " Modelo de destaque da Sony

        when 8.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Oppo'.
          ls_telemoveis-modelo = 'Find X6 Pro'. " Modelo premium da Oppo

        when 9.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Motorola'.
          ls_telemoveis-modelo = 'Edge 40 Pro'. " Modelo de alto desempenho da Motorola

        when 10.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Realme'.
          ls_telemoveis-modelo = 'GT3 Pro'. " Modelo de destaque da Realme

        when 11.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Vivo'.
          ls_telemoveis-modelo = 'X90 Pro+'. " Modelo premium da Vivo

        when 12.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Asus'.
          ls_telemoveis-modelo = 'ROG Phone 7'. " Smartphone gamer da Asus

        when 13.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Nokia'.
          ls_telemoveis-modelo = 'Nokia XR21'. " Modelo resistente da Nokia

        when 14.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'Honor'.
          ls_telemoveis-modelo = 'Magic5 Pro'. " Modelo premium da Honor

        when 15.
          ls_telemoveis-id_equipamento = lv_count.
          ls_telemoveis-descricao = 'Smartphone'.
          ls_telemoveis-tipo_equip_id = 'TLM'.
          ls_telemoveis-marca = 'ZTE'.
          ls_telemoveis-modelo = 'Axon 50 Ultra'. " Modelo de alta performance da ZTE

       endcase.

       "insere os telemóveis
       modify znn_equipamentos from ls_telemoveis.

     enddo.

    endif.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_RLA_EQUIPAMENTO=>INSERT_EQUIP
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_EMPLOYEE                    TYPE        ZNN_ATRIB_EQUI-ID_EMPLOYEE
* | [--->] ID_LTP                         TYPE        ZNN_EQUIPAMENTOS-DESCRICAO
* | [--->] ID_TLM                         TYPE        ZNN_EQUIPAMENTOS-DESCRICAO
* +--------------------------------------------------------------------------------------</SIGNATURE>
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
ENDCLASS.
