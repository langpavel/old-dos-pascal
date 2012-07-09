Program Zaklad_pro_sluzby_XMS;
uses CRT,G320x200,Dos;

const MaxX        :LongInt = 2000;
const MaxY        :LongInt = 2000;
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
const Hranice     :Byte = 140;
const FireD       :Byte = 6;

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
              X,Y       :LongInt;
              XInc,
              YInc      :ShortInt;
              Smer      :Byte;
              MSmer     :Byte;
              En        :Word;
              Stit      :Word;
              Kule      :Byte;
              Rakety    :Byte;
              Miny      :Byte;
              Lekarn    :Byte;
              MoveDelay :Byte;
              FireDelay :Byte;
             end;

type THome = record
              X,Y :LongInt;
             end;

type TRam = Array[0..15,0..15] of byte;

type TStrela = record
                X,
                Y        :LongInt;
                XInc,
                YInc     :ShortInt;
                Je       :Boolean;
                Ci       :Byte;
               end;

var
    Pole      :Array[0..20000] of byte;
    Handle    :Word;
    SizeKB    :Word;
    MoveStruc :TMoveStruc;
    Himem     :Pointer;
    IsItOK    :Boolean;
    Error     :Byte;

    Old09Int  :Pointer;
    Ints      :Array[0..255] of Pointer absolute 0:0;
    Stisk     :Array[1..128] of Boolean;

    Hr        :Array[1..2] of TTank;
    W1,W2,W3  :LongInt;
    B1        :Byte;
    Ram       :TRam;
    F         :File of TRam;
    Tank      :Array[1..2,1..8] of TRam;
    Strela    :TRam;
    Home1,
    Home2     :THome;
    Strely    :Array[1..16] of TStrela;

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

Procedure SmazPametKlaves;
 begin
  For W1:= 1 to 128 do Stisk[W1]:=False;
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
 var R     :TRam;
     w1,w2 :LongInt;
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

Function JeMoznoKreslitTanka(XMem,YMem:Word;Ram:TRam):Boolean;
 var
     R     :TRam;
     w1,w2 :LongInt;
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
  JeMoznoKreslitTanka:=True;
  For W1 := 0 to 15 do
   For W2 := 0 to 15 do
    If Ram[W1,W2] <> 0 then
     If (R[W1,W2]+1) mod 256 > 4 then JeMoznoKreslitTanka:=False;
 end;

Function JeMoznoKreslitStrelu(XMem,YMem:Word;Ram:TRam):Boolean;
 var
     R     :TRam;
     w1,w2 :LongInt;
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
  JeMoznoKreslitStrelu:=True;
  For W1 := 0 to 15 do
   For W2 := 0 to 15 do
    If Ram[W1,W2] <> 0 then
     If Byte(R[W1,W2]+1) > 1 then JeMoznoKreslitStrelu:=False;
 end;

Procedure KontrolujRamec(var Hr:TTank);
 begin
  If Hr.X < 0 then Hr.X:=0;
  If Hr.Y < 0 then Hr.Y:=0;
  If Hr.X > MaxX - Hranice then Hr.X:=MaxX-Hranice;
  If Hr.Y > MaxY - Hranice then Hr.Y:=MaxY-Hranice;
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

Procedure PutByteToXMS(XMem,YMem:LongInt;B:Byte);
 begin
   MoveStruc.Length:=1;
   MoveStruc.SourceHandle:=Handle;
   MoveStruc.SourceOffset:=Pointer(XMem+YMem*MaxX);
   MoveStruc.DestHandle:=0;
   MoveStruc.DestOffset:=Addr(B);
   Presun;
 end;

