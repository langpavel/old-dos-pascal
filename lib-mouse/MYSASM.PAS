Unit MysAsm;
Interface

const
 BtLeft  : Word = 1;
 BtRight : Word = 2;
 BtMid   : Word = 4;

type
 TKurzor   = Array[0..31] of Word;
 TStr16    = String[16];
 StrKurz   = Array[0..31] of TStr16;
 StrKurz2  = record
              S       :Array[0..15] of TStr16;
              NewLine :Word;
             end;
 TKurzFile = record
               K : StrKurz2;
               X : Byte;
               Y : Byte;
             end;

Procedure InitMouse(var OK:Boolean;var BCount:Word);
Procedure MouseOn;
Procedure MouseOff;
Procedure MouseXYBut(var X:Word;var Y:Word;var Buttons:Word);
Procedure SetMouseXY(X,Y:Word);
Procedure MouseWindow(X1,Y1,X2,Y2:Word);
Procedure NastavCitlivostMysi(X,Y,Spd:Word);
Procedure CtiCitlivostMysi(var X, Y, Spd:Word);
Procedure SetGrafKurzor(VztaznX,VztaznY:Word;Segm,OffS:Word);
{Procedure SetTextKurzor(Typ,Obr:Word);}
Procedure TextEditKurzor;
Procedure SipkaKurzor;
Procedure InverzSipkaKurzor;
Procedure WaitKurzor;
Procedure DrawKurzor;
Procedure DrawBoldKurzor;
Procedure KurzorFromFile(FileN:String;Xp,Yp :Word);
Procedure KurzorFromTFile(FileN:String);
Procedure UdalostMysi(Segm,Ofst,Udal:Word);

Function Stisknuto:Word;
Function XMysi:Word;
Function YMysi:Word;
Function StiskTlac(Tlac:Word):Boolean;

Implementation

var
   Kurzor    : TKurzor;

Procedure InitMouse(var OK:Boolean;var BCount:Word);
  var a,b:word;
 begin
  OK:=False;
  asm
   mov ax,$0
   int $33
   mov A,Ax
   mov B,Bx
  end;
  If A = $FFFF then OK:=True;
  BCount:=B;
 end;

Procedure MouseOn;
 begin
  Asm
   mov ax,$1
   int $33
  end;
 end;

Procedure MouseOff;
 begin
  Asm
   mov ax,$2
   int $33
  end;
 end;

Procedure MouseXYBut(var X:Word;var Y:Word;var Buttons:Word);
var B,C,D:Word;
 begin
  asm
   mov ax,$3
   int $33
   mov B,Bx
   mov C,Cx
   mov D,Dx
  end;
   X:=C;
   Y:=D;
   Buttons:=B;
 end;

Procedure SetMouseXY(X,Y:Word);
 begin
  asm
   mov cx,X
   mov dx,Y
   mov ax,$4
   int $33
  end;
 end;

Procedure MouseWindow(X1,Y1,X2,Y2:Word);
 begin
  asm
   mov cx,X1
   mov dx,X2
   mov ax,$7
   int $33
   mov cx,Y1
   mov dx,Y2
   mov ax,$8
   int $33
  end;
 end;

Procedure NastavCitlivostMysi(X,Y,Spd:Word);
 begin
  asm
   mov bx,X
   mov cx,Y
   mov dx,Spd
   mov ax,$1A
   int $33
  end;
 end;

Procedure CtiCitlivostMysi(var X, Y, Spd:Word);
 var xx,yy,s:Word;
 begin
  asm
   mov ax,$1B
   int $33
   mov xx,bx
   mov yy,cx
   mov s,dx
  end;
 end;

Function SpecialGrafKurzor(Xr,Yr,Xp,Yp:Byte;Segm,Offs:Word):Boolean;
var Pomoc:Word;
 begin
  asm
   mov dx,OffS
   mov ax,Segm
   mov es,ax

   mov bh,Xr
   mov ch,Yr

   mov bl,Xp
   mov cl,Yp

   mov ax,$12
   int $33
   mov Pomoc,ax
  end;
  If Pomoc = $FFFF then SpecialGrafKurzor:=True else SpecialGrafKurzor:=False;
 end;

