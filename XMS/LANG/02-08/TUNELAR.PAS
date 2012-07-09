Program Zaklad_pro_sluzby_XMS;
uses CRT,G320x200;

const MaxX        :LongInt = 3000;
const MaxY        :LongInt = 1800;
const Krok        :Byte = 1;
const GameDelay   :Word = 1;

const Pol1X       :LongInt = 171;
const Pol1Y       :LongInt = 10;
const Pol2X       :LongInt = 10;
const Pol2Y       :LongInt = 10;
const RamecX      :LongInt = 140;
const RamecY      :LongInt = 140;
const T1X         :LongInt = 171+70;
const T1Y         :LongInt = 10+70;

type TMoveStruc = record
                   Length       :LongInt;
                   SourceHandle :Word;
                   SourceOffset :Pointer;
                   DestHandle   :Word;
                   DestOffset   :Pointer;
                   {Nastavenim Handle na 0 se bude presouvat
                   z/do realne pameti na adrese Src/DestOffset}
                  end;

type TTank = record
              X,Y    :LongInt;
              Smer   :Byte;
              MSmer  :Byte;
              En     :Word;
              Stit   :Word;
              Kule   :Byte;
              Rakety :Byte;
              Miny   :Byte;
              Lekarn :Byte;
             end;

type THome = record
              X,Y :LongInt;
             end;

type TRam = Array[0..15,0..15] of byte;

var
    Pole      :Array[0..3000] of byte;
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;

    Old09Int  :Pointer;
    Ints      :Array[0..255] of Pointer absolute 0:0;
    Stisk     :Array[1..128] of Boolean;

    Hr1       :TTank;
    Hr2       :TTank;
    W1,W2     :LongInt;
    Bool      :Boolean;
    B1        :Byte;
    Ram       :TRam;
    F         :File of TRam;
    Tank      :Array[1..2,1..8] of TRam;
    Home1,
    Home2     :THome;

Procedure GetHIMEMAddr; {$I -GetAddr.xms }
Procedure Alokuj;       {$I -Alokuj.xms  }
Procedure Uvolni;       {$I -Uvolni.xms  }
Procedure Presun;       {$I -Presun.xms  }
Procedure GetXMSSize;   {$I -XMSSize.xms }

Procedure KeyServis; interrupt;
 var X:Byte;
 begin
  X:=Port[$60];
  If X < $80 then Stisk[X]:=True
             else Stisk[X-$80]:=False;
  asm
   pushf
   call Old09Int

   mov ah,01
   int $16
   jz @@Zero

   xor ax,ax
   int $16
@@Zero:
  end;
 end;

Procedure ZobrazRamec(X,Y,Sirka,Vyska,XMem,YMem:Word);
 begin
  For W1 := 0 to Vyska-1 do
   begin
    MoveStruc.Length:=Sirka;
    MoveStruc.SourceHandle:=Handle;
    MoveStruc.SourceOffset:=Pointer(XMem+(W1+YMem)*MaxX);
    MoveStruc.DestHandle:=0;
    MoveStruc.DestOffset:=Ptr($A000,X+(Y+W1)*320);
    Presun;
   end;
 end;

Procedure ZapisRamec(XMem,YMem:Word;Ram:TRam);
 var R:TRam;
 begin
  For W1 := 0 to 15 do
   begin
    MoveStruc.Length:=16;
    MoveStruc.SourceHandle:=Handle;
    MoveStruc.SourceOffset:=Pointer(XMem+(W1+YMem)*MaxX);
    MoveStruc.DestHandle:=0;
    MoveStruc.DestOffset:=Ptr(Seg(R),Ofs(R)+W1*16);
    Presun;
   end;
  For W1 := 0 to 15 do
   For W2 := 0 to 15 do
    If Ram[W1,W2] <> 0 then R[W1,W2]:=Ram[W1,W2];
  For W1 := 0 to 15 do
   begin
    MoveStruc.Length:=16;
    MoveStruc.SourceHandle:=0;
    MoveStruc.SourceOffset:=Ptr(Seg(R),Ofs(R)+W1*16);
    MoveStruc.DestHandle:=Handle;
    MoveStruc.DestOffset:=Pointer(XMem+(W1+YMem)*MaxX);
    Presun;
   end;
 end;

