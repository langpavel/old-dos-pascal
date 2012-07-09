{ fm.pas }
{ FMSOUND Copyright 1997 by Ethan Brodsky.  All rights reserved. }

{ Functions documented in FM.H }

unit FM;
 {$L FM.OBJ}
  interface
    type
      PPatch = ^TPatch;
      TPatch =
        record
          chars:   array[0..1] of byte;
          ksl_lev: array[0..1] of byte;
          att_dec: array[0..1] of byte;
          sus_rel: array[0..1] of byte;
          wav_sel: array[0..1] of byte;
          fb_conn: byte;
        end;

    function  fm_get_patch_sine: PPatch;
    function  fm_get_patch_piano: PPatch;

    function  fm_detect: boolean;

    procedure fm_reset;

    procedure fm_load_patch(ch: integer; patch: PPatch);

    function  fm_play_tone(ch: integer; freq: integer; vol: integer): boolean;
    procedure fm_stop_tone(ch: integer);

  implementation
    function  fm_get_patch_sine: PPatch; external;
    function  fm_get_patch_piano: PPatch; external;

    function  fm_detect: boolean; external;

    procedure fm_reset; external;

    procedure fm_load_patch(ch: integer; patch: PPatch); external;

    function  fm_play_tone(ch: integer; freq: integer; vol: integer): boolean; external;
    procedure fm_stop_tone(ch: integer); external;

  end.