Procedure SetGrafKurzor(VztaznX,VztaznY:Word;Segm,OffS:Word);
 begin
  asm
   mov dx,OffS
   mov ax,Segm
   mov es,ax
   mov bx,VztaznX
   mov cx,VztaznY
   mov ax,$09
   int $33
  end;
 end;

{Procedure SetTextKurzor(Typ,Obr:Word);
 begin
  asm
   mov dx,
   mov ax,Sg
   mov es,ax
   mov bx,Typ
   mov cx,Obr
   mov ax,$0A
   int $33
  end;
 end;}

Procedure KurzorFromFile(FileN:String;Xp,Yp :Word);
 var
    F     :File of TKurzor;
 begin
  Assign(F,FileN);
  Reset(f);
  Read(f,Kurzor);
  Close(f);
  SetGrafKurzor(Xp,Yp,Seg(Kurzor),Ofs(Kurzor));
 end;

Procedure KurzorFromTFile(FileN:String);
 var
    F             :File of TKurzFile;
    Fi            :TKurzFile; {K, X, Y}
    W,Wx,W2,W3,W4 :Word;
 begin
  Assign(F,FileN);
  Reset(f);
  Read(f,Fi);
  Close(f);
  For W:= 0 to 15 do
   begin
    W2:=0;
    W3:=0;
    W4:=1;
     For Wx:=0 to 15 do
      begin
       Case Ord(UpCase(Fi.K.S[W][15-Wx])) of
        Ord('I'): begin W2:=W2+W4; W3:=W3+W4; end;
        Ord('*'): begin W2:=W2+W4; end;
        Ord('B'): begin W3:=W3+W4; end;
        Ord('C'): begin end;
       else W2:=W2+W4;
       end;
       W4:=W4 * 2;
      end;
    Kurzor[W]:=W2;
    Kurzor[W+16]:=W3;
   end;
  SetGrafKurzor(Fi.X,Fi.Y,Seg(Kurzor),Ofs(Kurzor));
 end;


