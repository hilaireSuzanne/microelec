add wave \
  :conso_dyn_tb:bd0:din_real1 \
  :conso_dyn_tb:bd0:din_real2
add wave \
  :conso_dyn_tb:bd0:dout
add wave \
  :conso_dyn_tb:bd0:tt_val
add wave \
  :conso_dyn_tb:bd0:capa_charge_val
add wave \
  :conso_dyn_tb:bd0:internal_energy
add wave \
  :conso_dyn_tb:bd0:start_integral
add wave \
  :conso_dyn_tb:bd0:stop_integral
add wave \
  :conso_dyn_tb:bd0:integral

run -all
exit
