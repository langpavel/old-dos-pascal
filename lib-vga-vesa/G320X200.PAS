{$M 65520,0,655360}
Unit G320x200;
interface

Const MaxX = 319;
      MaxY = 199;
      MinX = 0;
      MinY = 0;

type
     TXY = record
               X,Y:Word;
              end;
     TObraz = Array[0..319,0..199] of Byte;
     TObrazReal = Array[0..199,0..319] of Byte;
     TBarva = record
                Red,Green,Blue:Byte;
              end;
     TBarvy = Array[0..255] of TBarva;
     TMapXY = record
               X,Y:Byte;
              end;
     TMapFile = Array[0..100,0..100] of TMapXY;
     TSource = Array[0..100,0..100] of Byte;
     PSource = ^TSource;
     PMap    = ^TMapFile;
     PMaping = ^TMaping;
     TMaping = record
                Source :PSource;
                Map    :PMap;
                Cil    :TXY;
               end;

var
    Screen      :TObraz absolute $A000:$0000;
    Colors      :TBarvy;
    Transparent :Byte;
    PutImgMode  :Byte;

Procedure InitGr;
Procedure CloseGr;
Procedure Put(X,Y:Word;C:Byte);
Function  Get(X,Y:Word):Byte;
Procedure LoadScreen;
Function  SaveScreen:Boolean;
Procedure LoadPal;
Function  SavePal:Boolean;
Function  ImgSize(X1,Y1,X2,Y2:Word):Word;
Procedure GetImg(X1,Y1,X2,Y2:Word;var Bm:Pointer);
Procedure PutImg(X1,Y1:Word;Bm:Pointer);
Procedure LoadImgFromFile(FileName:String;var Bm:Pointer);
Procedure SaveImgToFile(FileName:String;Bm:Pointer);
Function  ImgLarge(Bm:Pointer):Word;
Procedure FreeImg(var Bm:Pointer);
Procedure SetRGB(Barva:Word;R,G,B:Byte);
Procedure RefreshPalette;
Procedure MakeGrayScale;
Procedure Rectangle(X1,Y1,X2,Y2:Word;Color:Byte;Fill:Boolean);
Procedure FillAll(Source:Byte);
Procedure ChangeColor(Source,Target:Byte);
Function  SelectColor(var Selected:Byte):Boolean;
{Procedure PlaceVideo(V:Pointer;Krok:Byte;Play:Boolean);}
Procedure SaveScreenToFile(FName:String);
Procedure LoadScreenFromFile(FName:String);
Procedure LoadMap(FileName:String;var P:PMap);
Procedure Mapuj(Map:PMaping);
Procedure GetSourceFromScreen(xX,xY:Word;var P:PSource);
Procedure LoadPaletteFromFile(Name:String);
Procedure LoadBGR256PaletteFromFile(Name:String);
Function  EditColor(var Color:Byte):Boolean;
Procedure SavePalToFile(Name:String);

Implementation
uses crt;
type
     PSaveScr = ^TSaveScr;
     TSaveScr = record
                 Obraz:TObraz;
                 Next:PSaveScr;
                end;
     PSavePal = ^TSavePal;
     TSavePal = record
                 Pal:TBarvy;
                 Next:PSavePal;
                end;

{    PVideoHead = ^TVideoHead;}
{    TVideoHead = record
                   X,Y                  :Word;
                   Height,Width         :Word;
                   Frame,Frames         :Word;
                   BFrames              :Pointer;
                   Active               :Boolean;
                   NextVideo            :PVideoHead;
                  end;}

var
    SScr   :PSaveScr;
    SPal   :PSavePal;
    MinGrMode :Byte;
{   PVideo :PVideoHead;}

Procedure InitGr; assembler;
{ graf mod. 320x200x256 }
 asm
  mov ah,$0F
  int $10
  mov MinGrMode,al

  mov ax,$0013
  int $10

  mov AX,seg Colors
  mov ES,AX
  mov DX,offset Colors

  mov AX,$1017
  mov BX,$0000
  mov CX,$00FF

  int $10
 end;

Procedure CloseGr; assembler;
{ graf mod. 320x200x256 }
 asm
  xor ah,ah
  mov al,MinGrMode
  int $10
 end;

Procedure Put(X,Y:Word;C:Byte);
 begin
  If (X < 320) and (Y < 200) then Mem[$A000:Y*320+X]:=C;
 end;

