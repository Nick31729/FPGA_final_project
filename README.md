FPGA_Final_Project
==================

Authors:<br>
-------------
107321013 107321043<br>
<br>Input/Output unit:要放圖片<br>
---------------------
input:clear,左,右,三顆按鍵選關卡,最右邊pause<br>
clear:清除版面，重置設定<br>
左,右:移動人物<br>
三顆按鍵:由左至右1、2、3選擇關卡<br>
pause:暫停遊戲<br>

<br>output:LED燈，七段顯示器，8X8顯示器，蜂鳴器<br>
LED燈:顯示血量<br>
七段顯示器:顯示過了幾秒<br>
8X8顯示器:顯示遊戲畫面<br>
蜂鳴器:左右移動和勝利失敗會發出聲音<br>
<br>功能說明:<br>
-----------
<br>左右閃躲隨機掉落物，超過10秒獲勝，或是被掉落物撞到5次5格生命用完即失敗<br>

<br>程式模組說明:<br>
------------
input/output:
```verilog
output reg [7:0] DATA_R, DATA_G, DATA_B,
output reg [6:0] d7_1, 
output reg [2:0] COMM, //LED 8*8
output reg [4:0] Life,
output reg [1:0] COMM_CLK,//7 segment's enable
output EN,//LED
output beep,//sound
input CLK, clear, Left, Right,
input L1,L2,L3,pause
```
<br>DATA_R, DATA_G, DATA_B接到8X8顯示器<br>
d7_1接到七段顯示器<br>
COMM接到8X8顯示器<br>
Life接到LED燈<br>
COMM_CLK接到七段顯示器的enable<br>
EN接到8x8的enable<br>
beep接到蜂鳴器<br>
CLK為內建的clock，clear、Left、Right接到4-bit SW<br>
L1、L2、L3、pause接到紅色指撥開關<br>

*** 請說明各 I/O 變數接到哪個 FPGA I/O 裝置，例如: button, button2 -> 接到 4-bit SW<br><br>
*** 請加強說明程式邏輯<br>
<br>Demo video:<br>
----------------
[  要顯示的文字 ](  鏈接的地址 )<br>
