(* Pouziva:
type TMoveStruc = record
                   Length       :LongInt;
                   SourceHandle :Word;
                   SourceOffset :Pointer;
                   DestHandle   :Word;
                   DestOffset   :Pointer;
                   {Nastavenim Handle na 0 se bude presouvat z/do realne
                   pameti na adrese Offset}
                  end;

var
    MoveStruc :TMoveStruc
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;
*)
begin
 asm
  mov ax,seg MoveStruc
  mov ds,ax
  mov si,offset MoveStruc
  mov ah,00Bh
  call Himem
  mov IsItOK,al
  mov Error,bl
 end;
end;
