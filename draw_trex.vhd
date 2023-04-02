library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_arith.ALL;

entity draw_trex is
	generic(
		H_counter_size: natural:= 10;
		V_counter_size: natural:= 10
	);
	port(
		clk: in std_logic;
		jump: in std_logic;
		down: in std_logic;
		reset: in std_logic;
		start: in std_logic;
		pixel_x: in integer;
		pixel_y: in integer;
		rgbDrawColor: out std_logic_vector(11 downto 0) := (others => '0')
	);
end draw_trex;

architecture arch of draw_trex is
	constant PIX : integer := 16;
	constant COLS : integer := 40;
	constant T_FAC : integer := 100000;
	constant cactusSpeed1 : integer := 40;
	constant cactusSpeed2 : integer := 50;
	constant nubeSpeed1 : integer := 35;
	constant nubeSpeed2 : integer := 30;
	constant nubeSpeed3 : integer := 25;
	constant nubeSpeed4 : integer := 20;

	-- Nubes
	signal cloudX_1: integer := COLS;
	signal cloudY_1: integer := 10;
	
	signal cloudX_2: integer := COLS;
	signal cloudY_2: integer := 15;
	
	signal cloudX_3: integer := COLS;
	signal cloudY_3: integer := 20;
	
	signal cloudX_4: integer := COLS;
	signal cloudY_4: integer := 25;
	
	-- T-Rex
	signal trexX: integer := 8;
	signal trexY: integer := 24;
	signal saltando: std_logic := '0';	
	signal agachado: std_logic := '0';	
	
	-- Cactus	
	signal cactusX_1: integer := COLS;
	signal cactusX_2: integer := COLS;
	signal cactusY: integer := 24;
	
	signal gameover: std_logic := '0';
	
