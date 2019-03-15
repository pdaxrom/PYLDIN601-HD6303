(*****************************************************************************)
(*                                                                           *)
(*                         UniED instalation program                         *)
(*                                Version 1.10 (ама HEX)                     *)
(*                                                                           *)
(*                      (c) 1989 Dimitar Georgiev /MAG/                      *)
(*                                                                           *)
(*      Language:               UniPascal / Turbo Pascal                     *)
(*      Operating System:       UniDOS    / MS-DOS                           *)
(*                                                                           *)
(*****************************************************************************)

(*) {$I-,R-}                                     { UniPascal compiler options }
{*) {$A-,B-,D+,E+,F-,I+,L+,N-,O-,R-,S+,V+}    { Turbo Pascal compiler options }

program UeCfg(Message, Output);
  (*)  type word = cardinal;
            byte = shortcard;
  {*)  uses UniPascal, unilex; {*}

  const
        Version = 1;
        SubVersion = $11;

        WrkLen = 6;
        UsrLen = 20;
        BufLen = 30000;
        MaxByDef = 20;
        MaxUsrList = 40;

  type Buff        = packed array[0..BufLen] of char;
       WrkString   = String[WrkLen];
       UsrString   = String[UsrLen];
       LongStr     = String;
       InFileType  = text;
       OutFileType = file;
       ByteDef     = packed array[1..MaxByDef] of byte;
       UsrItem     = record
                     Name: UsrString;
                     Len:  Integer;
                     Def:  ByteDef;
                     end;

  var
      ifs: integer;
      ifl: file;
      Bool: array[boolean] of string[3];
      MaxI: longint;
type
  {$I inittype.inc}
  {$I edcmds.inc}
  {$I tokens.inc}
  {$I keyb.inc}

  const ComentToken = ';';
        ODelimLen   = 4;
  var
     CtrlTok: char;
     Delimiters:  set of char ;
     Separators:  set of char ;
     OdelimTbl: array[1..ODelimLen] of char;
     Equal : WrkString;
     Shift : WrkString;
     Contr : WrkString;
     Space : WrkString;
     Lpar  : WrkString;
     Rpar  : WrkString;
     LBpar : WrkString;

  var Conf:     AsmInitType;
      Line:     longstr;
      ErrMsg:   longstr;
      PgmName,
      InFname,
      OutFname: LongStr;
      inf:      infiletype;
      outf:     outfiletype;
      CmdList:  ^buff;
      EndList:  word;
      UsrEndList: integer;
      UsrList: array[0..MaxUsrList] of UsrItem;


{$I constinit.inc}

(*) procedure breakpoint(n: natural); code $5f, $0f; (*)

  procedure NoMem;
  begin
  Writeln('Not Enought memory to load file(s)');
  halt;
  end;

