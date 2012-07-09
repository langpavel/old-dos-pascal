Program Zaklad_pro_sluzby_XMS;
uses CRT;
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

Procedure GetHIMEMAddr;
{$I -GetAddr.xms}

Procedure Alokuj;
{$I -Alokuj.xms}

Procedure Uvolni;
{$I -Uvolni.xms}

Procedure Presun;
{$I -Presun.xms}

Procedure GetXMSSize;
{$I -XMSSize.xms}

begin
GetHIMEMAddr;
GetXMSSize;
WriteLn('Velikost nejvetsiho bloku XMS v systemu: ',SizeKB,' Kb');

{SizeKB:=6700;
Alokuj;
If not IsItOK then begin Sound(1000); Delay(1000); NoSound; Halt; end;
Uvolni;}
end.