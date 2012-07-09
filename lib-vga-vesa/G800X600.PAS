{Unit pro praci s grafikou 800x600 v 256 barvach}
Unit Vesa;
interface

type TVesaInfo = record
                  VESA     :Array[0..3] of Char;
                  Ver      :Word;
                  OEMPtr   :Pointer;
                  Um       :Array[0..3] of byte;
                  ModeList :Pointer;
                  Vyhrazeno:Array[0..237] of byte;
                 end;
type PVesaInfo = ^TVesaInfo;

Function VESAInfo(VesaInfoArray:PVesaInfo):Boolean;
Function InitGrModeErr:Boolean;
Procedure Put(X,Y:Word;C:byte);
Procedure Fill(Color:Word);
Procedure CloseGr;

implementation

var
    ActualWindow   :Word;

Function VESAInfo(VesaInfoArray:PVesaInfo):Boolean; assembler;
 asm
  mov ax,4F00h
  mov di,word ptr [VesaInfoArray]
  mov es,word ptr [VesaInfoArray+2]
  int 010h
  sub al,04Eh
 end;

Function InitGrModeErr:Boolean; assembler;
 asm
  mov ax,04F02h
  mov bx,00103h
  int 010h
  mov al,ah
 end;

Procedure Put(X,Y:Word;C:byte); assembler;
 asm
  cli
  mov ax,Y
  mov bx,800
  mul bx       {dx:ax <=Y*800  (dx:ax <- ax*bx)}
  mov bx,ax
  add ax,X
  push ax

  cmp ax,bx
  jnc @@OK
  inc dx
@@Ok:
  mov cx,dx
  sub cx,ActualWindow
  jcxz @@zapis
  mov ActualWindow,dx
  mov bx,0
  mov ax,04f05h
  int 010h

@@zapis:
  mov bx,0A000h
  mov es,bx
  pop ax
  mov bx,ax
  mov cl,C
  mov es:[bx],cl
  sti
 end;

Procedure Fill(Color:Word); assembler;
 asm
  mov ax,Color
  mov cx,8
@@xxx:
  push cx
  push ax
  mov dx,cx
  dec dx
  mov ActualWindow,dx
  mov bx,0
  mov ax,04f05h
  int 010h

  mov ax,0A000h
  mov es,ax
  mov di,0
  pop ax
  mov cx,32768
  rep stosw
  pop cx
  loop @@xxx
 end;

Procedure CloseGr; assembler;
 asm
  mov ax,3
  int 010h
 end;

END.
