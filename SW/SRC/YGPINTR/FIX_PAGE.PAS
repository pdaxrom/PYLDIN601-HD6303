program fix_pages;

  procedure fixpage(name: string; value: word);
    var f: file;
  begin
    assign(f, name);
    reset(f, 1);
    blockwrite(f, value, 2);
    close(f);
  end { fixpage };

begin
  fixpage('\emulator\pagerom8.bin', $5aa5 { кое▓о е А5 5А });
  fixpage('\emulator\pagerom9.bin', $5aa5 { кое▓о е А5 5А });
end { fix_pages }.