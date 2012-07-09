Program Zaklad_pro_sluzby_XMS;
uses CRT,MysAsm,Graph256;
Const Z=2;
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
    PY,PX:Array[1..2] of LongInt;
    Ch:Char;
    Hra:Byte;
    pb:Byte;
    En:Word;
    AP:Array[1..2]  of Boolean;

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

Function ReadKl:Char;
var A1 :Byte;
 begin

  asm
   mov ah,$00
   int $16
   mov A1,Al
   mov Pb,Ah
  end;
  ReadKl:=CHr(A1);
 end;


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
    If Not(Bo1) AND Bo2 Then F:=6;
    If Bo1 AND Not(Bo2) Then F:=4;
    If Not(Bo1) AND Not(Bo2) Then F:=0;
    SetColor(F);

  End;

Procedure Vynuluj(Hr:Byte);
 Var W:Word;
     F:Byte;
 Begin
  Sound(500);
  For F:= 0 To 3 Do
   Begin
  MoveStruc.Length:=2;
  MoveStruc.SourceHandle:=Handle;
  MoveStruc.SourceOffset:=Pointer((25+LongInt(PY[Hr])+F)*200 + PX[Hr] div 4+5);
  MoveStruc.DestHandle:=0;
  MoveStruc.DestOffset:=Addr(W);
  Presun;

    Case (PX[hr] mod 4) of
      0: Begin
           W:=(W OR (1+2+4+8+16+32+64+128)) XOR (1+2+4+8+16+32+64+128);
         End;
      1: Begin
           W:=(W OR (4+8+16+32+64+128+256+512)) XOR (4+8+16+32+64+128+256+512);
         End;
      2: Begin
           W:=(W OR (16+32+64+128+256+512+1024+2048)) XOR (16+32+64+128+256+512+1024+2048);
         End;
      3: Begin
           W:=(W OR (64+128+256+512+1024+2048+4096+8192)) XOR (64+128+256+512+1024+2048+4096+8192);
         End;
     End;

  MoveStruc.Length:=2;
  MoveStruc.SourceHandle:=0;
  MoveStruc.SourceOffset:=Addr(W);
  MoveStruc.DestHandle:=Handle;
  MoveStruc.DestOffset:=Pointer((25+LongInt(PY[HR])+F)*200 + PX[hr] div 4+5);
  Presun;
   End;
  NoSound;
 End;
Procedure Kresli(Hr:Byte);
 Begin
  For I1:= 0 To 49 Do
    Begin
      MoveStruc.Length:=20;
      MoveStruc.SourceHandle:=Handle;
      MoveStruc.SourceOffset:=Pointer((LongInt(I1)+PY[Hr])*200 + PX[Hr] div 4);
      MoveStruc.DestHandle:=0;
      MoveStruc.DestOffset:=Addr(R);
      Presun;
      AP[Hr]:=False;
      For I:=1 To 15 Do
        Begin
          For I2:=1 To 4 Do
            If ((I = 1) AND (I2 > PX[Hr] mod 4)) OR ((I = 15) AND (I2 <= PX[Hr] mod 4)) OR ((I <> 1) AND (I <> 15)) Then
            Begin
              Barva(R[I],I2);
              If  (I*4+I2-PX[Hr] mod 4 > 24) AND (I*4+I2-PX[Hr] mod 4 <= 28)
                 AND (I1>24) AND (I1<=28)
              Then If GetColor <> 0 Then Ap[Hr]:=True;
        FBox(Hr*150-140+I*z*4+I2*z-PX[Hr] mod 4 * z ,10+I1*z,Hr*150-140+I*z*4+z-1+I2*z - PX[Hr] mod 4 * z,10+I1*z+z-1);
            End;
        End;
    End;
 End;

BEGIN
 DirectVideo:=False;
 GetHIMEMAddr;
SizeKB:=256;
Alokuj;
asm mov ax,$13; int $10 end;

For I1:= 0 To 399 Do
  Begin
    For I:=1 To 200 Do
      Begin
        If (I1<=25) OR (I1>=375) OR (I>=95) OR (I<=5) Then
        R[I]:=255
        Else
        R[I]:=Random(2)*4+Random(2)*4*4+Random(2)*4*4*4+Random(2)+1+4+16+64;
      End;

    MoveStruc.Length:=200;
    MoveStruc.SourceHandle:=0;
    MoveStruc.SourceOffset:=Addr(R);
    MoveStruc.DestHandle:=Handle;
    MoveStruc.DestOffset:=Pointer(LongInt(I1)* 200);

    Presun;
  End;
PX[1]:=10;
PY[1]:=10;
PX[2]:=100;
PY[2]:=100;
Kresli(1); Kresli(2);
  Repeat
    Ch:=ReadKl;
    Case Char(pb) of
      'H':Begin Dec(PY[1]); Hra:=1; End;
      'P':Begin Inc(PY[1]); Hra:=1; End;
      'K':Begin Dec(PX[1]); Hra:=1; End;
      'M':Begin Inc(PX[1]); Hra:=1; End;
      'G':Begin Dec(PY[1]); Dec(PX[1]); Hra:=1; End;
      'I':Begin Dec(PY[1]); Inc(PX[1]); Hra:=1; End;
      'O':Begin Inc(PY[1]); Dec(PX[1]); Hra:=1; End;
      'Q':Begin Inc(PY[1]); Inc(PX[1]); Hra:=1; End;

      #17:Begin Dec(PY[2]); Hra:=2; End;
      #45:Begin Inc(PY[2]); Hra:=2; End;
      #30:Begin Dec(PX[2]); Hra:=2; End;
      #32:Begin Inc(PX[2]); Hra:=2; End;
      #16:Begin Dec(PY[2]); Dec(PX[2]); Hra:=2; End;
      #18:Begin Dec(PY[2]); Inc(PX[2]); Hra:=2; End;
      #44:Begin Inc(PY[2]); Dec(PX[2]); Hra:=2; End;
      #46:Begin Inc(PY[2]); Inc(PX[2]); Hra:=2; End;
      Else
        Hra:=0;
     End; {16 30 44}
    If Hra <> 0 Then
      Begin
        GotoXY(1,1);
        If AP[Hra] Then Vynuluj(Hra);
      End;
     Kresli(1);
     Kresli(2);
    While KeyPressed Do ReadKey;
  Until Ch=#27;
  Uvolni;
END.
