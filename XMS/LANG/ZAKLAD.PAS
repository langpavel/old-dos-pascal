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

Procedure GetHIMEMAddr; {$I -GetAddr.xms}
Procedure Alokuj;       {$I -Alokuj.xms}
Procedure Uvolni;       {$I -Uvolni.xms}
Procedure Presun;       {$I -Presun.xms}
Procedure GetXMSSize;   {$I -XMSSize.xms}

begin
 GetHIMEMAddr;


end.