Procedure DrawMap;
 var
     Bool,C,
     Dr,W      :Boolean;
     Zoom      :Byte;
     X,Y       :LongInt;
     A,B       :Word;

 Procedure Draw;
  var D:Word;
  begin
  If Zoom = 1 then
   begin
    If X > MaxX - 320 then X := MaxX-320;
    If Y > MaxY - 200 then Y := MaxY-200;
{}   ZobrazRamec(0,0,320,200,X,Y);
   end
  else
   begin
   B:=(MaxY - Y) div Zoom;
   If B > 199 then B:=199;
   For W2:=0 to B do
    begin
     MoveStruc.Length:=Zoom*320;
     If MoveStruc.Length > MaxX - X then MoveStruc.Length:=MaxX - X;
     MoveStruc.SourceHandle:=Handle;
     MoveStruc.SourceOffset:=Pointer(W2*Zoom*MaxX+Y*MaxX+X);
     MoveStruc.DestHandle:=0;
     MoveStruc.DestOffset:=Pointer(LongInt(Addr(Pole))+X);
     Presun;
     A:=(MaxX - X) div Zoom;
     If A > 319 then A:= 319;
     If A < 319 then For W1:=A to 319 do Put(W1,W2,0);
     For W1:=0 to A do Put(W1,W2,Pole[W1*Zoom+X]);
    end;
   If B < 199 then
    For D:=B to 199 do
      For W1:=0 to 319 do Put(W1,D,0);
    end;
   If W and (Zoom > 1) then Rectangle(0,0,Trunc((Zoom-1)/Zoom*320),Trunc((Zoom-1)/Zoom*200),7,False);
  end;

 begin
  Zoom:=10;
  X:=0;
  Y:=0;
  W:=True;
  Bool:=False;
  Repeat
   If Zoom = 0 then begin Zoom := 1; C:=False; end;
   If Zoom > 100 then begin Zoom := 100; C:=False; end;
   If X > MaxX then begin X:=MaxX; C:=False; end;
   If Y > MaxY then begin Y:=MaxY; C:=False; end;
   If X < 0 then begin X:=0; C:=False; end;
   If Y < 0 then begin Y:=0; C:=False; end;
   If C or Dr then
    begin
{}   Dr:=False;
     Draw;
    end;
   C:=True;
   Case UpCase(ReadKey) of
    #0      :Case ReadKey of
              'H':Dec(Y,Zoom*25);
              'P':Inc(Y,Zoom*25);
              'K':Dec(X,Zoom*25);
              'M':Inc(X,Zoom*25);
             end;
    #27,#13 :Bool:=True;
    '+'     :begin
               Zoom:=Zoom-1;
               If Zoom = 0 then Zoom := 1;
               Dr:= true;
             end;
    '-'     :begin
               Zoom:=Zoom+1;
               If Zoom > 100 then Zoom := 100;
               Dr:= true;
             end;
    'W'     :W:=Not W;
    else C:=False;
   end;
  Until Bool
 end;

Procedure NovaPlocha;
var a,b:Word;
    Special:Tram;
begin
 LoadPaletteFromFile('Loading.pal');
 LoadScreenFromFile('Loading.pic');
 Repeat
  Hr[1].X:=Random(MaxX);
  Hr[1].Y:=Random(MaxY);
 Until JeMoznoKreslitTanka(Hr[1].X,Hr[1].Y,Tank[1,4]);
 Repeat
  Hr[2].X:=Random(MaxX);
  Hr[2].Y:=Random(MaxY);
 Until JeMoznoKreslitTanka(Hr[2].X,Hr[2].Y,Tank[2,6]);
 KontrolujRamec(Hr[1]);
 KontrolujRamec(Hr[2]);
   For W2:= 0 to 10000 do
{}  begin
      B1:=Random(256);
      Boolean(Pole[W2]):=B1 mod 2 = 0;
      Inc(Pole[W2]);
      If B1 > 253 then Pole[W2]:=3;
    end;

 For W1:= 0 to 15 do
  For W2:= 0 to 15 do
   Special[W1,W2]:=0;

 For W1:= 0 to 15 do
  begin
   Special[7,W1]:=7;
   Special[W1,7]:=7;
   Special[7,W1]:=7;
   Special[W1,W1]:=7;
   Special[15-w1,W1]:=7;
  end;

 For W1:= 0 to MaxY-1 do
  begin
   MoveStruc.Length:=MaxX;
   MoveStruc.SourceHandle:=0;
   MoveStruc.SourceOffset:=Addr(Pole[Random(10000-MaxX)]);
   MoveStruc.DestHandle:=Handle;
   MoveStruc.DestOffset:=Pointer(W1*MaxX);
   Presun;
   A:=Trunc(W1/(MaxY-1) * 200)+10;
   B:=Get(A,159);
   For W2:= 160 to 190 do Put(A,W2,B);
  end;

  For W1:= 0 to 150 do
   begin
    A:=Trunc(W1/150*100)+200;
    B:=Get(A,159);
    For W2:= 160 to 190 do Put(A,W2,B);
    ZapisRamec(50 + Random(MaxX-100),50 + Random(MaxY-100),Special);
   end;
