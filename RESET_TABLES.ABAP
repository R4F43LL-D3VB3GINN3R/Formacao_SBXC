delete from znn_username.
delete from ysap_employee.

data: it_table type table of znn_candidatos.
data: it_table2 type table of znn_candidatos.

select * from znn_candidatos into table it_table.

loop at it_table into data(ls_table).
  ls_table-id_employee = 0.
  ls_table-alterado_por = ''.
  ls_table-estado = '0'.
  append ls_table to it_table2.
endloop.

modify znn_candidatos from table it_table2.
