-- Written BY TAREK ELOUARET, ETIS LABORATORY, UNIVERSITY OF CERGY-PARIS CY
-- COPYWRITE WELL SAVED

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library neuronal;
use neuronal.package_type.all;

use neuronal.float_pkg.all;
use neuronal.fixed_pkg.all;
use neuronal.fixed_float_types.all;

entity spatial_working_memory is
  port (
	clk 		           : in std_logic;
  	flag_signature         : in std_logic; -- means that the signature tree has well been sorted
  	flag_learning          : in std_logic; -- means the signature_weights are invited to learn and adjust their values
  	flag_reset_image       : in std_logic; -- means that the signature tree has well been sorted
  	
  	signature_neurons      : in table_of_line_max_WTA;
  	number_of_line_max_WTA : in type_number_of_line_max_WTA;
    	
  	azimuth_neurons        : in table_azimuth;
  	azimuth_weight         : in array_2D_azimuth_weight; -- connected with Azimuth set of groups and fixed as 0.001
  
    signature_weight_coordonate       : out find_coordonate_type -- connected with of SWM !!

  	--SWM_neurons 		   : out array_2D
  	);
end entity spatial_working_memory;

architecture neuronFunction of spatial_working_memory is
  signal flag_t_vector     : std_logic_vector(SIZE_WIDTH_T -1 downto 0) := (others => '0'); 
  --signal flag_SWM : std_logic:= '0';
  -- Calculate the absoluate value between two signals
  shared variable SWM_neurons_t 		   : array_2D := (others =>(others => (others => '0')));
  --signal SWM_neurons_weight 	   : std_logic_type; --connection with just one dimension which is signature, later we change it to 2Dimension to mark each weight with its neurons group!!!!
  shared variable SWM_neurons_flag_learning : std_logic_type := (others => (others => '0'));
  shared variable signature_weight_t       : array_2D := (others =>(others => random_value));
    
  shared variable number_of_line_max_WTA_t   : integer;
  
   function activate_function(Azimuth_neuron :     sfixed(SIZE_WIDTH_T -1 downto -6) -- calculation of maximum (Aj(t) * Wj,il(t))
                    ) return  sfixed is 
                    variable temp : sfixed(SIZE_WIDTH_T -1 downto -6);

      begin
            if Azimuth_neuron > 1 then 
                temp := "0000000000000001000000";   
            elsif  Azimuth_neuron < 0 then 
                temp := (others =>'0'); 
            else  temp := Azimuth_neuron;
                  
            end if;

      return temp;

  end function;
  
    function maximum_set_azimuth(Azimuth_neuron :     table_azimuth; l : natural -- calculation of maximum (Aj(t) * Wj,il(t))
                      ) return  sfixed is 
                      variable temp : sfixed(SIZE_WIDTH_T -1 downto -6);

        begin
            temp := Azimuth_neuron (l);
                      
            for j in l to l+NUMBER_OF_NEURONS_SET_AZIMUTH -1 loop 
                    if Azimuth_neuron (j) >= temp then 
                        temp := Azimuth_neuron (j);
                    end if;               
            end loop;
 
        return temp;
    end function;
   
   
       function maximum_set_SWM(SWM_neurons_t :     array_2D; SWM_neurons_flag_learning: std_logic_type; i_lignes: type_number_of_line_max_WTA -- calculation of maximum neuron value to get updated its weight connection! --- SECOND VERSION OF MAXIMUM CALCULATION 
                  ) return  sfixed is 
                  variable temp : sfixed(SIZE_WIDTH_T -1 downto -6); 
        begin
            temp := (others => '0');
      
            for i in 0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE - 1 loop 
                for j in 0 to NUMBER_OF_column_NEURONS - 1 loop
                     if SWM_neurons_t (to_integer(unsigned(i_lignes(i))),j) >= temp and SWM_neurons_flag_learning (to_integer(unsigned(i_lignes(i))),j) /= '1' then 
                        temp := SWM_neurons_t (to_integer(unsigned(i_lignes(i))),j);
                     end if; 
                end loop;
            end loop;
      
        return temp;
    end function;


     function find_coordonate(Maximum_neuron :     sfixed(SIZE_WIDTH_T -1 downto -6); SWM_neurons_t_t :array_2D; SWM_neurons_flag_learning: std_logic_type; i_lignes: type_number_of_line_max_WTA -- Extract I,J coordoonate to update their flag_signal !!
                     ) return  find_coordonate_type is 

                     variable return_values : find_coordonate_type;
       begin
          
            for i in 0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE - 1 loop 
                for j in 0 to NUMBER_OF_column_NEURONS - 1 loop 
                
                    if Maximum_neuron = SWM_neurons_t_t(to_integer(unsigned(i_lignes(i))),j) and SWM_neurons_flag_learning (to_integer(unsigned(i_lignes(i))),j) /= '1' then -- find the coordonate I,J though the maximium curent neuron and its flag_learning value !!!!
                        return_values (0) := to_integer(unsigned(i_lignes(i))); return_values (1) := j;
                        exit;
                    end if;
                end loop;
            end loop;
       
       return return_values;
  end function;
   
   
