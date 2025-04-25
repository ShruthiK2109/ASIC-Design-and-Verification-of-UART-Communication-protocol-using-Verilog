// uart_top.v
// Top-level wrapper instantiating both UART_TX and UART_RX

module UART_TOP
#(
  parameter CLKS_PER_BIT = 217
)
(
  // Global
  input  wire        i_Clock,

  // Transmitter interface
  input  wire        i_TX_DV,      // start transmit pulse
  input  wire [7:0]  i_TX_Byte,    // byte to send
  output wire        o_TX_Active,  // high while TX is busy
  output wire        o_TX_Serial,  // serial data out
  output wire        o_TX_Done,    // one-clock pulse when byte done

  // Receiver interface
  input  wire        i_RX_Serial,  // serial data in
  output wire        o_RX_DV,      // one-clock pulse when byte valid
  output wire [7:0]  o_RX_Byte     // received byte
);

  // Transmitter instance
  UART_TX #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx_inst (
    .i_Clock     (i_Clock),
    .i_TX_DV     (i_TX_DV),
    .i_TX_Byte   (i_TX_Byte),
    .o_TX_Active (o_TX_Active),
    .o_TX_Serial (o_TX_Serial),
    .o_TX_Done   (o_TX_Done)
  );

  // Receiver instance
  UART_RX #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_inst (
    .i_Clock     (i_Clock),
    .i_RX_Serial (i_RX_Serial),
    .o_RX_DV     (o_RX_DV),
    .o_RX_Byte   (o_RX_Byte)
  );

endmodule

