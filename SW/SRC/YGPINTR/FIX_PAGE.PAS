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
  fixpage('\emulator\pagerom8.bin', $5aa5 { ����� � �5 5� });
  fixpage('\emulator\pagerom9.bin', $5aa5 { ����� � �5 5� });
end { fix_pages }.