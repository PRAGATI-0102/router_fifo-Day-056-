`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2023 10:33:01 PM
// Design Name: 
// Module Name: router_fifo_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module router_fifo_tb();

        reg clk,rstn,soft_rst;
        reg write_enb,read_enb,lfd_state;
        reg [7:0] data_in;
        
        wire empty,full;
        wire [7:0] data_out;
        
        parameter period = 10;
        reg [7:0] header,parity;
        reg [1:0] addr;
        
        integer i;
        
        router_fifo dut(clk,rstn,soft_rst,write_enb,read_enb,lfd_state,data_in,empty,full,data_out); 
        
        initial
        begin
            clk = 0;
            forever #(period/2) clk = ~clk;
        end
        
        // Reet task
        
        task rst();
        begin
            @(negedge clk)
            rstn = 1'b0;
            @(negedge clk)
            rstn = 1'b1;
        end
        endtask
        
        task soft_reset();
        begin
            @(negedge clk)
            soft_rst = 1'b1;
            @(negedge clk)
            soft_rst = 1'b0;
        end
        endtask
        
        // Packet Generation
        
        task pkt_gen;
            reg[7:0]payload_data;
	        reg[5:0]payload_len;
	        
	        begin
	           @(negedge clk)
	           payload_len=6'd14;
	           addr = 2'b01;
	           header = {payload_len,addr};
	           data_in = header;
	           lfd_state = 1'b1;
	           write_enb = 1'b1;
	           
	           for(i=0;i<payload_len;i=i+1)
	           begin 
	               @(negedge clk)
	               begin
                       lfd_state = 1'b0;
                       payload_data = {$random}%256;
                       data_in = payload_data;
	               end
	               
	               @(negedge clk)
	               begin
	                   parity = {$random}%256;
	                   data_in = parity;
	               end
	           end
	        end
	     endtask
	     
	     initial
	     begin
	       rst();
	       soft_reset();
	       pkt_gen;
	       
	       repeat(2)
	       @(negedge clk)
	       read_enb = 1;
	       write_enb = 0;
	       
	       @(negedge clk)
	       wait(empty)
        
           @(negedge clk)
	       read_enb = 0;
	       
	       #100;
	       $finish;
	     end
	           
        
endmodule