-- Sprites
type sprite_block is array(0 to 15, 0 to 15) of integer range 0 to 1;
constant cloud1: sprite_block:=(  
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
									 (0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 8
									 (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 9
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 10
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15

constant cloud2: sprite_block:=(  
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 4
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 5
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 6
									 (0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0), -- 7
									 (0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 8
									 (0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 9
									 (0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 10
									 (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), -- 11
									 (0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0), -- 12
		 							 (0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));-- 15
									 
constant trex_1: sprite_block:=(
									(0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									(0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 1 
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 2
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0));-- 15	

constant trex_2: sprite_block:=(
									(0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 0 
									(0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 1 
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 2
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 3
									(0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0), -- 5
									(0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0), -- 6
									(1,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,0,0,1,0,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15
	
constant trex_3: sprite_block:=(
									(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 0 
									(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 1 
									(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0), -- 2
									(0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0), -- 3 
									(0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1), -- 4
									(0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1), -- 5
									(0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1), -- 6
									(0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0), -- 7
									(1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,0), -- 8
									(1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0), -- 9
									(0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 10
									(0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0), -- 11
									(0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0), -- 12
		 							(0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0), -- 13
									(0,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0), -- 14
									(0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0));-- 15	

constant cactus1: sprite_block :=(
									 (0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0), -- 0 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 1 
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 2
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 3
									 (0,0,0,0,0,1,0,1,1,1,0,1,0,0,0,0), -- 4
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 5
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 6
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 7
									 (0,0,0,0,1,1,0,1,1,1,0,1,0,0,0,0), -- 8
									 (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0), -- 9
									 (0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0), -- 10
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 11
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 12
		 							 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 13
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0), -- 14
									 (0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0));-- 15									
									 
constant GA: sprite_block :=(
									 (0,1,1,1,1,1,1,0,0,0,1,1,1,1,1,0), -- 0 
									 (1,1,1,1,1,1,1,0,0,0,1,1,0,1,1,0), -- 1 
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 2
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 3
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 4
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 5
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 6
									 (1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1), -- 7
									 (1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1), -- 8
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 9
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 10
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 11
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 12
		 							 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 13
									 (1,1,1,1,1,1,1,0,0,1,1,0,0,0,1,1), -- 14
									 (0,1,1,1,1,1,0,0,0,1,1,0,0,0,1,1));-- 15									
									 
constant ME: sprite_block :=(
									 (1,1,0,0,0,1,1,0,0,1,1,1,1,1,1,1), -- 0 
									 (1,1,1,0,1,1,1,0,0,1,1,1,1,1,1,1), -- 1 
									 (1,1,1,0,1,1,1,0,0,1,1,0,0,0,0,0), -- 2
									 (1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0), -- 3
									 (1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0), -- 4
									 (1,1,0,1,0,1,1,0,0,1,1,0,0,0,0,0), -- 5
									 (1,1,0,1,0,1,1,0,0,1,1,0,0,0,0,0), -- 6
									 (1,1,0,0,0,1,1,0,0,1,1,1,1,1,1,1), -- 7
									 (1,1,0,0,0,1,1,0,0,1,1,1,1,1,1,1), -- 8
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,0,0), -- 9
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,0,0), -- 10
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,0,0), -- 11
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,0,0), -- 12
		 							 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,0,0), -- 13
									 (1,1,0,0,0,1,1,0,0,1,1,1,1,1,1,1), -- 14
									 (1,1,0,0,0,1,1,0,0,1,1,1,1,1,1,1));-- 15	

constant OV: sprite_block :=(
									 (0,1,1,1,1,1,0,0,0,1,1,0,0,0,1,1), -- 0 
									 (1,1,1,1,1,1,1,0,0,1,1,0,0,0,1,1), -- 1 
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 2
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 3
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 4
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 5
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 6
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 7
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 8
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 9
									 (1,1,0,0,0,1,1,0,0,1,1,0,0,0,1,1), -- 10
									 (1,1,0,0,0,1,1,0,0,1,1,1,0,1,1,1), -- 11
									 (1,1,0,0,0,1,1,0,0,0,1,1,0,1,1,0), -- 12
		 							 (1,1,0,0,0,1,1,0,0,0,1,1,1,1,1,0), -- 13
									 (1,1,1,1,1,1,1,0,0,0,0,1,1,1,0,0), -- 14
									 (0,1,1,1,1,1,0,0,0,0,0,1,1,1,0,0));-- 15	

constant ER: sprite_block :=(
									 (1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1), -- 0 
									 (1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0), -- 1 
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 2
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 3
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 4
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,1,1,1), -- 5
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,1,1,0), -- 6
									 (1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0), -- 7
									 (1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0), -- 8
									 (1,1,0,0,0,0,0,0,0,1,1,0,1,1,1,0), -- 9
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,1,1,0), -- 10
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,1,1,1), -- 11
									 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 12
		 							 (1,1,0,0,0,0,0,0,0,1,1,0,0,0,1,1), -- 13
									 (1,1,1,1,1,1,1,0,0,1,1,0,0,0,1,1), -- 14
									 (1,1,1,1,1,1,1,0,0,1,1,0,0,0,1,1));-- 15	


type color_arr is array(0 to 1) of std_logic_vector(11 downto 0);		

constant sprite_color_green 	: color_arr := ("010111001111", "000011110000");
constant sprite_color_blanco	: color_arr := ("010111001111", "111111111111");
constant sprite_color_blue 	: color_arr := ("010111001111", "000000001111");
constant sprite_color_black	: color_arr := ("010111001111", "000000000000");

begin
	draw_objects: process(clk, pixel_x, pixel_y)	
	
	variable sprite_x : integer := 0;
	variable sprite_y : integer := 0;
	
	begin			
		if(clk'event and clk='1') then		
			-- Dibuja el fondo
			rgbDrawColor <= "0110" & "1100" & "1111";
					
			-- Dibuja el suelo
			if(pixel_y = 400 or pixel_y = 401) then
				rgbDrawColor <= "1111" & "1111" & "1111";		
			end if;
			if(pixel_y >= 401 and pixel_y <= 480) then
				rgbDrawColor <= "1101" & "1010" & "0110";		
			end if;
			
			sprite_x := pixel_x mod PIX;
			sprite_y := pixel_y mod PIX;
							
			-- Nube 1
			if ((pixel_x / PIX = cloudX_1) and (pixel_y / PIX = 1)) then 
				rgbDrawColor <= sprite_color_blanco(cloud1(sprite_y, sprite_x));
			end if;	

			-- Nube 2
			if ((pixel_x / PIX = cloudX_2) and (pixel_y / PIX = 2)) then 
				rgbDrawColor <= sprite_color_blanco(cloud2(sprite_y, sprite_x));
			end if;
	
			-- Nube 3
			if ((pixel_x / PIX = cloudX_3) and (pixel_y / PIX = 3)) then 
				rgbDrawColor <= sprite_color_blanco(cloud1(sprite_y, sprite_x));
			end if;	

			-- Nube 4
			if ((pixel_x / PIX = cloudX_4) and (pixel_y / PIX = 4)) then 
				rgbDrawColor <= sprite_color_blanco(cloud2(sprite_y, sprite_x));
			end if;	
			
			if (gameover ='0') then
				-- Cactus1
				if ((pixel_x / PIX = cactusX_1) and (pixel_y / PIX = cactusY)) then 
					rgbDrawColor <= sprite_color_green(cactus1(sprite_y, sprite_x));
				end if;				
				if ((pixel_x / PIX = cactusX_2) and (pixel_y / PIX = cactusY)) then 
					rgbDrawColor <= sprite_color_green(cactus1(sprite_y, sprite_x));
				end if;
				
				-- T-Rex
				if (saltando = '1') then
					if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
						rgbDrawColor <= sprite_color_green(trex_2(sprite_y, sprite_x));			
					end if;
				else
					if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
						rgbDrawColor <= sprite_color_green(trex_1(sprite_y, sprite_x));			
					end if;
				end if;
				
				if (agachado = '1') then
					if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
						rgbDrawColor <= sprite_color_green(trex_3(sprite_y, sprite_x));			
					end if;
				else
					if	((pixel_x / PIX = trexX) and (pixel_y / PIX = trexY)) then
						rgbDrawColor <= sprite_color_green(trex_1(sprite_y, sprite_x));			
					end if;
				end if;
			else
				if((pixel_x/PIX=18) and (pixel_y/PIX=10))then
				rgbDrawColor <= sprite_color_black(ga(sprite_y, sprite_x));	
				end if;
				if((pixel_x/PIX=19) and (pixel_y/PIX=10))then
				rgbDrawColor <= sprite_color_black(me(sprite_y, sprite_x));	
				end if;
				if((pixel_x/PIX=21) and (pixel_y/PIX=10))then
				rgbDrawColor <= sprite_color_black(ov(sprite_y, sprite_x));	
				end if;
				if((pixel_x/PIX=22) and (pixel_y/PIX=10))then
				rgbDrawColor <= sprite_color_black(er(sprite_y, sprite_x));	
				end if;
			end if;
		end if;
	end process;
	
	actions: process(clk, jump, down)	
	variable cactusCount1: integer := 0;
	variable cactusCount2: integer := 0;
	variable nubeCount1: integer := 0;
	variable nubeCount2: integer := 0;
	variable nubeCount3: integer := 0;
	variable nubeCount4: integer := 0;
	begin		
			if(clk'event and clk = '1') then
			-- Salto
			if(jump = '1') then
				saltando <= '1';
				if (trexY > 20) then
					trexY <= trexY - 1;
				else
					saltando <= '0';
				end if;
			else
			   saltando <= '0';
				if (trexY < 24) then
					trexY <= trexY + 1;
				end if;
			end if;		
			
			--Agachado
			if(down = '1') then
				agachado <= '1';
			else
			   agachado <= '0';
			end if;
			
			-- Movimiento de Nubes
			if (nubeCount1 >= T_FAC * nubeSpeed1) then
				if (cloudX_1 <= 0) then
					cloudX_1 <= COLS;				
				else
					cloudX_1 <= cloudX_1 - 1;					
				end if;
				nubeCount1 := 0;
			end if;
			nubeCount1 := nubeCount1 + 1;
		
			if (nubeCount2 >= T_FAC * nubeSpeed2) then
				if (cloudX_2 <= 0) then
					cloudX_2 <= COLS;				
				else
					cloudX_2 <= cloudX_2 - 1;					
				end if;
				nubeCount2 := 0;
			end if;
			nubeCount2 := nubeCount2 + 1;
			
			if (nubeCount3 >= T_FAC * nubeSpeed3) then
				if (cloudX_3 <= 0) then
					cloudX_3 <= COLS;				
				else
					cloudX_3 <= cloudX_3 - 1;					
				end if;
				nubeCount3 := 0;
			end if;
			nubeCount3 := nubeCount3 + 1;
			
			if (nubeCount4 >= T_FAC * nubeSpeed4) then
				if (cloudX_4 <= 0) then
					cloudX_4 <= COLS;				
				else
					cloudX_4 <= cloudX_4 - 1;					
				end if;
				nubeCount4 := 0;
			end if;
			nubeCount4 := nubeCount4 + 1;
			
			-- Movimiento del Cactus
			if (cactusCount1 >= T_FAC * cactusSpeed1) then
				if (cactusX_1 <= 0) then
					cactusX_1 <= COLS;				
				else
					cactusX_1 <= cactusX_1 - 1;					
				end if;
				cactusCount1 := 0;
			end if;
			cactusCount1 := cactusCount1 + 1;
			
			if (cactusCount2 >= T_FAC * cactusSpeed2) then
				if (cactusX_2 <= 0) then
					cactusX_2 <= COLS;				
				else
					cactusX_2 <= cactusX_2 - 1;					
				end if;
				cactusCount2 := 0;
			end if;
			cactusCount2 := cactusCount2 + 1;
			
			--Choque de cactus
			if (cactusX_1=trexX and cactusY=trexY) then
				gameover <= '1';
			end if;
			if (cactusX_2=trexX and cactusY=trexY) then
				gameover <= '1';
			end if;
			
			if(start = '1') then
			gameover <= '0';
			end if;
		end if;
	end process;
	
end arch;