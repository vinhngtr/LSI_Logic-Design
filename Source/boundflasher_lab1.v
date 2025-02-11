`timescale 1ns / 1ps
// School: Ho Chi Minh City University of Technology - Ho Chi Minh National
// University
// Student: Nguyen Trong Vinh - 2015070
// Instructor: Mr. Huynh Phuc Nghi
// Module: Lab1 LSI Logic Design
// Description: Verilog source code implementing BoundFlasher system based on
// FSM. The system has 2 sequential blocks to proceed output and store state
// and 1 combinational block to proceed changing state.

module boundFlasher_tb(
input wire clk, rst, flick,
output reg [15:0]LED
    );
    parameter Start = 3'b111;
    parameter OnTo5 = 3'b110;
    parameter OffTo0 = 3'b100;
    parameter OnTo10 = 3'b000;
    parameter OffTo5 = 3'b001;
    parameter OnTo15 = 3'b011;
    parameter Blink = 3'b010;
    reg [15:0] LEDtemp=16'b0;
    reg [2:0] current_state, next_state;
    reg final=1'b0;
    reg [1:0] countblink=2'b0;

    always @(*) begin
        case(current_state)
            Start: begin
                if (flick == 1'b1) next_state[2:0] = OnTo5;
                else next_state[2:0] = Start;
            end
            OnTo5: begin
                if (LED[5] == 1'b1) next_state[2:0]=OffTo0;
                else next_state[2:0]=OnTo5;
            end
            OffTo0: begin
                if (LED[0] == 1'b0) begin
                    if (final == 1'b1) next_state[2:0] = Blink;
                    else next_state[2:0] = OnTo10;
                end else next_state[2:0] = OffTo0;
            end
            OnTo10: begin
                if (((LED[6:5]==2'b01)||(LED[11:10]==2'b01)) && (flick == 1'b1)) next_state[2:0] = OffTo0;
                else if (LED[10] == 1'b1 && flick==0) next_state[2:0] = OffTo5;
                else next_state[2:0] = OnTo10;
            end
            OffTo5: begin
                if (LED[5] == 1'b0) next_state[2:0]= OnTo15;
                else next_state[2:0] = OffTo5;
            end
            OnTo15: begin
                if (((LED[6:5]==2'b01)||(LED[11:10]==2'b01)) && (flick == 1'b1)) next_state[2:0]=OffTo5;
                else if (LED[15] == 1'b1) next_state[2:0] = OffTo0;
                else next_state[2:0] = OnTo15;
            end
            Blink: begin
                if (countblink == 2) next_state[2:0] = Start;
                else next_state[2:0] = Blink;
            end
            default: next_state[2:0] = Start;
        endcase
    end
    
    always @(posedge clk, negedge rst) begin
        if(~rst) begin
            current_state<=Start;
        end else if (((LED[6:5]==2'b01)||(LED[11:10]==2'b01)) && (flick == 1'b1)) begin
	    if(current_state[2:0]==OnTo10) current_state[2:0] <= OffTo0;
	    else current_state[2:0]<=OffTo5;
	end
	else current_state[2:0] <= next_state[2:0];
    end
    
    always @(posedge clk, negedge rst) begin
        if(~rst) begin
            LED <= 16'b0;
            final <= 0;
            countblink <= 0;
        end else begin
            case(current_state)
                Start: begin
                    LED<=16'b0;
                end
                OnTo5: begin
                    if(LED[5]==1'b0) LED <= (LED<<1)|1'b1;
                    else LED <= (LED>>1);
                end
                OffTo0: begin
                    if(LED[0]==1'b1) LED <= LED>>1;
                    else if(final==1'b0) LED <= (LED<<1)|1'b1;
                end
                OnTo10: begin
                    if (((LED[6:5]==2'b01)||(LED[11:10]==2'b01)) && (flick == 1'b1)) begin 
			LED <= LED >> 1;
                    end
		    else if (LED[10] == 1'b0) LED <= (LED<<1)|1'b1;
                    else if (LED[10] == 1'b1) LED <= LED>>1;
                end
                OffTo5: begin
                    if (LED[5] == 1'b1) LED <= LED>>1;
                    else LED <= (LED<<1)|1'b1;
                end
                OnTo15: begin
                    if (((LED[6:5]==2'b01)||(LED[11:10]==2'b01)) && (flick == 1'b1)) begin 
			LED <= LED>>1;
		    end
                    else if (LED[15] == 1'b1) begin
                        final <= 1;
                        LED <= LED>>1;
                    end else if (LED[15] == 1'b0) LED <= (LED<<1)|1'b1;
                end
                Blink: begin
                    if (countblink < 2) LED <= ~LED;
                    countblink <= countblink + 1;
                end
            endcase
        end
    end
endmodule