Function Get(X,Y:Word):Byte;
 begin
  If (X < 320) and (Y < 200) then Get:=Mem[$A000:Y*320+X] else Get:=0;
 end;


Procedure LoadScreen;
 var NP:PSaveScr;
 begin
  If SScr <> nil then
   begin
    Screen:=SScr^.Obraz;
    np:=sscr^.next;
    dispose(sscr);
    sscr:=np;
   end;
 end;

Function SaveScreen:Boolean;
 var NP:PSaveScr;
 begin
  If MaxAvail < SizeOf(PSaveScr)
  then SaveScreen:=False
  else
   begin
    New(NP);
    NP^.Next:=SScr;
    NP^.Obraz:=Screen;
    SScr:=NP;
    SaveScreen:=True;
   end;
 end;

Procedure LoadPal;
 var NP:PSavePal;
 begin
  If SPal <> nil then
   begin
    Colors:=SPal^.Pal;
    NP:=SPal^.next;
    dispose(SPal);
    SPal:=NP;
    RefreshPalette;
   end;
 end;

Function SavePal:Boolean;
 var NP:PSavePal;
 begin
  If MaxAvail < SizeOf(PSavePal)
  then SavePal:=False
  else
   begin
    New(NP);
    NP^.Next:=SPal;
    NP^.Pal:=Colors;
    SPal:=NP;
    SavePal:=True;
   end;
 end;

Function ImgSize(X1,Y1,X2,Y2:Word):Word;
{ 00  01  02  03  04  05 }
{ Delka   Vyska   Data...}
 begin
  ImgSize:=4+((X2-X1+1)*(Y2-Y1+1));
 end;

Procedure GetImg(X1,Y1,X2,Y2:Word;var Bm:Pointer);
var
    P      :Pointer;
    X,Y    :Word;
 begin
  P:=Bm;
  Word(P^):=X2-X1;
  LongInt(P):=LongInt(P)+2;
  Word(P^):=Y2-Y1;
  LongInt(P):=LongInt(P)+2;
   For X:= X1 to X2 do
    For Y:= Y1 to Y2 do
     begin
      Byte(P^):=Mem[$A000:Y*320+X];
      LongInt(P):=LongInt(P)+1;
     end;
 end;

Procedure PutImg(X1,Y1:Word;Bm:Pointer);
var
    P      :Pointer;
    X,Y    :Word;
    A,B    :Word;
 begin
  P:=Bm;
  A:=Word(P^);
  LongInt(P):=LongInt(P)+2;
  B:=Word(P^);
  LongInt(P):=LongInt(P)+2;
   For X:= X1 to X1 + A do
    For Y:= Y1 to Y1 + B do
     begin
      If (X < 320) and (Y < 200) then
        Case PutImgMode of
         0: Mem[$A000:Y*320+X]:=Byte(P^);
         1: If Byte(P^) <> Transparent then Mem[$A000:Y*320+X]:=Byte(P^);
        end;
      LongInt(P):=LongInt(P)+1;
     end;
 end;

Procedure LoadImgFromFile(FileName:String;var Bm:Pointer);
 var
     F    :File of Byte;
     P    :Pointer;
 begin
  Assign(F,FileName);
  Reset(F);
  GetMem(Bm,FileSize(F));
  P:=Bm;
   repeat
    Read(F,Byte(P^));
    LongInt(P):=LongInt(P)+1;
   until Eof(F);
  Close(F);
 end;

Procedure SaveImgToFile(FileName:String;Bm:Pointer);
 var
     F     :File of Byte;
     P     :Pointer;
     A,B,C :Word;

 begin
  If Bm <> nil then
   begin
    Assign(F,FileName);
    Rewrite(F);
    P:=Bm;
    A:=Word(P^);
    LongInt(P):=LongInt(P)+2;
    B:=Word(P^);
    LongInt(P):=LongInt(P)+2;
    P:=Bm;
     For C := 0 to (A+1)*(B+1)+4 do
      begin
       Write(F,Byte(P^));
       LongInt(P):=LongInt(P)+1;
      end;
    Close(F);
   end;
 end;

