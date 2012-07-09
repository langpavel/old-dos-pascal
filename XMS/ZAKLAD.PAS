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
{$I GetAddr}

Procedure Alokuj;
{$I Alokuj}

Procedure Uvolni;
{$I Uvolni}

Procedure Presun;
{$I Presun}

Procedure GetXMSSize;
{$I XMSSize}

begin
GetHIMEMAddr;


end.