{ Pouziva:
var
    Handle :Word;
    Himem  :Pointer;
    IsItOK :Boolean;
    Error  :Byte;
}
begin
 asm
  mov ah,00Ah
  mov dx,Handle
  call Himem
  mov IsItOK,al
  mov Error,bl
 end;
end;
