program Yspeed;
  var microsec: longint;
      instruc:  longint;
begin
  repeat
    write('Instructions: '); readln(instruc);
    write('Microseconds: '); readln(microsec);
    writeln;
    writeln('Instructions per second:      ', instruc/microsec*1000000:0:10);
    writeln('Microseconds per instruction: ', microsec/instruc:0:10);
  until eof(input);
end.