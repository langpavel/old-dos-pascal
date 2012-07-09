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

Procedure GetHIMEMAddr; {$I xGetAddr.inc}
Procedure Alokuj;       {$I xAlokuj.inc}
Procedure Uvolni;       {$I xUvolni.inc}
Procedure Presun;       {$I xPresun.inc}
Procedure GetXMSSize;   {$I xXMSSize.inc}

