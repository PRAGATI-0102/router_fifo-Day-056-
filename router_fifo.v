`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2023 09:22:13 PM
// Design Name: 
// Module Name: router_fifo
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


module router_fifo(clk,rstn,soft_rst,write_enb,read_enb,lfd_state,data_in,empty,full,data_out);

        input clk,rstn,soft_rst;
        input write_enb,read_enb,lfd_state;
        input [7:0] data_in;
        
        output empty,full,data_out;
        reg [7:0] data_out;
        
        reg [4:0] rd_pointer, wr_pointer;
        reg [6:0] count;
        reg [8:0] mem [15:0]; //16X9 memory size FIFO
        
        reg lfd_state_t;
        
        integer i;
        
        always@(posedge clk)
        begin
            if(!rstn)
            lfd_state_t <= 0;
            else
            lfd_state_t <= lfd_state;
        end
        
        // Read Operation
        
        always@(posedge clk)
        begin
            if(!rstn)
            data_out <= 8'b0;
            
            else if(soft_rst)
            data_out <= 8'bz;
            
            else if(count == 0)
            data_out <= 8'bz;
            
            else if((read_enb)&&(!empty))
            data_out <= mem[rd_pointer[3:0]][7:0];
        end
        
        // Write Operation
        
        always@(posedge clk)
        begin
            if((!rstn) || (soft_rst))
            begin
                for(i=0;i<16;i=i+1)
                mem[i] <= 0;
            end
            
            else if((write_enb) && (!full))
            begin
                if(lfd_state_t)
                begin
                    mem[wr_pointer[3:0]][8] <= 1'b1;
                    mem[wr_pointer[3:0]][7:0] <= data_in;
                end
                
                else
                begin
                    mem[wr_pointer[3:0]][8] <= 1'b0;
                    mem[wr_pointer[3:0]][7:0] <= data_in;
                end
            end
         end
         
         // Pointer Generation
         
         always@(posedge clk)
         begin
            if(!rstn)
            begin
                wr_pointer <= 1'b0;
            end
            else if((write_enb) && (!full))
            begin
                wr_pointer <= wr_pointer + 1'b1;
            end
         end
         
         always@(posedge clk)
         begin
            if(!rstn)
            begin
                rd_pointer <= 1'b0;
            end
            else if((read_enb) && (!empty))
            begin
                rd_pointer <= rd_pointer + 1'b1;
            end
         end
         
         // Counter Block
         
         always@(posedge clk)
         begin
            if((read_enb) && (!empty))
            begin
                if(mem[rd_pointer[3:0]][8] == 1'b1)
                count <= mem[rd_pointer[3:0]][7:2] + 1'b1;
                else if(count != 0)
                count <= count - 1;
            end
         end
         
         // Full and Empty Conditions
         
         assign full = (wr_pointer == ({~rd_pointer[4],rd_pointer[3:0]}));
         assign empty = (rd_pointer == wr_pointer);
             
endmodule