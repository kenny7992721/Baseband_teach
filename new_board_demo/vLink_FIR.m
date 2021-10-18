clear;clc;close all

%%Program .bit file tp FPGA
smMatVLXSP6(0, 'Program','top_verilink_siso.bit');

data_num = 100;
test_data = randi([-50,50], data_num, 1, 'single');


%% Matlab Simulation
m_result = filter([-17 4 -10 3],1,  test_data);

%% FPGA Simulation
%將float整數轉換為binary給FPGA
data_wFPGA = cast(test_data,'int16');  %值map為 int16
data_wFPGA = typecast(data_wFPGA,'uint16'); %值轉換為unsigned表示


% Open FPGA Board and set serial number.
smMatVLXSP6(0, 'Open', 'H6RX-L0V6-K0D0-8W19-FF04-AC80');

%Write to FPGA Board
smMatVLXSP6(0, 'Write', data_wFPGA, data_num);

%Read From FPGA Board
[ret readbuf] = smMatVLXSP6(0, 'Read', data_num);
%readbuf = typecast(readbuf,'int16');
readbuf = cast(readbuf, 'uint16');
readbuf = typecast(readbuf, 'int16');
readbuf.';
%close FPGA Board
smMatVLXSP6(0, 'Close');

%% 
stem(1:data_num, m_result,    'MarkerSize',5,'LineWidth',1.2,'Color',[0 0 1]);
hold on 
plot(1:data_num, readbuf,    'MarkerSize',5,'Marker','*','LineStyle','none', 'Color',[1 0 0]);
if isequal(readbuf,m_result)
    fprintf('compare result is MACH\n');
else
    fprintf('compare result is unmach\n');
end
    