Procedure SmazRamec(XMem,YMem:Word;Ram:TRam);
 var R:TRam;
 begin
  For W1 := 0 to 15 do
   begin
    MoveStruc.Length:=16;
    MoveStruc.SourceHandle:=Handle;
    MoveStruc.SourceOffset:=Pointer(XMem+(W1+YMem)*MaxX);
    MoveStruc.DestHandle:=0;
    MoveStruc.DestOffset:=Ptr(Seg(R),Ofs(R)+W1*16);
    Presun;
   end;
  For W1 := 0 to 15 do
   For W2 := 0 to 15 do
    If Ram[W1,W2] <> 0 then R[W1,W2]:=0;
  For W1 := 0 to 15 do
   begin
    MoveStruc.Length:=16;
    MoveStruc.SourceHandle:=0;
    MoveStruc.SourceOffset:=Ptr(Seg(R),Ofs(R)+W1*16);
    MoveStruc.DestHandle:=Handle;
    MoveStruc.DestOffset:=Pointer(XMem+(W1+YMem)*MaxX);
    Presun;
   end;
 end;

Function GetByteFromXMS(XMem,YMem:LongInt):Byte;
 var B:Word;
 begin
   MoveStruc.Length:=2;
   MoveStruc.SourceHandle:=Handle;
   MoveStruc.SourceOffset:=Pointer(XMem+YMem*MaxX);
   MoveStruc.DestHandle:=0;
   MoveStruc.DestOffset:=Addr(B);
   Presun;
   GetByteFromXMS:=Byte(B);
 end;

Procedure DrawMap;
 begin
  FillAll(7);
  For W1:=0 to (MaxX - 1) div 10 do
   For W2:=0 to (MaxY - 1) div 10 do
    Put(W1+10,W2+10,GetByteFromXMS(W1*10,W2*10));
 end;

Procedure NovaPlocha;
begin
 B1:=2;
 FillAll(0);
 DirectVideo:=False;
 TextColor(7);
 For W1:= 0 to MaxY-1 do
  begin
   For W2:= 0 to MaxX-1 do
    begin
      B1:=Random(3);
{      If B1 mod 2 = 1 then Pole[W2]:=2 else Pole[W2]:=3;}
      Boolean(Pole[W2]):=not B1 mod 2 = 1;
      Inc(Pole[W2]);
{     If B1 = 255 then Pole[W2]:=1;
      If (W2 < 70) or (Random(200) - W2 > 80) then Pole[W2]:=6;
      If (W1 < 70) or (Random(200) - W1 > 80) then Pole[W2]:=6;}
    end;
   MoveStruc.Length:=MaxX;
   MoveStruc.SourceHandle:=0;
   MoveStruc.SourceOffset:=Addr(Pole);
   MoveStruc.DestHandle:=Handle;
   MoveStruc.DestOffset:=Pointer(W1*MaxX);
   Presun;
   GoToXY(1,1);
   Write('Generuji plochu: ',Trunc(W1/(MaxY-1) * 100),'%   ');
  end;
end;

Procedure Konec;
 begin;
  Uvolni;
  CloseGr;
  Halt;
 end;

Procedure Menu;
 var B:Boolean;
 begin
  LoadPaletteFromFile('Menu.pal');
  LoadScreenFromFile('Menu.pic');
  B:=False;
  Repeat
   Case Upcase(ReadKey) of
    'K',#27 :Konec;
    'S'     :Hra;
{   'N'     :Nastaveni;}
   end;
  Until B;
 end;

