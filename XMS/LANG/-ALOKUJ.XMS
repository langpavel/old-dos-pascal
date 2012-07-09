{ Pouziva:
var
    Handle :Word;
    SizeKB :Word;
    Himem  :Pointer;
    IsItOK :Boolean;
    Error  :Byte;
}
begin
 asm
  mov ah,009h
  mov dx,SizeKB
  call Himem
  mov Handle,dx
  mov IsItOK,al
  mov Error,bl
 end;
end;
