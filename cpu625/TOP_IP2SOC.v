`timescale 1ns / 1ps
//=====================================================================
//
// Designer   : Junyao Wang
//
// Description:
// As the project of Computer Organization Experiments, Wuhan University
// In spring 2022
// The overall of the pipelined xg-riscv implementation.
//
// ====================================================================

module TOP_IP2SOC(
input			RSTN,
input [3:0]	BTN_y,
input [15:0] SW,
input			clk_100mhz,
output CR,
output seg_clk,
output seg_sout,
output SEG_PEN,
output seg_clrn,
output led_clk,
output led_sout,
output LED_PEN,
output led_clrn,
output RDY,
output readn,
output [4:0]	BTN_x
    );

	wire rst;
	wire [4:0] Key_out;
	wire [3:0] BTN_OK, pulse_out;
	wire [15:0] SW_OK, LED_out;
	wire [31:0] inst;
	
	
	
	
	SAnti_jitter	U9(.clk(clk_100mhz),
							.RSTN(RSTN),
							.readn(readn),
							.Key_y(BTN_y),
							.Key_x(BTN_x),
							.SW(SW),
							.Key_out(Key_out),
							.Key_ready(RDY),
							.pulse_out(pulse_out),
							.BTN_OK(BTN_OK),
							.SW_OK(SW_OK),
							.CR(CR),
							.rst(rst)
							);

	wire [31:0] Div;
	wire Clk_CPU;
	clk_div			U8(.clk(clk_100mhz),
							.rst(rst),
							.SW2(SW_OK[2]),
							.clkdiv(Div),
							.Clk_CPU(Clk_CPU));
							
	wire [31:0] Ai, Bi;
	wire [7:0]	blink;
	
	SEnter_2_32		M4(.clk(clk_100mhz),
							.BTN(BTN_OK[2:0]),
							.Ctrl({SW_OK[7:5], SW_OK[15], SW_OK[0]}),
							.D_ready(RDY),
							.Din(Key_out),
							.readn(readn),
							.Ai(Ai),
							.Bi(Bi),
							.blink(blink));
	wire mem_w, CPU_MIO, data_ram_we, MIO_Ready;
	wire counter0_out, counter1_out, counter2_out, counter_we;
	wire [3:0] WEA;
	wire [31:0] Addr_out, Data_in, Data_out, PC, spo;
	
	xgriscv				U1(.clk(Clk_CPU),
							.reset(rst),
							.MIO_ready(MIO_ready),
							.inst_in(inst),
							.Data_in(Data_in),
							//.data_ram_we(data_ram_we),
							.mem_w(mem_w),
							.PC_out(PC),
							.Addr_out(Addr_out),
							.Data_out(Data_out), 
							.CPU_MIO(CPU_MIO),
							.WEA(WEA),
							.INT(counter0_out)
				);
	
	wire [31:0]	douta, counter_out, ram_data_in, CPU2IO;
	//wire [15:0]	led_out;
	wire [9:0]	ram_addr;
	
	wire GPIOf0000000_we, GPIOe0000000_we;
	
	ROM_D				U2(.a(PC[11:2]),
							.spo(inst));
	RAM_B				U3(.clka(clk_100mhz),
							.wea(WEA),
							.addra(ram_addr),
							.dina(ram_data_in),
							.douta(douta)
						);
	
	MIO_BUS			U4(.clk(clk_100mhz),
							.rst(rst),
							.BTN(BTN_OK),
							.SW(SW_OK),
							.mem_w(mem_w),
							.Cpu_data2bus(Data_out),				//data from CPU
							.addr_bus(Addr_out),
							.ram_data_out(douta),
							.led_out(LED_out),
							.counter_out(counter_out),
							.counter0_out(counter0_out),
							.counter1_out(counter1_out),
							.counter2_out(counter2_out),
						
							.Cpu_data4bus(Data_in),				//write to CPU
							.ram_data_in(ram_data_in),				//from CPU write to Memory
							.ram_addr(ram_addr),						//Memory Address signals
							.data_ram_we(data_ram_we),
							.GPIOf0000000_we(GPIOf0000000_we),
							.GPIOe0000000_we(GPIOe0000000_we),
							.counter_we(counter_we),
							.Peripheral_in(CPU2IO)
					);
					
	wire [7:0] point_out, LE_out;
	wire [31:0] Disp_num;
	//assign IO_clk = ~Clk_CPU;
	
	Multi_8CH32		U5(.clk(~Clk_CPU),
							.rst(rst),
							.EN(GPIOe0000000_we),								//Write EN
							.Test(SW_OK[7:5]),						//ALU&Clock,SW[7:5]	
							.point_in({Div[31:0],Div[31:0]}),					//���8λ��ʾ�����8��С����
							.LES({64{1'b0}}),					//���8λ��ʾ�����8����˸λ
							.Data0(CPU2IO),					//disp_cpudata
							.data1({2'b00, PC[31:2]}),
							.data2(inst),
							.data3(counter_out),
							.data4(Addr_out),
							.data5(Data_out),
							.data6(Data_in),
							.data7(PC),
							.point_out(point_out),
							.LE_out(LE_out),
							.Disp_num(Disp_num));
							
	SSeg7_Dev		U6(.clk(clk_100mhz),			//	ʱ��
							.rst(rst),			//��λ
							.Start(Div[20]),		//����ɨ������
							.SW0(SW_OK[0]),			//�ı�(16����)/ͼ��(����)�л�
							.flash(Div[25]),		//�߶�����˸Ƶ��
							.Hexs(Disp_num),	//32λ����ʾ��������
							.point(point_out),	//�߶���С���㣺8��
							.LES(LE_out),		//�߶���ʹ�ܣ�=1ʱ��˸
							.seg_clk(seg_clk),	//������λʱ��
							.seg_sout(seg_sout),	//�߶���ʾ����(�������)
							.SEG_PEN(SEG_PEN),	//�߶�����ʾˢ��ʹ��
							.seg_clrn(seg_clrn)	//�߶�����ʾ����
							);
	
	
	wire [1:0] counter_set;
	wire [13:0] GPIOf0;
	SPIO				U7(.clk(~Clk_CPU),							//ʱ��
							.rst(rst),                    //��λ
							.Start(Div[20]),                  //����ɨ������
							.EN(GPIOf0000000_we),                     //PIO/LED��ʾˢ��ʹ��
							.P_Data(CPU2IO),          //�������룬���ڴ����������
							.counter_set(counter_set),  //���ڼ���/��ʱģ����ƣ���ʵ�鲻��
							.LED_out(LED_out),        //�����������
							.led_clk(led_clk),          //������λʱ��
							.led_sout(led_sout),         //�������
							.led_clrn(led_clrn),         //LED��ʾ����
							.LED_PEN(LED_PEN),          //LED��ʾˢ��ʹ��
							.GPIOf0(GPIOf0)			//���ã�GPIO			 
						);
	Counter_x 		U10(.clk(~Clk_CPU),
							.rst(rst),
							.clk0(Div[6]),
							.clk1(Div[9]),
							.clk2(Div[11]),
							.counter_we(counter_we),
							.counter_val(CPU2IO),
							.counter_ch(counter_set),				//Counter channel set 

							.counter0_OUT(counter0_out),
							.counter1_OUT(counter1_out),
							.counter2_OUT(counter2_out),
							.counter_out(counter_out)
						);
endmodule
