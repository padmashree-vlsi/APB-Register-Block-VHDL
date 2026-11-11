----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2026 15:02:15
-- Design Name: 
-- Module Name: apb_slave_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity apb_slave_tb is
--  Port ( );
end apb_slave_tb;

architecture Behavioral of apb_slave_tb is
 -- Testbench signals
    signal PCLK    : STD_LOGIC := '0';
    signal PRESETn : STD_LOGIC := '0';

    signal PSEL    : STD_LOGIC := '0';
    signal PENABLE : STD_LOGIC := '0';
    signal PWRITE  : STD_LOGIC := '0';

    signal PADDR   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal PWDATA  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal PRDATA  : STD_LOGIC_VECTOR(31 downto 0);
    signal PREADY  : STD_LOGIC;
    signal PSLVERR : STD_LOGIC;
begin
-- Instantiate the APB slave
    DUT: entity work.apb_slave
        port map (
            PCLK    => PCLK,
            PRESETn => PRESETn,
            PSEL    => PSEL,
            PENABLE => PENABLE,
            PWRITE  => PWRITE,
            PADDR   => PADDR,
            PWDATA  => PWDATA,
            PRDATA  => PRDATA,
            PREADY  => PREADY,
            PSLVERR => PSLVERR
        );

    -- Generate 100 MHz clock
    PCLK <= not PCLK after 5 ns;

    -- Test stimulus
    stimulus: process
    begin

        -- Reset
        PRESETn <= '0';
        wait for 20 ns;
        PRESETn <= '1';
        wait for 10 ns;

        -- Write to register 0
        PSEL <= '1';
        PWRITE <= '1';
        PADDR <= x"00";
        PWDATA <= x"12345678";
        wait until rising_edge(PCLK);

        PENABLE <= '1';
        wait until rising_edge(PCLK);
        wait for 1 ns;

        PSEL <= '0';
        PENABLE <= '0';
        wait for 10 ns;
-- Write to register 1
PSEL <= '1';
PWRITE <= '1';
PADDR <= x"04";
PWDATA <= x"AAAAAAAA";
wait until rising_edge(PCLK);
PENABLE <= '1';
wait until rising_edge(PCLK);
wait for 1 ns;
PSEL <= '0';
PENABLE <= '0';
wait for 10 ns;

-- Write to register 2
PSEL <= '1';
PWRITE <= '1';
PADDR <= x"08";
PWDATA <= x"55555555";
wait until rising_edge(PCLK);
PENABLE <= '1';
wait until rising_edge(PCLK);
wait for 1 ns;
PSEL <= '0';
PENABLE <= '0';
wait for 10 ns;

-- Write to register 3
PSEL <= '1';
PWRITE <= '1';
PADDR <= x"0C";
PWDATA <= x"DEADBEEF";
wait until rising_edge(PCLK);
PENABLE <= '1';
wait until rising_edge(PCLK);
wait for 1 ns;
PSEL <= '0';
PENABLE <= '0';
wait for 10 ns;
-- Test idle read output
PSEL <= '0';
PENABLE <= '0';
PWRITE <= '0';
PADDR <= x"00";
wait for 1 ns;

assert PRDATA = x"00000000"
    report "PRDATA should be zero during idle!"
    severity error;
        -- Read register 0
        PSEL <= '1';
        PWRITE <= '0';
        PADDR <= x"00";
        wait for 1 ns;

        PENABLE <= '1';
        wait for 1 ns;

        assert PRDATA = x"12345678"
            report "Register 0 read failed!"
            severity error;

        assert PSLVERR = '0'
            report "Unexpected APB error!"
            severity error;

        assert PREADY = '1'
            report "PREADY is not high!"
            severity error;

        PSEL <= '0';
        PENABLE <= '0';
        wait for 10 ns;