end;

Procedure PosunTanka(var Hr:TTank);
 begin
  SmazRamec(Hr.X+65,Hr.Y+65,Tank[1,Hr.MSmer]);
  If JeMoznoKreslitTanka(Hr.X+Hr.XInc+65,Hr.Y+Hr.YInc+65,Tank[1,Hr.Smer]) then
   begin
    Hr.X:=Hr.X+Hr.XInc;
    Hr.Y:=Hr.Y+Hr.YInc;
   end
  else
   begin
    Hr.Smer:=Hr.MSmer;
    Hr.Smer:=Hr.MSmer;
   end;
  KontrolujRamec(Hr);
 end;

Procedure KresliTanky;
 begin
   ZapisRamec(Hr[1].X+65,Hr[1].Y+65,Tank[1,Hr[1].Smer]);
   ZapisRamec(Hr[2].X+65,Hr[2].Y+65,Tank[2,Hr[2].Smer]);
   ZobrazRamec(Pol1X,Pol1Y,RamecX,RamecY,Hr[1].X,Hr[1].Y);
   ZobrazRamec(Pol2X,Pol2Y,RamecX,RamecY,Hr[2].X,Hr[2].Y);
 end;

Procedure Smer(var H:TTank);
 begin
   If (H.XInc = 0) and
      (H.YInc =-1) then H.Smer:=1;
   If (H.XInc = 0) and
      (H.YInc = 1) then H.Smer:=2;
   If (H.XInc =-1) and
      (H.YInc = 0) then H.Smer:=3;
   If (H.XInc = 1) and
      (H.YInc = 0) then H.Smer:=4;
   If (H.XInc =-1) and
      (H.YInc =-1) then H.Smer:=5;
   If (H.XInc = 1) and
      (H.YInc =-1) then H.Smer:=6;
   If (H.XInc = 1) and
      (H.YInc = 1) then H.Smer:=7;
   If (H.XInc =-1) and
      (H.YInc = 1) then H.Smer:=8;
 end;

Procedure Konec;
 begin;
  Uvolni;
  CloseGr;
  Halt;
 end;
{$F-}

Procedure Nastaveni;
 var
     Bool    :Boolean;
     Pole    :Array[1..4] of byte;
 begin
  LoadPaletteFromFile('Setup.pal');
  LoadScreenFromFile('Setup.pic');
  Bool:=False;
  Repeat
   Case ReadKey of
{}  #00: Case ReadKey of
           'H':Begin end;
         end;
    #27: Bool:=True;
   end;

  Until Bool;
 end;


Procedure UrciPosun(Sm:Byte;var X:ShortInt;var Y:ShortInt);
 begin
  Case Sm of
   1: begin X:= 0; Y:=-1; end;
   2: begin X:= 0; Y:= 1; end;
   3: begin X:=-1; Y:= 0; end;
   4: begin X:= 1; Y:= 0; end;
   5: begin X:=-1; Y:=-1; end;
   6: begin X:= 1; Y:=-1; end;
   7: begin X:= 1; Y:= 1; end;
   8: begin X:=-1; Y:= 1; end;
  end;
 end;

