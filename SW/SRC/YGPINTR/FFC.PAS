program ffc;
  var f: file; ch: char; s: string;
begin
  writeln('Fix First Character. version 1.00 (и д░│га нема да има)');
  if not (paramcount in [1, 2]) then begin
    writeln('  usage: ffc <filename> [character]');
    writeln(' action: first character of a file is changed.');
    writeln('   note: character is changed to space if second parameter is omited.');
    writeln('returns: ErrorLevel <> if some error occurs');
    halt(2); end
  else begin
    assign(f, paramstr(1)); reset(f, 1);
    if IOresult <> 0 then begin
      writeln('Can''t open file ', ParamStr(1));
    end { if };
    if paramcount = 1 then
      ch:= ' '
    else begin
      s:= paramstr(2); ch:= s[1];
    end { if };
    blockwrite(f, ch, 1);
    if IOresult <> 0 then begin
      halt(1);
    end { if };
    close(f);
    if IOresult <> 0 then begin
      halt(1);
    end { if };
  end { if };
end { comment }.