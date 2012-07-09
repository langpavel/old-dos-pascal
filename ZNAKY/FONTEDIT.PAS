Program EditorTextZnaku;
uses DOS,Graph,CRT,MysAsm;
type
    TZnak  = Array[0..15] of Byte;
    TZnaky = Array[0..255] of TZnak;

var
   Z      :TZnaky;
   Sav    :TZnak;
   F      :File of TZnaky;
   GD,GM  :Integer;
   Aktual :Byte;
   X,Y    :Word;
   Klav   :Char;
   Zoom   :Byte;

Function Mocnina(I,M:Integer):LongInt;
 var X,P:Integer;
 begin
  P:=1;
  For X:=2 to M do
   P:=P*I;
  Mocnina:=P;
 end;

Procedure Vykresli(PX,PY:Word;Act:Word);
 var
    X,Y   :Byte;
 begin
  MouseOff;
  For Y:= 0 To 15 Do
   For X:= 0 to 7 do
    If Act < 256 then
    If (Z[Act,Y] div Mocnina(2,8-X)) mod 2 = 1
    then
     begin
      SetFillStyle(1,15);
      Bar(X*Zoom+PX,Y*Zoom+PY,X*Zoom+Zoom-1+PX,Y*Zoom+Zoom-1+PY);
      PutPixel(X+Zoom*8+2,Y+1,15);
     end
    else
     begin
      SetFillStyle(1,7);
      Bar(X*Zoom+PX,Y*Zoom+PY,X*Zoom+Zoom-1+PX,Y*Zoom+Zoom-1+PY);
      PutPixel(X+Zoom*8+2,Y+1,7);
     end
    else
    If (Sav[Y] div Mocnina(2,8-X)) mod 2 = 1 then
     begin
      SetFillStyle(1,15);
      Bar(X*Zoom+PX,Y*Zoom+PY,X*Zoom+Zoom-1+PX,Y*Zoom+Zoom-1+PY);
      PutPixel(X+Zoom*8+2,Y+1,15);
     end
    else
     begin
      SetFillStyle(1,7);
      Bar(X*Zoom+PX,Y*Zoom+PY,X*Zoom+Zoom-1+PX,Y*Zoom+Zoom-1+PY);
      PutPixel(X+Zoom*8+2,Y+1,7);
     end;
  MouseOn;
 end;

begin
 Zoom:=30;
 InitGraph(Gd,Gm,'D:\bat');
 If ParamCount = 0 then Halt;
 Assign(F,ParamStr(1));
 Reset(f);
 Read(f,Z);
 Close(f);
 ClearDevice;
 DirectVideo:=False;
 TextColor(15);
 MouseOn;
 Inc(Aktual);
 Vykresli(1,1,Aktual);
  Repeat
   If KeyPressed then
    begin
     Klav:=ReadKey;
     Case Klav of
      '.','>','+' : begin
                     Inc(Aktual);
                     Vykresli(1,1,Aktual);
                    end;
      ',','<','-' : begin
                     Dec(Aktual);
                     Vykresli(1,1,Aktual);
                    end;
      'p'         : begin
                     For GD := 0 to 7 do
                      begin
                       Y:=Z[Aktual,GD];
                       Z[Aktual,GD]:=Z[Aktual,15-GD];
                       Z[Aktual,15-GD]:=Y;
                      end;
                     Vykresli(1,1,Aktual);
                    end;
(*    'P'         : begin
                     For GD := 0 to 13 do
                     For GM := 0 to 3 do
                      begin
                       Y:=(Z[Aktual,GD] div Mocnina(2,GM) mod 2);
{                       Z[Aktual,GD]:=Z[Aktual,GD] or ;}
                       Z[Aktual,13-GD]:=Y;
                      end;
                     Vykresli(1,1,Aktual);
                    end;  *)
      'i','I'     : begin
                     For GD := 0 to 13 do
                      begin
                       Z[Aktual,GD]:=255-Z[Aktual,GD];
                      end;
                     Vykresli(1,1,Aktual);
                    end;
      'c'         : begin
                     Sav:=Z[Aktual];
                     Zoom:=5;
                     Vykresli(300,1,256);
                     Zoom:=30;
                    end;
      'C'         : begin
                     Z[Aktual]:=Sav;
                     Vykresli(1,1,Aktual);
                    end;
     end;
    end;
   If Stisknuto = 1 then
    begin
     If (XMysi < Zoom * 8) and (YMysi < Zoom * 16) then
     If (Z[Aktual,YMysi div Zoom])  <>  (Z[Aktual,YMysi div Zoom] or Mocnina(2,8-(XMysi div Zoom))) then
      begin
       Z[Aktual,YMysi div Zoom]:=Z[Aktual,YMysi div Zoom] or Mocnina(2,8-(XMysi div Zoom));
       Vykresli(1,1,Aktual);
      end;
    end;

   If Stisknuto = 2 then
    begin
     If (XMysi < Zoom * 8) and (YMysi < Zoom * 16) then
     IF (Z[Aktual,YMysi div Zoom])  <>  (Z[Aktual,YMysi div Zoom] and (255-Mocnina(2,8-(XMysi div Zoom)))) then
      begin
       Z[Aktual,YMysi div Zoom]:=Z[Aktual,YMysi div Zoom] and (255-Mocnina(2,8-(XMysi div Zoom)));
       Vykresli(1,1,Aktual);
      end;
    end;
  until Klav = #27;
 CloseGraph;
 Assign(F,ParamStr(1));
 ReWrite(f);
 Write(f,Z);
 Close(f);
end.