Procedure NovaStrela(T:Byte;var H:TTAnk);
 var
    B:Byte;
    X,Y:ShortInt;
 begin
  If H.Kule > 0 then
   begin
    B:=0;
    Repeat Inc(B) until not Strely[B].Je;
    UrciPosun(H.Smer,X,Y);
    Strely[B].X:=H.X+X*6;
    Strely[B].Y:=H.Y+Y*6;
    Strely[B].XInc:=X*2;
    Strely[B].YInc:=Y*2;
    Strely[B].Je:=True;
    Strely[B].Ci:=T;
    Dec(H.Kule);
    Hr[T].FireDelay:=FireD;
   end;
 end;

Procedure PosunStrely;
 var B,c:Byte;
 begin
  For B:= 1 to 16 do
   If Strely[B].Je then
    begin
     SmazRamec(Strely[B].X+65,Strely[B].Y+65,Strela);
     If JeMoznoKreslitStrelu(Strely[B].X+Strely[B].XInc+65,
                             Strely[B].Y+Strely[B].YInc+65,Strela) then
        begin
         Strely[B].X:=Strely[B].X+Strely[B].XInc;
         Strely[B].Y:=Strely[B].Y+Strely[B].YInc;
         ZapisRamec(Strely[B].X+65,Strely[B].Y+65,Strela);
        end
       else
        begin
         Strely[B].Je:=False;
         Inc(Hr[Strely[B].Ci].Kule);
         For C:=0 to 10 do PutByteToXMS(Strely[B].X+Random(7)-3,Strely[B].Y+Random(7)-3,0);
        end;
    end;
 end;

Procedure Hra;
 var Bool:Boolean;
  Procedure MenuHry;
   var
    B:Boolean;
    S:Byte;
 begin
  Ints[9]:=Old09Int;
  SavePal;
  SaveScreen;
  FillAll(0);
  LoadPaletteFromFile('Menu.pal');
  LoadScreenFromFile('MenuHry.pic');
  B:=False;
  S:=1;
  Repeat
   Case Upcase(ReadKey) of
    'P'     :begin B:=True; end;
    'N'     :begin SavePal; SaveScreen; Nastaveni; LoadPal; LoadScreen; end;
    'K'     :begin Bool:=True; B:=True; end;

    #13 : Case S of
           1 :begin B:=True; end;
           2 :begin SavePal; SaveScreen; Nastaveni; LoadPal; LoadScreen; end;
           3 :begin Bool:=True; B:=True; end;
          end;
     #00 : Case ReadKey of
            'P':S:=S+1;
            'H':S:=S-1;
           end;
    end;
    If S = 0 then S:= 3;
    If S = 4 then S:= 1;
    If S = 1 then Rectangle(189,59,191,61,30,True)
             else Rectangle(189,59,191,61,29,True);
    If S = 2 then Rectangle(189,79,191,81,30,True)
             else Rectangle(189,79,191,81,29,True);
    If S = 3 then Rectangle(189,99,191,101,30,True)
             else Rectangle(189,99,191,101,29,True);
   Until B;
   LoadPal;
   LoadScreen;
   Ints[9]:=Addr(KeyServis);
   SmazPametKlaves;
  end;

 begin
 NovaPlocha;
 Hr[1].Kule:=8;
 Hr[2].Kule:=8;
 For Byte(Bool):= 1 to 16 do Strely[Byte(Bool)].Je:=False;
 PutImgMode:=1;
 Transparent:=255;

 LoadPaletteFromFile('Hr_pole.pal');
 LoadScreenFromFile('Hr_pole.pic');
 Bool:=False;
 Old09Int:=Ints[9];
 Ints[9]:=Addr(KeyServis);

 Hr[1].Smer:=4;
 Hr[2].Smer:=3;
 SmazPametKlaves;
 Bool:=False;
  Repeat
    Hr[1].XInc:= 0;
    Hr[1].YInc:= 0;
    Hr[2].XInc:= 0;
    Hr[2].YInc:= 0;

