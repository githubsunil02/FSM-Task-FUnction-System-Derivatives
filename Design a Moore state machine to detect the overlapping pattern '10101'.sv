module moore_10101 (
  input logic clk,
  input logic rst,
  input logic data,
  output logic out
);
  
// start encording
  
  typedef enum logic [2:0] {
    S0 = 3'b000,  // Idle
    S1 = 3'b001,  // 1
    S2 = 3'b010,  // 10
    S3 = 3'b011,  // 101
    S4 = 3'b100,  // 1010
    S5 = 3'b101  // 10101 (Match)
  } state_t;
  
  state_t current_state, next_state;
  
  // State Register (Sequential with asynchronous active-high reset)
  
  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      current_state <= S0;
    else
      current_state <= next_state;
  end
  
  // 2. Next-State Logic (Combinational)
  
 always_comb begin
   case (current_state)
     S0: next_state = data ? S1 : S0;
     S1: next_state = data ? S1 : S2;
     S2: next_state = data ? S3 : S0;
     S3: next_state = data ? S1 : S4;
     S4: next_state = data ? S5 : S0;
     S5: next_state = data ? S1 : S4;  // Overlapping logic: '10101' + '0' -> '1010' (S4)
      default: next_state = S0;
    endcase
  end
  
  // 3. Output Logic (Moore: depends only on current_state)
  assign out = (current_state == S5);

endmodule 
