type
   keycode= record
	      name: WrkString;
	      code: packed Array[1..3] of char;
	    end;
const
  NumberOfKeys = 35;
var
  SpKey: array[1..NumberOfKeys] of keycode;


