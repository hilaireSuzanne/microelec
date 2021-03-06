// On prend 1fs dans le timescale pour que les mesures de temps dans le domaine "numérique" soient précises.
// (à confirmer)
`timescale 1ns/1fs


module timing_study_tb;

// Paramètres du testbench
parameter real digital_tick    = 15          ;    // (ns) Temps entre deux transitions du signal d'entrée

// Les signaux logiques et électriques
logic  din0                ; // Signal logique destiné à piloter le test
logic  din1                ; // Signal logique destiné à piloter le test
bit    fin_test           ; // vaut 0 au débu de la simu
// Les variables adaptées ou mesurées exprimées sous forme de signaux réels. 
real capa_charge_val      ; // La valeur de la capacité de charge
real tt_val               ; // La valeur du temps de transition en entrée
real start_time           ; 
real stop_time            ;
real start_tran_time           ; 
real stop_tran_time            ;

// On instancie la maquette de test, en utilisant la connection générique pour simplifie l'écriture
timing_study_bd bd0  (
                          .din0(din0), 
                          .din1(din1), 
                          .tt_val(tt_val),
                          .capa_charge_val(capa_charge_val),
                          .start_time(start_time),
                          .stop_time(stop_time),
                          .start_tran_time(start_tran_time),
                          .stop_tran_time(stop_tran_time),
                          .fin_test(fin_test)
                          ) ;

// La liste des points de test à effectuer est déterminée par 2 tables de paramètres directement
// extraite du fichier Liberty de la bibliothèque NANGATE
localparam NBSLOPES = 7 ;
localparam NBCAPA   = 7 ;
localparam real rise_values[0:NBSLOPES-1] = '{0.00117378,0.00472397,0.0171859,0.0409838,0.0780596,0.130081,0.198535} ; // ns
localparam real capa_values[0:NBCAPA-1] = '{0.365616,7.553090,15.106200,30.212400,60.424700,120.849000,241.699000}; // fF
// Table pour récupérer le temps de propagation mesuré
real tab_prop_time_A1 [0:1] [0:NBSLOPES-1][0:NBCAPA-1] ;
real tab_prop_time_A2 [0:1] [0:NBSLOPES-1][0:NBCAPA-1] ;
real tab_trans_time_A1 [0:1] [0:NBSLOPES-1][0:NBCAPA-1] ;
real tab_trans_time_A2 [0:1] [0:NBSLOPES-1][0:NBCAPA-1] ;

///////////////////////////////////////////////////////////////
// Le testbench proprement dit défini dans le monde "logique".
///////////////////////////////////////////////////////////////

integer File ;
initial 
begin:simu
   int slope_index,capa_index, i ;
   real prop_time ;

   // On teste A1 : donc on met A2 à 1 pour avoir une monté en sortie   
   din0 = 0 ;
   din1 = 1 ;
    // Result for A1
   // Boucle principale sur la liste des pentes d'entrée
   for(slope_index=0;slope_index<NBSLOPES;slope_index++) 
   begin
     // Attention on change la valeur de la pente lorsque l'on est sur que rien ne bouge dans la partie analogique
     #(digital_tick) ; tt_val = rise_values[slope_index]*1.0e-9  ;
     // Boucle secondaire sur la liste des capa de charge
     for(capa_index=0;capa_index<NBCAPA;capa_index++) 
     begin
       // Attention on change la valeur de la capa de charge lorsque l'on est sur que rien ne bouge dans la partie analogique
       #(digital_tick) ; capa_charge_val = capa_values[capa_index]*1.0e-15  ;
       // On provoque une montée du signal de commande : donc du signal de sortie
       #(digital_tick) ; din0 = 1 ;
       // On récupère la mesure du temps de propagation (toujours en attendant que d'être dans une zone stable)
       #(digital_tick) ; tab_prop_time_A1[0][slope_index][capa_index] = (stop_time - start_time)/1.0e-9 ;
       #(digital_tick) ; tab_trans_time_A1[0][slope_index][capa_index] = (stop_tran_time - start_tran_time)/1.0e-9 ;
       // On provoque une descente du signal de commande
       #(digital_tick) ; din0 = 0 ;
       #(digital_tick) ; tab_prop_time_A1[1][slope_index][capa_index] = (stop_time - start_time)/1.0e-9 ;
       #(digital_tick) ; tab_trans_time_A1[1][slope_index][capa_index] = (stop_tran_time - start_tran_time)/1.0e-9 ;
     end
   end

   #(digital_tick);
   #(digital_tick);
   #(digital_tick);
   #(digital_tick);
   din0=1;
   din1=0;
   #(digital_tick);
   #(digital_tick);
   #(digital_tick);
   #(digital_tick);
  
   // result for A2 
   // Boucle principale sur la liste des pentes d'entrée
   for(slope_index=0;slope_index<NBSLOPES;slope_index++) 
   begin
     // Attention on change la valeur de la pente lorsque l'on est sur que rien ne bouge dans la partie analogique
     #(digital_tick) ; tt_val = rise_values[slope_index]*1.0e-9  ;
     // Boucle secondaire sur la liste des capa de charge
     for(capa_index=0;capa_index<NBCAPA;capa_index++) 
     begin
       // Attention on change la valeur de la capa de charge lorsque l'on est sur que rien ne bouge dans la partie analogique
       #(digital_tick) ; capa_charge_val = capa_values[capa_index]*1.0e-15  ;
       // On provoque une montée du signal de commande : donc du signal de sortie
       #(digital_tick) ; din1 = 1 ;
       // On récupère la mesure du temps de propagation (toujours en attendant que d'être dans une zone stable)
       #(digital_tick) ; tab_prop_time_A2[0][slope_index][capa_index] = (stop_time - start_time)/1.0e-9 ;
       #(digital_tick) ; tab_trans_time_A2[0][slope_index][capa_index] = (stop_tran_time - start_tran_time)/1.0e-9 ;
       // On provoque une descente du signal de commande
       #(digital_tick) ; din1 = 0 ;
       #(digital_tick) ; tab_prop_time_A2[1][slope_index][capa_index] = (stop_time - start_time)/1.0e-9 ;
       #(digital_tick) ; tab_trans_time_A2[1][slope_index][capa_index] = (stop_tran_time - start_tran_time)/1.0e-9 ;
     end
   end


   #(digital_tick);
   // On a récupéré tous les temps de propagation, il n'y a plus qu'à écrire dans un fichier 
   // les résultats de mesure. Ici on utilise le format du fichier "Liberty"
   #(digital_tick) ;
   // Ecriture des résultats
   // Création du fichier de résultats
   File = $fopen("AND2_X4_prop_time.dat") ;


   $fwrite(File,"timing() {\n\n") ;
   $fwrite(File,"related_pin        : \"A1\";\n") ;
   $fwrite(File,"timing_sense       : positive_unate; ;\n\n") ;
   $fwrite(File,"cell_rise(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_prop_time_A1[0][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \\\n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;
   
   $fwrite(File,"cell_fall(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_prop_time_A1[1][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \\\n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;
   
   $fwrite(File,"transition_rise(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_trans_time_A1[0][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \\\n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;
   
   $fwrite(File,"transistion_fall(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_trans_time_A1[1][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n") ;
   $fwrite(File,"};\n\n\n\n\n\n") ;
   
   $fwrite(File,"related_pin        : \"A2\";\n") ;
   $fwrite(File,"timing_sense       : positive_unate; ;\n\n") ;
   $fwrite(File,"cell_rise(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_prop_time_A2[0][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \\\n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;
   
   $fwrite(File,"cell_fall(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_prop_time_A2[1][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;
   
   $fwrite(File,"transition_rise(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_trans_time_A2[0][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \\\n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;
   
   $fwrite(File,"transistion_fall(Timing_7_7) {\n") ;
   $fwrite(File,"    index_1 (\"") ;
   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
    begin
        $fwrite(File,"%10.8f",rise_values[slope_index]) ;
       if(slope_index < NBSLOPES-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
    end

   $fwrite(File,"    index_2 (\"") ;
   for(capa_index=0;capa_index<NBCAPA;capa_index++)
   begin
        $fwrite(File,"%10.8f",capa_values[capa_index]) ;
       if(capa_index < NBCAPA-1)
           $fwrite(File,",") ;
       else
           $fwrite(File,"\");\n") ;
       end

   for(slope_index=0;slope_index<NBSLOPES;slope_index++)
   begin
        if(slope_index == 0) 
           $fwrite(File,"    values (\"") ;
        else
           $fwrite(File,"             ") ;
       for(capa_index=0;capa_index<NBCAPA;capa_index++)
       begin
       $fwrite(File,"%10.8f",tab_trans_time_A2[1][slope_index][capa_index]) ;
       if(capa_index < NBCAPA-1)
            $fwrite(File,",") ;
       else
            $fwrite(File,"\"") ;
       end
       if(slope_index < NBSLOPES-1)
           $fwrite(File,", \n") ;
       else
           $fwrite(File,");\n") ;
   end
   $fwrite(File,"};\n\n\n") ;

   $fwrite(File,"}\n") ;
   $fclose(File) ;
   fin_test = 1 ;
end
endmodule
