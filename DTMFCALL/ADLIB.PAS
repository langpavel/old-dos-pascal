{Max chanel = (0..8)}
Unit ADLIB;
interface
uses FM;
var
   Volume:Integer;
   Chanel:Integer;
   Okt   :2..256;
   Patch :TPatch;

Function IsAdlib:Boolean;
Procedure Sound(freq:word);
Procedure SoundChanel(Chanel:word;freq:word);
Procedure Piano;
Procedure Sine;
Procedure SineChanel(ch:word);
Procedure NoSound;
Procedure StopChanel(Ch:Word);
Procedure Music(S:String);
Procedure SetVolume(S:Integer);
Procedure SetPatch(ch:Integer;chars,ksl_lev,att_dec,sus_rel,wav_sel:Word;fb_conn:Byte);

Procedure WritePatch(P:PPatch);

implementation
 var
   I,DNot      :Integer;
   Ton         :Array[0..12] of Real;
   Freq, f2    :Real;

Procedure WritePatch(P:PPatch);
 Function DecToHex(X:Byte):String;
  var S:String;
  begin
   If X div 16 < 10 then S[1]:=Char(X div 16 + 48) else S[1]:=Char(X div 16 + 55);
   If X mod 16 < 10 then S[2]:=Char(X mod 16 + 48) else S[2]:=Char(X mod 16 + 55);
   S[0]:=Char(2);
   DecToHex:=S;
  end;
 begin
  WriteLn(' Chars:   ',DecToHex(P^.Chars[0]),DecToHex(P^.Chars[1]));
  WriteLn(' ksl_lev: ',DecToHex(P^.ksl_lev[0]),DecToHex(P^.ksl_lev[1]));
  WriteLn(' att_dec: ',DecToHex(P^.att_dec[0]),DecToHex(P^.att_dec[1]));
  WriteLn(' sus_rel: ',DecToHex(P^.sus_rel[0]),DecToHex(P^.sus_rel[1]));
  WriteLn(' wav_sel: ',DecToHex(P^.wav_sel[0]),DecToHex(P^.wav_sel[1]));
  WriteLn(' fb_conn: ',DecToHex(P^.fb_conn));
 end;

Procedure SetPatch(ch:Integer;chars,ksl_lev,att_dec,sus_rel,wav_sel:Word;fb_conn:Byte);
 begin
  Word(Patch.chars):=Chars;
  Word(Patch.ksl_lev):=ksl_lev;
  Word(Patch.att_dec):=att_dec;
  Word(Patch.sus_rel):=sus_rel;
  Word(Patch.wav_sel):=wav_sel;
  Patch.fb_conn:=fb_conn;
  fm_load_patch(ch, Addr(Patch));
 end;

Function IsAdlib:Boolean;
 begin
  IsAdlib:=fm_detect;
 end;

Procedure SetVolume(S:Integer);
 begin
  Volume:=S;
 end;

Procedure InitMusic(RelFreq:Real);
 begin
  Okt:=8;
  Ton[0]:=261.6256  ; {C }
  Ton[1]:=277.1826  ; {C#}
  Ton[2]:=293.6648  ; {D }
  Ton[3]:=311.1270  ; {D#}
  Ton[4]:=329.6276  ; {E }
  Ton[5]:=349.2282  ; {F }
  Ton[6]:=369.9944  ; {F#}
  Ton[7]:=391.9954  ; {G }
  Ton[8]:=415.3047  ; {G#}
  Ton[9]:=440       ; {A }
  Ton[10]:=466.1638 ; {A#}
  Ton[11]:=493.8834 ; {H }
  Ton[12]:=RelFreq/8;
 end;

Procedure Piano;
 begin
  fm_load_patch(chanel, fm_get_patch_piano);
 end;

Procedure Sine;
 begin
  fm_load_patch(chanel, fm_get_patch_Sine);
 end;

Procedure SineChanel(ch:word);
 begin
  fm_load_patch(ch, fm_get_patch_Sine);
 end;

Procedure Sound(freq:word);
 begin
  fm_play_tone(chanel,freq,volume);
 end;

Procedure SoundChanel(Chanel:word;freq:word);
 begin
  fm_play_tone(chanel,freq,volume);
 end;

Procedure NoSound;
var I:Byte;
 begin
  For I:=0 to 15 do
  fm_stop_tone(I);
 end;

Procedure StopChanel(Ch:Word);
 begin
  fm_stop_tone(ch);
 end;

Procedure Music(S:String);
 begin
     NoSound;
     If (S='C')  or (S='c')   or (S='1')   then Sound(Trunc(Ton[0]*Okt*Ton[12]));
     If (S='C#') or (S='c#')  or (S='1.5') then Sound(Trunc(Ton[1]*Okt*Ton[12]));
     If (S='D')  or (S='d')   or (S='2')   then Sound(Trunc(Ton[2]*Okt*Ton[12]));
     If (S='D#') or (S='d#')  or (S='2.5') then Sound(Trunc(Ton[3]*Okt*Ton[12]));
     If (S='E')  or (S='e')   or (S='3')   then Sound(Trunc(Ton[4]*Okt*Ton[12]));
     If (S='F')  or (S='f')   or (S='4')   then Sound(Trunc(Ton[5]*Okt*Ton[12]));
     If (S='F#') or (S='f#')  or (S='4.5') then Sound(Trunc(Ton[6]*Okt*Ton[12]));
     If (S='G')  or (S='g')   or (S='5')   then Sound(Trunc(Ton[7]*Okt*Ton[12]));
     If (S='G#') or (S='g#')  or (S='5.5') then Sound(Trunc(Ton[8]*Okt*Ton[12]));
     If (S='A')  or (S='a')   or (S='6')   then Sound(Trunc(Ton[9]*Okt*Ton[12]));
     If (S='A#') or (S='a#')  or (S='6.5') then Sound(Trunc(Ton[10]*Okt*Ton[12]));
     If (S='H')  or (S='h')   or (S='7')   then Sound(Trunc(Ton[11]*Okt*Ton[12]));
     If (S='-')  or (S='N')   or (S='n')   then NoSound;

     If (S='O1') or (S='o1') then Okt:=2;
     If (S='O2') or (S='o2') then Okt:=4;
     If (S='O3') or (S='o3') then Okt:=8;
     If (S='O4') or (S='o4') then Okt:=16;
     If (S='O5') or (S='o5') then Okt:=32;
     If (S='O6') or (S='o6') then Okt:=64;
     If (S='O7') or (S='o7') then Okt:=128;
     If (S='O8') or (S='o8') then Okt:=256;

     If (S='+1') or (S='O+1') or (S='+') then If Okt < 256 then Okt:=Okt*2;
     If (S='-1') or (S='O-1') or (S='-') then If Okt > 2   then Okt:=Round(Okt/2);
 end;

begin
Chanel:=0;
Volume:=32;
fm_reset;
InitMusic(1);
end.
