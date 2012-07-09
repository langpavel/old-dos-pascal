Program Znaky;
uses DOS;
type
    TZnaky = Array[0..255,0..15] of Byte;
var
   Z   :TZnaky;
   F   :File of TZnaky;
   GD,
   X,Y :Byte;

begin
 If ParamCount = 0 then Halt;
 Assign(F,ParamStr(1));
 Reset(f);
 Read(f,Z);
 Close(f);
 For X:= 0 to 255 do
  For GD := 0 to 7 do
   begin
    Y:=Z[X,GD];
    Z[X,GD]:=Z[X,15-GD];
    Z[X,15-GD]:=Y;
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
  mov bh,16         {pocet bytu na znak}
  int $10           {sluzba obrazovky}
 end;

end.



