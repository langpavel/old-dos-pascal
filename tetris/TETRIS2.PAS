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

(********************************************************)
Procedure rotate; forward;

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

Procedure drawbox(x,y,b:byte);
 begin
  GoToXY((x)*2+33,(y)+4);
  textcolor(b);
  textbackground(0);
  Write('ÛÛ');
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
     if (c <> 0) then drawbox(b,a,14) else drawbox(b,a,0);
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

Procedure generate;
 var a:byte;
 begin
  x:=2; y:=0;
  case Random(6) of
   0: begin kostka[0]:=1+3*16; kostka[1]:=1; end;
   1: begin kostka[0]:=255-15; kostka[1]:=0; end;
   2: begin kostka[0]:=96;     kostka[1]:=6; end;
   3: begin kostka[0]:=96;     kostka[1]:=3; end;
   4: begin kostka[0]:=224;    kostka[1]:=2; end;
   5: begin kostka[0]:=224;    kostka[1]:=8; end;
  end;
  for a:=0 to Random(4) do rotate;
  if (not test(x,y,kostka)) then terminate:=true;
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
       drawbox(b+x,a+y,15);
      end;
    end;
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
     #0 : case ReadKey of
          'K': posun(-1,0,false);
          'M': posun(1,0,false);
          'H': rotate;
          'P': posun(0,1,true);
          end;
    end;
   end;
 end;

Procedure initscreen;
 begin
  ClrScr;
  textcolor(128+12);
  textbackground(1);
  GoToXY(33,1);
  Write('  TETRIS v 0.1  ');

  textcolor(7);
  textbackground(0);
  GoToXY(32,3);
  Write('ษออออออออออออออออป');
  for y:=4 to 23 do
   begin
    GoToXY(32,y);
    Write('บ                บ');
   end;
  GoToXY(32,24);
  Write('ศออออออออออออออออผ');
 end;

begin
 terminate:=false;
 randomize;

 initscreen;
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

