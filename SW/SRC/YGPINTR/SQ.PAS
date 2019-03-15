program sq;
  uses unitime;
  var st, et: time;
      w: word;
      s: string;
  function _sqrt(x: real): real; {$l sqrt.obj} external;
  var x, y, dmax, xmax: real;
begin
(*
  repeat readln(x);
    writeln('sqrt = ', sqrt(x),
            ', _sqrt = ', _sqrt(x),
            'sqrt - _sqrt = ', sqrt(x) - _sqrt(x));
    writeln('sqrt¤ = ', sqr(sqrt(x)), ', _sqrt¤ = ', sqr(_sqrt(x)));
  until false;


  writeln('Start of sqrt');
  fetch_time(st);
  x:= 0;
  repeat x:= x +1;
    if sqrt(x) = 0 then;
  until x > 1000;
  fetch_time(et);
  time2str(st, s);
  write('Start ', s);
  time2str(et, s);
  write(', End ', s);
  sub_time(et, st, st, w);
  time2str(st, s);
  writeln(', duration ', s);

  writeln('Start of _sqrt');
  fetch_time(st);
  x:= 0;
  repeat x:= x + 1;
    if _sqrt(x) = 0 then;
  until x > 1000;
  fetch_time(et);
  time2str(st, s);
  write('Start ', s);
  time2str(et, s);
  write(', End ', s);
  sub_time(et, st, st, w);
  time2str(st, s);
  writeln(', duration ', s);
*)
  dmax:= 0;
  writeln(message, 'Start of _sqrt');
  fetch_time(st);
  x:= 1/4;
  repeat x:= x + 0.0001;
    y:= abs(_sqrt(x) - sqrt(x));
    if y <> 0 then begin
      writeln(message, 'x = ', x:0:7, 
              ',  = ', y, '($', longword(y),')');
      writeln('x = ', x:0:7, 
              ',  = ', y, '($', longword(y),')');
      if y > dmax then begin
        dmax:= y; xmax:= x;
      end { if };
    end { if };
  until x >= 4;
  fetch_time(et);
  time2str(st, s);
  write('Start ', s);
  time2str(et, s);
  write(', End ', s);
  sub_time(et, st, st, w);
  time2str(st, s);
  writeln(', duration ', s);
  if dmax = 0 then begin
    writeln(message, 'Н┐ма ░азлики!');
    writeln('Н┐ма ░азлики!'); end
  else begin
    writeln(message, 'Има ░азлики! Виж ▒и ┤иле▓о!');
    x:= xmax; xmax:= sqrt(x) - _sqrt(x);
    writeln('MAX ░азлика п░и ', x, ', и ▒е пол│╖ава:');
    writeln('sqrt = ', sqrt(x),
            ', _sqrt = ', _sqrt(x),
            'sqrt - _sqrt = ', sqrt(x) - _sqrt(x), '($', longword(xmax), ')');
    writeln('sqrt¤ = ', sqr(sqrt(x)), ', _sqrt¤ = ', sqr(_sqrt(x)));
  end { if };
end.