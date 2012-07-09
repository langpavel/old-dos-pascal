Program ToFile;
uses DOS;
type
    TZnaky = Array[0..255,0..15] of Byte;
    TZnk   = Array[0..255,0..13] of Byte;
var
   Z   :TZnaky;
   Zx  :TZnk;
   F   :File of TZnaky;
   P   :^TZnk;
   X,Y :Word;

begin
 asm
  mov ax,$1130      {vyber funkce}
  mov bh,$02        {vyber funkce}
  int $10           {sluzba obrazovky}
  mov X,es
  mov Y,bp
 end;
 P:=Ptr(X,Y);
 Zx:=P^;
  For X:=0 to 255 do
   For Y:=0 to 13 do
    Z[X,Y]:=Zx[X,Y];

 Assign(F,'font.now');
 ReWrite(f);
 Write(f,Z);
 Close(f);
end.



