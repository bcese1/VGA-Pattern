library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
--use ieee.std_logic_arith.all;

entity vgatest is
   port (
      CLK100MHZ, reset: in std_logic;
--      sw: in std_logic_vector(2 downto 0); --only needed if you want to test the vga. the switch will be the color to show
      hsync, vsync: out  std_logic;  --output for vga
      redout,greenout,blueout: out std_logic_vector(3 downto 0) --output for vga
   );
end vgatest;

architecture arch of vgatest is

   signal rgb_reg, rgb: std_logic_vector(2 downto 0);
   signal video_on: std_logic;
   signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
   
   constant cblue : std_logic_vector(2 downto 0) := "001";
   constant cgreen : std_logic_vector(2 downto 0) := "010";
   constant cred : std_logic_vector(2 downto 0) := "100";
   constant cblack : std_logic_vector(2 downto 0) := "000";
   constant ccyan : std_logic_vector(2 downto 0) := "011";
   constant cmagenta : std_logic_vector(2 downto 0) := "101";
   constant cyellow : std_logic_vector(2 downto 0) := "110";
   constant cwhite : std_logic_vector(2 downto 0) := "111";
   type tile_map is array(0 to 1199) of std_logic_vector(2 downto 0);
   signal mapindex : unsigned(19 downto 0);
   signal pixel_x_convert, pixel_y_convert : std_logic_vector(9 downto 0);
   signal tile_row, tile_col : std_logic_vector(9 downto 0);
   signal color : std_logic_vector(2 downto 0);
   

   component vgatimehelper
     port (
       clk, reset       : in std_logic;
       hsync, vsync     : out std_logic;
       video_on, p_tick : out std_logic;
       pixel_x, pixel_y : out std_logic_vector(9 downto 0));
   end component;

	--you add here
	signal clk50mhz : std_logic;
	
	--add your tile map here
    signal grid_map : tile_map := (cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cblue,cgreen,cred,cblack,ccyan,cmagenta,cyellow,cwhite
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
,cwhite,cyellow,cmagenta,ccyan,cblack,cred,cgreen,cblue
);
begin

    mapindex <= unsigned(tile_col) * 40 + unsigned(tile_row);
--    mapindex <= std_logic_vector(resize(unsigned(tile_row) * 40 + unsigned(tile_col),  mapindex'length));


 
  -- instantiate VGA sync circuit 
   vga_unit: vgatimehelper
      port map(clk=>clk50mhz, reset=>reset, hsync=>hsync,
               vsync=>vsync, video_on=>video_on,
               p_tick=>open, pixel_x=>pixel_x, pixel_y=>pixel_y);

   --You need to make a 50mhk clock divider and set to signal clk50mhz
   clk_div : process(CLK100MHZ, reset)
   begin
      if reset = '1' then
        clk50mhz <= '0';
      elsif CLK100MHZ'event and CLK100MHZ = '1' then
        clk50mhz <= not clk50mhz;
      end if;
   end process clk_div;       
   
   --you need to find the downconvert new pixel x and y
   pixel_x_convert <= std_logic_vector(unsigned(pixel_x) / 2);
   pixel_y_convert <= std_logic_vector(unsigned(pixel_y) / 2);
   --using you new pixel x and y you need to find the tile row and col
   tile_col <= std_logic_vector(unsigned(pixel_y_convert) / 8);
   tile_row <= std_logic_vector(unsigned(pixel_x_convert) / 8);  
   --using the tile row and col access the array to read the color
   color <= grid_map(to_integer(unsigned(mapindex)));
   -- rgb buffer
   process (CLK100MHZ,reset)
   begin
      if reset='1' then
         rgb_reg <= (others=>'0');
      elsif (CLK100MHZ'event and CLK100MHZ='1') then
         rgb_reg <= color; --change this to the color from your tile map
      end if;
   end process;

   rgb <= rgb_reg when video_on='1' else "000";
   redout(0) <= rgb(2);
   redout(1) <= rgb(2);
   redout(2) <= rgb(2);
   redout(3) <= rgb(2);
   greenout(0) <= rgb(1);
   greenout(1) <= rgb(1);
   greenout(2) <= rgb(1);
   greenout(3) <= rgb(1);
   blueout(0) <= rgb(0);
   blueout(1) <= rgb(0);
   blueout(2) <= rgb(0);
   blueout(3) <= rgb(0);
   
end arch;

--## Pmod Header JC
--set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { redout[0] }]; #IO_L18P_T2_A12_D28_14 Sch=jc1/ck_io[41]
--set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { redout[1] }]; #IO_L18N_T2_A11_D27_14 Sch=jc2/ck_io[40]
--set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { redout[2] }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=jc3/ck_io[39]
--set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { redout[3] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=jc4/ck_io[38]
--set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { blueout[0] }]; #IO_L16P_T2_CSI_B_14 Sch=jc7/ck_io[37]
--set_property -dict { PACKAGE_PIN P13   IOSTANDARD LVCMOS33 } [get_ports { blueout[1] }]; #IO_L19P_T3_A10_D26_14 Sch=jc8/ck_io[36]
--set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { blueout[2] }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=jc9/ck_io[35]
--set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { blueout[3] }]; #IO_L20P_T3_A08_D24_14 Sch=jc10/ck_io[34]

--## Pmod Header JD
--set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { greenout[0] }]; #IO_L20N_T3_A07_D23_14 Sch=jd1/ck_io[33]
--set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { greenout[1] }]; #IO_L21P_T3_DQS_14 Sch=jd2/ck_io[32]
--set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { greenout[2] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=jd3/ck_io[31]
--set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { greenout[3] }]; #IO_L22P_T3_A05_D21_14 Sch=jd4/ck_io[30]
--set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { hsync }]; #IO_L22N_T3_A04_D20_14 Sch=jd7/ck_io[29]
--set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { vsync }]; #IO_L23P_T3_A03_D19_14 Sch=jd8/ck_io[28]
--#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { jd[6] }]; #IO_L23N_T3_A02_D18_14 Sch=jd9/ck_io[27]
--#set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { jd[7] }]; #IO_L24P_T3_A01_D17_14 Sch=jd10/ck_io[26]
