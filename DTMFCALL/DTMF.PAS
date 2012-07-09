Unit DTMF;
Interface
uses Adlib,CRT;
const Del1 = 100;                       {Delka trvani tonu}
const Del2 = 100;                        {Delka trvani pauzy}

Function InitDTMF:Boolean;
Function TestChar(ch:Char):Boolean;
Procedure Call(S:String);

Implementation

const Row  :Array[0..3] of Word = (1209,1336,1477,1633);
const Line :Array[0..3] of Word = ( 697, 770, 852, 941);

Function InitDTMF:Boolean;
begin
 If IsAdlib then
  begin SineChanel(0); SineChanel(1); InitDTMF:=True; end
  else InitDTMF:=False;
end;

Function TestChar(ch:Char):Boolean;
begin
 TestChar:=(((Ch >= '0') and (Ch <= '9')) or (Ch = '*') or (Ch = '#') or ((Ch >= 'A') and (Ch <= 'D')))
end;

Procedure CallOne(B:Byte);
 begin
 SoundChanel(0,Row[B mod 4]);
 SoundChanel(1,Line[B div 4]);
 Delay(Del1);
 StopChanel(0);
 StopChanel(1);
 Delay(Del2);
 end;

Procedure Call(S:String);
var X:Byte;
 begin
  For X:=1 to Byte(S[0]) do
   begin
    Case UpCase(S[X]) of
     '1': CallOne(0);
     '2': CallOne(1);
     '3': CallOne(2);
     'A': CallOne(3);
     '4': CallOne(4);
     '5': CallOne(5);
     '6': CallOne(6);
     'B': CallOne(7);
     '7': CallOne(8);
     '8': CallOne(9);
     '9': CallOne(10);
     'C': CallOne(11);
     '*': CallOne(12);
     '0': CallOne(13);
     '#': CallOne(14);
     'D': CallOne(15);
    end;
   end;
 end;
end.

