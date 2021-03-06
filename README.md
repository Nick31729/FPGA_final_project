FPGA_Final_Project
==================

Authors: <br>
-------------

107321013 107321043<br>

Input/Output unit:<br>
---------------------
INPUT: clear,左,右<br>
clear:清除版面，重置設定<br>
左,右:移動人物<br>
[ 圖1 ](  https://user-images.githubusercontent.com/59498380/72051840-f4e5bc00-32fe-11ea-8c09-dff5b544ec7f.jpg )<br>
三顆按鍵選關卡,最右邊pause<br>
三顆按鍵:由左至右1、2、3選擇關卡<br>
pause:暫停遊戲<br>
[ 圖2 ](  https://user-images.githubusercontent.com/59498380/72051837-f44d2580-32fe-11ea-93d6-be4e9794aac7.jpg )<br>
OUTPUT:  LED燈，七段顯示器，8X8顯示器，蜂鳴器<br>
LED燈:顯示血量<br>
[ 圖3 ](  https://user-images.githubusercontent.com/59498380/72051843-f7481600-32fe-11ea-9734-466c9b8a29b3.jpg )<br>
七段顯示器:顯示過了幾秒<br>
[ 圖4 ](  https://user-images.githubusercontent.com/59498380/72051849-f911d980-32fe-11ea-9980-c854519f1123.jpg )<br>
8X8顯示器:顯示遊戲畫面<br>
[ 圖5 ](  https://user-images.githubusercontent.com/59498380/72051817-e8616380-32fe-11ea-8e73-0fd5c70ccd01.jpg )<br>
蜂鳴器:左右移動和勝利失敗會發出聲音<br>
[ 圖6 ](  https://user-images.githubusercontent.com/59498380/72051829-f0210800-32fe-11ea-9b7b-6ee3ba4a11a4.jpg )<br>

<br>功能說明:<br>
-----------
<br>左右閃躲隨機掉落物，超過10秒獲勝，或是被掉落物撞到5次，5格生命用完即失敗<br>

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
<br>DATA_R, DATA_G, DATA_B : 接到8X8顯示器<br>
d7_1 : 接到七段顯示器<br>
COMM : 接到8X8顯示器<br>
Life : 接到LED燈<br>
COMM_CLK : 接到七段顯示器的enable<br>
EN : 接到8x8的enable<br>
beep : 接到蜂鳴器<br>
CLK : 為內建的clock<br>
clear、Left、Right : 接到藍色按鈕<br>
L1、L2、L3、pause : 接到紅色4-bit SW<br>

```verilog
initial
		begin
			bcd_m = 0;
			bcd_s = 0;
			line = 3;//人的位置
			random01 = (5*random01 + 3)%16;
			r = random01 % 8;
			random02 = (5*(random02+1) + 3)%16;
			r1 = random02 % 8;
			random03= (5*(random03+2) + 3)%16;
			r2 = random03 % 8;
			random04= (5*(random04+4) + 3)%16;
			r3 = random04 % 8;
			a = 0;
			b = 0;
			c = 0;
			d=0;
			touch = 0;
			DATA_R = 8'b11111111;
			DATA_G = 8'b11111111;
			DATA_B = 8'b11111111;
			plate[0] = 8'b11111111;
			plate[1] = 8'b11111111;
			plate[2] = 8'b11111111;
			plate[3] = 8'b11111111;
			plate[4] = 8'b11111111;
			plate[5] = 8'b11111111;
			plate[6] = 8'b11111111;
			plate[7] = 8'b11111111;
			people[0] = 8'b11111111;
			people[1] = 8'b11111111;
			people[2] = 8'b11111111;
			people[3] = 8'b00111111;
			people[4] = 8'b11111111;
			people[5] = 8'b11111111;
			people[6] = 8'b11111111;
			people[7] = 8'b11111111;
			count1 = 0;
			beepopen<=0;
		end
 ```
初始化各項參數，其中random初始化各項參數，其中random01~04是用來取得隨機數的是用來取得隨機數的。<br>
```verilog
always@(posedge CLK_beep)
		begin
			if(beepopen==1)
			begin
				beep<=~beep;
				end
			else
				beep<=0;
		end
```
產生聲音的模組，beepopen=1時beep會反覆開關
```verilog
always@(posedge CLK_div)
	begin
		seg1[0] = A0;//bcd_s
		seg1[1] = B0;
		seg1[2] = C0;
		seg1[3] = D0;
		seg1[4] = E0;
		seg1[5] = F0;
		seg1[6] = G0;
		
		seg2[0] = A1;//bcd_m
		seg2[1] = B1;
		seg2[2] = C1;
		seg2[3] = D1;
		seg2[4] = E1;
		seg2[5] = F1;
		seg2[6] = G1;
		
		if(count1 == 0)//顯示個位
			begin
			d7_1 <= seg1;
			COMM_CLK[1] <= 1'b1;//不亮
			COMM_CLK[0] <= 1'b0;//亮
			count1 <= 1'b1;//將顯示十位
			end
		else if(count1 == 1)//顯示十位
			begin
			d7_1 <= seg2;
			COMM_CLK[1] <= 1'b0;
			COMM_CLK[0] <= 1'b1;
			count1 <= 1'b0;
			end
	end
```
```verilog
always@(posedge CLK_time, posedge clear)
	begin
		if(clear)
			begin
				bcd_m = 4'b0;
				bcd_s = 4'b0;
			end
		else
			begin
				if((touch < 5)&&(bcd_m<1)&&(pause==0))
				begin
				if(bcd_s >= 9)
				begin
				bcd_s <= 0;
				bcd_m <= bcd_m + 1;
				end
				else
				bcd_s <= bcd_s + 1;
				if(bcd_m > 9) bcd_m <= 0;
				end
			end
	end
```
4位元讓他可以數到9，bcd_m是十位數，bcd_s是個位數，數到9會進位<br>
clear會重置為0<br>
```verilog
always@(posedge CLK_div)
	begin
		if(count >= 7)//依序點亮0~7排
			count <= 0;
		else
			count <= count + 1;
		COMM = count;//控制顯示哪一排
		EN = 1'b1;
		if(touch < 5)//遊戲進行中
			begin
			DATA_G <= plate[count];
			DATA_R <= people[count];
			if(touch == 0)//LED
			Life <= 5'b11111;
			else if(touch == 1)
			Life <= 5'b11110;
			else if(touch == 2)
			Life <= 5'b11100;
			else if(touch == 3)
			Life <= 5'b11000;
			else if(touch == 4)
			Life <= 5'b10000;
			end
		else
			begin
			DATA_R <= plate[count];
			DATA_G <= 8'b11111111;
			Life <= 5'b00000;
			end
	end
```
Life是指LED燈<br>
```verilog
right = Right;
		left = Left;	
		beepopen<=0;
		if(clear == 1)
			
				begin

				touch = 0;
				line = 3;
				a = 0;
				b = 0;
				c = 0;
				d = 0;
				random01 = (5*random01 + 3)%16;
				r = random01 % 8;
				random02 = (5*(random02+1) + 3)%16;
				r1 = random02 % 8;
				random03= (5*(random03+2) + 3)%16;
				r2 = random03 % 8;
				random04= (5*(random04+4) + 3)%16;
				r3 = random04 % 8;
				plate[0] = 8'b11111111;
				plate[1] = 8'b11111111;
				plate[2] = 8'b11111111;
				plate[3] = 8'b11111111;
				plate[4] = 8'b11111111;
				plate[5] = 8'b11111111;
				plate[6] = 8'b11111111;
				plate[7] = 8'b11111111;
				people[0] = 8'b11111111;
				people[1] = 8'b11111111;
				people[2] = 8'b11111111;
				people[3] = 8'b00111111;
				people[4] = 8'b11111111;
				people[5] = 8'b11111111;
				people[6] = 8'b11111111;
				people[7] = 8'b11111111;
				beepopen<=0;
				end
```
clear後初始化參數<br>
```verilog
		if((L1==1)&&(pause==0))
		begin
		if(bcd_m>0)
		begin
		beepopen<=1;
		people[0] = 8'b11111111;//將人消除
		people[1] = 8'b11111111;
		people[2] = 8'b11111111;
		people[3] = 8'b11111111;
		people[4] = 8'b11111111;
		people[5] = 8'b11111111;
		people[6] = 8'b11111111;
		people[7] = 8'b11111111;
		plate[0] = 8'b11011011;//WIN :)
		plate[1] = 8'b10011101;
		plate[2] = 8'b01011011;
		plate[3] = 8'b01011111;
		plate[4] = 8'b01011111;
		plate[5] = 8'b01011011;
		plate[6] = 8'b10011101;
		plate[7] = 8'b11011011;
		end
		else
		begin
		if(touch < 5)
			begin
				if(a == 0)
				begin
				plate[r][a] = 1'b0;
				a = a+1;
				end
				else if (a > 0 && a <= 7)
				begin
				plate[r][a-1] = 1'b1;
				plate[r][a] = 1'b0;
				a = a+1;
				end
				else if(a == 8) 
				begin
				plate[r][a-1] = 1'b1;
				random01 = (5*random01 + 3)%16;
				r = random01 % 8;
				a = 0;
				end
```
先選關卡，pause!=1則開始關卡，bcd_m>1表示超過10秒遊戲勝利。<br>
a=0表示Y軸在0，點亮1隨機掉落物，a=0~7:先熄滅上一個位置再點亮新Y軸位置。<br>
a=8:表示掉到底部了，熄滅後產生新的隨機位置。<br>
以下各物件以此類推<br>
```verilog
//people move		
				if((right == 1) && (line != 7))
				begin
				beepopen<=1;
				people[line][6] = 1'b1;
				people[line][7] = 1'b1;
				line = line + 1;	
				end
				if((left == 1) && (line != 0))//先消再亮
				begin
				beepopen<=1;
				people[line][6] = 1'b1;
				people[line][7] = 1'b1;
				line = line - 1;
						
				end
				people[line][6] = 1'b0;
				people[line][7] = 1'b0;
		
			if(plate[line][6] == 0)//撞到(在人的地方亮)
				begin
				touch = touch + 1;
				plate[r][6] = 1'b1;
						
				plate[r1][6] = 1'b1;
						
				plate[r2][6] = 1'b1;
						
				a = 8;
				b = 8;
				c = 8;
				end
			else if (plate[line][7] == 0)
			begin
			touch = touch + 1;
												
			plate[r][7] = 1'b1;
						
			plate[r1][7] = 1'b1;
					
			plate[r2][7] = 1'b1;
			a = 8;
			b = 8;
			c = 8;
						
			end
					
				
		end
			//game over ---> GG
		else
		begin
		beepopen<=1;
		plate[0] = 8'b01111101;
		plate[1] = 8'b10111011;
		plate[2] = 8'b11011101;
		plate[3] = 8'b11011111;
		plate[4] = 8'b11011111;
		plate[5] = 8'b11011101;
		plate[6] = 8'b10111011;
		plate[7] = 8'b01111101;
		end
		end//>15
		end//L 1
```
不管是在人的兩格其中一格碰到都會扣分，掉落物碰到即消除<br>
以下2.3關概念相同<br>
```verilog
module segment7(input [0:3] a, output A,B,C,D,E,F,G);
	assign A = ~(a[0]&~a[1]&~a[2] | ~a[0]&a[2] | ~a[1]&~a[2]&~a[3] | ~a[0]&a[1]&a[3]),
	       B = ~(~a[0]&~a[1] | ~a[1]&~a[2] | ~a[0]&~a[2]&~a[3] | ~a[0]&a[2]&a[3]),
		C = ~(~a[0]&a[1] | ~a[1]&~a[2] | ~a[0]&a[3]),
		D = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[2]&~a[3] | ~a[0]&a[1]&~a[2]&a[3] | ~a[1]&~a[2]&~a[3]),
		E = ~(~a[1]&~a[2]&~a[3] | ~a[0]&a[2]&~a[3]),
		F = ~(~a[0]&a[1]&~a[2] | ~a[0]&a[1]&~a[3] | a[0]&~a[1]&~a[2] | ~a[1]&~a[2]&~a[3]),
		G = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[1]&~a[2] | ~a[0]&a[2]&~a[3]);
			 
endmodule
```
符合的條件取補數才能點亮7段顯示器<br>

<br>Demo video:<br>
----------------
[ 實際影片 ](  https://drive.google.com/open?id=1bDPZdaXdy9TPSILRYz-iKI4iSlz8mOq6 )<br>
