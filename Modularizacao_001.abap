"----------------------------------------------------------------------------------------------------------------------

                                            [INJETANDO DADOS NA TABELAZ]

"----------------------------------------------------------------------------------------------------------------------

REPORT ztemp004_rafael_rfcs_funcoes.

DATA: lt_spfli  TYPE STANDARD TABLE OF zrl_spfli,
      ls_rspfli TYPE zrl_spfli.

"populando tabelaz transparente
CLEAR ls_rspfli.
ls_rspfli-carrid = 'AA'.   " Companhia aérea
ls_rspfli-connid = sy-index + 1. " Número do voo
ls_rspfli-cityfrom = 'Porto'. " Cidade de origem
ls_rspfli-airpfrom = 'PT'.   " Aeroporto de origem
ls_rspfli-cityto = 'Lisboa'.  " Cidade de destino
ls_rspfli-airpto = 'FSC'.     " Aeroporto de destino
ls_rspfli-fltime = 60.        " Duração do voo em minutos
ls_rspfli-deptime = '120000'.  " Horário de partida
ls_rspfli-arrtime = '130000'.   " Horário de chegada
ls_rspfli-distance = 177.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'N'.        " Tipo de voo (Nacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'TP'.   " Companhia aérea
ls_rspfli-connid = sy-index + 2. " Número do voo
ls_rspfli-cityfrom = 'Lisboa'. " Cidade de origem
ls_rspfli-airpfrom = 'LIS'.   " Aeroporto de origem
ls_rspfli-cityto = 'Madrid'.  " Cidade de destino
ls_rspfli-airpto = 'MAD'.     " Aeroporto de destino
ls_rspfli-fltime = 75.        " Duração do voo em minutos
ls_rspfli-deptime = '140000'.  " Horário de partida
ls_rspfli-arrtime = '151500'.   " Horário de chegada
ls_rspfli-distance = 360.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'N'.        " Tipo de voo (Nacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'LH'.   " Companhia aérea
ls_rspfli-connid = sy-index + 3. " Número do voo
ls_rspfli-cityfrom = 'Lisboa'. " Cidade de origem
ls_rspfli-airpfrom = 'LIS'.   " Aeroporto de origem
ls_rspfli-cityto = 'Frankfurt'.  " Cidade de destino
ls_rspfli-airpto = 'FRA'.     " Aeroporto de destino
ls_rspfli-fltime = 150.        " Duração do voo em minutos
ls_rspfli-deptime = '160000'.  " Horário de partida
ls_rspfli-arrtime = '173000'.   " Horário de chegada
ls_rspfli-distance = 1030.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'I'.        " Tipo de voo (Internacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'RY'.   " Companhia aérea
ls_rspfli-connid = sy-index + 4. " Número do voo
ls_rspfli-cityfrom = 'Porto'. " Cidade de origem
ls_rspfli-airpfrom = 'PT'.   " Aeroporto de origem
ls_rspfli-cityto = 'Barcelona'.  " Cidade de destino
ls_rspfli-airpto = 'BCN'.     " Aeroporto de destino
ls_rspfli-fltime = 100.        " Duração do voo em minutos
ls_rspfli-deptime = '090000'.  " Horário de partida
ls_rspfli-arrtime = '100000'.   " Horário de chegada
ls_rspfli-distance = 620.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'N'.        " Tipo de voo (Nacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'UX'.   " Companhia aérea
ls_rspfli-connid = sy-index + 5. " Número do voo
ls_rspfli-cityfrom = 'Lisboa'. " Cidade de origem
ls_rspfli-airpfrom = 'LIS'.   " Aeroporto de origem
ls_rspfli-cityto = 'Madri'.  " Cidade de destino
ls_rspfli-airpto = 'MAD'.     " Aeroporto de destino
ls_rspfli-fltime = 120.        " Duração do voo em minutos
ls_rspfli-deptime = '110000'.  " Horário de partida
ls_rspfli-arrtime = '123000'.   " Horário de chegada
ls_rspfli-distance = 620.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'N'.        " Tipo de voo (Nacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'AF'.   " Companhia aérea
ls_rspfli-connid = sy-index + 6. " Número do voo
ls_rspfli-cityfrom = 'Paris'. " Cidade de origem
ls_rspfli-airpfrom = 'CDG'.   " Aeroporto de origem
ls_rspfli-cityto = 'Londres'.  " Cidade de destino
ls_rspfli-airpto = 'LHR'.     " Aeroporto de destino
ls_rspfli-fltime = 90.        " Duração do voo em minutos
ls_rspfli-deptime = '080000'.  " Horário de partida
ls_rspfli-arrtime = '093000'.   " Horário de chegada
ls_rspfli-distance = 214.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'I'.        " Tipo de voo (Internacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'IB'.   " Companhia aérea
ls_rspfli-connid = sy-index + 7. " Número do voo
ls_rspfli-cityfrom = 'Madrid'. " Cidade de origem
ls_rspfli-airpfrom = 'MAD'.   " Aeroporto de origem
ls_rspfli-cityto = 'Barcelona'.  " Cidade de destino
ls_rspfli-airpto = 'BCN'.     " Aeroporto de destino
ls_rspfli-fltime = 75.        " Duração do voo em minutos
ls_rspfli-deptime = '100000'.  " Horário de partida
ls_rspfli-arrtime = '111500'.   " Horário de chegada
ls_rspfli-distance = 300.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'N'.        " Tipo de voo (Nacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'BA'.   " Companhia aérea
ls_rspfli-connid = sy-index + 8. " Número do voo
ls_rspfli-cityfrom = 'Londres'. " Cidade de origem
ls_rspfli-airpfrom = 'LHR'.   " Aeroporto de origem
ls_rspfli-cityto = 'Nova York'.  " Cidade de destino
ls_rspfli-airpto = 'JFK'.     " Aeroporto de destino
ls_rspfli-fltime = 420.        " Duração do voo em minutos
ls_rspfli-deptime = '110000'.  " Horário de partida
ls_rspfli-arrtime = '180000'.   " Horário de chegada
ls_rspfli-distance = 3450.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'I'.        " Tipo de voo (Internacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'KLM'.   " Companhia aérea
ls_rspfli-connid = sy-index + 9. " Número do voo
ls_rspfli-cityfrom = 'Amsterdã'. " Cidade de origem
ls_rspfli-airpfrom = 'AMS'.   " Aeroporto de origem
ls_rspfli-cityto = 'Lisboa'.  " Cidade de destino
ls_rspfli-airpto = 'LIS'.     " Aeroporto de destino
ls_rspfli-fltime = 180.        " Duração do voo em minutos
ls_rspfli-deptime = '140000'.  " Horário de partida
ls_rspfli-arrtime = '170000'.   " Horário de chegada
ls_rspfli-distance = 1150.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'I'.        " Tipo de voo (Internacional)
APPEND ls_rspfli TO lt_spfli.

CLEAR ls_rspfli.
ls_rspfli-carrid = 'AZ'.   " Companhia aérea
ls_rspfli-connid = sy-index + 10. " Número do voo
ls_rspfli-cityfrom = 'Roma'. " Cidade de origem
ls_rspfli-airpfrom = 'FCO'.   " Aeroporto de origem
ls_rspfli-cityto = 'Milão'.  " Cidade de destino
ls_rspfli-airpto = 'MXP'.     " Aeroporto de destino
ls_rspfli-fltime = 90.        " Duração do voo em minutos
ls_rspfli-deptime = '130000'.  " Horário de partida
ls_rspfli-arrtime = '143000'.   " Horário de chegada
ls_rspfli-distance = 360.      " Distância em milhas
ls_rspfli-distid = 'MI'.       " Unidade de distância
ls_rspfli-fltype = 'N'.        " Tipo de voo (Nacional)
APPEND ls_rspfli TO lt_spfli.

cl_demo_output=>display( lt_spfli ).

MODIFY zrl_spfli FROM TABLE lt_spfli.
