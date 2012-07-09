{$M 6000,1024,67000}
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
type TScreen =  Array[0..319,0..199] of byte;
type TPalette = Array[0..255,0..2] of byte;
type TGrb =     record
                 Palette   :TPalette;
                 Screen    :TScreen;
                end;
type TGrbMem =  record
                 Scr       :TGrb;
                 MinHandle :Word;
                end;

var
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;

    FilName   :String;
    Rpt       :Word;
    MinHndl   :Word;
    Grb       :^TGrbMem;
    Ints      :Array[0..255] of Pointer absolute 0:0;
    F         :File of TGrb;

Procedure GetHIMEMAddr; {$I -GetAddr.xms}
Procedure Alokuj;       {$I -Alokuj.xms}
Procedure Uvolni;       {$I -Uvolni.xms}
Procedure Presun;       {$I -Presun.xms}
Procedure GetXMSSize;   {$I -XMSSize.xms}

Procedure Konec;
 begin
  Word(Ints[255]):=0;
  Dispose(Grb);
  Halt;
 end;

begin
 GetHIMEMAddr;
 If Word(Pointer(LongInt(Addr(Ints[$FF]))+2)^) <> $1234 then
  begin
   WriteLn('V pameti neni nainstalovan rezidentni program GRAB.EXE !!');
   Halt;
  end;
 New(Grb);
 Handle:=Word(Ints[255]);
 If Handle = 0 then Konec;
 Rpt:=0;
  Repeat
   Inc(Rpt);
   MoveStruc.Length:=(320*200)+(256*3)+2;
   MoveStruc.SourceHandle:=Handle;
   MoveStruc.SourceOffset:=Ptr(0,0);
   MoveStruc.DestHandle:=0;
   MoveStruc.DestOffset:=Grb;
   Presun;
   Uvolni;
   Handle:=Grb^.MinHandle;

   Str(Rpt,FilName);
   FilName:='PIC'+FilName+'.GRB';
   Assign(F,FilName);
   Rewrite(F);
   Write(F,Grb^.Scr);
   Close(F);

   If Handle = 0 then Konec;
  until KeyPressed;
 Konec;
end.

