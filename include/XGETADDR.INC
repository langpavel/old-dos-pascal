{
var
    Himem  :Pointer;
}
var
   A,B:Word;
     C:Byte;
begin
 asm
  mov ax,04300h
  int 02Fh
  mov C,al

  mov ax,04310h
  int 02Fh
  mov A,es
  mov B,bx
 end;
 If C <> $80 then
    begin
     WriteLn(#13,#10,'HIMEM.SYS neni instalovan. Pristup k XMS neni mozny !!');
     Halt;
    end;
 Himem:=Ptr(A,B);
end;