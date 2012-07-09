Program Zaklad_pro_sluzby_XMS;
uses CRT;
type TMoveStruc = record
                   Length       :LongInt;
                   SourceHandle :Word;
                   SourceOffset :Pointer;
                   DestHandle   :Word;
                   DestOffset   :Pointer;
                   {Nastavenim Handle na 0 se bude presouvat
                   z/do realne pameti na adrese Src/DestOffset}
                  end;
var
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;

Procedure GetHIMEMAddr;           {$I -GetAddr.xms}
Procedure Alokuj;                 {$I -Alokuj.xms}
Procedure Uvolni;                 {$I -Uvolni.xms}
Procedure Presun;                 {$I -Presun.xms}
Procedure GetXMSSize;             {$I -XMSSize.xms}

Function ByteToHex(X:Byte):String;
 const Hex : Array[0..15] of char = '0123456789ABCDEF';
 begin
  ByteToHex:=Hex[X div 16]+Hex[X mod 16];
 end;

begin
GetHIMEMAddr;
SizeKB:=4;
Alokuj;
If not IsItOK then
  begin
   WriteLn('Nastala chyba ',Error,' (',ByteToHex(Error),'h) pri alokaci XMS.');
   Halt;
  end;
ReadLn;

MoveStruc.Length:=4000;
MoveStruc.SourceHandle:=0;
MoveStruc.SourceOffset:=Ptr($B800,0);
MoveStruc.DestHandle:=Handle;
MoveStruc.DestOffset:=Ptr(0,0);

Presun;

asm
 mov ax,$13
 int $10
end;

MoveStruc.Length:=4000;
MoveStruc.SourceHandle:=Handle;
MoveStruc.SourceOffset:=Ptr(0,0);
MoveStruc.DestHandle:=0;
MoveStruc.DestOffset:=Ptr($A000,0);

Presun;

ReadKey;
Uvolni;
end.
