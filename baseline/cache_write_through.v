module cache
(
  //input clock,
  input reset,
  input cpuRead,
  input cpuWrite,
  input [`MEM_ADDR_SIZE-1:0] cpuAddr,
  input [`WORD_SIZE_BIT-1:0] cpuData,
  input [`WORD_SIZE_BIT-1:0] memData,
  input done_w,
  input done_r,
  
  output reg hit,
  output reg read,
  output reg write,
  output reg [`WORD_SIZE_BIT-1:0] rData,
  output reg [`MEM_ADDR_SIZE-1:0] addr,
  output reg [`WORD_SIZE_BIT-1:0] wData
);

reg valid [3:0];
reg dirty [3:0];
reg [`MEM_ADDR_SIZE-7:0] tag [3:0];


reg [`WORD_SIZE_BIT-1:0] block [3:0][3:0];

wire [1:0] blockOffset;
wire [1:0] wordOffset;
wire [`MEM_ADDR_SIZE-7:0] tag_temp;

assign blockOffset = cpuAddr[5:4];
assign wordOffset = cpuAddr[3:2];
assign tag_temp=cpuAddr[`WORD_SIZE_BIT-1:6];
//assign blockAddr=cpuAddr[9:4];
//assign hit=(tag_temp==tag[blockOffset])&&(valid[blockOffset]==1'b1);


integer i;
//initialization
initial
begin
for(i=0;i<=3;i=i+1)
begin
  dirty[i] = 1'b0;
  valid[i] = 1'b0;
  tag[i] = 4'b0;
  block[0][i] = 32'b0;
  block[1][i] = 32'b0;
  block[2][i] = 32'b0; 
  block[3][i] = 32'b0;
  
end
  hit = 1'b0;
  read = 1'b0;
  write = 1'b0;
  addr = 'bz;
  rData = 'bz;
  wData = 'bz;
end



always @( *)begin
  hit=0;
  if (cpuRead==1'b1)begin// read data 
      if ( (tag_temp==tag[blockOffset])&&(valid[blockOffset]==1'b1)) begin //case of hit
          case (blockOffset)
              2'b00: rData =  block[0][wordOffset][31:0];
              2'b01: rData = block[1][wordOffset][31:0];
              2'b10: rData = block[2][wordOffset][31:0];
              2'b11: rData = block[3][wordOffset][31:0];
          endcase
          hit=1;
      end else begin //case of miss
          
      
      
      
          hit =0;
          read=1;
          write=0;//read for the whole block
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b0000};
          #22 read=0;
          @ (posedge done_r) read=1;
          case (blockOffset)
              2'b00: block[0][0][31:0]=memData;
              2'b01: block[1][0][31:0]=memData;
              2'b10: block[2][0][31:0]=memData;
              2'b11: block[3][0][31:0]=memData;
          endcase
          
          
          
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b0100};
          #22 read=0;
          @ (posedge done_r) read=1;
          case (blockOffset)
              2'b00: block[0][1][31:0]=memData;
              2'b01: block[1][1][31:0]=memData;
              2'b10: block[2][1][31:0]=memData;
              2'b11: block[3][1][31:0]=memData;
          endcase
          #10
          
          
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b1000};
          #22 read=0;
          @ (posedge done_r) read=1;
          case (blockOffset)
              2'b00: block[0][2][31:0]=memData;
              2'b01: block[1][2][31:0]=memData;
              2'b10: block[2][2][31:0]=memData;
              2'b11: block[3][2][31:0]=memData;
          endcase
          #10
          
         
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b1111};
          #22 read=0;
          @ (posedge done_r) read=1;
          case (blockOffset)
              2'b00: block[0][3][31:0]=memData;
              2'b01: block[1][3][31:0]=memData;
              2'b10: block[2][3][31:0]=memData;
              2'b11: block[3][3][31:0]=memData;
          endcase
         
          
          tag[blockOffset]=tag_temp;
          valid[blockOffset]=1;
          // read data from the block
          case (blockOffset)
              2'b00: rData =  block[0][wordOffset][31:0];
              2'b01: rData = block[1][wordOffset][31:0];
              2'b10: rData = block[2][wordOffset][31:0];
              2'b11: rData = block[3][wordOffset][31:0];
          endcase
          hit=1;
      end
  end else //else if write data
  
  if (cpuWrite==1'b1)begin
      if ( (tag_temp==tag[blockOffset])&&(valid[blockOffset]==1'b1)) begin  // case of hit
          case (blockOffset) // change data in block
              2'b00: block[0][wordOffset][31:0]=cpuData;
              2'b01: block[1][wordOffset][31:0]=cpuData;
              2'b10: block[2][wordOffset][31:0]=cpuData;
              2'b11: block[3][wordOffset][31:0]=cpuData;
          endcase
          read=0;
          write=1; // write through, change data in memory
          addr=cpuAddr;
          wData=cpuData;
          @ (posedge done_w)begin
            hit=1;
          end
          
      end else begin // case of miss
          hit =0;
          read=1;// read data for the whole block from the memory
          write=0;
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b0000};
          #22 read = 0;
          @(posedge done_r) read  = 1;
          case (blockOffset)
              2'b00: block[0][0][31:0]=memData;
              2'b01: block[1][0][31:0]=memData;
              2'b10: block[2][0][31:0]=memData;
              2'b11: block[3][0][31:0]=memData;
          endcase
         
          
          
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b0100};
          #22 read = 0;
          @(posedge done_r) read  = 1;
       
          case (blockOffset)
              2'b00: block[0][1][31:0]=memData;
              2'b01: block[1][1][31:0]=memData;
              2'b10: block[2][1][31:0]=memData;
              2'b11: block[3][1][31:0]=memData;
          endcase
          
          
          
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b1000};
          #22 read = 0;
          @(posedge done_r) read  = 1;
          case (blockOffset)
              2'b00: block[0][2][31:0]=memData;
              2'b01: block[1][2][31:0]=memData;
              2'b10: block[2][2][31:0]=memData;
              2'b11: block[3][2][31:0]=memData;
          endcase
          
          
          addr={cpuAddr[`MEM_ADDR_SIZE-1:4],4'b1111};
          #22 read = 0;
          @(posedge done_r) read  = 1;
          case (blockOffset)
              2'b00: block[0][3][31:0]=memData;
              2'b01: block[1][3][31:0]=memData;
              2'b10: block[2][3][31:0]=memData;
              2'b11: block[3][3][31:0]=memData;
          endcase
          
          
          tag[blockOffset]=tag_temp;
          valid[blockOffset]=1;
          
          case (blockOffset) //write data into the block
              2'b00: block[0][wordOffset][31:0]=cpuData;
              2'b01: block[1][wordOffset][31:0]=cpuData;
              2'b10: block[2][wordOffset][31:0]=cpuData;
              2'b11: block[3][wordOffset][31:0]=cpuData;
          endcase
          read=0;
          write=1; // write through, write data into memory
          addr=cpuAddr;
          wData=cpuData;
          @ (posedge done_w)begin
            hit=1;
          end
      end
  end
  
  
  
end


endmodule
