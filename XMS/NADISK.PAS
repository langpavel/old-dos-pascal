Program Zaklad_pro_sluzby_XMS;
uses CRT;
type TMoveStruc = record
                   Length       :LongInt;
                   SourceHandle :Word;
                   SourceOffset :Pointer;
                   DestHandle   :Word;
                   DestOffset   :Pointer;
                   {Nastavenim Handle na 0 se bude presouvat z/do realne
                   pameti na adrese Offset}
                  end;
type TPal = Array[0..255] of record R,G,B:Byte; end;
var
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;

   Ints   :Array[0..255] of Pointer absolute $0000:$0000;
   Hl,I1  :Word;
   I      :Byte;
   Screen :Array[1..64000] of Byte absolute $A000:0;
   Naz    :String;
   MPal,Pal    :TPal;
   by          :Boolean;
   f           :File;

Procedure GetHIMEMAddr;
{$I GetAddr}

Procedure Alokuj;
{$I Alokuj}

Procedure Uvolni;
{$I Uvolni}

Procedure Presun;
{$I Presun}

Procedure GetXMSSize;
{$I XMSSize}

Procedure NastavPaletu;
  Begin
    Asm
      mov ax,seg pal
      mov es,ax
      mov dx,offset pal
      mov ax,01012h
      mov bx,0
      mov cx,0FFh
      int 10h
    End;
    MPal:=Pal;
  End;

begin
If ParamCount = 0 Then Halt;
GetHIMEMAddr;


Hl:=Word(Ints[$FF]);
If Hl = 0 Then Halt;


asm mov ax,$13; int $10 end;
I:=0;
Assign(F,ParamStr(1));
Rewrite(F,1);
Repeat
  Inc(I);
  Handle:=Hl;

  MoveStruc.Length:=3*256;
  MoveStruc.SourceHandle:=Handle;
  MoveStruc.SourceOffset:=Pointer(64002);
  MoveStruc.DestHandle:=0;
  MoveStruc.DestOffset:=Addr(Pal);
  Presun;
  By:=False;
  For I1 := 0 To 255 Do
    Begin
      If (Pal[I1].R <> MPal[I1].R) OR (Pal[I1].G <> MPal[I1].G) OR (Pal[I1].B <> MPal[I1].B) Then By:=True;
    End;
  If (By) OR (I = 1) Then NastavPaletu;

  MoveStruc.Length:=64000;
  MoveStruc.SourceHandle:=Handle;
  MoveStruc.SourceOffset:=Pointer(2);
  MoveStruc.DestHandle:=0;
  MoveStruc.DestOffset:=Ptr($A000,0);
  Presun;

  MoveStruc.Length:=2;
  MoveStruc.SourceHandle:=Handle;
  MoveStruc.SourceOffset:=Pointer(0);
  MoveStruc.DestHandle:=0;
  MoveStruc.DestOffset:=Addr(Hl);
  Presun;

  Uvolni;
  BlockWrite(F,Screen,64000);
  BlockWrite(F,Pal,3*256);
Until Hl = 0;
Close(F);
Word(Ints[$FF]):=0;
end.