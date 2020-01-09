module LD_final_project(output reg [7:0] DATA_R, DATA_G, DATA_B,
								output reg [6:0] d7_1, 
								output reg [2:0] COMM, //LED 8*8
								output reg [4:0] Life,
								output reg [1:0] COMM_CLK,//7 segment's enable
								output EN,//LED
								output beep,//sound
								input CLK, clear, Left, Right,
								input L1,L2,L3,pause
								);
	reg [7:0] plate [7:0];//掉落物
	reg [7:0] people [7:0];//user
	reg [6:0] seg1, seg2;
	reg [3:0] bcd_s,bcd_m;//個 十位
	reg [2:0] random01, random02, random03,random04, r, r1, r2,r3;
	reg left, right, temp,beepopen,flag,flag1;
	segment7 S0(bcd_s, A0,B0,C0,D0,E0,F0,G0);//input bcd_s
	segment7 S1(bcd_m, A1,B1,C1,D1,E1,F1,G1);
	divfreq div0(CLK, CLK_div);
	divfreq1 div1(CLK, CLK_time);
	divfreq2 div2(CLK, CLK_mv);
	divfreq3 div3(CLK, CLK_beep);
	byte line, count, count1;
	integer a, b, c,d,touch;//flag左下，flag1右下

//初始值
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
//sound
always@(posedge CLK_beep)
		begin
			if(beepopen==1)
			begin
				beep<=~beep;
				end
			else
				beep<=0;
		end
//7段顯示器的視覺暫留除
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

//計時&進位	
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

//主畫面的視覺暫留	
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

	
//遊戲
always@(posedge CLK_mv)
	begin
		
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
////////////////////////////////////////
			//fall object 1
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
/////////////////////////////////////////	
			//fall object 2
				if(b == 0)
					begin
						plate[r1][b] = 1'b0;
						b = b+1;
					end
				else if (b > 0 && b <= 7)
					begin
						plate[r1][b-1] = 1'b1;
						plate[r1][b] = 1'b0;
						b = b+1;
					end
				else if(b == 8) 
					begin
						plate[r1][b-1] = 1'b1;
						random02 = (5*(random01+1) + 3)%16;
						r1 = random02 % 8;
						
						b = 0;
					end
/////////////////////////////////////////		
			//fall object 3
				if(c == 0)
					begin
						plate[r2][c] = 1'b0;
						c = c+1;
					end
				else if (c > 0 && c <= 7)
					begin
						plate[r2][c-1] = 1'b1;
						plate[r2][c] = 1'b0;
						c = c+1;
					end
				else if(c == 8) 
					begin
						plate[r2][c-1] = 1'b1;
						random03= (5*(random01+2) + 3)%16;
						r2 = random03 % 8;
						c = 0;
					end
/////////////////////////////////////////	
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
		if((L2==1)&&(pause==0))
		begin
		if(bcd_m>0)
		begin
		beepopen<=1;
		people[0] = 8'b11111111;
		people[1] = 8'b11111111;
		people[2] = 8'b11111111;
		people[3] = 8'b11111111;
		people[4] = 8'b11111111;
		people[5] = 8'b11111111;
		people[6] = 8'b11111111;
		people[7] = 8'b11111111;
		plate[0] = 8'b11011011;
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
				if(a == 0)//1x2y
					begin
						plate[r][a] = 1'b0;
						a = a+1;
					end
				else if (a > 0 && a <= 7)
						begin
							plate[r][a-2] = 1'b1;
							plate[r][a] = 1'b1;
							plate[r][a-1] = 1'b0;
							plate[r][a] = 1'b0;
							a = a+1;
						end
				else if(a == 8) 
					begin
						plate[r][a-2] = 1'b1;
						plate[r][a-1] = 1'b1;
						random01 = (5*random01 + 3)%16;
						r = random01 % 8;
						a = 0;
					end