Function ImgLarge(Bm:Pointer):Word;
var
    A,B :Word;
    P   :Pointer;
 begin
    P:=Bm;
    A:=Word(P^);
    LongInt(P):=LongInt(P)+2;
    B:=Word(P^);
    ImgLarge:=(A+1)*(B+1)+4;
 end;

Procedure FreeImg(var Bm:Pointer);
var
    A,B :Word;
    P   :Pointer;
 begin
    P:=Bm;
    A:=Word(P^);
    LongInt(P):=LongInt(P)+2;
    B:=Word(P^);
    FreeMem(Bm,(A+1)*(B+1)+4);
{    Bm:=nil;}
 end;

Procedure SetRGB(Barva:Word;R,G,B:Byte);
var
   w          :Word;
   b1,b2,b3   :Byte;
 begin
  b1:=R;
  b2:=G;
  b3:=B;
  w:=Barva;
  asm
   mov AX,$1010
   mov BX,w
   mov DH,b1
   mov CH,b2
   mov CL,b3
   int $10
  end;
  Colors[Barva].Red:=b1;
  Colors[Barva].Green:=b2;
  Colors[Barva].Blue:=b3;
 end;

Procedure RefreshPalette; assembler;
 asm
   mov AX,seg Colors
   mov ES,AX
   mov DX,offset Colors
   mov AX,$1012
   mov BX,$0000
   mov CX,$00FF

   int $10
 end;

Procedure MakeGrayScale; assembler;
 asm
  mov AX,$101B
  mov BX,$0000
  mov CX,$00FF
  int $10
 end;

Procedure Rectangle(X1,Y1,X2,Y2:Word;Color:Byte;Fill:Boolean);
 var A,B:Word;
   begin
      If Fill then
       For A:=X1 to X2 do
        For B:=Y1 to Y2 do
         Put(A,B,Color)
      else
       begin
        For A:=X1 to X2 do
         begin
          Put(A,Y1,Color);
          Put(A,Y2,Color);
         end;
        For A:=Y1 to Y2 do
         begin
          Put(X1,A,Color);
          Put(X2,A,Color);
         end;
       end;
   end;

Procedure FillAll(Source:Byte);
var A:Word;
begin
 For A:= 0 to 320*200 do Mem[$A000:A]:=Source;
end;

Procedure ChangeColor(Source,Target:Byte);
var A:Word;
begin
 For A:= 0 to 320*200 do If Mem[$A000:A] = Target then Mem[$A000:A]:=Source;
end;