(*  procedure writes( const s: string);
  var
    i: integer;
   begin
   for i:= 1 to length(s) do
     begin
     write('#',ord(s[i]));
     end;
   end; { writes }
 *)

  function OtherDelimiter((*)const(*) ch:char): char;
    var i: integer;
  begin
    i:=1;
    while i < ODelimLen do begin
      if ch = ODelimTbl[i] then begin
        (*) return(ODelimTbl[succ(i)]);
        {*) OtherDelimiter:= ODelimTbl[succ(i)]; exit; {*}
      end { if };
      inc(i); inc(i);
    end { while };
    (*) return(ch);
    {*) OtherDelimiter:= ch; {*}
  end { OtherDelimiter};

  procedure packstr( var stmp: longstr);
  var i: integer;
  begin
  i:=1;
  while i <= length(stmp) do
    if stmp[i] = Space[1]
      then delete(stmp, i, 1)
      else inc(i);
  end; {pack str}

  (*)
  function GetInteger(const Buffer; offset: cardinal; limit: integer; var endpos: standard.word): longint;
     code $5f, $14, $30;
  (*)

  procedure CleanStr( var s: LongStr);
    var i,j:   word;
        up:    boolean;
        keyup: char;
  begin
  i:= 1; j:= length(s)+1;
  if j> 1
    then begin
         while (s[i]= Space[1]) and (i<j) do inc(i);
         while (s[j-1]= Space[1]) and (i<j) do dec(j);
         end;
  if j= i then
    s:= ''
  else begin (*){$w-}(*)
    move(s[i],s[1],j-i); s[0]:= chr(j-i); {s:= copy(s,i,j-i);}
    up:=True; keyup:= Space[1]; j:=0;
    for i:=1 to length(s) do begin
      if s[i] in Delimiters then begin
        if up then begin
          keyup:= OtherDelimiter(s[i]); up:= false; end
        else if s[i]  = keyup then begin
          keyup:= Space[1]; up:= true;
        end;
      end;
      if up then begin
        s[i]:= upcase(s[i]);
        if (s[i] = ComentToken) and  (j=0) then j:=i;
      end;
    end;
    if j = 1 then s:='';
    if 1 < j then s[0]:= chr(j-1);  {s:=copy(s,1,j-1);}
  end { if };
  end {cleanstr};

  procedure clean(var s: Longstr);
    var i,j: word;
  begin
  if s= '' then (*)return{*)exit{*};
  i:=1;
  while (s[i]= Space) and (i<=length(s)) do inc(i);
  if i=1 then (*)return{*)exit{*};
  j:=length(s)-i+1;
  if j>0 then begin (*){$w-}(*)
    move(s[i],s[1],j); s[0]:= chr(j); {s:=copy(s,i,j)} end
  else s:='';
  end; { clean }

  function OpenTextFile( var f: InFileType; var Fname: longstr; DfltExt: wrkString): boolean;
  begin
  OpenTextFile:= true;
  if pos('.',Fname)= 0 then
     begin
     { Fname:= Fname+'.'+DfltExt; }
     fname[succ(length(fname))]:='.';
     (*){$w-}(*) move(dfltext[1],fname[length(fname)+2],3);
     fname[0]:= chr(length(fname)+succ(length(Dfltext)));
     end;
  (*) reset(f,Fname); {*) assign(f, fname); reset(f); {*}
  if ioresult <> 0
    then begin
         ErrMsg:= 'Error in opening file:'{ +fname };
         (*){$w-}(*) move(fname[1],errmsg[succ(length(errmsg))],length(fname));
         errmsg[0]:= chr(length(errmsg)+length(fname));
         OpenTextFile:= false;
         end;
  end; { OpenTextFile }

  function OpenBinFile( var f: File; var Fname: longstr;DfltExt: WrkString; option: char): boolean;
  begin
  OpenBinFile:= true;
  if pos('.',Fname)= 0 then
     begin
     { Fname:= Fname+'.'+DfltExt; }
     fname[succ(length(fname))]:='.';
     (*){$w-}(*) move(dfltext[1],fname[length(fname)+2],3);
     fname[0]:= chr(length(fname)+succ(length(Dfltext)));
     end;
  if upcase(option) = 'W' then begin
    (*) rewrite(f,fname);
    {*) assign(f,fname); rewrite(f, 1); {*}
  end { if };
  if upcase(option) = 'R' then begin
    (*) reset(f,fname);
    {*) assign(f, fname); reset(f, 1); {*}
  end { if };
  if ioresult <> 0
    then begin ErrMsg:= 'Error in opening file:';
         {errmsg:= errmsg +fname;}
         move(fname[1],errmsg[succ(length(errmsg))],length(fname));
         errmsg[0]:= chr(length(errmsg)+length(fname));
         OpenBinFile:= false;
         end;
  end; { OpenBinFile }

  (*)segment(*) procedure Initialize;
    var cc: integer;
        dfltext: wrkstring;
  begin
    ConstInit;
    write(#10#13'UniEd Configuration. Version ',Version,'.',(*)standard.(*)byte(SubVersion));
  if MsgLimit < 79 then writeln;
  writeln('    (c) 1989 Software R&D Lab' (*){*), ' IBM PC/XT/AT'{*});
  with Conf do
    begin InsMode:=   $ff;  MakeBack:=  $0;
    DfltExt[1]:=   Space[1]; DfltExt[2]:=   Space[1]; DfltExt[3]:=   Space[1];
    Margins[1]:= 1; Margins[2]:= 66; Margins[3]:= 5;
    ConfChar:= #$c0;
    Tabs[1]:= 1;
    for cc:=1 to 15 do
      Tabs[cc+1]:= 8*cc;
    end; { with Conf }
  ParamStr(0, PgmName);
  dfltext:= 'cmd';
  if (ParamCount <> 2) and (ParamCount <> 1)
    then begin writeln;
         writeln('Usage:', PgmName, ' DefFile[.def] [UeFile[.cmd]]');
         halt(0);
         end;
  if pos('.',Pgmname)= 0 then
     begin
     { PgmName:= PgmName+'.'+DfltExt; }
     pgmname[succ(length(pgmname))]:='.';
     (*){$w-}(*) move(dfltext[1],pgmname[length(PgmName)+2],3);
     PgmName[0]:= chr(length(PgmName)+succ(length(Dfltext)));
     end;
  ParamStr(1, InFname); OutFname:= 'UE.CMD';
  if ParamCount=2 then ParamStr(2, OutFname);
  if not (OpenTextFile(inf, InFname, 'def') )
    then begin writeln;
         writeln(ErrMsg);
         halt(0);
         end;
  Maxi:= MaxAvail- 512;
  if maxi<0 then NoMem;
  (*) getmemword(cmdlist,maxi);
  {*) if maxi > 65000 then maxi:= 65000;
      getmem(cmdlist, maxi);
  {*}
{writeln(#10'Words avail: ', Maxi, ' = $', standard.word(Maxi));}
  end; { Initialize }

  procedure ModifyConfig;
    var i:integer;
  begin
  with conf do
    begin
    for i:=1 to 15 do
      if (tabs[i] < 255) then tabs[i]:= tabs[i] -1;
    tabs[16]:= 255;
    for i:=1 to 3 do
      margins[i]:= margins[i] - 1;
    end;{with}
  end;

  procedure ShowConf;
  var
    i,mode: integer;
    ok: boolean;
  begin
  modifyconfig;
  writeln(#10'Environment configuration:');
  with conf do
    begin
    writeln('InsMode     = ', bool[insmode =$ff]);
    writeln('MakeBackups = ', bool[makeback=$ff]);
    write(  'ConfirmChar = ');
    ok:= false;
    for mode := 1 to 3 do
      for i:=1 to NumberOfKeys do
        begin
        if (not ok) and (SpKey[i].Code[mode] = ConfChar) then
          begin
          ok := true;
          case mode of
            2: write('S-');
            3: write('C-');
            end;
          writeln(SpKey[i].name);
          end;
        end;
    if not ok and (ConfChar in [ '!'..'~', 'А'..'┐']) then writeln( ConfChar);
    if not ok and (ConfChar in [ #0..#$1f ]) then writeln( 'C-',chr(ord(ConfChar)+$40));
    writeln('DfltExt     = ', dfltext[1],dfltext[2],dfltext[3]) ;
    writeln('Margins     = ', succ(margins[1]):5,succ(margins[2]):5,succ(margins[3]):5);
    writeln('Tabs are :');
    for i:=1 to 16 do
      if tabs [i] < 255
        then write((tabs[i]+1):4);
    writeln;
    end;
  end; { ShowConf }

  procedure Err( s: longstr);
  begin
  writeln;
  if (length(line)>0) then writeln(line);
  writeln('Err:  ',s,'! Skipped.'#10);
  end; { Err }

  procedure AddUsrList ((*)const{*)var{*}s: longstr; BdefLen: integer;
                        (*)const{*)var{*} Bdef: ByteDef);
  var i: integer;
  begin
  if UsrEndList = MaxUsrList
    then begin
         Err('Printer`s definiton table full');
         (*) return; {*) exit; {*}
         end;
  i:=0;
  while ( i<UsrEndLIst ) do
    begin
    if s = UsrList[i].Name then
      begin
      Err('Control sequence olready defined');
      (*) return; {*) exit; {*}
      end;
    inc(i);
    end;
  i:=1;
  with UsrList[UsrEndList] do
    begin
    while (i<= length(s)) and (i <= UsrLen) do
      begin
      Name[i]:= s[i];
      inc(i);
      end;
    Name[0]:= chr(pred(i));
    Len:= BdefLen;
    for i:=1 to BdefLen do
      if (Bdef[i] <> $ff) and (chr(Bdef[i]) <> Cchar)
        then Def[i]:= Bdef[i]
        else begin Err('$FF and $1F can`t be inserted on to PrnDefinition');
             (*) return; {*) exit; {*}
             end;
{  writeln('AddingToList(',UsrEndList,'):',name, Len:5 );
  for i:=1 to Bdeflen do
    write( ' $',standard.byte(def[i]):2);
  writeln;}
    end; {with}
  inc(UsrEndList);
  end; {AddUsrList}

  function HasUsrList((*)const(*) s: longstr; var recno: integer ): boolean;
  var i: integer;
  begin
  {writeln('HasUsrList:',s);}
  recno:= 0;
  while recno< UsrEndList do
    if UsrList[recno].Name = s
      then (*)return(true){*)begin HasUsrList:= true; exit end {*}
      else inc(recno);
  (*)return(false);{*)HasUsrList:= false; {*}
  end;{has usr list}

  procedure MakeConfig;
    var lineno: word;

    function Getline( var S: longStr): boolean;
    begin
    repeat
      If Eof(inf)
        then (*)return(false){*) begin Getline:= false; exit end{*};
      write(#13,InFname,'(',lineno,')'#24);inc(lineno);
      readln(inf,s);
      { write( #10,#13, lineno:4,'>', s ); readln;}
      CleanStr(s);
    until S<> '';
    (*)return(true);{*) Getline:= true;{*}
    end; { Getline }

    procedure ProcessLine;
      var lineno: integer;

      function GetS( (*)const(*) s: String): boolean;
      begin
 {    writeln('GetS>',s,'<>',line);
      writeln('pos=',pos(s,line));}
      if length(s) = 0
        then (*)return(true);{*) begin gets:= true; exit; end;{*}
      GetS:= false;
      if pos(s,line) = 1
        then begin delete(line,1,length(s));
             clean(line);
             GetS:= true;
{            write(#13#10'gets:',line); }
             end;
      end; { GetS }

      function GetCh( var res: char): boolean;
        var shft,ctrl: boolean;

        function OtherKey( var ch: char): boolean;
          var
              ok: boolean;
              i: word;
        begin
        ok:= False; i:=0;
        while  not ok and (i< NumberOfKeys) do
          begin inc(i);
          ok:= Gets(SpKey[i].name);
          end;
        OtherKey:= ok;
        if not ok
          then (*) return(false) {*) begin otherkey:= false; exit end {*}
          else if ctrl
             then ch:= SpKey[i].code[3]
             else if shft
                then ch:= SpKey[i].code[2]
                else ch:= SpKey[i].code[1];
        end; { OtherKey }

        function ControlChar( var ch: char):boolean;
        begin
        controlChar:= false;
        if length(line) < 2
          then (*)return(){*) exit {*};
        ControlChar:= (line[1]='^') and (line[2] in ['A'..'Z']);
        ch:= chr(ord(line[2])-$40);
        delete(line,1,2);
        clean(line);
        end; { ControlChar }

      var ch: char;
          ok: boolean;
          pm: integer;
      begin
      clean(line);
      if line = '' then
        (*)return(false){*) begin GetCh:= false end {*};
      shft:= false; ctrl:= false;
      pm:=pos('-',line);
      if  (pm >1) and (pm < 4)
        then begin shft:= gets(Shift);
             ctrl:= gets(Contr);
             delete(line,1,pos('-',line));
             clean(line);
             end;
      ok:= OtherKey(res);
      ch:= line[1];
      if not ok then
          if (ch = '^') then
            ok:= ControlChar(res)
          else if (ch >='0') and (ch <='@') then
             begin ok:= true;
             res:= ch;
             delete(line,1,1);
             clean(line);
             end
          else if (ch >='A') and (ch <='Z') then
             begin ok:= true;
             if ctrl
               then res:= chr(ord(ch) and (*)standard.(*)byte($1f))
               else res:= ch;
             delete(line,1,1);
             clean(line);
             end
          else ok:= false;
      GetCh:= ok;
      end; { GetCh }

      function Defined( (*)const(*) st1,st2: wrkstring): boolean;
        var ok: boolean;
      begin
      ok:= GetS(st1);
      if not ok
        then ok:= GetS(st2);
      Defined:= ok;
      end; { Defined }

      function Exist( (*)const(*) st1, st2, st3: WrkString; b1, b2, b3: Boolean): boolean;
      var
        ok1,ok2,ok3: boolean;
        i: integer;
      begin
      ok1:= false;
      ok2:= false;
      ok3:= false;
      for i:= 1 to 3 do
        begin
        if not ok1 then ok1:= GetS(st1) or ok1;
        if not ok2 then ok2:= GetS(st2) or ok2;
        if not ok3 then ok3:= GetS(st3) or ok3;
        end;
      ok1:= (not b1) or ok1;
      ok2:= (not b2) or ok2;
      ok3:= (not b3) or ok3;
      exist:= ok1 and ok2 and ok3;
      end; { Exist }

      function SetByte( var b: byte): boolean;
        var ok: boolean;
            i: longint;
            er: word;
            ll: longstr;
      begin
{      writeln('set byte',line);}
      i:= GetInteger( line, 1, length(line), er);
      ok:= ioresult = 0;
      if ok
        then delete(line,1,er);
{      writeln('ok=',bool[ok],'i= ',i,'er= ',er,':',line ); readln;}
      ok:= ok  and (i<256);
      if ok then b:= i;
      clean(line);
      (*)return(ok); {*) SetByte:= ok; {*}
      end; { SetByte }

      function SetBool( var b: byte): boolean;
        var ok, yes, no: boolean;
      begin
{      writeln('set bool',line);}
      no:= false;
      ok:= gets(Equal);
      yes:= defined('YES', 'TRUE');
      if not yes then no:= defined('NO', 'FALSE');
      ok:= ok and ( yes or no);
      if ok and yes
        then b:= $ff
        else b:= 0;
      SetBool:= ok;
{      writeln(bool[ok],b);}
      end; { SetBool }

      function SetChar( var ch: char): boolean;
      begin
      SetChar:= gets(Equal) and GetCh(ch);
      end; { SetChar }


      function SetStr( var s: LongStr): boolean;
        var i: word;
            ok: boolean;
            ch: char;
      begin
      s:= ''; i:=2; ch:= line[1];
      ok:= (ch in delimiters) or (ch in Separators);
      if ok  then
        begin
        ch := OtherDelimiter(ch);
        while (i<length(line)) and (line[i] <> ch) do
          begin s[succ(length(s))]:= line[i]; s[0]:= chr(succ(length(s))); inc(i); end;
        ok:= (line[i] = ch);
        if ok
          then begin delete(line,1,i); clean(line); end
          else line:= '';
        end;
      (*)return(ok);{*)SetStr:= ok;{*}
      end; { SetStr }

      procedure ProcessSet;
        var ok: boolean;
            coll: colortype;
            ls: longstr;
            cc,tab: integer;
            bb: byte;
            cch: char;
      begin
{      writeln('Set:');}
      ok:= false;
      if not ok and exist ( 'INSERT', 'MODE', Space, true, false, false)
        then begin bb:= Conf.InsMode; ok:= SetBool(bb); Conf.InsMode:= bb; end;
      if not ok and exist ( 'MAKE', 'BACKUP', 'S ', true, true, false)
        then begin bb:= Conf.MakeBack; ok:= SetBool(bb); Conf.MakeBack:= bb; end;
      if not ok and exist ( 'CONF', 'IRM', 'CHAR ', true, true, false)
        then begin cch:= Conf.ConfChar; ok:= gets(Equal) and GetCh(cch); Conf.ConfChar:= cch; end;
      if not ok and exist ( 'DFLT', 'EXT', Space, false, true, false)
        then begin ok:= gets(Equal) and SetStr(ls);
             for cc:= 1 to 3 do
               if cc>length(ls)
                 then Conf.DfltExt[cc]:= Space[1]
                 else Conf.DfltExt[cc]:= ls[cc];
             end;
      if not ok and exist ( 'MARGIN', Shift, Space, true, false, false)
        then begin ok:= gets(Equal);
             with Conf do
               begin
               cc:=1;
               while (cc < 4) and ok do
                begin bb:= Margins[cc];
                ok := ok and SetByte(bb);
                margins[cc]:= bb;
                inc(cc);
                end;
               if (cc=4) and (not ok )
                 then begin Margins[3]:= Margins[1];
                      ok:= true;
                      end;
               if (margins[1] > margins[2]) or   (margins[1] > margins[3]) or
                  (margins[3] > margins[2]) or   (margins[2] > 248)
                  then begin Err('Invalid Margins setting');
                       margins[1]:= 1; Margins[2]:= 248; margins[3]:= 5;
                       (*)return;{*)exit{*};
                       end;
               end;
             end;
      if not ok and exist ( 'TABS', Space, Space, true, false, false)
        then begin ok:= gets(Equal);
             if ok then
               with Conf do
                 begin
                 for cc:= 1 to 16 do
                  begin bb:= tabs[cc];
                  ok := ok and SetByte(bb) and (bb <> 0);
                  if not ok
                    then Tabs[cc]:= 255
                    else tabs[cc]:= bb;
                  end;
                 ok:= true;
                 for cc:=1 to 15 do
                   begin
                   Tab:= Tabs[cc];
                   if( (Tab >= Tabs[cc+1]) or (Tab > 249)) and (Tab<>255) then ok:= false;
                   end;
                 if (Tabs[16]<>255) and (Tabs[16]>249) then ok:=false;
                 if not ok
                  then begin Err('Invalid Tabs setting');
                       Tabs[1]:= 1;
                       for cc:=1 to 14 do
                         Tabs[cc+1]:= 8*cc;
                       (*)return;{*)exit;{*}
                       end;
               end;
             end;
      if not ok
        then Err('Set option fault');
      end; { ProcessSet }

      function ScanCmdList( CmdPtr : Byte ) : cmatchType;
        {-See if current cmd buffer matches any installed cmds}
        {-Return Match if so, PartMatch if possible match, NoMatch if a loser}
        {-Return cmdcode if matched}
        var Cpos, Cofs, CmdLen : Integer;
            Done: Boolean;
            Result: cmatchType;

      begin { EdScancmdlist }

      {Initialize}
      Cpos := 0;
      CmdLen := Ord(CmdList^[0]);
      if CmdLen= 0
        then begin
             ScanCmdList:= NoMatch;
             (*)return();{*)exit;{*}
             end;
      repeat
        {Offset within this cmd}
        Cofs := 1;
        Result := PartMatch;

        while (Result = PartMatch) and (Cofs <= CmdPtr) and (Cofs <= CmdLen) do
          if cbuf[Cofs] <> CmdList^[Cpos+Cofs] then
            Result := NoMatch
          else
            Inc(Cofs);

        Done := (Result = PartMatch) ;

        inc(Cpos,Succ(CmdLen));
        if not(Done) then
          begin
          { move to next cmd}
          inc(Cpos,Succ(ord(CmdList^[Cpos])));
          {Bytes in next cmd}
          CmdLen := Ord(CmdList^[Cpos]);
          end
        else if (CmdPtr = CmdLen) then
          begin
          {The whole cmd matched}
          Result := Match;
        end;

      until Done or (CmdLen = 0);

      ScanCmdList := Result;
      end; { EdScancmdlist }

      procedure ProcessDefine;
        var sequ: WrkString;
            deff: longstr;

        function Getcmd: boolean;
          var ok: boolean;
              cmd: cmdtype;
              ln: longstr;
              i,j: integer;
        begin
        {write('getcmd');}
        ok:= gets(Lpar);
        ok:= false;
        cmd:= CmdType(1);
        ln:= line;
        while not ok and (cmd <> CmdType(154)) do
          begin line:= ln;
          ok:= exist(tokens[cmd,1], tokens[cmd,2], tokens[cmd,3], true, true,true);
          cmd:= succ(cmd);
          end;
        cmd:= pred(cmd);
        {writeln(line);}
        ok:= ok and gets(Rpar);
        if ok
         then begin {deff:= deff + CChar + chr(ord(cmd));}
            deff[succ(length(deff))]:= Cchar;
            deff[length(deff)+2]:= chr(ord(cmd));
            deff[0]:= chr(length(deff)+2);
            end
         else if (UsrEndList <> 0) then
              begin
              i:=1;
              line:= ln;
              while (length(line)<> 0) and (not ok) do
                 begin
                 if line[1] = Rpar
                   then ok:= true
                   else begin ln[i]:= line[1];
                        inc(i);
                        end;
                 delete(line,1,1);
                 end;{while}
              ln[0]:= chr(pred(i));
              packstr(ln);
              ok := HasUsrList(ln, i);
              if ok then
                with UsrList[i] do
                  begin
                  for j:= 1 to Len do
                    begin
                    deff[length(deff) + 3*j -2]:= Cchar;
                    deff[length(deff) + 3*j -1]:= CtrlTok;
                    deff[length(deff) + 3*j   ]:= chr(def[j]);
                    end;
                  deff[0]:= chr(length(deff)+ 3*Len);
                  end;
              end;
        if not ok then line:= ln;
{        if not ok then writeln('GetCmd: false'#10,ln,#10,line);}
        Getcmd:= ok;
        end; { Getcmd }

        function GetString: boolean;
          var s: longstr;
              ok: boolean;

        begin
        ok:= setstr(s);
        if ok then
          begin
          {deff:= deff+s;}
          move(s[1], deff[succ(length(deff))], length(s));
          deff[0]:= chr(length(deff) + length(s));
          end;
        (*)return(ok);{*) exit;{*}
        end; { GetString }

        procedure AppendDef;
          var i, ldef, lcmd : byte;
        begin
        ldef:= length(deff);
        lcmd:= length(cbuf);
        if (EndList+2+ldef+lcmd) div 2 > Maxi
          then begin
               err('Definition buffer full');
               halt;
               end;
        CmdList^[EndList]:= chr(lcmd);
        for i:= 1 to lcmd do
          CmdList^[EndList+i]:= cbuf[i];
        inc(endlist,succ(lcmd));
        CmdList^[EndList]:= chr(ldef);
        for i:=1  to ldef do
          CmdList^[endlist+i]:= deff[i];
        inc(endlist,succ(ldef));
        end; { AppendDef }

        function EdControlFilter(Ch : Char) : Char;
        begin { EdControlFilter }
        ch:= Upcase(ch);
        if ch in [#0..#32]
          then EdControlFilter:= Chr(Ord(Ch)+64)
          else EdControlFilter:= Ch;
        end; { EdControlFilter }

        var ok: boolean;
            i: integer;
            ch: char;
      procedure InsertDef;
      begin
      sequ:= '      ';
      i:= 1;
      while ok and (length(line)>0) and (not gets(Equal)) and (i<WrkLen) do
        begin ok:= getch(ch);
        if i>1
          then ch:= EdControlFilter(ch);
        sequ[i]:= ch;
        inc(i);
        end;
      if not ok
        then begin err('Incorect CMD sequence');
             (*)return;{*)exit;{*}
             end;
      deff:= '';
      while (length(line)>0) and ok do
        begin
        if line[1] = Lpar
         then ok:= Getcmd
        else if line[1] in delimiters
          then ok:= GetString
          else ok:= false;
        clean(line);
        end;
      if not ok
        then begin
             Err('Definition not correct');
             (*)return;{*)exit;{*}
             end;
      i:=1;cbuf:= '';
      while (i <= length(Sequ)) and (sequ[i] <> Space) do
        begin
        {cbuf:= cbuf + sequ[i];}
        cbuf[succ(length(cbuf))]:= sequ[i];
        cbuf[0]:=succ(cbuf[0]);
        inc(i);
        end;
      cmdptr:= pred(i);
      ok:= (cmdptr < 1 );
{      write('Define: '); writes(cbuf);write(' = '); writes(deff);}
      case ScanCmdList(CmdPtr)  of
        NoMatch:
          AppendDef;
        Match:
          Err('Sequence is already defined');
        PartMatch:
          Err('Not reachable sequence');
        end {case}
      end; {insert def}

      procedure StudyDef;
      var
        stmp: LongStr;
        tmpdef: ByteDef;
        i: integer;
        bb: byte;
      begin
      ok := setstr(stmp);
{      writeln(#10'Study(',bool[ok],'):',stmp);}
      if ok then packstr(stmp);
      ok:= ok and gets(Equal);
      if ok then
        begin
        i:=0;
        while ok and (i <= MaxByDef) do
          begin
          ok:= setbyte(bb);
          if ok then
            begin tmpdef[succ(i)]:= bb;
            inc(i);
            end;
          end;
        ok := (i>0);
        end;
      if ok then AddUsrList(stmp, i, tmpdef);
      if not ok then Err('Printer command deifnition fault');
      end; {study def}

      begin { ProcessDefine }
      ok:= true;
      if line[1] = LBpar
        then StudyDef
        else InsertDef;
      end; { ProcessDefine }

    begin { ProcessLine }
    if Defined('DEF ','D ')
      then ProcessDefine
    else if Defined('SET ','S ')
      then ProcessSet
    else Err('Undefined option!');
    end; { ProcessLine }

  var
    cmd: cmdType;
  begin { make config }
  fillchar(cmdlist^, maxi*2 -1, #0); endlist:= 0;
  lineno:= 1;
  while Getline(line) do
    ProcessLine;
  end; { make config }

  procedure SaveConfig;
  begin
  inc(endlist,2);
  BlockWrite(outf,endlist,2);
  BlockWrite(outf,cmdlist^,endlist);
  BlockWrite(outf,conf,sizeof(conf));
  end; { save config }

  (*)segment(*) procedure LoadUniEd;
  var
    uni: string[8];
    i: integer;
  begin
  uni:= 'UniEd';
  if not OpenBinFile(outf,OutFname,'cmd','r')
    then begin writeln;
         writeln(ErrMsg);
         halt(0);
         end;
  ifs:= filesize(outf);
  if (ifs div 2) > Maxi-1 then NoMem;
  blockread(outf,cmdlist^,ifs);
  for i:=1 to  5 do
    begin
{    writeln(cmdlist^[i+1]:3, ' - ', uni[i]);}
    if (cmdlist^[i+1] <> uni[i]) then
      begin  writeln;
      writeln('File ', OutFname,' is not UniED`s child!');
      halt(0);
      end;
    end;
  i:=7;
 { write('UniEd Ver.', ord(cmdlist^[i]):2, ord(cmdlist^[i+1]):3);}
  if (Version <> ord(cmdlist^[i])) or (SubVersion < ord(cmdlist^[i+1]))
    then begin writeln; writeln;
         writeln('   Sorry,');
         writeln('versions of ');
         writeln('   ', OutFName);
         writeln('and');
         writeln('   ', PgmName);
         writeln('must be compatible!');
         halt;
         end;
  close(outf);
  if OpenBinFile(outf,OutFname,'cmd','w') then;
  blockwrite(outf, cmdlist^, ord(cmdlist^[i+3]) + 256*ord(cmdlist^[i+2]) );
  end;

begin { uecfg }
Initialize;
LoadUniEd;
MakeConfig;
ShowConf;
SaveConfig;
close(outf);
close(inf);
end. { uecfg }
