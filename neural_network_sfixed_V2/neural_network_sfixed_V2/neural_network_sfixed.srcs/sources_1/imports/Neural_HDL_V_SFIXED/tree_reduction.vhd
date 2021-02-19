library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library neuronal;
use neuronal.package_type.all;

use neuronal.float_pkg.all;
use neuronal.fixed_pkg.all;
use neuronal.fixed_float_types.all;


entity tree_reduction is
  generic (
	SIZE_WIDTH :natural := SIZE_WIDTH_T;
  	NBR_NEURON :natural := NBR_NEURON_T;
  	NBR_PIXELS :natural := NBR_PIXELS_T 
  );
  port (
	clk 		             : in std_logic;
	reset                    : in std_logic;
  	flag                     : in std_logic;
  	mux_table_input          : in table;
  	flag_signature           : out std_logic;
  	number_of_line_max_WTA   : out type_number_of_line_max_WTA;
  	mux_table_output         : out table
  	);
end entity tree_reduction;

architecture treeFunction of tree_reduction is
    shared variable flag_t : std_logic;
    shared variable flag_signature_t : std_logic; 
    shared variable mux_table_t : table;
    shared variable number_of_line_max_WTA_t : type_number_of_line_max_WTA := (others => (others => '1'));
    
begin
    --flag <= flag_t;
    
    tree_reduction : process (mux_table_input, flag)
        variable active_neuron_variable : natural := 0;
        variable number_of_ligne  : natural;
        variable cnt : natural := 0;
        
        variable temp:      sfixed (SIZE_WIDTH_T -1 downto -6);
         
       begin
                   
       if flag = '1' then             
            flag_signature_t := '0'; 
            mux_table_t := mux_table_input;   
          
       for i in 0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE - 1 loop
            temp := (others => '0');     
            for j in table'LEFT to table'RIGHT - 1 loop 
                   if mux_table_t(j) >= temp then 
                        --cnt := 0;
                        for l in 0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE - 1 loop
                            if j /= number_of_line_max_WTA_t(l) and l = active_neuron_variable then
                                temp := mux_table_t(j);
                                number_of_ligne := j;
                                exit;
                            elsif j /= number_of_line_max_WTA_t(l) then 
                                cnt := 1; -- just to continue swapping the loop 
                            else 
                                exit;
                            end if;
                        end loop;
                   end if;             
            end loop;
            active_neuron_variable := active_neuron_variable +1;
            number_of_line_max_WTA_t(i) := std_logic_vector(to_unsigned(number_of_ligne, number_of_line_max_WTA_t(i)'length));
        end loop;
        
        flag_signature_t := '1'; 
        mux_table_output <= mux_table_t;
        number_of_line_max_WTA <= number_of_line_max_WTA_t;
        flag_signature <= flag_signature_t;  
        
        else       
        
            flag_signature_t := '0'; 
            mux_table_output <= mux_table_t;
            number_of_line_max_WTA <= number_of_line_max_WTA_t;
            flag_signature <= flag_signature_t;
        end if;
    end process tree_reduction;
    


end treeFunction;