-- Read register 1
PSEL <= '1';
PWRITE <= '0';
PADDR <= x"04";
PENABLE <= '0';
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;
assert PRDATA = x"AAAAAAAA"
    report "Register 1 read failed!" severity error;
PSEL <= '0';
PENABLE <= '0';
wait for 10 ns;

-- Read register 2
PSEL <= '1';
PADDR <= x"08";
PENABLE <= '0';
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;
assert PRDATA = x"55555555"
    report "Register 2 read failed!" severity error;
PSEL <= '0';
PENABLE <= '0';
wait for 10 ns;

-- Read register 3
PSEL <= '1';
PADDR <= x"0C";
PENABLE <= '0';
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;
assert PRDATA = x"DEADBEEF"
    report "Register 3 read failed!" severity error;
PSEL <= '0';
PENABLE <= '0';
wait for 10 ns;
        -- Test invalid address
        PSEL <= '1';
        PWRITE <= '0';
        PADDR <= x"10";
        PENABLE <= '0';
        wait for 1 ns;

        PENABLE <= '1';
        wait for 1 ns;

        assert PSLVERR = '1'
            report "Invalid address error test failed!"
            severity error;

        PSEL <= '0';
        PENABLE <= '0';
        -- Test invalid write address
PSEL <= '1';
PENABLE <= '0';
PWRITE <= '1';
PADDR <= x"10";
PWDATA <= x"FFFFFFFF";
wait for 1 ns;

PENABLE <= '1';
wait for 10 ns;

assert PSLVERR = '1'
    report "PSLVERR not asserted for invalid write!"
    severity error;

PSEL <= '0';
PENABLE <= '0';
PWRITE <= '0';
wait for 1 ns;
-- Verify invalid write did not corrupt register 0
PSEL <= '1';
PWRITE <= '0';
PADDR <= x"00";
PENABLE <= '0';
wait for 1 ns;

PENABLE <= '1';
wait for 1 ns;

assert PRDATA = x"12345678"
    report "Invalid write corrupted register 0!"
    severity error;

PSEL <= '0';
PENABLE <= '0';
wait for 1 ns;
-- Test reset functionality
PRESETn <= '0';
wait for 1 ns;
PRESETn <= '1';
wait for 1 ns;

-- Read register 0 after reset
PSEL <= '1';
PWRITE <= '0';
PADDR <= x"00";
PENABLE <= '0';
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;

assert PRDATA = x"00000000"
    report "Reset failed for register 0!"
    severity error;

-- Read register 1 after reset
PENABLE <= '0';
PADDR <= x"04";
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;

assert PRDATA = x"00000000"
    report "Reset failed for register 1!"
    severity error;

-- Read register 2 after reset
PENABLE <= '0';
PADDR <= x"08";
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;

assert PRDATA = x"00000000"
    report "Reset failed for register 2!"
    severity error;

-- Read register 3 after reset
PENABLE <= '0';
PADDR <= x"0C";
wait for 1 ns;
PENABLE <= '1';
wait for 1 ns;

assert PRDATA = x"00000000"
    report "Reset failed for register 3!"
    severity error;

PSEL <= '0';
PENABLE <= '0';
wait for 1 ns;

-- Check register 0
PADDR <= x"00";
wait for 1 ns;
assert PRDATA = x"00000000"
    report "Register 0 reset failed!" severity error;

-- Check register 1
PADDR <= x"04";
wait for 1 ns;
assert PRDATA = x"00000000"
    report "Register 1 reset failed!" severity error;

-- Check register 2
PADDR <= x"08";
wait for 1 ns;
assert PRDATA = x"00000000"
    report "Register 2 reset failed!" severity error;

-- Check register 3
PADDR <= x"0C";
wait for 1 ns;
assert PRDATA = x"00000000"
    report "Register 3 reset failed!" severity error;

PRESETn <= '1';
wait for 1 ns;
        report "APB basic tests completed!" severity note;

        wait;
    end process;

end Behavioral;