begin
  
	--signature_weight <= signature_weight_t; 
	--SWM_neurons <= SWM_neurons_t;
	
	SWM:process (clk, flag_signature, flag_learning, flag_reset_image)
	variable Azimuth_neuron_t :     table_azimuth;
	variable l :     natural;
	variable Maximum_learning_value: sfixed(SIZE_WIDTH_T -1 downto -6);
   -- variable find_coordonate_t: find_coordonate_type;
    variable i,j : natural;
	variable flag_SWM : std_logic := '0';

	begin 
	
	if rising_edge(clk) then 
	
        if flag_reset_image = '1' then --- else if pour plus tard !! !!!!!!!!
            SWM_neurons_flag_learning  := (others => (others => '0'));
            SWM_neurons_t              := (others =>(others => (others => '0')));
            
       end if; 
	   if flag_signature = '1' then
            --if rising_edge(clk) then 
            if flag_learning = '1' then  -- There will be a learning phase, and we deal just with the first maximum lines of WTA (signature) !
		          for i in 0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE - 1 loop 
		                l := 0;
                        for j in 0 to NUMBER_OF_column_NEURONS -1 loop
                            
                            for k in l to l+NUMBER_OF_NEURONS_SET_AZIMUTH -1 loop
                                Azimuth_neuron_t(k) := azimuth_neurons(k) * azimuth_weight(to_integer(unsigned(number_of_line_max_WTA(i))),k);
                            end loop;
                                                
		                    SWM_neurons_t(to_integer(unsigned(number_of_line_max_WTA(i))),j) := activate_function((signature_neurons(i) * signature_weight_t(to_integer(unsigned(number_of_line_max_WTA(i))),j)) * (maximum_set_azimuth(Azimuth_neuron_t, l)));	                    
		                    l := l+3;
		                end loop;
		          end loop;
		          flag_SWM := '1';
		          
		      else -- -- There will be not a learning phase , and we deal just with one line of WTA (signature)!!!
		      
                    --for i in 0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE - 1 loop 
                            l := 0;
                            for j in 0 to NUMBER_OF_column_NEURONS -1 loop
                                          
                                          for k in l to l+NUMBER_OF_NEURONS_SET_AZIMUTH -1 loop
                                              Azimuth_neuron_t(k) := azimuth_neurons(k) * azimuth_weight(to_integer(unsigned(number_of_line_max_WTA(0))),k);
                                          end loop;
                                                              
                                          SWM_neurons_t(to_integer(unsigned(number_of_line_max_WTA(0))),j) := activate_function(SWM_neurons_t(to_integer(unsigned(number_of_line_max_WTA(0))),j) + (signature_neurons(0) * signature_weight_t(to_integer(unsigned(number_of_line_max_WTA(0))),j)) * (maximum_set_azimuth(Azimuth_neuron_t, l)));                        
                                          l := l+3;
                            end loop;
                    --end loop;
                    flag_SWM := '1';
		      end if;
	    --end if;
		    
            if flag_learning = '1' and flag_SWM = '1' then
                                   --if rising_edge(clk) then 
                                        --
                                        --Maximum_learning_value := maximum_set_SWM(linearize_2D_array(SWM_neurons_t), SWM_neurons_flag_learning); -- CHOOSE THE MAXIMUM VALUE FROM NEURONS TO be UPDATE & LEARN -- FIRST VERSION 
                                        Maximum_learning_value := maximum_set_SWM(SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA); -- CHOOSE THE MAXIMUM VALUE FROM NEURONS TO be UPDATE & LEARN -- SECOND VERSION 

                            
                                        -- UPDATE NOW THE WEIGHT OF THE SELECTED NEURON WITH MAXIMUM VALUE!  
                                        -- UPDATE the signal weight flag of neurons to not compete in the next itteration while reset = 0 for same image!!  
                                        signature_weight_t(find_coordonate(Maximum_learning_value, SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA)(0), find_coordonate(Maximum_learning_value, SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA)(1)) := "0000000000000001000000";--Through coordonate i and J, we update the weight of the selected competeor neuron!!
                                        SWM_neurons_flag_learning (find_coordonate(Maximum_learning_value, SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA)(0), find_coordonate(Maximum_learning_value, SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA)(1)) := '1'; -- flag_signal as reference of weight update completion for current image, we should reset it just after getting a new image!!!!
                                        signature_weight_coordonate (0) <= find_coordonate(Maximum_learning_value, SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA)(0); 
                                        signature_weight_coordonate (1) <= find_coordonate(Maximum_learning_value, SWM_neurons_t, SWM_neurons_flag_learning, number_of_line_max_WTA)(1);
                                        flag_SWM := '0'; -- to reset flag_swm_calculation for next itteration!!
                                   --end if;
            end if;
        end if;
	 end if;
	end process SWM; 
end neuronFunction;