{ --> }If Stisk[077] then Hr[1].XInc:=Hr[1].XInc + 1;
{\/ Dn}If Stisk[080] then Hr[1].YInc:=Hr[1].YInc + 1;
{ <-- }If Stisk[075] then Hr[1].XInc:=Hr[1].XInc - 1;
{/\ Up}If Stisk[072] then Hr[1].YInc:=Hr[1].YInc - 1;

{  D  }If Stisk[032] then Hr[2].XInc:=Hr[2].XInc + 1;
{  S  }If Stisk[031] then Hr[2].YInc:=Hr[2].YInc + 1;
{  A  }If Stisk[030] then Hr[2].XInc:=Hr[2].XInc - 1;
{  W  }If Stisk[017] then Hr[2].YInc:=Hr[2].YInc - 1;

{ Esc }If Stisk[001] then MenuHry;

   Hr[1].MSmer:=Hr[1].Smer;
   Hr[2].MSmer:=Hr[2].Smer;
   Smer(Hr[1]);
   Smer(Hr[2]);
   PosunTanka(Hr[1]);
   PosunTanka(Hr[2]);
   KresliTanky;

   If Hr[1].FireDelay > 0 then Dec(Hr[1].FireDelay);
   If Hr[2].FireDelay > 0 then Dec(Hr[2].FireDelay);

   If Hr[1].FireDelay = 0
   then {1. Enter}If Stisk[028] then NovaStrela(1,Hr[1]);

   If Hr[2].FireDelay = 0
   then {2. Ctrl }If Stisk[029] then NovaStrela(2,Hr[2]);

   PosunStrely;
   Delay(GameDelay);

  Until Bool;
 Ints[9]:=Old09Int;
 DrawMap;
end;

Procedure Menu;
 var
    B:Boolean;
    S:Byte;
 begin
  LoadPaletteFromFile('Menu.pal');
  LoadScreenFromFile('Menu.pic');
  B:=False;
  S:=1;
  Repeat
   Case Upcase(ReadKey) of
    'S'     :begin SavePal; SaveScreen; Hra;       LoadPal; LoadScreen; end;
    'N'     :begin SavePal; SaveScreen; Nastaveni; LoadPal; LoadScreen; end;
    'K',#27 :B:=True;

    #13 : Case S of
           1: begin SavePal; SaveScreen; Hra;       LoadPal; LoadScreen; end;
           2: begin SavePal; SaveScreen; Nastaveni; LoadPal; LoadScreen; end;
           3: B:=True;
          end;
    #00 : Case ReadKey of
           'P':S:=S+1;
           'H':S:=S-1;
          end;
   end;
   If S = 0 then S:= 3;
   If S = 4 then S:= 1;
   If S = 1 then Rectangle(189,59,191,61,30,True)
            else Rectangle(189,59,191,61,29,True);
   If S = 2 then Rectangle(189,79,191,81,30,True)
            else Rectangle(189,79,191,81,29,True);
   If S = 3 then Rectangle(189,99,191,101,30,True)
            else Rectangle(189,99,191,101,29,True);
  Until B;
 end;

{****************************************************************************}

BEGIN
 GetHIMEMAddr;
 GetXMSSize;
  If SizeKB < MaxX*MaxY div 1000 then
    begin
      WriteLn('Nedostatek XMS pameti. Je nutno nejmene ',MaxX*MaxY div 1000,' Kb, ale je dostupno pouze ',SizeKB,' Kb.');
      Halt;
    end;
 SizeKB:=MaxX*MaxY div 1000;
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
 Assign(F,'Strela.IMG');
 Reset(F);
 Read(F,Strela);
 Close(F);

 Alokuj;
 InitGr;
 Randomize;
 Menu;
 Konec;
END.





