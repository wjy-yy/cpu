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
module VGAIO(input clk, rst,							//100MHzʱ��
				 input [15:0]VRAMOUT,					//�ı���ʾ��������
				 input [12:0]Pixel,						//ͼ����ʾ�������룺en_RRRR_GGGG_BBBB
				 input [13:0]Test,						//������ʾ�������룺en_RRRR_GGGG_BBBB
				 input [31:0]Din,							//��ʾ�Ĵ�������
				 input [3:0]Regaddr,						//��ʾ�Ĵ�����ַ
				 input [12:0]Cursor,						//Ӳ������ַ
				 input Blink,								//�����˸Ƶ��

				 output[8:0]row,			// pixel ram row address, 480 lines
				 output[9:0]col,			// pixel ram col address, 640 pixels
				 output[3:0]R, G, B,
				 output reg HSYNC, VSYNC,
				 output[12:0]VRAMA,					//�ı���ʾ�����ַ
				 output rdn									//VAM��ַ
				 );
		wire[11:0] pixel_in = Pixel[11:0];
		wire[11:0] TEST_D = Test[11:0];
		wire pixel_en = Pixel[12];
		wire TESTEN = Test[12] && Test[13];
		
wire h_sync;
wire v_sync;
//wire [8:0] row;												//����������
//wire [9:0] col;                                    //����������
wire read;
wire[15:0]Font16out;										//�ֿ����ROM����ֵ
wire[7:0] Font8out;											//�ֿ����ROM����ֵ
reg[11:0]Pixels;
reg [3:0]red,green,blue;
reg [15:0]VRAM_BUF;
reg[31:0]MODE=32'h40000001;								//ȱʡ״̬640*480���ı���8*8�ֿ�


	always@(posedge clk)											//������ʾ�Ĵ���
		if(rst)MODE <= 32'h40000001;
		else begin 
				MODE <= Din;
				if(!rdn)VRAM_BUF <= VRAMOUT;
				else VRAM_BUF <= VRAM_BUF;
		end

//�ı�VRAM��ַ�ϳɣ��ַ�����
	wire[6:0]char_col = MODE[6:4]==3'b000 ? col[9:3] : //8*8  �ַ�������
											 {1'b0,col[9:4]};		//16*16�ַ�������
	wire[5:0]char_row = MODE[6:4]==3'b000 ? row[8:3] : //8*8  �ַ�������
										    {1'b0,row[8:4]};		//16*16�ַ�������
	
//��ʾ��λ���ַ�����ӳ��VRAM��ַ����
//	assign VRAMA = char_row*(64+16) + char_col;
	assign VRAMA = MODE[6:4]==3'b000 ? 						//�ı�VRAMӳ���ַ
				 (char_row << 6) + (char_row << 4) + char_col : //8*8����:  80�ַ�=64+16
				 (char_row << 5) + (char_row << 3) + char_col;	//16*16���壺40�ַ�=32+8


//VRAM���ź�
//	assign rdn =~(read && (col[2:0] == 3'b000));	//�ַ��е�ַ=0ʱ������ʾ
	assign rdn =~(read && vrd);									//VRAM���źţ���Ƶ��ʾ����Ч
	wire vrd = MODE[6:4]==3'b000 ? col[2:0] == 3'b000 :	//��ʾ���£�8*8�ַ��е�ַ=000
											 col[3:0] == 4'b0000;	//��ʾ���£�16*16�ַ��е�ַ=0000

//�ֿ�ROM���ʣ���ַ�ϳ�
	wire[16:0] font_addr = MODE[6:4]==3'b000 ? 					//�ֿ�ROM��ַ�ϳ�
								{7'b0,VRAM_BUF[6:0],row[2:0]} :		//8*8�ֿ�
								{VRAM_BUF[12:0],row[3:0]}; 			//16*16�ֿ�	
								
	Font8		Font_8(.a(font_addr[10:0]), .spo(Font8out));	//8*8�ֿⷢ����ROM����Font88
							  						
	//Font1616		Font16(clk, font_addr, Font16out);				//16*16�ֿⷢ����ROM����

	wire Font8dot  = MODE[6:4]==3'b000 ? Font8out[~col[2:0]] : 1'b0; 			//ȡ��ǰ8*8�ַ���ʾ��
	wire Font8Bdot = MODE[6:4]==3'b000 && VRAM_BUF[14:12]!=3'b000 ? 
										 ~Font8out[~col[2:0]] : 1'b0; 					//ȡ��ǰ8*8�ַ�������
	wire Font16dot = MODE[6:4]==3'b010 ? Font16out[~col[3:0]] : 1'b0;			//ȡ��ǰ16*16�ַ���ʾ��				

//�ַ���ʾ����(Attributes) 
//	wire[2:0]Attr8F = VRAM_BUF[10:8];								//8*8�ַ�ǰ��
	wire[11:0]Attr8F = {VRAM_BUF[15:14], VRAM_BUF[15:14],VRAM_BUF[13],
							  VRAM_BUF[13:11], VRAM_BUF[10],  VRAM_BUF[10:8]};	
	wire[2:0]Attr8B = VRAM_BUF[14:12];							//8*8�ַ�����
	wire[2:0]Attr16 = VRAM_BUF[15:13];							//16*16�ַ�����
	
//	wire[2:0]Char_color = Fontdot? Attr : MODE[6:4]==3'b000 ? 
//															  VRAM_BUF[14:12] : 3'b000;	//�����ޱ���ɫ

//Ӳ�����ϳɣ���˸���
	wire size = MODE[6:4]==3'b000 ? row[2:0] > 3 : row[3:0] > 4;
	wire Blinking = (Cursor[12:7]==char_row) &&	size &&					//����С����
						 (Cursor[6:0] ==char_col);

	assign R =Blinking ? red   ^  {4{Blink}} : red;
	assign G =Blinking ? green ^  {4{Blink}} : green;
	assign B =Blinking ? blue  ^  {4{Blink}} : blue;
	
//��ʾ���غϳ�
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
	always @(posedge clk)VGACLK <= VGACLK+1;				//ͬ��ʱ�ӷ�Ƶ
		
//������ʾɨ��ͬ��ģ�飺vga_core		
	 VGA_Scan  VScans(.clk(VGACLK[1]),						//25MHz						
							.rst(rst),
							.row(row), 								//����������
							.col(col),								//����������
							.Active(read), 						//��Ƶ��Ч
							.HSYNC(h_sync),						//��ɨ��ͬ��
							.VSYNC(v_sync)							//��ɨ��ͬ��
							);
							
//vga signals���
	always @(posedge VGACLK[1])begin	
        HSYNC <=  h_sync; 								// horizontal synchronization
        VSYNC <=  v_sync; 								// vertical   synchronization
        red   <=  read ? Pixels[11:8]: 4'h0; 	// 4-bit red
        green <=  read ? Pixels[7:4] : 4'h0; 	// 4-bit green
        blue  <=  read ? Pixels[3:0] : 4'h0;		// 4-bit blue
    end 

endmodule
