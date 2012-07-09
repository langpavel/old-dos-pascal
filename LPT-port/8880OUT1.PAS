Program LPT2_vystup_na_MT8880;
uses CRT,DOS;

Procedure Zapis(B:Byte;RS0:Byte);
 begin
  Port[$278]:=B+RS0*16;
  Delay(1);
  Port[$27A]:=0;
  Delay(1);
  Port[$27A]:=1;
  Delay(1);
 end;

Procedure Reset;
 begin
  Delay(10);
  Port[$27A]:=1;
  Delay(10);
  Zapis(0,1);
  Zapis(0,1);
  Zapis(8,1);
  Zapis(0,1);
 end;

Procedure Vysilej(Ton:Byte;Long:Boolean);
 begin
  If Long then Zapis(8+4+2+1,1) else Zapis(8+4+1,1);
  Zapis(0,1);
  Zapis(Ton,0);
 end;

Procedure Ondrus;
 begin
  Vysilej(2,true);   Delay(500);
  Vysilej(1,false);  Delay(500);
  Vysilej(1,false);  Delay(500);
  Vysilej(0,false);  Delay(500);
  Vysilej(5,false);
 end;

Procedure TestTelecom;
 begin
  Vysilej(1,true);  Delay(250);
  Vysilej(3,true);  Delay(250);
  Vysilej(0,true);  Delay(250);
  Vysilej(0,true);  Delay(250);
  Vysilej(1,true);  Delay(250);
  Vysilej(6,true);
 end;

var I:LongInt;

begin
Reset;
 Repeat
  ReadLn(i);
  If i < 16 then Vysilej(i,true);
  If i = 21105 then Ondrus;
  If i = 130016 then TestTelecom;
  If i=16 then For i:= 0 to 15 do begin Vysilej(i,false); Delay(300); end;
 until (i > 30) and (i <> 21105) and (i <> 130016);
Reset;
end.

