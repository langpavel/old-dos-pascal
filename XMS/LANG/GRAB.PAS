{$M 1024,0,1024}
Program Grabbler;
uses CRT,DOS;
type TMoveStruc = record
                   Length       :LongInt;
                   SourceHandle :Word;
                   SourceOffset :Pointer;
                   DestHandle   :Word;
                   DestOffset   :Pointer;
                   {Nastavenim Handle na 0 se bude presouvat z/do realne
                   pameti na adrese Offset}
                  end;
type TScreen = Array[0..319,0..199] of byte;
type TPalette = Array[0..255,0..2] of byte;
type TGrb = record
             Palette   :TPalette;
             Screen    :TScreen;
             MinHandle :Word;
            end;

var
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;
    MinHndl   :Word;
    Grb       :TGrb;
    Ints      :Array[0..255] of Pointer absolute 0:0;
    Scr       :TScreen absolute $A000:$0000;

Procedure GetHIMEMAddr; {$I -GetAddr.xms}
Procedure Alokuj;       {$I -Alokuj.xms}
Procedure Uvolni;       {$I -Uvolni.xms}
Procedure Presun;       {$I -Presun.xms}
Procedure GetXMSSize;   {$I -XMSSize.xms}

Procedure PrtScr; interrupt;
 begin
  GetXMSSize;
  If SizeKB < 65 then
   begin
    Sound(1000);
    Delay(1000);
    NoSound;
   end
  else
   begin
    SizeKB:=65;
    MinHndl:=Handle;
    Alokuj;
    Grb.MinHandle:=MinHndl;
    Word(Ints[$FF]):=Handle;
     asm
      xor bx,bx
      mov cx,00100h
      mov ax,seg Grb
      mov es,ax
      mov dx,offset Grb
      mov ax,01017h
      int 010h
     end;
    Grb.Screen:=Scr;

    MoveStruc.Length:=(320*200)+(256*3)+2;
    MoveStruc.SourceHandle:=0;
    MoveStruc.SourceOffset:=Addr(Grb);
    MoveStruc.DestHandle:=Handle;
    MoveStruc.DestOffset:=Ptr(0,0);

    Presun;

    Sound(800);
    Delay(30);
    Sound(1000);
    Delay(30);
    NoSound;
   end;
 end;

Procedure I1C; interrupt;
 begin
  Ints[$05]:=Addr(PrtScr);
 end;

begin
 GetHIMEMAddr;
 Handle:=0;
 Word(Ints[$FF]):=Handle;
 Word(Pointer(LongInt(Addr(Ints[$FF]))+2)^):=$1234;
 Ints[$05]:=Addr(PrtScr);
 Ints[$1C]:=Addr(I1C);
 Keep(0);
end.

