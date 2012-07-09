Program Zaklad_pro_sluzby_XMS;
uses CRT,MysAsm,Graph256;
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
    I,I1,I2:Word;
    XM,YM,B:Word;
    PY,PX:Word;

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

Procedure Barva(B,X:Byte);
  Var F:Byte;
      Bo1,Bo2:Boolean;
  Begin
    Case X of
      1: Begin
           Bo1:=(B OR 1)=B;
           Bo2:=(B OR 2)=B;
         End;
      2: Begin
           Bo1:=(B OR 4)=B;
           Bo2:=(B OR 8)=B;
         End;
      3: Begin
           Bo1:=(B OR 16)=B;
           Bo2:=(B OR 32)=B;
         End;
      4: Begin
           Bo1:=(B OR 64)=B;
           Bo2:=(B OR 128)=B;
         End;
     End;

    If Bo1 AND Bo2 Then F:=15;
    If Not(Bo1) AND Bo2 Then F:=1;
    If Bo1 AND Not(Bo2) Then F:=9;
    If Not(Bo1) AND Not(Bo2) Then F:=0;
    SetColor(F);


  End;

begin
GetHIMEMAddr;
SizeKB:=256;
Alokuj;
asm mov ax,$13; int $10 end;

For I1:= 0 To 399 Do
  Begin
    For I:=1 To 100 Do
      Begin
        If (I1<=25) OR (I1>=375) OR (I>=195) OR (I<=5) Then
        R[I]:=255
        Else
        R[I]:=Random(4)*4+Random(4)*4*4+Random(4)*4*4*4+Random(4);
      End;

    MoveStruc.Length:=200;
    MoveStruc.SourceHandle:=0;
    MoveStruc.SourceOffset:=Addr(R);
    MoveStruc.DestHandle:=Handle;
    MoveStruc.DestOffset:=Pointer(LongInt(I1)* 200);

    Presun;
  End;
PX:=
Repeat
  PY:=YM+150;
  PX:=XM+0;
  For I1:= 0 To 49 Do
    Begin

      MoveStruc.Length:=10;
      MoveStruc.SourceHandle:=Handle;
      MoveStruc.SourceOffset:=Pointer((LongInt(I1)+PY)*200 + PX div 4);
      MoveStruc.DestHandle:=0;
      MoveStruc.DestOffset:=Addr(R);
      Presun;
      For I:=1 To 10 Do
        Begin
          For I2:=1 To 4 Do
            If ((I = 1) AND (I2 > PX mod 4)) OR ((I = 10) AND (I2 <= PX mod 4)) OR ((I <> 1) AND (I <> 10)) Then
            Begin
              Barva(R[I],I2);
              FBox(I*8+I2*2-PX mod 4 * 2 ,I1*2,I*8+1+I2*2 - PX mod 4 * 2,I1*2+1);
            End;
        End;
    End;

Until KeyPressed;
ReadKey;
Uvolni;
end.
