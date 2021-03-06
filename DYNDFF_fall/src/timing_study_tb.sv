// On prend 1fs dans le timescale pour que les mesures de temps dans le domaine "numérique" soient précises.
// (à confirmer)
`timescale 1ps/1fs


module timing_study_tb;

// Paramètres du testbench
parameter real digital_tick    = 20000          ;    // (ns) Temps entre deux transitions du signal d'entrée

// Les signaux logiques et électriques
logic  din                ; // Signal logique destiné à piloter le test
logic  clk                ; // Signal logique destiné à piloter le test
wire   q                ; // Signal logique destiné à piloter le test
bit    fin_test           ; // vaut 0 au débu de la simu
// Les variables adaptées ou mesurées exprimées sous forme de signaux réels. 
real capa_charge_val      ; // La valeur de la capacité de charge
real tt_val_clk               ; // La valeur du temps de transition en entrée
real tt_val_d               ; // La valeur du temps de transition en entrée
real d_time_rise           ; 
real clk_time_rise            ;

integer File;

// On instancie la maquette de test, en utilisant la connection générique pour simplifie l'écriture
setup_study_bd bd0  (
                          .din(din), 
                          .clk(clk),
                          .capa_charge_val(capa_charge_val),
                          .tt_val_clk(tt_val_clk),
                          .tt_val_d(tt_val_d),
                          .clk_rise_time(clk_time_rise),
                          .d_rise_time(d_time_rise),
                          .dout(q),
                          .fin_test(fin_test)) ;

// La liste des points de test à effectuer est déterminée par 2 tables de paramètres directement
// extraite du fichier Liberty de la bibliothèque NANGATE
localparam load_capacitance = 60.7300000;
localparam NBSLOPES_CK = 3 ;
localparam NBSLOPES_D   = 3 ;
localparam real clk_tran_values[0:NBSLOPES_CK-1] = '{0.00117378,0.0449324,0.198535} ; // ns
localparam real d_tran_values[0:NBSLOPES_D-1] = '{0.00117378,0.0449324,0.198535};// ns 
// initial setup time ns
localparam real setup_step = 5;
localparam real std_delay = 10;
// Table pour récupérer le temps de propagation mesuré
real tab_setup_time[0:NBSLOPES_CK-1][0:NBSLOPES_D-1] ;

///////////////////////////////////////////////////////////////
// Le testbench proprement dit défini dans le monde "logique".
///////////////////////////////////////////////////////////////

always #(digital_tick/2) clk = ~clk;



initial 
begin:simu
   int clk_tran_index,d_tran_index;
   int shorter;
   real prop_time ;
    

   // On teste A1 : donc on met A2 à 1 pour avoir une monté en sortie   
   din = 1 ;
   clk = 1 ;
   capa_charge_val = load_capacitance*1.0e-15;
    // Result for A1
   // Boucle principale sur la liste des pentes d'entrée
   for(clk_tran_index=0;clk_tran_index<NBSLOPES_CK;clk_tran_index++) 
   begin
     // Attention on change la valeur de la pente lorsque l'on est sur que rien ne bouge dans la partie analogique
     #(digital_tick) ; tt_val_clk = clk_tran_values[clk_tran_index]*1.0e-9  ;
     // Boucle secondaire sur la liste des capa de charge
     for(d_tran_index=0;d_tran_index<NBSLOPES_D;d_tran_index++) 
     begin
        #(digital_tick); tt_val_d = d_tran_values[d_tran_index]*1.0e-9  ;
       // Attention on change la valeur de la capa de charge lorsque l'on est sur que rien ne bouge dans la partie analogique
       // On provoqueune monte du signal de commande : donc du signal de sortie

       shorter = 1;
       for (int i = 1200 ; i>=-2000; i--)
           begin
            if (d_tran_index == 0 && shorter == 1)
                begin
                    i=100;
                    shorter = 0;
                end
            else if(d_tran_index ==1 && shorter == 1)
                begin
                    i = 300;
                    shorter = 0;
                end  
            #(digital_tick-i*setup_step) ; din = 0 ;
            #(digital_tick/2 + i*setup_step); // resync on clk
            din = 1;
            if (q == 1)
                begin
                    // on majore de 10%
                    tab_setup_time[clk_tran_index][d_tran_index] = 1.05*(clk_time_rise- d_time_rise)/1.0e-6;
                    // set dout to 0
                    #(digital_tick/2) ;
                    // test si la valeur de D est dans la bascule
                    #(digital_tick);
                    break;
                end
            else
                begin
                    tab_setup_time[clk_tran_index][d_tran_index] = 0;
                end
            // set dout to 0
            #(digital_tick/2) ;
            // test si la valeur de D est dans la bascule
            #(digital_tick);
          end
     end
   end


   // Write result in file
   File = $fopen("/tmp/DFF_X1_setup_time_falling.dat");
   $fwrite (File, "timing () {\n\n");   
   $fwrite (File, "related_pin : \"CK\n;\n");   
   $fwrite (File, "timing_type : setup_falling;\n");   
   $fwrite (File, "rise_constraint(Setup_3_3){\n");
   $fwrite (File, "index_1( \"");
   for(int j=0; j< NBSLOPES_CK; j++)
       begin
        $fwrite(File,"%10.8f",clk_tran_values[j]) ;
        if (j < NBSLOPES_CK-1)
            $fwrite(File, ", ");
        else
            $fwrite(File, "\");\n");
       end 
   $fwrite (File, "index_2( \"");
   for(int j=0; j< NBSLOPES_D; j++)
       begin
        $fwrite(File,"%10.8f",d_tran_values[j]) ;
        if (j < NBSLOPES_D-1)
            $fwrite(File, ", ");
        else
            $fwrite(File, "\");\n");
       end
       
   for(clk_tran_index=0;clk_tran_index<NBSLOPES_CK;clk_tran_index++)
   begin
     if(clk_tran_index == 0) 
        $fwrite(File,"    values (\"") ;
     else
        $fwrite(File,"             ") ;
     for(d_tran_index=0;d_tran_index<NBSLOPES_D;d_tran_index++)
     begin
       $fwrite(File,"%10.8f",tab_setup_time[clk_tran_index][d_tran_index]) ;
       if(d_tran_index < NBSLOPES_D-1)
          $fwrite(File,",") ;
       else
          $fwrite(File,"\"") ;
     end
     if(clk_tran_index < NBSLOPES_CK-1)
        $fwrite(File,", \\\n") ;
     else
        $fwrite(File,");\n") ;
   end
   $fwrite(File,"}\n") ;
   
   
   $fclose(File);
   fin_test = 1 ;
end
endmodule
