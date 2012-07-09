Unit Text;

interface

const
   MaxX   :Word = 80;
   MaxY   :Word = 25;
   MStr   :Word = 16;


 Procedure OutChar(X,Y:Integer; Znk:Char; TCol,BCol: Byte; Blink:Boolean);
 Procedure Color(X,Y:Integer; L,TCol,BCol: Byte; Blink:Boolean);
 Procedure StrOut(X,Y:Integer; S:String; TCol,BCol: Byte; Blink:Boolean);
 Procedure Clr(Popr,Pozadi:Byte);
 Procedure DownLine;
 Procedure UpLine;
 Procedure DownPage;
 Procedure UpPage;


implementation

uses Dos,CRT;

type
   TMem = array[0..80*25*32] of Byte;

var
   Mem    :TMem absolute $B800:$0000;
   Ip     :Integer;

Procedure OutChar(X,Y:Integer; Znk:Char; TCol,BCol: Byte; Blink:Boolean);
 begin
{ If Y>=MaxY then Y:=Y-(MaxY*MStr div 2);}
  If Y<=0 then Y:=Y+(MaxY*MStr div 2);
  Mem[((Y-1)*MaxX+(X-1))*2]:=Ord(Znk);
  If BCol > 7 then BCol:=BCol mod 8;
  If Blink then BCol:=BCol+8;
  Mem[((Y-1)*MaxX+(X-1))*2+1]:=TCol+BCol*16;
 end;

Procedure Color(X,Y:Integer; L,TCol,BCol: Byte; Blink:Boolean);
 var I:Integer;
 begin
  For I:=X to X+L-1 do
   begin
{   If Y>=MaxY then Y:=Y-(MaxY*MStr div 2);}
    If Y<=0 then Y:=Y+(MaxY*MStr div 2);
    If BCol > 7 then BCol:=BCol mod 8;
    If Blink then BCol:=BCol+8;
    Mem[((Y-1)*MaxX+(I-1))*2+1]:=TCol+BCol*16;
   end;
 end;

Procedure StrOut(X,Y:Integer; S:String; TCol,BCol: Byte; Blink:Boolean);
 var I:Integer;
 begin
  For I:=1 to Ord(S[0]) do OutChar(X+I-1,Y,S[I],TCol,BCol,Blink);
 end;


Procedure Clr(Popr,Pozadi:Byte);
 var I:Integer;
 begin
  For I:= 0 to MaxX*MaxY*MStr div 2 do
   begin
    Mem[I*2]:=0;
    Mem[I*2+1]:=Popr+Pozadi*16;
   end;
 end;

Procedure DownLine;
 var
    X     :Array[0..160] of Byte;
    I     :Integer;
 begin
  For I:= 0 to MaxX*2-1 do X[I]:=Mem[I];
  For I:= 160 to MaxX*MaxY*MStr do Mem[I-160]:=Mem[I];
  For I:= MaxX*MaxY*MStr - 160 to MaxX*MaxY*MStr do Mem[I]:=X[I-(MaxX*MaxY*MStr - 160)];
 end;

Procedure UpLine;
 var
    X     :Array[0..160] of Byte;
    I     :Integer;
 begin
  For I:= MaxX*MaxY*MStr - 160 to MaxX*MaxY*MStr do X[I-(MaxX*MaxY*MStr - 160)]:=Mem[I];
  For I:= 0 to MaxX*MaxY*MStr - 160 do Mem[(MaxX*MaxY*MStr - 160)-I+160]:=Mem[(MaxX*MaxY*MStr - 160)-I];
  For I:= 0 to MaxX*2-1 do Mem[I]:=X[I];
 end;

Procedure DownPage;
 var
    X     :Array[0..160*25] of Byte;
    I     :Integer;
 begin
  For I:= 0 to MaxX*MaxY*2-1 do X[I]:=Mem[I];
  For I:= MaxX*MaxY*2 to MaxX*MaxY*MStr do Mem[I-MaxX*MaxY*2]:=Mem[I];
  For I:= MaxX*MaxY*MStr - MaxX*MaxY*2 to MaxX*MaxY*MStr do Mem[I]:=X[I-(MaxX*MaxY*MStr - MaxX*MaxY*2)];
 end;

Procedure UpPage;
 var
    X     :Array[0..160*25] of Byte;
    I     :Integer;
 begin
  For I:= MaxX*MaxY*MStr - MaxX*MaxY*2 to MaxX*MaxY*MStr do X[I-(MaxX*MaxY*MStr - MaxX*MaxY*2)]:=Mem[I];
  For I:= 0 to MaxX*MaxY*MStr - MaxX*MaxY*2 do Mem[(MaxX*MaxY*MStr - MaxX*MaxY*2)-I+MaxX*MaxY*2]:=Mem[(MaxX*MaxY*MStr -
  MaxX*MaxY*2)-I];
  For I:= 0 to MaxX*MaxY*2-1 do Mem[I]:=X[I];
 end;

end.