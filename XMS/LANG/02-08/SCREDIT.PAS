Program ScreenEditor;
uses G320x200,CRT,MysAsm;
var
    ch    :Char;
    X,Y   :Word;
    C,B   :Byte;
    br    :TBarva;
    F     :File of TBarvy;
    X1,Y1,
    X2,Y2 :Word;

function FileExists(FileName: String): Boolean;
var F: file;
begin
 {$I-}
 Assign(F, FileName);
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;

begin
 InitGr;
 FillAll(0);
 C:=15;
 B:=0;
 If FileExists(ParamStr(1)) then LoadScreenFromFile(ParamStr(1));
 If FileExists(ParamStr(2)) then If ParamCount = 3 then LoadBGR256PaletteFromFile(ParamStr(2))
                                                   else LoadPaletteFromFile(ParamStr(2));
{ InverzSipkaKurzor;}
 MouseWindow(0,0,637,199);
 MouseOn;
 Repeat
  Repeat
   X:=XMysi div 2+1;
   Y:=YMysi;
    Case Stisknuto of
     1:begin
        MouseOff;
        Put(X,Y,C);
        MouseOn;
       end;
     2:begin
        MouseOff;
        Put(X,Y,B);
        MouseOn;
       end;
    end;

  Until KeyPressed;
  Ch:=UpCase(ReadKey);
   Case Ch of
    #27:Halt;
    'S':begin MouseOff; SaveScreenToFile(ParamStr(1)); If ParamCount > 1 then SavePalToFile(ParamStr(2)); MouseOn; end;
    'C':begin MouseOff; SelectColor(C); MouseOn; end;
    'V':begin MouseOff; SelectColor(B); MouseOn; end;
    'G':begin MouseOff; C:=Get(X,Y); MouseOn; end;
    'F':begin MouseOff; FillAll(C); MouseOn; end;
    'R':begin
         Repeat
          If Stisknuto = 1 then begin X1:=XMysi div 2+1; Y1:=YMysi; end;
          If Stisknuto = 2 then begin X2:=XMysi div 2+1; Y2:=YMysi; end;
         Until KeyPressed;
         MouseOff;
         Rectangle(X1,Y1,X2,Y2,C,True);
         MouseOn;
        end;
   end;
 Until False;
end.








