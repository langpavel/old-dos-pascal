Program Zvuk;
uses DTMF,Adlib,CRT;
const CCC = 200;
var
    Ch    :Char;
    Count :LongInt;
    Mem   :String;
    X     :Word;
    A,B   :Word;
begin
 If not InitDTMF then Halt;
 Count:=CCC+1;
 Mem:='123A456B789C*0#D';
 ClrScr;
 TextColor(9);
 Write('Program DTMF Dialer (c) Copyleft Pavel Lang 2001',#13#10,
       'Full DTMF code support ');
 TextColor(2);
 Write('(0123456789 *# ABCD)  ');
 TextColor(4);
 WriteLn('R = repeat   ESC, Enter, Q = quit ');
 TextColor(12); A:=WhereX; B:=WhereY; GoToXY(69,1); Write('Vol: ',Volume,'/63 '); GoToXY(A,B);
 TextColor(11);
  Repeat
   If keypressed then
    begin
     Ch:=ReadKey;
     Ch:=Upcase(Ch);
     If Ch = '+' then begin Volume:=Volume+1; If Volume > 63 then Volume:=63; Adlib.Sound(440); Delay(100); Adlib.NoSound; end;
     If Ch = '-' then begin Volume:=Volume-1; If Volume < 0  then Volume:=0;  Adlib.Sound(440); Delay(100); Adlib.NoSound; end;
     TextColor(12); A:=WhereX; B:=WhereY; GoToXY(69,1); Write('Vol: ',Volume,'/63 '); GoToXY(A,B);
     If Ch = 'R' then           {Repeat}
      begin
       TextColor(2);
       If WhereX <> 1 then WriteLn;
       Write(Mem);
       GotoXY(1,WhereY);
       For X:= 1 to Byte(Mem[0]) do
        begin
         TextColor(12);
         Write(Mem[X]);
         Call(Mem[X]);
         TextColor(10);
         Write(#8,Mem[X]);
        end;
       WriteLn;
       Count:=CCC+1;
      end;
     If TestChar(Upcase(Ch)) then
      begin
       TextColor(12);
       If WhereX = 1 then Mem:='';
       Write(ch);
       Mem:=Mem+CH;
       Call(Ch);
       TextColor(10);
       Write(#8,ch);
       Count:=0;
      end;
    end else Delay(10);
   If Count = CCC then begin WriteLn; end;
   If Count <= CCC then Inc(Count);
  Until (Ch = #27) or (Ch = #13) or (Ch = 'Q');
 TextColor(7);
 ClrScr;
 WriteLn('Call me: +420445533890'#13#10'Have a fun :)');
end.

