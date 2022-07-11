`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:24:38 06/17/2011 
// Design Name: 
// Module Name:    vga_wrapper 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module VGAIO(input clk, rst,							//100MHz时钟
				 input [15:0]VRAMOUT,					//文本显示编码输入
				 input [12:0]Pixel,						//图形显示像素输入：en_RRRR_GGGG_BBBB
				 input [13:0]Test,						//测试显示像素输入：en_RRRR_GGGG_BBBB
				 input [31:0]Din,							//显示寄存器输入
				 input [3:0]Regaddr,						//显示寄存器地址
				 input [12:0]Cursor,						//硬件光标地址
				 input Blink,								//光标闪烁频率

				 output[8:0]row,			// pixel ram row address, 480 lines
				 output[9:0]col,			// pixel ram col address, 640 pixels
				 output[3:0]R, G, B,
				 output reg HSYNC, VSYNC,
				 output[12:0]VRAMA,					//文本显示缓冲地址
				 output rdn									//VAM地址
				 );
		wire[11:0] pixel_in = Pixel[11:0];
		wire[11:0] TEST_D = Test[11:0];
		wire pixel_en = Pixel[12];
		wire TESTEN = Test[12] && Test[13];
		
wire h_sync;
wire v_sync;
//wire [8:0] row;												//像素列坐标
//wire [9:0] col;                                    //像素行坐标
wire read;
wire[15:0]Font16out;										//字库点阵ROM读出值
wire[7:0] Font8out;											//字库点阵ROM读出值
reg[11:0]Pixels;
reg [3:0]red,green,blue;
reg [15:0]VRAM_BUF;
reg[31:0]MODE=32'h40000001;								//缺省状态640*480、文本、8*8字库


	always@(posedge clk)											//更新显示寄存器
		if(rst)MODE <= 32'h40000001;
		else begin 
				MODE <= Din;
				if(!rdn)VRAM_BUF <= VRAMOUT;
				else VRAM_BUF <= VRAM_BUF;
		end

//文本VRAM地址合成：字符坐标
	wire[6:0]char_col = MODE[6:4]==3'b000 ? col[9:3] : //8*8  字符列坐标
											 {1'b0,col[9:4]};		//16*16字符列坐标
	wire[5:0]char_row = MODE[6:4]==3'b000 ? row[8:3] : //8*8  字符行坐标
										    {1'b0,row[8:4]};		//16*16字符行坐标
	
//显示定位：字符坐标映射VRAM地址计算
//	assign VRAMA = char_row*(64+16) + char_col;
	assign VRAMA = MODE[6:4]==3'b000 ? 						//文本VRAM映射地址
				 (char_row << 6) + (char_row << 4) + char_col : //8*8字体:  80字符=64+16
				 (char_row << 5) + (char_row << 3) + char_col;	//16*16字体：40字符=32+8


//VRAM读信号
//	assign rdn =~(read && (col[2:0] == 3'b000));	//字符列地址=0时更新显示
	assign rdn =~(read && vrd);									//VRAM读信号：视频显示区有效
	wire vrd = MODE[6:4]==3'b000 ? col[2:0] == 3'b000 :	//显示更新：8*8字符列地址=000
											 col[3:0] == 4'b0000;	//显示更新：16*16字符列地址=0000

//字库ROM访问：地址合成
	wire[16:0] font_addr = MODE[6:4]==3'b000 ? 					//字库ROM地址合成
								{7'b0,VRAM_BUF[6:0],row[2:0]} :		//8*8字库
								{VRAM_BUF[12:0],row[3:0]}; 			//16*16字库	
								
	Font8		Font_8(.a(font_addr[10:0]), .spo(Font8out));	//8*8字库发生器ROM访问Font88
							  						
	//Font1616		Font16(clk, font_addr, Font16out);				//16*16字库发生器ROM访问

	wire Font8dot  = MODE[6:4]==3'b000 ? Font8out[~col[2:0]] : 1'b0; 			//取当前8*8字符显示点
	wire Font8Bdot = MODE[6:4]==3'b000 && VRAM_BUF[14:12]!=3'b000 ? 
										 ~Font8out[~col[2:0]] : 1'b0; 					//取当前8*8字符背景点
	wire Font16dot = MODE[6:4]==3'b010 ? Font16out[~col[3:0]] : 1'b0;			//取当前16*16字符显示点				

//字符显示属性(Attributes) 
//	wire[2:0]Attr8F = VRAM_BUF[10:8];								//8*8字符前景
	wire[11:0]Attr8F = {VRAM_BUF[15:14], VRAM_BUF[15:14],VRAM_BUF[13],
							  VRAM_BUF[13:11], VRAM_BUF[10],  VRAM_BUF[10:8]};	
	wire[2:0]Attr8B = VRAM_BUF[14:12];							//8*8字符背景
	wire[2:0]Attr16 = VRAM_BUF[15:13];							//16*16字符属性
	
//	wire[2:0]Char_color = Fontdot? Attr : MODE[6:4]==3'b000 ? 
//															  VRAM_BUF[14:12] : 3'b000;	//汉字无背景色

//硬件光标合成：闪烁光标
	wire size = MODE[6:4]==3'b000 ? row[2:0] > 3 : row[3:0] > 4;
	wire Blinking = (Cursor[12:7]==char_row) &&	size &&					//光标大小设置
						 (Cursor[6:0] ==char_col);

	assign R =Blinking ? red   ^  {4{Blink}} : red;
	assign G =Blinking ? green ^  {4{Blink}} : green;
	assign B =Blinking ? blue  ^  {4{Blink}} : blue;
	
//显示像素合成
	wire Text = MODE[3:0]!=4'b000;
	always@* begin													
		case(1'b1)
			TESTEN:	Pixels = TEST_D;
			Test[13]: Pixels = 12'h000;	
//			Font8dot && Text:	Pixels = Attr8F;
//			Font8Bdot && Text:	Pixels = {3{1'b1,Attr8B}}; 
//			Font16dot && Text:	Pixels = {3{1'b1,Attr16}};
			pixel_en:	Pixels = pixel_in;			
			default:		Pixels = 12'h000;						
		endcase
	end

	
reg[2:0] VGACLK;	
	always @(posedge clk)VGACLK <= VGACLK+1;				//同步时钟分频
		
//调用显示扫描同步模块：vga_core		
	 VGA_Scan  VScans(.clk(VGACLK[1]),						//25MHz						
							.rst(rst),
							.row(row), 								//像素行坐标
							.col(col),								//像素列坐标
							.Active(read), 						//视频有效
							.HSYNC(h_sync),						//行扫描同步
							.VSYNC(v_sync)							//列扫描同步
							);
							
//vga signals输出
	always @(posedge VGACLK[1])begin	
        HSYNC <=  h_sync; 								// horizontal synchronization
        VSYNC <=  v_sync; 								// vertical   synchronization
        red   <=  read ? Pixels[11:8]: 4'h0; 	// 4-bit red
        green <=  read ? Pixels[7:4] : 4'h0; 	// 4-bit green
        blue  <=  read ? Pixels[3:0] : 4'h0;		// 4-bit blue
    end 

endmodule
