//
//Date: 2011/09/19
//以北瀚FIFO介面做 FPGA量測
//量測電路: 16-bit 4-tap FIR Filter
//
module top_veriLink_SISO(
    input            SDK_CLK,            //48M Clock
    input            SDK_RSTN,          //寫入bit檔後產生 ﹉﹍﹍﹉ 波形
    //input          APP_CS,            //high when Board open

    output reg       SDK_RD,            //通知FIFO介面 要讀取Data
    output reg       SDK_WR,            //通知FIFO介面 要寫入Data

    input            SDK_Empty,         //讀入的buffer 已空
    input            SDK_AlmostEmpty,   //讀入的buffer 已空
    input            SDK_AlmostFull,    //寫入buffer 剩一個位置
	 

    input      [15:0]SDK_DI,            //讀取FIFO 的資料線
    output reg [15:0]SDK_DO             //寫入FIFO 的資料線
);

wire CS = SDK_RSTN;
wire Empty = SDK_Empty;
wire aEmpty = SDK_AlmostEmpty;
wire aFull= SDK_AlmostFull;

wire Reset = ~CS;
wire [15:0] ckt_data_out;
reg  write_outFF;
reg  ckt_Enable;

//-----------------------量測電路-----------------------
fir_tap4 m_ckt(
    .clk(SDK_CLK),
    .rst(Reset),
    .enable(ckt_Enable),
    .in(SDK_DI),
    .out(ckt_data_out)
);

//-----------------------FIFO 收送狀態機------------------------
    reg [1:0]cur_state; reg [1:0]nex_state;
    parameter Stop   = 2'd0,
	      rExe   = 2'd1,
	      wLast  = 2'd2,
	      rwExe  = 2'd3;

    always @* begin 		//next state control
	nex_state = 2'bxx;
	{SDK_RD,ckt_Enable,write_outFF} = 3'bxxx;
	case(cur_state)
	    Stop:begin	nex_state = ( ~Empty & ~aFull)? rExe :Stop;
	        	{SDK_RD,ckt_Enable,write_outFF} = 3'b000;
		 end
	    rExe:begin	nex_state = ( ~aEmpty & ~aFull)? rwExe:wLast;
	        	{SDK_RD,ckt_Enable,write_outFF} = 3'b110;
		 end
	    wLast:begin	nex_state = Stop;
	        	{SDK_RD,ckt_Enable,write_outFF} = 3'b001;
		 end
	    rwExe:begin	nex_state = ( ~aEmpty & ~aFull)? rwExe:wLast;
	        	{SDK_RD,ckt_Enable,write_outFF} = 3'b111;
		 end
	endcase
    end

    always @(posedge SDK_CLK)	//cur_state  
	if (SDK_RSTN == 1'b0)	cur_state <= Stop;
	else			cur_state <= nex_state;


//-----------------------輸出端Filp-Flop buffer電路--------------
    always @(posedge SDK_CLK, negedge SDK_RSTN)
	if (SDK_RSTN == 1'b0)   SDK_WR <= 1'b0;
	else			SDK_WR <= write_outFF;
	     
    always @(posedge SDK_CLK)
	if (write_outFF == 1'b1) 
			        SDK_DO <= ckt_data_out;

endmodule 
