Unit Graph256;
Interface
Function GetColor:Byte;
Procedure SetColor(B:Byte);
Procedure InitGraph;
Procedure Box(x1,y1,x2,y2:Integer);
Procedure FBox(x1,y1,x2,y2:Integer);
Procedure PutPixel(x,y:Integer;Barva:Byte);

Implementation
Var AColor:Byte;
Procedure InitGraph;
  Begin
    Asm
      Mov ax,$0013
      Int $10
    End;
  End;

Procedure SetColor(B:Byte);
  Begin
    AColor:=B;
  End;

Function GetColor:Byte;
  Begin
    GetColor:=AColor;
  End;

Procedure PutPixel(x,y:Integer;Barva:Byte);
  Begin
    Mem[$A000:x+y*320]:=Barva;
  End;

Procedure Box(x1,y1,x2,y2:Integer);
  Var I:Integer;
  Begin
    For I:= x1 To x2 Do
      Begin
        PutPixel(I,Y1,AColor);
        PutPixel(I,Y2,AColor);
      End;
    For I:= y1+1 To y2-1 Do
      Begin
        PutPixel(X1,I,AColor);
        PutPixel(X2,I,AColor);
      End;
  End;

Procedure FBox(x1,y1,x2,y2:Integer);
  Var I1,I2:Integer;
  Begin
    For I1:= x1 To x2 Do
      For I2:= y1 To y2 Do
        PutPixel(I1,I2,AColor);
  End;

BEGIN
  AColor:=15;
END.