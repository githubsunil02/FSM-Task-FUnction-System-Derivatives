// Design a Mealy state machine to detect the non-overlapping pattern 

module mealy_10101_non_overlapping (
    input  wire clk,
    input  wire rst,   // Active-high asynchronous reset
    input  wire data,
    output reg  out
);

// State encoding
  typedef enum logic [2:0] {
    S0 = 3'b000,
    S1 = 3'b001,
    S2 = 3'b010,
    S3 = 3'b011,
    S4 = 3'b100
  }state_t;
  
  state_t current_state, next_state;
  
 // sequential state registerwith asynchronous active-high reset
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin 
      current_state <= S0;
      end else begin
        current_state <= next_state;
      end
  end

 // Next state and Mealy output logic (depends on state and input)
      
 always_comb begin
   next_state = current_state;
   out = 1'b0;
   
   case(current_state)
     S0: begin
       if (data == 1'b1)
         next_state = S1;
       else 
         next_state = S0;
     end
     S1: begin
       if (data == 1'b0)
         next_state = S2;
       else 
         next_state = S1;
     end
     S2: begin
       if (data == 1'b1)
         next_state = S3;
       else 
         next_state = S2;
     end     
     S3: begin
       if (data == 1'b0)
         next_state = S4;
       else 
         next_state = S1;
     end    
     S4: begin
       if (data == 1'b1) begin
         out = 1'b1;         // patten 10101 detected
         next_state = S0;    // Non-overlapping Go back to idle
        end else begin
         next_state = S0;
        end
     end
     
     default: begin
        next_state = S0;
        out        = 1'b0;
     end
   endcase
 end
endmodule



//******************************* TestBench ************************* //

`timescale 1ns / 1ps
module tb_mealy_10101_non_overlapping;
  logic clk;
  logic rst;
  logic data;
  logic rst;
  // Initiate the Unit Under Test (UUT)
  tb_mealy_10101_non_overlapping uut (
    .clk(clk),
    .rst(rst),
    .data(data),
    .out(out)
  );
  
// Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

// Task for active-high asynchronous reset
  
  task apply_reset();
    begin
            rst  = 1'b1;
            data = 1'b0;
            #12;
            rst  = 1'b0;
            @(posedge clk);
        end
    endtask
// Task to drive a single bit on the rising edge of clk

     task drive_bit(input logic b);
        begin
            data = b;
            @(posedge clk);
        end
    endtask
  // Task to drive a sequence of bits
    task drive_sequence(input logic [31:0] seq, input int len);
        int i;
        begin
            for (i = len - 1; i >= 0; i--) begin
                drive_bit(seq[i]);
            end
        end
    endtask

    initial begin
        // Initialize signals
        clk  = 1'b0;
        rst  = 1'b0;
        data = 1'b0;

        // Apply reset task
        $display("[%0t] Applying Reset...", $time);
        apply_reset();

        // Test Case 1: Send valid pattern '10101' -> expect out = 1
        $display("[%0t] Test Case 1: Driving '10101'", $time);
        drive_bit(1'b1); // 1
        drive_bit(1'b0); // 0
        drive_bit(1'b1); // 1
        drive_bit(1'b0); // 0
        drive_bit(1'b1); // 1 -> 'out' should pulse high here

        // Test Case 2: Send non-matching / random bits
        $display("[%0t] Test Case 2: Driving '01100'", $time);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b0);

        // Test Case 3: Send back-to-back non-overlapping pattern '1010110101'
        $display("[%0t] Test Case 3: Driving back-to-back '1010110101'", $time);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1); // 1st match out = 1
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1);
        drive_bit(1'b0);
        drive_bit(1'b1); // 2nd match out = 1

        #20;
        $display("[%0t] Simulation Finished.", $time);
        $finish;
    end

    // Monitor output changes
    initial begin
        $monitor("Time=%0t | rst=%b | data=%b | state=%s | out=%b", 
                 $time, rst, data, uut.current_state.name(), out);
    end

endmodule
