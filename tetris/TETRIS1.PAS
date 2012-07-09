Program Tetris;
{ program byl napsan za ucelem pochopeni problemu pri  }
{ vytvareni kodu pro procesor rady 8051                }

uses CRT;
const SPEED:word = 65535;

type TKostka = array[0..1] of byte;
var
     x,y       :shortint;    { x = 0..7, y = 0..19 }
     kostka    :TKostka;
     plocha    :array[0..19] of byte;
     terminate :boolean; { SIGTERM }
     wait      :word;

Function getbit(b,index:byte):boolean;
 var a:byte;
 begin
      a:=b;
      asm
       mov al,1
       mov cl,index
       shl al,cl
       and A,al
      end;
  if (a=0) then getbit:=false else getbit:=true;
 end;

Procedure putbox(x,y:byte); { place box to buffer }
 var a,b:byte;
 begin
  a:=plocha[y];
  b:=x;
  asm
   mov al,1
   mov cl,B
   rol al,cl
   or  A,al
  end;
  plocha[y]:=a;
 end;

Procedure writebuffer;
 var a,b,c:byte;
 begin
  for a:=0 to 19 do
   for b:=0 to 7 do
    begin
     c:=plocha[a];
     asm
      mov al,1
      mov cl,B
      shl al,cl
      and c,al
     end;
     GoToXY(b*2+30,a+2);
     if (c <> 0) then Write('лл') else Write('  ');
    end;
 end;

Procedure generate;
 begin
  kostka[0]:=1+3*16;
  kostka[1]:=1;
{  kostka[0]:=255-15;
  kostka[1]:=0;}
  x:=2; y:=0;
 end;


Procedure drawpiece;
 var a,b,c,d:byte;
 begin
  for a:=0 to 3 do  {line}
   for b:=0 to 3 do {col}
    begin
     c:=kostka[a div 2];
     if ((a mod 2) = 1) then c:=c div 16 else c:=c mod 16;
     asm
      mov al,1
      mov cl,B
      shl al,cl
      and c,al
     end;
     if (c <> 0) then
      begin
       GoToXY((b+x)*2+30,(a+y)+2);
       Write('лл');
      end;
    end;
 end;


Function test(xt,yt:shortint; piece:array of byte):boolean;    { return true if piece can be placed }
 var a,b,c,d:byte;
 begin
  for a:=0 to 3 do  {line}
   for b:=0 to 3 do {col}
    begin
     c:=piece[a div 2];
     if ((a mod 2) = 1) then c:=c div 16 else c:=c mod 16;
     d:=plocha[yt+a];
     if (getbit(c,b) and ((getbit(d,b+xt) or (xt+b<0) or (xt+b>7)) or (yt+a > 19))) then
      begin test:=false; exit; end;
    end;
  test:=true;
 end;

Procedure piecetobuffer;
 var a,b,c:byte;
 begin
  for a:=0 to 3 do  {line}
   begin
     c:=kostka[a div 2];
     if ((a mod 2) = 1) then c:=c div 16 else c:=c mod 16;
     if (x>0) then plocha[y+a]:=plocha[y+a] OR (c SHL x) else
     if (x<0) then plocha[y+a]:=plocha[y+a] OR (c SHR -x) else
     plocha[y+a]:=plocha[y+a] OR c;
   end;
  repeat
   b:=0;
   for a:=0 to 19 do
    begin
     if (plocha[a]=255) then
      begin
       for c:=a downto 1 do plocha[c]:=plocha[c-1];
       b:=1;
      end;
    end;
  until (b=0)
 end;

Procedure posun(xi,yi:shortint;c:boolean);
{ c == true => if not success place box to buffer, don't move, generate next }
 begin
  if (xi<>0) then
   if test(x+xi,y,kostka) then
    begin
     x:=x+xi;
     writebuffer;
     drawpiece;
    end;
  if (yi<>0) then
   if test(x,y+yi,kostka) then
    begin
     y:=y+yi;
     writebuffer;
     drawpiece;
    end
   else
    begin
     piecetobuffer;
     writebuffer;
     generate;
    end;
 end;

Function bmov(b,i1,i2:byte):byte;
 begin
  bmov:=((b SHR i1) AND 1) SHL i2;
 end;

{   7  6  5  4  3  2  1  0
  128 64 32 16  8  4  2  1
                             1   2   1   2
                             0 4 0 4 1 5 1 5
                             2 6 2 6 3 7 3 7

  0 1x2 3    \    4 0|4 0    7 6 5 4   3 7 3 7  0 1 2 3
  4 5x6x7   --\   5x1|5x1x   3 2 1 0   2 6 2 6  4 5 6 7
~ 0 1x2 3 ~ --/   6 2|6x2   ~7 6 5 4~  1 5 1 5  0 1 2 3
  4 5 6 7    /    7 3|7 3    3 2 1 0   0 4 0 4  4 5 6 7
}

Procedure rotate;
 var new      :TKostka;
     b1,b2    :byte;
 begin
  b1:=kostka[0];
  b2:=kostka[1];
  new[1]:=bmov(b1,3,7) + bmov(b1,7,6) + bmov(b2,3,5) + bmov(b2,7,4) +
          bmov(b1,2,3) + bmov(b1,6,2) + bmov(b2,2,1) + bmov(b2,6,0);
  new[0]:=bmov(b1,1,7) + bmov(b1,5,6) + bmov(b2,1,5) + bmov(b2,5,4) +
          bmov(b1,0,3) + bmov(b1,4,2) + bmov(b2,0,1) + bmov(b2,4,0);
  if test(x,y,new) then kostka:=new;
  writebuffer;
  drawpiece;
 end;

Procedure readkeys;
 var ch:char;
 begin
  if KeyPressed then
   begin
    ch:=ReadKey;
    case ch of
     'a': posun(-1,0,false);
     'd': posun(1,0,false);
     'w': rotate;
     's': posun(0,1,true);
    #27 : begin terminate:=true; wait:=SPEED; end;
    end;
   end;
 end;

begin
 ClrScr;
 terminate:=false;


 generate;
 repeat
  for wait:=0 to SPEED do
   begin
    readkeys;
   end;
  posun(0,1,true);
  writebuffer;
  drawpiece;
 until terminate;
end.

