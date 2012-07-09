Program Zaklad_pro_sluzby_XMS;
uses CRT,MysAsm;
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
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;


    R:Array[1..1000] of Byte;
    I,I1:Word;
    XM,YM,B:Word;

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

begin
GetHIMEMAddr;
SizeKB:=256;
Alokuj;
asm mov ax,$13; int $10 end;

For I1:= 0 To 399 Do
  Begin
    For I:=1 To 640 Do R[I]:=i div 3+Random(3)-1;

    MoveStruc.Length:=640;
    MoveStruc.SourceHandle:=0;
    MoveStruc.SourceOffset:=Addr(R);
    MoveStruc.DestHandle:=Handle;
    MoveStruc.DestOffset:=Pointer(LongInt(I1)* 640);

    Presun;
  End;

Repeat
  MouseXYBut(XM,YM,B); XM:=XM Div 2;
  For I1:= 0 To 199 Do
    Begin

      MoveStruc.Length:=320;
      MoveStruc.SourceHandle:=Handle;
      MoveStruc.SourceOffset:=Pointer((LongInt(I1)+YM)*640  + XM);
      MoveStruc.DestHandle:=0;
      MoveStruc.DestOffset:=Ptr($A000,320*I1);

      Presun;
    End;

Until KeyPressed;
ReadKey;
Uvolni;
end.
