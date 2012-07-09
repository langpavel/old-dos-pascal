Program Test24LC64_1pokus;
uses CRT,DOS;
const ADDR   :word=$378;
{
 NAPAJENI na DATA 5,6,7 a GND

 SCL zapojeno na DATA0 - pin 2  (na LPT)    bit 0 BA+0
 SDA zapojeno na /STROBE - pin 1  (na LPT)  bit 0 BA+2 inverted!!

}

Procedure Cekej;
 begin
  Delay(10);
  ReadKey;
 end;

Procedure Init;
 begin
  Port[ADDR]:=255;
  Port[ADDR+2]:=0;  { log 1 na vystupu }
  Delay(1000);
 end;

Procedure ClkWr;    { Pouze na zapis !!! }
 begin
  Port[ADDR]:=255;
  Cekej;
  Port[ADDR]:=254;
  Cekej;
 end;

Function ClkRd:byte; {0,1}
 var a:byte;
 begin
  Port[ADDR+2]:=0;
  Cekej;
  Port[ADDR]:=255;
  Cekej;
  A:=Port[ADDR+2];
  a:=(NOT A) AND 1;
  Port[ADDR]:=254;
  Cekej;
  ClkRd:=a;
  Write(a);
 end;

Procedure Start;
 begin
  Cekej;
  Port[ADDR+2]:=0;
  Cekej;
  Port[ADDR]:=255;
  Cekej;
  Port[ADDR+2]:=1; {~~\__ na data}
  Cekej;
  Port[ADDR]:=254;
  Cekej;
  Write('~\_ ');
  Cekej;
 end;

Procedure Stop;
 begin
  Cekej;
  Port[ADDR+2]:=1;
  Cekej;
  Port[ADDR]:=255;
  Cekej;
  Port[ADDR+2]:=0; {__/~~ na data}
  Cekej;
  Port[ADDR]:=254;
  WriteLn('_/~');
  Cekej;
 end;
(***********************************************)
Procedure AckWr;   { Pouze na zapis !!! }
 var i:longint;
 begin
  Port[ADDR+2]:=0;
  Cekej;
  Port[ADDR]:=255;
  Cekej;
  Cekej;
  Cekej;
  Cekej;
  Write(' Aw',(NOT Port[ADDR+2]) AND 1,'; ');
  Port[ADDR]:=254;
  Cekej;
 end;

Procedure AckRd;
 begin
  Port[ADDR+2]:=1;
  Cekej;
  Port[ADDR]:=255;
  Cekej;
  Cekej;
  Cekej;
  Cekej;
  Write(' Ar',(NOT Port[ADDR+2]) AND 1,'; ');
  Port[ADDR]:=254;
  Cekej;
  Port[ADDR+2]:=0;
 end;



Procedure Outb(B:byte); {send one bit}
 begin
    if (b<>0) then
     begin
      Write('1');
      Port[ADDR+2]:=0; {"1"}
     end
    else
     begin
      Write('0');
      Port[ADDR+2]:=1; {"0"}
     end;
    ClkWr;
{    ReadKey;}
 end;

Procedure VysliB(b:byte);
 var a,c:byte;
 begin
  a:=b;
  for c:=0 to 7 do
   begin
    outb((a AND 128));
    a:= a SHL 1;
   end;
  AckWr;
 end;

(***************************************************************************)

Function CtiB:byte;
 var a,c:byte;
 begin
  a:=0;
  for c:=0 to 7 do
   begin
    A:=(A SHL 1) + ClkRd;
   end;
  AckRd;
  CtiB:=A;
 end;

Procedure ByteWrite(A:Word;B:Byte);
 begin
  Start;
  VysliB($A0);
  VysliB(A div 256);
  VysliB(A mod 256);
  VysliB(B);
  Stop;
 end;

Function ByteRead(A:Word):Byte;
 begin
  Start;
  VysliB($A0);
  VysliB(A div 256);
  VysliB(A mod 256);
  Stop;
  Start;
  VysliB($A1);
  ByteRead:=CtiB;
  Stop;
 end;

begin
 ClrScr;
 Init;
{ ByteWrite(0,5);}
 WriteLn(ByteRead(5));
 Readkey;
end.
