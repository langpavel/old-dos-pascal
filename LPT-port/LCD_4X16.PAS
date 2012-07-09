Program TestLCD_4x16;
uses CRT,DOS;
const ADDR   :word=$378;
var
     Sp      :byte;
     ch      :char;
     pos     :word;

Procedure WritePort;
 begin
 end;

Procedure Cekej;
 begin
  Delay(5);
 end;

Procedure Vysli(b:byte);
 begin
  Port[ADDR+2]:=Sp;
  Cekej;
  Port[ADDR]:=b;
  Cekej;
  Port[ADDR+2]:=Sp+1;
 end;

{
  /8,4  Ucc
  /2 .. RS
  /1 .. Enable
}
Procedure Init;
 begin
  Sp:=4+2;            {Aktivni napajeni a enter (1)}
  Vysli(32+16+8);
  Vysli(8+4+2+1);
  Vysli(1);
  Sp:=4;
 end;

Procedure ClearLCD;
 begin
  Sp:=4+2;            {Aktivni napajeni a enter (1)}
  Vysli(1);
  Sp:=4;
 end;

Procedure SeekOn(pos:integer);
 begin
  Sp:=4+2;            {Aktivni napajeni a enter (1)}
  Vysli(128+(pos and 127));
  Sp:=4;
 end;

Procedure BackSpace;
 begin
  SeekOn(pos-1);
  Vysli(32);
  SeekOn(pos-1);
  pos:=pos-1;
 end;

Procedure NewLine;
 begin
  If pos < 20 then pos:=64 else
  If (pos >= 64) and (pos < 84) then pos:=20 else
  If (pos >= 84) and (pos < 104) then pos:=0 else
  If (pos >= 20) and (pos < 40) then pos:=84;
  SeekOn(pos);
  WriteLn('Pozice:',pos);
 end;

begin
 ClrScr;
 Init;
 pos:=0;
 repeat
  ch:=ReadKey;
  case ch of
      #8:  begin BackSpace; end;
      #13: begin NewLine; end;
      #27: Exit;
      else begin Vysli(Byte(ch)); pos:=(pos+1) and 127; Seekon(pos); WriteLn(pos); end;
  end;
 until false;
end.