Function SelectColor(var Selected:Byte):Boolean;
var
    A,B   :Byte;
    Ch    :Char;
 begin
  SaveScreen;
  FillAll(0);
   For A:= 0 to 15 do
    For B:= 0 to 15 do
     begin
      Rectangle(A*10+1,B*10+1,A*10+9,B*10+9,B*16+A,True);
     end;
   A:=Selected;
   Repeat
    Rectangle(A mod 16*10,A div 16*10,A mod 16*10+10,A div 16*10+10,15,False);
    Ch:=UpCase(ReadKey);
    Rectangle(A mod 16*10,A div 16*10,A mod 16*10+10,A div 16*10+10,0,False);
     Case Ch of
      #13:begin Selected:=A; SelectColor:=True; end;
      #27:begin SelectColor:=False; end;
      'E':EditColor(A);
      #0: Case ReadKey of
           'M':A:=A+1;
           'K':A:=A-1;
           'H':A:=A-16;
           'P':A:=A+16;
          end;
     end;
   Until (Ch=#27) or (Ch=#13);
  LoadScreen;
 end;

Procedure LoadVideoFromFile(Fln:String;var P:Pointer);
 var  L:LongInt;
      F:File of Byte;
 begin
  Assign(F,Fln);
  Reset(F);
  GetMem(P,FileSize(F));
  L:=-1;
   Repeat
    Inc(L);
    Read(F,Byte(Pointer(LongInt(P)+L)^));
   Until Eof(F);
  Close(F);
 end;

{     TVideoHead = record
                   X,Y                  :Word;
                   Height,Width         :Word;
                   Frame,Frames         :Word;
                   BFrames              :Pointer;
                   Active               :Boolean;
                   NextVideo            :PVideoHead;
                  end;}

{Procedure PlaceVideo(V:Pointer;Krok:Byte;Play:Boolean);
 var NP:PVideoHead;
 begin
    New(NP);
    NP^.NextVideo:=PVideo;
    NP^:=TVideoHead(V^);
    NP^.NextVideo:=Nil;
    NP^.Active:=Play;
    NP^.Frame:=Krok;
    PVideo:=NP;
 end;}

Procedure SaveScreenToFile(FName:String);
 var F:File of TObraz;
 begin
  Assign(F,FName);
  ReWrite(F);
  Write(F,Screen);
  Close(F);
 end;

Procedure LoadScreenFromFile(FName:String);
 var F:File of TObraz;
 begin
  Assign(F,FName);
  Reset(F);
  Read(F,Screen);
  Close(F);
 end;

Procedure LoadMap(FileName:String;var P:PMap);
var F:File of TMapFile;
begin
 New(P);
 Assign(F,FileName);
 Reset(F);
 Read(F,P^);
 Close(F);
end;

Procedure Mapuj(Map:PMaping);
var X,Y:Byte;
begin
 For Y:=0 to 100 do
  For X:=0 to 100 do
   begin
    If (Map^.Map^[X,Y].X <= 100) and (Map^.Map^[X,Y].Y <= 100)
    then Put(Map^.Cil.X+X,Map^.Cil.Y+Y,Map^.Source^[Map^.Map^[X,Y].X,Map^.Map^[X,Y].Y])
    else Put(Map^.Cil.X+X,Map^.Cil.Y+Y,0);
   end;
end;

Procedure GetSourceFromScreen(xX,xY:Word;var P:PSource);
var X,Y:Word;
begin
 New(P);
 For X:=0 to 100 do
  For Y:=0 to 100 do
   begin
    P^[X,Y]:=Get(X+xX,Y+xY);{P^[X,Y]:=Screen[X+xX,Y+xY];}
   end;
end;

Procedure LoadPaletteFromFile(Name:String);
 var F:File of TBarvy;
 begin
  Assign(F,Name);
  Reset(F);
  Read(F,Colors);
  Close(F);
  RefreshPalette;
 end;

Procedure LoadBGR256PaletteFromFile(Name:String);
 var
     F:File of TBarvy;
     B:Byte;
     c:TBarva;
 begin
  Assign(F,Name);
  Reset(F);
  Read(F,Colors);
  Close(F);
  For B:= 0 to 255 do
   begin
    C:=Colors[B];
    Colors[B].Red:=C.Blue div 4;
    Colors[B].Green:=C.Green div 4;
    Colors[B].Blue:=C.Red div 4;
   end;
  RefreshPalette;
 end;

Function  EditColor(var Color:Byte):Boolean;
 var Bool :Boolean;
     C    :TBarva;
 begin
  C:=Colors[Color];
  SaveScreen;
  DirectVideo:=False;
  GoToXY(1,1);
  FillAll(0);
  TextColor(15);
  TextBackground(0);
  Write('<R>,<G>,<B> = pricti',#13,#10,#13,#10,'<r>,<g>,<b> = odecti hodnotu');
  Rectangle(0,100,MaxX,MaxY,Color,True);
  Bool:=False;
  Repeat
   GoToXY(1,5);
   Write('Cervena:  ',C.Red,' ',#13,#10,#13,#10,
         'Zelena:   ',C.Green,' ',#13,#10,#13,#10,
         'Modra:    ',C.Blue,' ');
   Case ReadKey of
    'R':Inc(C.Red);
    'G':Inc(C.Green);
    'B':Inc(C.Blue);

    'r':Dec(C.Red);
    'g':Dec(C.Green);
    'b':Dec(C.Blue);

    #27:Bool:=True;
   end;

   If C.Red = 64 then C.Red:=0;
   If C.Green = 64 then C.Green:=0;
   If C.Blue = 64 then C.Blue:=0;

   If C.Red = 255 then C.Red:=63;
   If C.Green = 255 then C.Green:=63;
   If C.Blue = 255 then C.Blue:=63;

   SetRGB(Color,C.Red,C.Green,C.Blue);
  Until Bool;
  LoadScreen;
 end;

Procedure SavePalToFile(Name:String);
 var F:File of TBarvy;
 begin
  Assign(F,Name);
  Rewrite(F);
  Write(F,Colors);
  Close(F);
 end;


(*** PRI NACITANI UNITu : ***)
begin
 SScr:=Nil;
{PVideo:=Nil;}
end.










