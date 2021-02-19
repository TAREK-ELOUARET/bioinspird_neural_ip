library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;



library neuronal;
--use neuronal.MATH_REAL.all;
use neuronal.float_pkg.all;
use neuronal.fixed_pkg.all;
use neuronal.fixed_float_types.all;

package package_type is

constant SIZE_WIDTH_T :natural := 16;

constant NUMBER_OF_ACTIVE_NEURONS_SIGNATURE : natural := 1; -- NUMBER OF MAXIMUM SELECTED NEURONS 
--constant    NBR_NEURON_T :natural := 50; -- 3000
--constant    NBR_PIXELS_T :natural := 2916; --2916 

--constant NUMBER_OF_NEURONS_SET_AZIMUTH :natural := 180; -- number of neurons in each Azimuth group !!
--constant NUMBER_OF_SIGNATURE_NEURONS :natural := 50; --3000
--constant NUMBER_OF_column_NEURONS :natural := 3;


constant NBR_NEURON_T :natural := 100; -- 3000
constant NBR_PIXELS_T :natural := 2916; --2916 

constant NUMBER_OF_NEURONS_SET_AZIMUTH :natural := 180; -- number of neurons in each Azimuth group !!
constant NUMBER_OF_SIGNATURE_NEURONS :natural := 100; --3000
constant NUMBER_OF_column_NEURONS :natural := 3;


--constant    NBR_NEURON_T :natural := 3000; -- 3000
--constant    NBR_PIXELS_T :natural := 2916; --2916 

--constant NUMBER_OF_NEURONS_SET_AZIMUTH :natural := 180; -- number of neurons in each Azimuth group !!
--constant NUMBER_OF_SIGNATURE_NEURONS :natural := 3000; --3000
--constant NUMBER_OF_column_NEURONS :natural := 3;


constant table_2D_to_1D_size :natural := (NUMBER_OF_SIGNATURE_NEURONS * NUMBER_OF_column_NEURONS);


type table is array(0 to NBR_NEURON_T -1) of sfixed(SIZE_WIDTH_T -1 downto -6);
type table_of_line_max_WTA is array(0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE -1) of sfixed(SIZE_WIDTH_T -1 downto -6);

type type_number_of_line_max_WTA is array(0 to NUMBER_OF_ACTIVE_NEURONS_SIGNATURE -1) of std_logic_vector(SIZE_WIDTH_T -1 downto 0);

type table_azimuth is array(0 to NUMBER_OF_column_NEURONS*NUMBER_OF_NEURONS_SET_AZIMUTH -1) of sfixed(SIZE_WIDTH_T -1 downto -6);
type weight_WTA is array(0 to NBR_NEURON_T -1, 0 to NBR_PIXELS_T -1) of sfixed(SIZE_WIDTH_T -1 downto -6); -- Type of weight connected to Pixels and WTA signature !!!

--type table_2D_to_1D is array(0 to table_2D_to_1D_size - 1) of sfixed(SIZE_WIDTH_T -1 downto -6);
type array_2D is array (0 to NUMBER_OF_SIGNATURE_NEURONS -1, 0 to NUMBER_OF_column_NEURONS -1) of sfixed(SIZE_WIDTH_T -1 downto -6);--no double??
type array_2D_azimuth_weight is array (0 to NUMBER_OF_SIGNATURE_NEURONS -1, 0 to NUMBER_OF_column_NEURONS * NUMBER_OF_NEURONS_SET_AZIMUTH -1) of sfixed(SIZE_WIDTH_T -1 downto -6);-- type of azimuth_weight_connection??
type std_logic_type is array (0 to NUMBER_OF_SIGNATURE_NEURONS -1, 0 to NUMBER_OF_column_NEURONS -1) of std_logic;--for weights SWM type??


type find_coordonate_type is array (0 to 1) of natural;--no double??

--alias TYPE_OF_SIGNAL: std_logic_vector(SIZE_WIDTH-1 downto 0) is std_logic_vector(SIZE_WIDTH-1 downto 0);

--function CALCULATION_NBR_CYCLES(nombre_neurons : integer )  return  integer;
--function ABS_FUNCTION(A : sfixed(SIZE_WIDTH_T - 1 downto -6))  return  sfixed;
function comparaison_function(A : sfixed(SIZE_WIDTH_T - 1 downto -6); B :     sfixed(SIZE_WIDTH_T - 1 downto -6)) return  sfixed;


function random_value return  sfixed;
function UNIFORM(SEED1,SEED2: POSITIVE) return sfixed;

end package_type;

package body package_type is
   
   
   
     function UNIFORM(SEED1,SEED2: POSITIVE) return sfixed
                                                                     is
    -- Description:
    --        See function declaration in IEEE Std 1076.2-1996
    -- Notes:
    --        a) Returns 0.0 on error
    --
    variable Z, K: INTEGER;
    variable TSEED1 : INTEGER := INTEGER'(SEED1);
    variable TSEED2 : INTEGER := INTEGER'(SEED2);
    
    variable X      :  sfixed(SIZE_WIDTH_T - 1 downto -6);

begin
    -- Check validity of arguments
    if SEED1 > 2147483562 then
            assert FALSE
                    report "SEED1 > 2147483562 in UNIFORM"
                    severity ERROR;
            X := (others => '0');
           -- return;
    end if;

    if SEED2 > 2147483398 then
            assert FALSE
                    report "SEED2 > 2147483398 in UNIFORM"
                    severity ERROR;
            X := (others => '0');
           -- return;
    end if;

    -- Compute new seed values and pseudo-random number
    K := TSEED1/53668;
    TSEED1 := 40014 * (TSEED1 - K * 53668) - K * 12211;

    if TSEED1 < 0  then
            TSEED1 := TSEED1 + 2147483563;
    end if;

    K := TSEED2/52774;
    TSEED2 := 40692 * (TSEED2 - K * 52774) - K * 3791;

    if TSEED2 < 0  then
            TSEED2 := TSEED2 + 2147483399;
    end if;

    Z := TSEED1 - TSEED2;
    if Z < 1 then
            Z := Z + 2147483562;
    end if;

    -- Get output values
    --SEED1 := POSITIVE'(TSEED1);
    --SEED2 := POSITIVE'(TSEED2);
    X :=  sfixed (to_signed(Z, X'length)) * to_sfixed(4.656613e-10, X'RIGHT, X'LEFT) ;
    return X;  
    
end function;

   function comparaison_function(A :     sfixed(SIZE_WIDTH_T - 1 downto -6); B :     sfixed(SIZE_WIDTH_T - 1 downto -6)
                      ) return  sfixed is 
    begin
    
        if (A >= B) then return A;
            else return B;
        end if;
    end function;


function random_value return  sfixed is  --------- Create a random_value for a max value of 0.001 !!
    variable seed1, seed2: positive;               -- seed values for random generator
    variable rand: real;   -- random real-number value in range 0 to 1.0
    variable rand_num :     sfixed(SIZE_WIDTH_T - 1 downto -6);
    variable range_of_rand : real := 0.001;    -- the range of random values created will be 0 to +1000.
begin
    --UNIFORM(seed1, seed2, rand);   -- generate random number
    rand_num := UNIFORM(seed1, seed2) * to_sfixed(range_of_rand, rand_num'RIGHT, rand_num'LEFT); -- rescale to 0..1000, convert integer part
    return rand_num;
  
end function;


end package_type;