begin
 Randomize;
 GetHIMEMAddr;
 GetXMSSize;
 If SizeKB < MaxX*MaxY div 1000 then
    begin
      WriteLn('Nedostatek XMS pameti. Je nutno nejmene ',MaxX*MaxY div 1000,' Kb, ale je dostupno pouze ',SizeKB,' Kb.');
      Halt;
    end;
 SizeKB:=MaxX*MaxY div 1000;
 Alokuj;
 InitGr;
 NovaPlocha;
 PutImgMode:=1;
 Transparent:=255;

 LoadPaletteFromFile('Hr_pole.pal');
 LoadScreenFromFile('Hr_Pole.pic');
 Bool:=False;
 Old09Int:=Ints[9];
 Ints[9]:=Addr(KeyServis);

 Assign(F,'TANKG.IMG');
 Reset(F);
  For W1 := 1 to 8 do
   Read(F,Tank[1,W1]);
 Close(F);
 Assign(F,'TANKB.IMG');
 Reset(F);
  For W1 := 1 to 8 do
   Read(F,Tank[2,W1]);
 Close(F);

 Hr1.Smer:=1;
 Hr2.Smer:=1;

  Repeat
   If    (Stisk[077]) and
      not(Stisk[080]) and
      not(Stisk[075]) and
      not(Stisk[072]) then Hr1.Smer:=4;

   If not(Stisk[077]) and
         (Stisk[080]) and
      not(Stisk[075]) and
      not(Stisk[072]) then Hr1.Smer:=2;

   If not(Stisk[077]) and
      not(Stisk[080]) and
         (Stisk[075]) and
      not(Stisk[072]) then Hr1.Smer:=3;

   If not(Stisk[077]) and
      not(Stisk[080]) and
      not(Stisk[075]) and
         (Stisk[072]) then Hr1.Smer:=1;

   If    (Stisk[077]) and
         (Stisk[080]) and
      not(Stisk[075]) and
      not(Stisk[072]) then Hr1.Smer:=7;

   If not(Stisk[077]) and
         (Stisk[080]) and
         (Stisk[075]) and
      not(Stisk[072]) then Hr1.Smer:=8;

   If not(Stisk[077]) and
      not(Stisk[080]) and
         (Stisk[075]) and
         (Stisk[072]) then Hr1.Smer:=5;

   If    (Stisk[077]) and
      not(Stisk[080]) and
      not(Stisk[075]) and
         (Stisk[072]) then Hr1.Smer:=6;


   If    (Stisk[032]) and
      not(Stisk[031]) and
      not(Stisk[030]) and
      not(Stisk[017]) then Hr2.Smer:=4;

   If not(Stisk[032]) and
         (Stisk[031]) and
      not(Stisk[030]) and
      not(Stisk[017]) then Hr2.Smer:=2;

   If not(Stisk[032]) and
      not(Stisk[031]) and
         (Stisk[030]) and
      not(Stisk[017]) then Hr2.Smer:=3;

   If not(Stisk[032]) and
      not(Stisk[031]) and
      not(Stisk[030]) and
         (Stisk[017]) then Hr2.Smer:=1;

   If    (Stisk[032]) and
         (Stisk[031]) and
      not(Stisk[030]) and
      not(Stisk[017]) then Hr2.Smer:=7;

   If not(Stisk[032]) and
         (Stisk[031]) and
         (Stisk[030]) and
      not(Stisk[017]) then Hr2.Smer:=8;

   If not(Stisk[032]) and
      not(Stisk[031]) and
         (Stisk[030]) and
         (Stisk[017]) then Hr2.Smer:=5;

   If    (Stisk[032]) and
      not(Stisk[031]) and
      not(Stisk[030]) and
         (Stisk[017]) then Hr2.Smer:=6;

   If Hr1.Smer <> Hr1.MSmer then
    begin
     SmazRamec(Hr1.X+65,Hr1.Y+65,Tank[1,Hr1.MSmer]);
     Hr1.MSmer:=Hr1.Smer;
    end;

   If Hr2.Smer <> Hr2.MSmer then
    begin
     SmazRamec(Hr2.X+65,Hr2.Y+65,Tank[2,Hr2.MSmer]);
     Hr2.MSmer:=Hr2.Smer;
    end;

{ --> }If Stisk[077] then If Hr1.X < MaxX-150-Krok then Hr1.X:=Hr1.X+Krok;
{\/ Dn}If Stisk[080] then If Hr1.Y < MaxY-150-Krok then Hr1.Y:=Hr1.Y+Krok;
{ <-- }If Stisk[075] then If Hr1.X >= Krok then Hr1.X:=Hr1.X-Krok;
{/\ Up}If Stisk[072] then If Hr1.Y >= Krok then Hr1.Y:=Hr1.Y-Krok;

{  D  }If Stisk[032] then If Hr2.X < MaxX-150-Krok then Hr2.X:=Hr2.X+Krok;
{  S  }If Stisk[031] then If Hr2.Y < MaxY-150-Krok then Hr2.Y:=Hr2.Y+Krok;
{  A  }If Stisk[030] then If Hr2.X >= Krok then Hr2.X:=Hr2.X-Krok;
{  W  }If Stisk[017] then If Hr2.Y >= Krok then Hr2.Y:=Hr2.Y-Krok;

{ Esc }If Stisk[001] then Bool:=True;

   ZapisRamec(Hr1.X+65,Hr1.Y+65,Tank[1,Hr1.Smer]);
   ZapisRamec(Hr2.X+65,Hr2.Y+65,Tank[2,Hr2.Smer]);

   ZobrazRamec(Pol1X,Pol1Y,RamecX,RamecY,Hr1.X,Hr1.Y);
   ZobrazRamec(Pol2X,Pol2Y,RamecX,RamecY,Hr2.X,Hr2.Y);

   Delay(GameDelay);
  Until Bool;
 Ints[9]:=Old09Int;
 DrawMap;
 While KeyPressed do begin ReadKey end;
 ReadKey;
 Konec;
end.