Procedure TextEditKurzor;
begin
 Kurzor[00+00]:=65535-(0 +064  +128  +256  +512  +1024 );
 Kurzor[01+00]:=65535-(0 +064  +128  +256  +512  +1024 );
 Kurzor[02+00]:=65535-(0 +064  +128  +256  +512  +1024 );
 Kurzor[03+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[04+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[05+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[06+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[07+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[08+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[09+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[10+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[11+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[12+00]:=65535-(0{+064} +128  +256  +512 {+1024});
 Kurzor[13+00]:=65535-(0 +064  +128  +256  +512  +1024 );
 Kurzor[14+00]:=65535-(0 +064  +128  +256  +512  +1024 );
 Kurzor[15+00]:=65535-(0 +064  +128  +256  +512  +1024 );

 Kurzor[00+16]:=(0{+64}{+128}{+256}{+512}{+1024});
 Kurzor[01+16]:=(0{+64} +128  +256  +512 {+1024});
 Kurzor[02+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[03+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[04+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[05+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[06+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[07+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[08+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[09+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[10+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[11+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[12+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[13+16]:=(0{+64}{+128} +256 {+512}{+1024});
 Kurzor[14+16]:=(0{+64} +128  +256  +512 {+1024});
 Kurzor[15+16]:=(0{+64}{+128}{+256}{+512}{+1024});
 SetGrafKurzor(7,7,Seg(Kurzor),Ofs(Kurzor));
end;

{Function Umocni2(M:Byte):Word;
 var I:Integer;
     W:Word;
  begin
   W:=2;
   For I:= 1 to I do W:=W*M;
   If M=0 then Umocni2:=1 else Umocni2:=W;
  end;
}
Function GetWValue(S:TSTR16):Word;
 var
    I:Integer;
    W,W2:Word;
 begin
  W:=0;
  W2:=1;
  For I:= 16 downto 1 do
   begin
    If UpCase(S[I]) = 'X' then W:=W+W2;
    W2:=W2*2;
   end;
  GetWValue:=W;
 end;

Procedure SipkaKurzor;
begin
 Kurzor[00+16]:=(GetWValue('                '));
 Kurzor[01+16]:=(GetWValue(' X              '));
 Kurzor[02+16]:=(GetWValue(' XX             '));
 Kurzor[03+16]:=(GetWValue(' XXX            '));
 Kurzor[04+16]:=(GetWValue(' XXXX           '));
 Kurzor[05+16]:=(GetWValue(' XXXXX          '));
 Kurzor[06+16]:=(GetWValue(' XXXXXX         '));
 Kurzor[07+16]:=(GetWValue(' XXXXXXX        '));
 Kurzor[08+16]:=(GetWValue(' XXXXXXXX       '));
 Kurzor[09+16]:=(GetWValue(' XXXXXXXXX      '));
 Kurzor[10+16]:=(GetWValue(' XXXxx          '));
 Kurzor[11+16]:=(GetWValue(' XX  xx         '));
 Kurzor[12+16]:=(GetWValue(' X   xx         '));
 Kurzor[13+16]:=(GetWValue('      xx        '));
 Kurzor[14+16]:=(GetWValue('      xx        '));
 Kurzor[15+16]:=(GetWValue('                '));

 Kurzor[00+00]:=65535-(GetWValue('                '));
 Kurzor[01+00]:=65535-(GetWValue(' X              '));
 Kurzor[02+00]:=65535-(GetWValue(' XX             '));
 Kurzor[03+00]:=65535-(GetWValue(' XXX            '));
 Kurzor[04+00]:=65535-(GetWValue(' XXXX           '));
 Kurzor[05+00]:=65535-(GetWValue(' XXXXX          '));
 Kurzor[06+00]:=65535-(GetWValue(' XXXXXX         '));
 Kurzor[07+00]:=65535-(GetWValue(' XXXXXXX        '));
 Kurzor[08+00]:=65535-(GetWValue(' XXXXXXXX       '));
 Kurzor[09+00]:=65535-(GetWValue(' XXXXXXXXX      '));
 Kurzor[10+00]:=65535-(GetWValue(' XXXxx          '));
 Kurzor[11+00]:=65535-(GetWValue(' XX  xx         '));
 Kurzor[12+00]:=65535-(GetWValue(' X   xx         '));
 Kurzor[13+00]:=65535-(GetWValue('      xx        '));
 Kurzor[14+00]:=65535-(GetWValue('      xx        '));
 Kurzor[15+00]:=65535-(GetWValue('                '));

 SetGrafKurzor(0,0,Seg(Kurzor),Ofs(Kurzor));
end;

Procedure InverzSipkaKurzor;
begin
 Kurzor[00+16]:=(GetWValue('                '));
 Kurzor[01+16]:=(GetWValue('X               '));
 Kurzor[02+16]:=(GetWValue('XX              '));
 Kurzor[03+16]:=(GetWValue('XXX             '));
 Kurzor[04+16]:=(GetWValue('XXXX            '));
 Kurzor[05+16]:=(GetWValue('XXXXX           '));
 Kurzor[06+16]:=(GetWValue('XXXXXX          '));
 Kurzor[07+16]:=(GetWValue('XXXXXXX         '));
 Kurzor[08+16]:=(GetWValue('XXXXXXXX        '));
 Kurzor[09+16]:=(GetWValue('XXXXXXXXX       '));
 Kurzor[10+16]:=(GetWValue('XXXxx           '));
 Kurzor[11+16]:=(GetWValue('XX  xx          '));
 Kurzor[12+16]:=(GetWValue('X   xx          '));
 Kurzor[13+16]:=(GetWValue('     xx         '));
 Kurzor[14+16]:=(GetWValue('     xx         '));
 Kurzor[15+16]:=(GetWValue('                '));

 Kurzor[00+00]:=65535-(GetWValue('                '));
 Kurzor[01+00]:=65535-(GetWValue('                '));
 Kurzor[02+00]:=65535-(GetWValue('                '));
 Kurzor[03+00]:=65535-(GetWValue('                '));
 Kurzor[04+00]:=65535-(GetWValue('                '));
 Kurzor[05+00]:=65535-(GetWValue('                '));
 Kurzor[06+00]:=65535-(GetWValue('                '));
 Kurzor[07+00]:=65535-(GetWValue('                '));
 Kurzor[08+00]:=65535-(GetWValue('                '));
 Kurzor[09+00]:=65535-(GetWValue('                '));
 Kurzor[10+00]:=65535-(GetWValue('                '));
 Kurzor[11+00]:=65535-(GetWValue('                '));
 Kurzor[12+00]:=65535-(GetWValue('                '));
 Kurzor[13+00]:=65535-(GetWValue('                '));
 Kurzor[14+00]:=65535-(GetWValue('                '));
 Kurzor[15+00]:=65535-(GetWValue('                '));

 SetGrafKurzor(0,0,Seg(Kurzor),Ofs(Kurzor));
end;

Procedure WaitKurzor;
begin
 Kurzor[00+16]:=(GetWValue('                '));
 Kurzor[01+16]:=(GetWValue('  XXXXXXXXXXXX  '));
 Kurzor[02+16]:=(GetWValue('   XXXXXXXXXX   '));
 Kurzor[03+16]:=(GetWValue('   X        X   '));
 Kurzor[04+16]:=(GetWValue('    X      X    '));
 Kurzor[05+16]:=(GetWValue('     XxxxxX     '));
 Kurzor[06+16]:=(GetWValue('      XXXX      '));
 Kurzor[07+16]:=(GetWValue('       xx       '));
 Kurzor[08+16]:=(GetWValue('       xx       '));
 Kurzor[09+16]:=(GetWValue('      X  X      '));
 Kurzor[10+16]:=(GetWValue('     X    X     '));
 Kurzor[11+16]:=(GetWValue('    X      X    '));
 Kurzor[12+16]:=(GetWValue('   XxxxxxxxxX   '));
 Kurzor[13+16]:=(GetWValue('   XXXXXXXXXX   '));
 Kurzor[14+16]:=(GetWValue('  XXXXXXXXXXXX  '));
 Kurzor[15+16]:=(GetWValue('                '));

 Kurzor[00+00]:=65535-(GetWValue(' XXXXXXXXXXXXXX '));
 Kurzor[01+00]:=65535-(GetWValue(' XXXXXXXXXXXXXX '));
 Kurzor[02+00]:=65535-(GetWValue(' XXXXXXXXXXXXXX '));
 Kurzor[03+00]:=65535-(GetWValue('  XXXXXXXXXXXX  '));
 Kurzor[04+00]:=65535-(GetWValue('   XXXXXXXXXX   '));
 Kurzor[05+00]:=65535-(GetWValue('    XXXXXXXX    '));
 Kurzor[06+00]:=65535-(GetWValue('     XXXXXX     '));
 Kurzor[07+00]:=65535-(GetWValue('      XXXX      '));
 Kurzor[08+00]:=65535-(GetWValue('      XXXX      '));
 Kurzor[09+00]:=65535-(GetWValue('     XXXXXX     '));
 Kurzor[10+00]:=65535-(GetWValue('    XXXXXXXX    '));
 Kurzor[11+00]:=65535-(GetWValue('   XXXXXXXXXX   '));
 Kurzor[12+00]:=65535-(GetWValue('  XXXXXXXXXXXX  '));
 Kurzor[13+00]:=65535-(GetWValue(' XXXXXXXXXXXXXX '));
 Kurzor[14+00]:=65535-(GetWValue(' XXXXXXXXXXXXXX '));
 Kurzor[15+00]:=65535-(GetWValue(' XXXXXXXXXXXXXX '));

 SetGrafKurzor(7,7,Seg(Kurzor),Ofs(Kurzor));
end;

Procedure DrawKurzor;
begin
 Kurzor[00+16]:=(GetWValue('       X        '));
 Kurzor[01+16]:=(GetWValue('       X        '));
 Kurzor[02+16]:=(GetWValue('       X        '));
 Kurzor[03+16]:=(GetWValue('       X        '));
 Kurzor[04+16]:=(GetWValue('       X        '));
 Kurzor[05+16]:=(GetWValue('       X        '));
 Kurzor[06+16]:=(GetWValue('       X        '));
 Kurzor[07+16]:=(GetWValue('XXXXXXXXXXXXXXX '));
 Kurzor[08+16]:=(GetWValue('       X        '));
 Kurzor[09+16]:=(GetWValue('       X        '));
 Kurzor[10+16]:=(GetWValue('       X        '));
 Kurzor[11+16]:=(GetWValue('       X        '));
 Kurzor[12+16]:=(GetWValue('       X        '));
 Kurzor[13+16]:=(GetWValue('       X        '));
 Kurzor[14+16]:=(GetWValue('       X        '));
 Kurzor[15+16]:=(GetWValue('                '));

 Kurzor[00+00]:=65535-(GetWValue('                '));
 Kurzor[01+00]:=65535-(GetWValue('                '));
 Kurzor[02+00]:=65535-(GetWValue('                '));
 Kurzor[03+00]:=65535-(GetWValue('                '));
 Kurzor[04+00]:=65535-(GetWValue('                '));
 Kurzor[05+00]:=65535-(GetWValue('                '));
 Kurzor[06+00]:=65535-(GetWValue('                '));
 Kurzor[07+00]:=65535-(GetWValue('                '));
 Kurzor[08+00]:=65535-(GetWValue('                '));
 Kurzor[09+00]:=65535-(GetWValue('                '));
 Kurzor[10+00]:=65535-(GetWValue('                '));
 Kurzor[11+00]:=65535-(GetWValue('                '));
 Kurzor[12+00]:=65535-(GetWValue('                '));
 Kurzor[13+00]:=65535-(GetWValue('                '));
 Kurzor[14+00]:=65535-(GetWValue('                '));
 Kurzor[15+00]:=65535-(GetWValue('                '));

 SetGrafKurzor(7,7,Seg(Kurzor),Ofs(Kurzor));
end;

Procedure DrawBoldKurzor;
begin

 Kurzor[00+16]:=(GetWValue('                '));
 Kurzor[01+16]:=(GetWValue('       X        '));
 Kurzor[02+16]:=(GetWValue('       X        '));
 Kurzor[03+16]:=(GetWValue('       X        '));
 Kurzor[04+16]:=(GetWValue('       X        '));
 Kurzor[05+16]:=(GetWValue('       X        '));
 Kurzor[06+16]:=(GetWValue('       X        '));
 Kurzor[07+16]:=(GetWValue(' XXXXXXxXXXXXX  '));
 Kurzor[08+16]:=(GetWValue('       X        '));
 Kurzor[09+16]:=(GetWValue('       X        '));
 Kurzor[10+16]:=(GetWValue('       X        '));
 Kurzor[11+16]:=(GetWValue('       X        '));
 Kurzor[12+16]:=(GetWValue('       X        '));
 Kurzor[13+16]:=(GetWValue('       X        '));
 Kurzor[14+16]:=(GetWValue('                '));
 Kurzor[15+16]:=(GetWValue('                '));

 Kurzor[00+00]:=65535-(GetWValue('      xxx       '));
 Kurzor[01+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[02+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[03+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[04+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[05+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[06+00]:=65535-(GetWValue('xxxxxxxXxxxxxxx '));
 Kurzor[07+00]:=65535-(GetWValue('xXXXXXXXXXXXXXx '));
 Kurzor[08+00]:=65535-(GetWValue('xxxxxxxXxxxxxxx '));
 Kurzor[09+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[10+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[11+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[12+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[13+00]:=65535-(GetWValue('      xXx       '));
 Kurzor[14+00]:=65535-(GetWValue('      xxx       '));
 Kurzor[15+00]:=65535-(GetWValue('                '));

 SetGrafKurzor(7,7,Seg(Kurzor),Ofs(Kurzor));
end;


Function Stisknuto:Word;
 var B:Word;
 begin
  asm
   mov ax,$3
   int $33
   mov B,Bx
  end;
   Stisknuto:=B;
 end;

Function StiskTlac(Tlac:Word):Boolean;
 var B:Word;
 begin
  asm
   mov ax,$3
   int $33
   mov B,Bx
  end;
  StiskTlac:=((B and Tlac)=Tlac);
 end;

Function XMysi:Word;
 var B:Word;
 begin
  asm
   mov ax,$3
   int $33
   mov B,Cx
  end;
   XMysi:=B;
 end;

Function YMysi:Word;
 var B:Word;
 begin
  asm
   mov ax,$3
   int $33
   mov B,Dx
  end;
   YMysi:=B;
 end;

 Procedure UdalostMysi(Segm,Ofst,Udal:Word);
  begin
   asm
    mov ax,$000c
    mov cx,Udal
    mov es,Segm
    mov dx,Ofst
    int $33
   end;
  end;

end.











