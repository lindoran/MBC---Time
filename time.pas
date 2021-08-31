module time;
{RTC and timer code (C) d. collins 2021 - use at own risk, free to 
 distribute.   This module contians routines for using the real time clock 
 module (DS3231)  as well as a 555 timer wired to pin 7 and 1 of PORT B
 of the GPIO for use with the GPIO Games Adapter for tracking 10ms intervals
 
 MIT License

Copyright (c) 2021 Dave Collins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.}
 
 
   {     MBC Expansion Port      
       GPIO GAME ADDAPTER CONN.  
     UP = U  DOWN = D lEFT = l   
        RIGHT = R  FIRE = F      
	555 TRIGGER = TRG (HIGH TRIGGERS)	
	555 EXPIRED = EXP (LOW = EXPIRED
	                   HIGH = RUNNING) 
    PASSIVE BUZZER = SND
	
        VCC   F U D L R   GND       
        |     | | | | |   |			  
       +5 1 2 3 4 5 6 7 8 GND    
        * * * * * * * * * * GPIO PORT A  
        * * * * * * * * * * GPIO PORT B  
          |           | |      
    	 EXP        TRG SND            }
 
TYPE 
  Timestamp  = array [0..6] of byte;

VAR
 CounterStart   : TimeStamp;
 CurrentTime    : TimeStamp;
 
CONST
  RTCOpcode = 132;
  minseconds = 60;
 
Procedure Init555Timer;
begin
 out[1] := 6;           (* SET WRITE Port B OPCODE *)
 out[0] := 63;          (* 00111111 - Enables bits 7,6 for writeing on port B*)
end;                     (* bit 7 is enabled for write due to sound module *)

Procedure Start555;
begin
 out[1] := 4;           (* WRITE PIN Port B OPCODE *)
 out[0] := 64;          (* 01000000 - Signal bit 6 to triger 555 *)
 out[1] := 4;
 out[0] := 63;          (* 00111111 - Terminate bit 6 *)
end;                     (* Be careful not to use 1 in bit 6 on sound writes*)

function Expired555 : boolean;
begin
 out[1] := 130; (* Read Port b OPCODE *)
 if (inp[0] = 0) then Expired555 := TRUE else Expired555 := FALSE;
end;

{delay counter using the 555 timer and an integer input practcal range
 is 11 - 32756ms with a resolution period of 11ms}
procedure delay(ms : integer);
var 
 count : integer;
begin
 count := 0;
 start555;
 while(count < ms) do 
  if expired555 = true then 
   begin
    count := count + 11;
    start555;
   end;
end;

 
{this gets the current seconds from the timer and outputs very quickly}
function RTCGetSec : integer;
begin 
 out[1] := RTCOpcode;
 RTCGetSec := inp[0];
end;
 
{this gets the time from the Z80MBC2 RTC module}
Procedure RTCGetTime;
var
 a:integer;
begin
 out[1] := RTCOpcode;
 for a := 0 to 6 do CurrentTime[a] := inp[0];
end;

{this time stamps the counter function to zero}
procedure RTCZeroCounter;
begin
 RTCGetTime;
 CounterStart := CurrentTime;
end;

{this outputs a number of seconds from the time stamp, it will output 0
 if the counter is left to go over 1 hour, this is to keep the math
 within the type limit for a basic intiger }

function RTCCounter : integer;
var
 timer : Timestamp;
 startsec,seconds : integer;

begin
 seconds := 0;
 startsec := 0;
 RTCGetTime;
 timer := CurrentTime;
 if timer[2] <> CounterStart[2] then
  begin
   RTCZeroCounter;
   RTCCounter := 0; {you will need to account for the counter resetting every hour}
   exit;
  end;
 {calculate start seconds}
 startsec := (CounterStart[1] * minseconds) + CounterStart[0];
 {calculate elapsed seconds}
 seconds := (timer[1] * minseconds) + timer[0];
 RTCCounter := seconds - startsec;
end;
modend.

