// UART Transmitter code
// This transmitter is able to transmit 8 bits of serial data, one start bit, one stop bit, and no parity bit. When transmission is complete, o_TX_Done will be driven high for one clock 
// cycle. 

// Parameters
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Frequency of i_Clock = 25 MHz, 115200 baud UART
// (25000000)/(115200) = 217

module UART_TX
#(parameter CLKS_PER_BIT = 217)
(
input i_Clock,
input i_TX_DV,
input [7:0] i_TX_Byte,
output o_TX_Active,
output reg o_TX_Serial,
output o_TX_Done 
);

parameter IDLE = 3'b000;
parameter TX_START_BIT = 3'b001;
parameter TX_DATA_BITS = 3'b010;
parameter TX_STOP_BIT = 3'b011;
parameter CLEANUP = 3'b100;
reg [2:0] r_SM_Main = 0;
reg [7:0] r_Clock_Count = 0;
reg [2:0] r_Bit_Index = 0;
reg [7:0] r_TX_Data = 0;
reg r_TX_Done = 0;
reg r_TX_Active = 0;

always @(posedge i_Clock)
begin

case (r_SM_Main)
IDLE:
begin
o_TX_Serial <= 1'b1;   // Drive Line High for Idle
r_TX_Done <= 1'b0;
r_Clock_Count <= 0;
r_Bit_Index <= 0;

if (i_TX_DV == 1'b1)
begin
r_TX_Active <= 1'b1;
r_TX_Data <= i_TX_Byte;
r_SM_Main <= TX_START_BIT;
end
else
r_SM_Main <= IDLE;
end // case: IDLE

// Send out Start Bit. Start bit = 0
TX_START_BIT:
begin
o_TX_Serial <= 1'b0;

// Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
if(r_Clock_Count < CLKS_PER_BIT-1)
begin
r_Clock_Count <= r_Clock_Count + 1;
r_SM_Main <= TX_START_BIT;
end
else
begin
r_Clock_Count <= 0;
r_SM_Main <= TX_DATA_BITS;
end
end // case: TX_START_BIT

// Wait CLKC_PER_BIT-1 clock cycles for data to finish
TX_DATA_BITS:
begin
o_TX_Serial <= r_TX_Data[r_Bit_Index];

if (r_Clock_Count < CLKS_PER_BIT-1)
begin

r_Clock_Count <= r_Clock_Count + 1;
r_SM_Main <= TX_DATA_BITS;
end
else
begin
r_Clock_Count <= 0;

// Check if we have sent out all the bits

if (r_Bit_Index < 7)
begin
r_Bit_Index <= r_Bit_Index + 1;
r_SM_Main <= TX_DATA_BITS;
end
else
begin
r_Bit_Index <= 0;
r_SM_Main <= TX_STOP_BIT;
end
end
end // case: TX_DATA_BITS

// Send out Stop bit. Stop bit = 1
TX_STOP_BIT:
begin
o_TX_Serial <= 1'b1;

// Wait CLKS_PER_BIT-1 clock cycles for stop bit to finish
if(r_Clock_Count < CLKS_PER_BIT-1)
begin
r_Clock_Count <= r_Clock_Count + 1;
r_SM_Main <= TX_STOP_BIT;
end
else
begin
r_TX_Done <= 1'b1;
r_Clock_Count <= 0;
r_SM_Main <= CLEANUP;
r_TX_Active <= 1'b0;
end
end // case: TX_STOP_BIT

// Stay here 1 clock
CLEANUP:
begin
r_TX_Done <= 1'b1;
r_SM_Main <= IDLE;
end
default:
r_SM_Main <= IDLE;
endcase
end
assign o_TX_Active = r_TX_Active;
assign o_TX_Done = r_TX_Done;
endmodule
