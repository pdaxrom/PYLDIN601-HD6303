


       ColorType = (            { Screen colors  }
                    TxtColor,                                    { Text color }
                    BlockColor,                                 { Block color }
                    BordColor,                          { Window status lines }
                    CmdColor,                            { Command line color }
                    CursorColor, { Color for solid block cursor, if activated }
                    MnColor,                              { Normal menu color }
                    MfColor,                               { Menu frame color }
                    MsColor,                       { Selected menu item color }
                    MhColor,        { Highlighted selection character in menu }
                    BoldColor,                     { Color for bold attribute }
                    DblColor,              { Color for doublestrike attribute }
                    UndColor,                { Color for underscore attribute }
                    SupColor,               { Color for superscript attribute }
                    SubColor,                 { Color for subscript attribute }
                    Alt1Color, { Color for alternate 1 attribute - Compressed }
                    Alt2Color      { Color for alternate 2 attribute - Italic }
                   );

       { Stores screen attributes }
       AttributeArray = packed array [ColorType] of Byte;

       InitType = packed record
         UndoLimit: byte;
         InsMode:   Boolean;
         AIMode:    Boolean;
         MakeBack:  Boolean;
         AbortChar: char;
         DfltExt:   String[4];

         ColorAttr: AttributeArray;
         end;

       AsmInitType = packed record
         InsMode:   byte;
         MakeBack:  byte;
         Margins:   packed array [1..3] of byte;
         ConfChar:  char;
         DfltExt:   packed array [1..3] of char;
         Tabs:      packed array [1..16] of byte;
       end; { InitType }
