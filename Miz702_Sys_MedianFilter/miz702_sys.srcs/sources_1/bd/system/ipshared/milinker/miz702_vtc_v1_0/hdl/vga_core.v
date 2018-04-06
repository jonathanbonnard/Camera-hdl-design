`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         milinker corperation
// WEB:             www.milinker.com
// BBS:             www.osrc.cn
// Engineer:        cuter
// Create Date:     07:28:50 11/30/2015 
// Design Name: 	vga_core
// Module Name:     vga_core
// Project Name: 	vga_core
// Target Devices:  XC702 Miz702
// Tool versions:   Vivado 2015.4
// Description: 	video timing controller, used to generate vga display timing
// Revision: 		V1.0
// Additional Comments: 
//1) _i PIN input  
//2) _o PIN output
//3) _n PIN active low
//4) _dg debug signal 
//5) _r  reg delay
//6) _s state machine
//////////////////////////////////////////////////////////////////////////////
module vga_core(
    input   wire    clk_i,
//    input   wire    resetn,
	
	input	wire[15:0]	h_total_i,
	input	wire[15:0]	v_total_i,
	input	wire[15:0]	hs_size_i,
	input	wire[15:0]	vs_size_i,
	input	wire[15:0]	hback_i,
	input	wire[15:0]	vback_i,
	input	wire[15:0]	hfront_i,
	input	wire[15:0]	vfront_i,
	input	wire[11:0]	data_i,
	
    output wire clk_o,
    output wire vsync_o,
    output wire hsync_o,
    output wire fsync_o,
	output wire [11:0]	data_o,
    output wire active_video_o,
    output wire [15:0] pixel_x_o,
    output wire [15:0] pixel_y_o
    );
    
    reg vsync_r;
    reg hsync_r;
    reg fsync_r;
	reg h_active_r;
	reg v_active_r;
    reg active_video_r;
//    reg clk;
	reg [11:0]	data_r;
	
    reg [15:0]  hcount_r;		 // �м����Ĵ���
    reg [15:0]  vcount_r;		 // �������Ĵ���

    reg [15:0]  pixel_x_r;		 // �м����Ĵ���
    reg [15:0]  pixel_y_r;         // �������Ĵ���

   	reg 		hcount_ov;	      // �м��������־λ
	reg 		vcount_ov;	      // �����������־λ
	//----------------�����ź�����--------------------
	
	
	//----------------��ɨ�����-------------------
	always@(posedge clk_o)
	begin
		if(hcount_r == (h_total_i-1'b1))      	// �м�������
			hcount_ov <= 1;         	// �м���������־
		else
			hcount_ov <= 0;
	end

	always@(posedge clk_o)
	begin
		if(hcount_ov == 1)
			hcount_r <= 16'b0;           //�м������¿�ʼ
		else
			hcount_r <= hcount_r + 1;    
	end
	//----------------��ͬ���źŵ�����-------------------
	always@(posedge clk_o)
	begin
		if(hcount_r > (hs_size_i-1'b1))
			hsync_r <= 1;
		else
			hsync_r <= 0;    //�͵�ƽͬ��
	end
	
	//----------------��ɨ�����---------------------
	always@(posedge clk_o)
	begin
		if(vcount_r == (v_total_i-1'b1))		// ����������
			vcount_ov <= 1;         	// ������������־
		else
			vcount_ov <= 0;
	end

	always@(posedge clk_o)
	begin
		if(hcount_ov == 1)
		begin
			if(vcount_ov == 1)
			   vcount_r <= 12'b0;      	//���������¿�ʼ
			else
			   vcount_r <= vcount_r + 1;
		end
	end
	//----------------��ͬ���ź�����-------------------
	always@(posedge clk_o)
	begin
		if(vcount_r > (vs_size_i-1'b1)) 
		  vsync_r <= 1;
		 else
		  vsync_r <= 0;             //�͵�ƽͬ��
	end
	//----------------��������Ч�ź�---------------------
	always@(posedge clk_o)
	begin
		if((hcount_r > (hs_size_i+hback_i-1'b1))&&(hcount_r <(h_total_i-hfront_i)))
		begin
			h_active_r <= 1;
			pixel_x_r <= hcount_r-hs_size_i-hback_i;
		end
		else
		begin
			h_active_r <= 0;
		end
	end
	//----------------��������Ч�ź�---------------------
	always@(posedge clk_o)
	begin
		if((vcount_r > (vs_size_i+vback_i-1'b1))&&(vcount_r <(v_total_i-vfront_i)))
		begin
			v_active_r <= 1;
			pixel_y_r <= vcount_r-vs_size_i-vback_i;
		end
		else
		begin
			v_active_r <= 0;             //�͵�ƽͬ��
		end
	end
	

//--------------- �ź����� ------------------------
assign clk_o = clk_i;
assign hsync_o = hsync_r;
assign vsync_o = vsync_r;
assign fsync_o = ((~fsync_r) & vsync_r);
assign active_video_o = h_active_r & v_active_r;
assign pixel_x_o = pixel_x_r;
assign pixel_y_o = pixel_y_r;

always@(posedge clk_o) begin
    fsync_r <= vsync_r;
end

//--------------- ���Ի��棬�����ڲ��� ---------------
always@(posedge clk_o) begin
if(active_video_o==1'b1) 
begin
	data_r <= data_i;
end
else
	data_r <= 12'b0;
end

assign data_o = data_r;
    
endmodule
