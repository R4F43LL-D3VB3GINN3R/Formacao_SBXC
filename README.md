"------------------------------------------------------------------------------------------------------------------------------------------
"------------------------------------------------------------------------------------------------------------------------------------------
"------------------------------------------------------------------------------------------------------------------------------------------
1 - 

Submissão de candidatura
Processamento
Determinar o próximo número de candidato disponível (devem ser sequenciais) 
Fazer upload do ficheiro em formato TXT para uma tabela interna (a tabela apenas tem um campo do tipo STRING), onde guarda cada linha do ficheiro.
Gravar o conteúdo da tabela interna num ficheiro no servidor. 
O ficheiro deve ser gravado no directório /tmp/cv/nn/ e deve ter o nome NNNNNNNNNN.txt onde (NNNNNNNNNN deverá ser substituído pelo número gerado para o candidato). 
Ou seja, vai guardar o ficheiro como algo do género /tmp/cv/nn/0000000001.txt
Se o ficheiro for gravado com sucesso, deve gravar um registo na tabela Znn_CANDIDATOS com o número do candidato, o nome introduzido no ecrã de seleção, estado = 0 (submetido) e a data/hora de submissão deverá ser a data e hora atuais.

*-----------------------------------------
* Identificação
*-----------------------------------------
Nome: Pedro
Idade: 27
*-----------------------------------------
* Formação
*-----------------------------------------
2015-2018 Licenciatura em Engenharia Informática - ISEP
*-----------------------------------------
* Experiência profissional
*-----------------------------------------
2019-2020 Consultor ABAP @ ABC Co.
2018-2019 Consultor ABAP @ XPTO Consulting

"------------------------------------------------------------------------------------------------------------------------------------------
"------------------------------------------------------------------------------------------------------------------------------------------
"------------------------------------------------------------------------------------------------------------------------------------------