/////////////////////////////////////////	
			//fall object 2
				if(b == 0)//2x1y
					begin
						plate[r1][b] = 1'b0;
						plate[r1+1][b] = 1'b0;
						b = b+1;
					end
				else if (b > 0 && b <= 7)
					begin
						plate[r1][b-1] = 1'b1;
						plate[r1+1][b-1] = 1'b1;
						plate[r1][b] = 1'b0;
						plate[r1+1][b] = 1'b0;
						b = b+1;
					end
				else if(b == 8) 
					begin
						plate[r1][b-1] = 1'b1;
						plate[r1+1][b-1] = 1'b1;
						random02 = (5*(random01+1) + 3)%16;
						r1 = random02 % 8;
						b = 0;
					end
					///////////////////fall object 3 3X2Y
				if(c == 0)
					begin
						plate[r2][c] = 1'b0;
						plate[r2+1][c] = 1'b0;
						plate[r2+2][c] = 1'b0;
						c = c+1;
					end
				else if (c > 0 && c <= 7)
					begin
						plate[r2][c-2] = 1'b1;
						plate[r2+1][c-2] = 1'b1;
						plate[r2+2][c-2] = 1'b1;
						plate[r2][c-1] = 1'b1;
						plate[r2+1][c-1] = 1'b1;
						plate[r2+2][c-1] = 1'b1;
						plate[r2][c] = 1'b0;
						plate[r2+1][c] = 1'b0;
						plate[r2+2][c] = 1'b0;
						plate[r2][c-1] = 1'b0;
						plate[r2+1][c-1] = 1'b0;
						plate[r2+2][c-1] = 1'b0;
						c = c+1;
					end
				else if(c == 8) 
					begin
						plate[r2][c-1] = 1'b1;
						plate[r2][c-2] = 1'b1;
						plate[r2+1][c-1] = 1'b1;
						plate[r2+1][c-2] = 1'b1;
						plate[r2+2][c-1] = 1'b1;
						plate[r2+2][c-2] = 1'b1;
						random03= (5*(random03+3) + 3)%16;
						r2 = random03 % 8;
						c = 0;
					end
/////////////////////////////////////////	
			//people move		
				if((right == 1) && (line != 7))
					begin
						beepopen<=1;
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line + 1;
					end
				if((left == 1) && (line != 0))
					begin
						beepopen<=1;
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line - 1;
					end
				people[line][6] = 1'b0;
				people[line][7] = 1'b0;
		
				if(plate[line][6] == 0)
					begin
						touch = touch + 1;
						plate[r][6] = 1'b1;
						plate[r][5] = 1'b1;
						plate[r1][6] = 1'b1;
						plate[r1+1][6] = 1'b1;
						plate[r2][6] = 1'b1;
						plate[r2][5] = 1'b1;
						plate[r2+1][6] = 1'b1;
						plate[r2+1][5] = 1'b1;
						plate[r2+2][6] = 1'b1;
						plate[r2+2][5] = 1'b1;
						a = 8;
						b = 8;
						c = 8;
					end
				else if (plate[line][7] == 0)
					begin
						touch = touch + 1;
												
						plate[r][7] = 1'b1;
						plate[r][6] = 1'b1;
						plate[r1][7] = 1'b1;
						plate[r1+1][7] = 1'b1;
						plate[r2][7] = 1'b1;
						plate[r2][6] = 1'b1;
						plate[r2+1][7] = 1'b1;
						plate[r2+1][6] = 1'b1;
						plate[r2+2][7] = 1'b1;
						plate[r2+2][6] = 1'b1;
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
			

		end
		end//level 2
		if((L3==1)&&(pause==0))
		begin
		if(bcd_m>0)
		begin
		beepopen<=1;
		people[0] = 8'b11111111;
		people[1] = 8'b11111111;
		people[2] = 8'b11111111;
		people[3] = 8'b11111111;
		people[4] = 8'b11111111;
		people[5] = 8'b11111111;
		people[6] = 8'b11111111;
		people[7] = 8'b11111111;
		plate[0] = 8'b11011011;
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
			flag=0;
			flag1=0;
			
				if(a == 0)//go left down
					begin
						plate[r][a] = 1'b0;
						a = a+1;
					end
				else if (a > 0 && a <= 7)
						begin
							plate[r][a-1] = 1'b1;
							if(r==0)
							begin 
							flag=1;
							end
							if(flag==1)
							begin
							r=r+1;
							end
							if(flag==0)
							begin
							r=r-1;
							end
							plate[r][a] = 1'b0;
							a = a+1;
						end
				else if(a == 8) 
					begin
						plate[r][a-1] = 1'b1;
						random01 = (5*random01 + 3)%16;
						r = random01 % 8;
						a = 0;
						flag=0;
					end
/////////////////////////////////////////	
			//fall object 2 go right down
				if(b == 0)
					begin
						plate[r1][b] = 1'b0;
						b = b+1;
					end
				else if (b > 0 && b <= 7)
					begin
						plate[r1][b-1] = 1'b1;
						if(r1==7)
						begin
						flag1=1;
						end
						if(flag1==1)
						begin
						r1=r1-1;
						end
						if(flag1==0)
						begin
						r1=r1+1;
						end
						plate[r1][b] = 1'b0;
						b = b+1;
					end
				else if(b == 8) 
					begin
						plate[r1][b-1] = 1'b1;
						random02 = (5*(random01+1) + 3)%16;
						r1 = random02 % 8;
						b = 0;
						flag1=0;
					end
