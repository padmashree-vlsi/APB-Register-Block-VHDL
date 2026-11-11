----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 14:39:55
-- Design Name: 
-- Module Name: apb_slave - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity apb_slave is
 Port (-- Clock and reset
        PCLK    : in  STD_LOGIC;
        PRESETn : in  STD_LOGIC;

        -- APB control signals
        PSEL    : in  STD_LOGIC;
        PENABLE : in  STD_LOGIC;
        PWRITE  : in  STD_LOGIC;

        -- APB address and data
        PADDR   : in  STD_LOGIC_VECTOR(7 downto 0);
        PWDATA  : in  STD_LOGIC_VECTOR(31 downto 0);

        -- APB output signals
        PRDATA  : out STD_LOGIC_VECTOR(31 downto 0);
        PREADY  : out STD_LOGIC;
        PSLVERR : out STD_LOGIC
     );
end apb_slave;

architecture Behavioral of apb_slave is
    signal reg0 : STD_LOGIC_VECTOR(31 downto 0);
    signal reg1 : STD_LOGIC_VECTOR(31 downto 0);
    signal reg2 : STD_LOGIC_VECTOR(31 downto 0);
    signal reg3 : STD_LOGIC_VECTOR(31 downto 0);
begin
        -- APB write operation
    process(PCLK, PRESETn)
    begin
        if PRESETn = '0' then
            reg0 <= (others => '0');
            reg1 <= (others => '0');
            reg2 <= (others => '0');
            reg3 <= (others => '0');

        elsif rising_edge(PCLK) then

            if PSEL = '1' and PENABLE = '1' and PWRITE = '1' then

                case PADDR is

                    when x"00" =>
                        reg0 <= PWDATA;

                    when x"04" =>
                        reg1 <= PWDATA;

                    when x"08" =>
                        reg2 <= PWDATA;

                    when x"0C" =>
                        reg3 <= PWDATA;

                    when others =>
                        null;

                end case;

            end if;
        end if;
    end process;
    -- APB read operation
process(PADDR, PSEL, PENABLE, PWRITE, reg0, reg1, reg2, reg3)
begin
    PRDATA <= (others => '0');

    if PSEL = '1' and PENABLE = '1' and PWRITE = '0' then
        case PADDR is
            when x"00" => PRDATA <= reg0;
            when x"04" => PRDATA <= reg1;
            when x"08" => PRDATA <= reg2;
            when x"0C" => PRDATA <= reg3;
            when others => PRDATA <= (others => '0');
        end case;
    end if;
end process;
        -- APB ready signal
    PREADY <= '1';

        -- APB error signal
    process(PADDR, PSEL, PENABLE, PWRITE)
    begin
        PSLVERR <= '0';

        if PSEL = '1' and PENABLE = '1' then
            if (PADDR /= x"00") and
               (PADDR /= x"04") and
               (PADDR /= x"08") and
               (PADDR /= x"0C") then

                PSLVERR <= '1';
            end if;
        end if;
    end process;

end Behavioral;
