Program PrevratZnaky;
uses DOS;
type
    TZnaky   = Array[0..255,0..13] of Byte;

var
   Z   :TZnaky;
   GD,
   X,Y :Word;
   P   :^TZnaky;

begin
 asm
  mov ax,$1130      {vyber funkce}
  mov bh,$02        {vyber funkce}
  int $10           {sluzba obrazovky}
  mov X,es
  mov Y,bp
 end;
 P:=Ptr(X,Y);
 Z:=P^;
  For X:=0 to 255 do
   For Y:=0 to 13 do
    Z[X,Y]:=Z[X,Y];
 For X:= 0 to 255 do
  For GD := 0 to 6 do
   begin
    Y:=Z[X,GD];
    Z[X,GD]:=Z[X,13-GD];
    Z[X,13-GD]:=Y;
   end;
 asm
  mov ax,SEG Z      {segment znaku}
  mov es,ax
  mov ax,OFFSET Z   {offset znaku}
  mov bp,ax
  mov ax,$1100      {vyber funkce}
  mov cx,$FF        {pocet ukladanych znakovych obrazcu}
  mov dx,$00        {offset znaku (ASCII 0)}
  mov bl,$00        {zavadeny blok fontu}
  mov bh,14         {pocet bytu na znak}
  int $10           {sluzba obrazovky}
 end;

end.