/////////////////////////////////////////		
			//fall object 3
				if(c == 0)
					begin
						plate[r2][c] = 1'b0;
						c = c+1;
					end
				else if (c > 0 && c <= 7)
					begin
						plate[r2][c-1] = 1'b1;
						plate[r2][c] = 1'b0;
						c = c+1;
					end
				else if(c == 8) 
					begin
						plate[r2][c-1] = 1'b1;
						random03= (5*(random01+2) + 3)%16;
						r2 = random03 % 8;
						c = 0;
					end
				if(d == 0)//2x1y
					begin
						plate[r3][d] = 1'b0;
						plate[r3+1][d] = 1'b0;
						d = d+1;
					end
				else if (d > 0 && d <= 7)
					begin
						plate[r3][d-1] = 1'b1;
						plate[r3+1][d-1] = 1'b1;
						plate[r3][d] = 1'b0;
						plate[r3+1][d] = 1'b0;
						d = d+1;
					end
				else if(d == 8) 
					begin
						plate[r3][d-1] = 1'b1;
						plate[r3+1][d-1] = 1'b1;
						random04 = (5*(random04+4) + 3)%16;
						r3 = random04 % 8;
						d = 0;
					end
/////////////////////////////////////////	
			//people move		
				if((right == 1) && (line != 7))
					begin
						beepopen<=1;
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line + 1;
					end
				if((left == 1) && (line != 0))
					begin
						beepopen<=1;
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line - 1;
					end
				people[line][6] = 1'b0;
				people[line][7] = 1'b0;
		
				if(plate[line][6] == 0)
					begin
						touch = touch + 1;
						plate[r][6] = 1'b1;
						
						plate[r1][6] = 1'b1;
						
						plate[r2][6] = 1'b1;
						plate[r3][6]=1'b1;
						plate[r3+1][6]=1'b1;
						a = 8;
						b = 8;
						c = 8;
						d = 8;
					end
				else if (plate[line][7] == 0)
					begin
						touch = touch + 1;
												
						plate[r][7] = 1'b1;
						
						plate[r1][7] = 1'b1;
						
						plate[r2][7] = 1'b1;
						plate[r3][7]=1'b1;
						plate[r3+1][7]=1'b1;
						a = 8;
						b = 8;
						c = 8;
						d = 8;
						
					end
				
			end
			//game over 
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
			

		end//>10
		end//level 3

	end
	
endmodule


//秒數轉7段顯示器
module segment7(input [0:3] a, output A,B,C,D,E,F,G);


	
	assign A = ~(a[0]&~a[1]&~a[2] | ~a[0]&a[2] | ~a[1]&~a[2]&~a[3] | ~a[0]&a[1]&a[3]),
	       B = ~(~a[0]&~a[1] | ~a[1]&~a[2] | ~a[0]&~a[2]&~a[3] | ~a[0]&a[2]&a[3]),
			 C = ~(~a[0]&a[1] | ~a[1]&~a[2] | ~a[0]&a[3]),
			 D = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[2]&~a[3] | ~a[0]&a[1]&~a[2]&a[3] | ~a[1]&~a[2]&~a[3]),
			 E = ~(~a[1]&~a[2]&~a[3] | ~a[0]&a[2]&~a[3]),
			 F = ~(~a[0]&a[1]&~a[2] | ~a[0]&a[1]&~a[3] | a[0]&~a[1]&~a[2] | ~a[1]&~a[2]&~a[3]),
			 G = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[1]&~a[2] | ~a[0]&a[2]&~a[3]);
			 
endmodule


		
//視覺暫留除頻器
module divfreq(input CLK, output reg CLK_div);
  reg [24:0] Count;
  always @(posedge CLK)
    begin
      if(Count > 3000)
        begin
          Count <= 25'b0;
          CLK_div <= ~CLK_div;
        end
      else
      Count <= Count + 1'b1;
    end
endmodule

//計時除頻器
module divfreq1(input CLK, output reg CLK_time);
  reg [25:0] Count;
  initial
    begin
      CLK_time = 0;
	 end	
		
  always @(posedge CLK)
    begin
      if(Count > 25000000)
        begin
          Count <= 25'b0;
          CLK_time <= ~CLK_time;
        end
      else
      Count <= Count + 1'b1;
    end
endmodule 

//掉落物&人物移動除頻器
module divfreq2(input CLK, output reg CLK_mv);
  reg [35:0] Count;
  initial
    begin
      CLK_mv = 0;
	 end	
		
  always @(posedge CLK)
    begin
      if(Count > 3500000)
        begin
          Count <= 35'b0;
          CLK_mv <= ~CLK_mv;
        end
      else
      Count <= Count + 1'b1;
    end
endmodule 
//聲音除頻器 
module divfreq3(input CLK, output reg CLK_beep);
	reg [24:0] Count;
initial
    begin
      CLK_beep = 0;
	 end	
	always @(posedge CLK)
	begin
		if(Count > 5000000)
		begin
			Count <= 25'b0;
			CLK_beep <= ~CLK_beep;
		end
		else
			Count <= Count + 1'b1;
	end
endmodule
