{Unit pro praci s grafikou v 256 barvach}
(****************************************
Graficke mody:
 cislo     rozliseni    pocet   vyznam.   bytu na   umi zobrazit
                        barev    bitu      pixel    bez prepoctu
 ---------------------------------------------------------------
*0100h      640x400      256      8b         1B        TRUE
*0101h      640x480      256      8b         1B        TRUE
 0102h      800x600       16      4b       1/2B        FALSE
*0103h      800x600      256      8b         1B        TRUE
 0104h     1024x768       16      4b       1/2B        FALSE
*0105h     1024x768      256      8b         1B        TRUE
 0106h     1280x1024      16      4b       1/2B        FALSE
*0107h     1280x1024     256      8b         1B        TRUE
 010Dh      320x200      32K     15b         2B        FALSE
 010Eh      320x200      64K     16b         2B        FALSE
 010Fh      320x200      16M     20b         4B        FALSE
 0110h      640x480      32K     15b         2B        FALSE
 0111h      640x480      64K     16b         2B        FALSE
 0112h      640x480      16M     20b         4B        FALSE
 0113h      800x600      32K     15b         2B        FALSE
 0114h      800x600      64K     16b         2B        FALSE
 0115h      800x600      16M     20b         4B        FALSE
 0116h     1024x768      32K     15b         2B        FALSE
 0117h     1024x768      64K     16b         2B        FALSE
 0118h     1024x768      16M     20b         4B        FALSE

*****************************************)

Unit VesaUni;
interface

type PVesaInfo = ^TVesaInfo;
     TVesaInfo = record
                  VESA     :Array[0..3] of Char;
                  Ver      :Word;
                  OEMPtr   :Pointer;
                  Um       :Array[0..3] of byte;
                  ModeList :Pointer;
                  Vyhrazeno:Array[0..237] of byte;
                 end;

type PModeInfo = ^TModeInfo;
     TModeInfo = record
                  Attributes         :word;
                  A_attributes       :byte;
                  b_attributes       :byte;
                  granularity        :word;
                  size               :word;
                  a_start_seg        :word;
                  b_start_seg        :word;
                  ChangeWindowProc   :pointer;
                  Bytes_per_scanline :word;
                  x_resolution       :word;
                  y_resolution       :word;
                  x_char             :byte;
                  y_char             :byte;
                  planes             :byte;
                  bits_per_pixel     :byte;
                  banks              :byte;
                  model_type         :byte;
                  bank_size          :byte;
                  image_pages        :byte;
                  reserved           :byte;
                  vyhrazeno          :array[1..224] of byte;
                 end;


Function VESAInfo(VesaInfoArray:PVesaInfo):Boolean;
Function InitGrModeErr(grMode:Word):Boolean;
Procedure Put(X,Y:Word;C:byte);
Function Get(X,Y:Word):byte;
Procedure Fill(Color:Word);
Procedure CloseGr;

implementation

var
    ActualWindow   :Word;
    ModeInfo       :TModeInfo;
    Segs           :Word;

Function VESAInfo(VesaInfoArray:PVesaInfo):Boolean; assembler;
 asm
  mov ax,4F00h
  mov di,word ptr [VesaInfoArray]
  mov es,word ptr [VesaInfoArray+2]
  int 010h
  sub al,04Eh
 end;

Function InitGrModeErr(grMode:Word):Boolean; assembler;
 asm
  mov di,offset ModeInfo
  mov ax,seg ModeInfo
  mov es,ax
  mov ax,4F01h
  mov cx,grMode
  int 010h

  mov ax,04F02h
  mov bx,grMode
  int 010h
  mov al,ah
 end;

Procedure Put(X,Y:Word;C:byte); assembler;
 asm

  cli
  mov ax,Y
  mov bx,ModeInfo.X_resolution
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

{zmena 4.12.99 Jan Ondrus  -->}

  mov cx,dx

  xor dx,dx
  mov ax,modeinfo.size
  div modeinfo.granularity


  mul cx
  mov dx,ax
{<--  zmena 4.12.99 Jan Ondrus}


  mov bx,0
  call ModeInfo.ChangeWindowProc

@@zapis:
  mov bx,ModeInfo.a_start_seg
  mov es,bx
  pop ax
  mov bx,ax
  mov cl,C
  mov es:[bx],cl
  sti
 end;

Function Get(X,Y:Word):Byte; assembler;
 asm
  cli
  mov ax,Y
  mov bx,ModeInfo.X_resolution
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
  jcxz @@cteni
  mov ActualWindow,dx
  mov bx,0
  call ModeInfo.ChangeWindowProc

@@cteni:
  mov bx,ModeInfo.a_start_seg
  mov es,bx
  pop ax
  mov bx,ax
  mov al,es:[bx]
  sti
 end;


Procedure Fill(Color:Word); assembler;
 asm
  mov ax,Color
  mov cx,segs
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

BEGIN
segs:=8;
END.
