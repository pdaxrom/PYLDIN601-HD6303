{
    EDCS.INC
}
type
  CmdType =
  (
  {Basic cursor movements  }
   Cun112,					 {for expansion}
   Clftch,	      { [lft]			  0. lft chacter}
   Crghch,	     { [rigth]			  1. rgh chacter}
   ClftWord,		{ [lft word]		    2. lft lexeme}
   CrghWord,	       { [rigth word]		    3. rgh lexeme}
   CUpln,	       { [up]			    4. Up ln}
   CDownln,	       { [down] 		    5. Down ln}
   CScrollUp,		 { [scrol up ]		      6. Scroll up}
   CScrollDown, 	 { [scroll down]	      7. Scroll down}
   CDownPage,		 { [page down]		      8. Down page}
   CUpPage,		 { [page up]		      9. Up page}
  {Quick movements}
   CwndTopFile,       { [top file]		  10. Top of wnd}
   CwndbotFile,    { [bot file] 	    11. bot of wnd}
   Clftln,	      { [begin ln]		12. Cursor to lft side}
   Crghln,	     { [end ln] 	       13. Cursor to rgh side}
   CTopScreen,		 { [top edge]		     14. Top of screen}
   CbotScreen,	      { [bot edge]	       15. bot of screen}
   Cun1,					 {for expansion}
   Cun2,					 {for expansion}
   CCpgotoln,		 { [goto ln]		   18. Goto ln n}
   CGotoColumn, 	 { [goto column]	     19. Goto column n}
   Cun3,					 {for expansion}
   CjmpLastpos,    { [last cursor]	       21. Previous cursor pos}
  {Insertion and deletion}
   CUndo,		 { [undo]		     22. Undo last deletion}
   CRestoreCurrentln,  { [restore]		   23. Restore ln as on entry}
   CTab,		 { [tab]		     24. Tab, either fixed or "smart"}
   CInsertCtrlch,      { [control ch]		 25. Inserting control chacter into text}
   CNewln,	       { [new ln]		 26. New ln in text buffer}
   CInsertln,	       { [insert ln]		 27. Inserting ln}
   Cdelrghch,	  { [rubout]		      28. del current chacter}
   Cdellftch,	   { [del ch]		  29. del lft chacter}
   CdelrghWord,     { [del word]	     30. del rgh lexeme}
   Cdellnrgh,	  { [del end ln]	 31. del ln rgh of cursor}
   Cdelln,	    { [del ln]		   32. del ln}
   Cun4,					 {for expansion}
  {Find and replace}
   CFind,		 { [find]		     34. Find pattern}
   CFindReplace,	 { [change]		     35. Find and replace}
   Cun5,					 {for expansion}
   CFindNext,		 { [next]		     37. Find next}
  {Files and DOS interface			    }
   Cun6,					 {for expansion}
   Cun7,					 {for expansion}
   Cun8,					 {for expansion}
   CAbandonFile,	 { [quit]		     41. Abandon file}
   CReadblk,	       { [read blk]		 42. Read file into wnd}
   CSaveFile,		 { [save]		     43. Save file}
   CWriteblk,	       { [write blk]		 44. Write blk to file, not appending}
   CSaveQuit,		 { [save] [quit]	     45. Save file and exit}

  {wnds}
   CAddwnd,	      { [add wnd]	       46. Add second wnd with same or different file}
   CSizewnd,	      { [size wnd]	       47. Resize current wnd}
   Cun9,					 {for expansion}
   CwndDown,	      { [next wnd]	       49. Switch wnds}
   Cun10,					 {for expansion}
   Cun11,					 {for expansion}

  {blks}
   CblkBegin,	       { [mark blk begin]	 52. Begin blk}
   CblkEnd,	       { [mark blk end] 	 53. End blk}
   CjmpTopOfblk,      { [blk top]		54. Top of blk}
   Cjmpbotblk,	   { [blk bot]		  55. bot of blk}
   CblkCopy,	       { [copy blk]		 56. Copy blk}
   CblkMove,	       { [move blk]		 57. Move blk}
   Cblkdel,	    { [del blk] 	   58. del blk}
   CblkHide,	       { [hide blk]		 59. Hide/display tggl blk}
   CblkWord,	       { [mark word]		   60. Mark current word as blk}

  {Text mrks}
   CtgglTextmrk,    { [show mrks]	     61. tggl text mrk display}
   CSetmrk0,	      { [set mark]		62. Set mrk}
   CSetmrk1,
   CSetmrk2,
   CSetmrk3,
   CSetmrk4,
   CSetmrk5,
   CSetmrk6,
   CSetmrk7,
   CSetmrk8,
   CSetmrk9,
   Cjmpmrk0,	     { [go mark]			 jmp mrk}
   Cjmpmrk1,
   Cjmpmrk2,
   Cjmpmrk3,
   Cjmpmrk4,
   Cjmpmrk5,
   Cjmpmrk6,
   Cjmpmrk7,
   Cjmpmrk8,
   Cjmpmrk9,
   Cun12,					 {for expansion}
   Cun13,					 {for expansion}
   Cun14,					 {for expansion}
   Cun15,					 {for expansion}
   Cun16,					 {for expansion}
   Cun17,					 {for expansion}
   Cun18,					 {for expansion}
   Cun19,					 {for expansion}
   Cun20,					 {for expansion}
   Cun21,					 {for expansion}
   Cun22,					 {for expansion}
   Cun23,					 {for expansion}
   Cun24,					 {for expansion}
   Cun25,					 {for expansion}
   Cun26,					 {for expansion}
   Cun27,					 {for expansion}
   Cun28,					 {for expansion}
   Cun29,					 {for expansion}
   Cun30,					 {for expansion}
   Cun31,					 {for expansion}
   Cun32,					 {for expansion}
   Cun33,					 {for expansion}

  {tggls and status}
   CSysInfo,		 { [info]		     104. Show system information}
   CShowMem,		 { [mem]		     105. Show available memory}
   CtgglInsert,        { [ins]			   106. tggl insert mode}
   CtgglAI,    { [tggl indent]		 107. tggl AI mode}
   Cun34,					 {for expansion}
   Cun35,					 {for expansion}
   Cun36,					 {for expansion}
   Cun37,					 {for expansion}
   Cun38,					 {for expansion}
   Cun39,					 {for expansion}
   Cun40,					 {for expansion}
   Cun41,					 {for expansion}
   Cun42,					 {for expansion}
   Cun43,					{for expansion}
   Cun44,					 {for expansion}
   Cun45,					 {for expansion}
   Cun46,					 {for expansion}
   Cun47,					 {for expansion}
   Cun48,					 {for expansion}
  {Utility cmds}
   Cun49,					 {for expansion}
   Cun50,					 {for expansion}
   Cun51,					 {for expansion}
   Cun52,					 {for expansion}
   CLogDrive,		 { [log drive]		     127. Log drive or path}
   Cun53,					 {for expansion}
  {Additional cmds}
   Cun54,					 {for expansion}
   Cun55,					 {for expansion}
   Cun56,					 {for expansion}
   Cun57,					 {for expansion}
   CSetUndoLimit,	 { [undo limit] 	     133. Set default undo limit}
   Cun58,					 {for expansion}
   CGetDefaultExtension, { [dflt extension]	     135. Get a new default file extension}
   Cun59,					 {for expansion}
   Cun60,					 {for expansion}
   Cun61,					 {for expansion}
   Cun62,					 {for expansion}
   Cun63,					 {for expansion}
   Cun64,					 {for expansion}
   Cun65,					 {for expansion}
   Cun66,					 {for expansion}
   Cun67,					 {for expansion}
   Cun68,					 {for expansion}
   Cun69,					 {for expansion}
   Cun70,					 {for expansion}
   Cun71,					 {for expansion}
   Cun72,					 {for expansion}
   Cun73,					 {for expansion}
   CWriteNamedFile,	 { [save as]		     151. Save current wnd to another file}

   Cun74,					 {for expansion}
   CwndUp,	      { [prev wnd]	       153. Move to previous wnd}
   Cun75,					 {for expansion}
   Cun76,					 {for expansion}
   Cun77,					 {for expansion}
   Cun78,					 {for expansion}
   Cun79,					 {for expansion}
   Cun80,					 {for expansion}
   Cun81,					 {for expansion}
   Cun82,					 {for expansion}
   Cun83,					 {for expansion}
   Cun84,					 {for expansion}
   Cun85,					 {for expansion}
   Cun86,					 {for expansion}
   Cun87,					 {for expansion}
   Cun88,					 {for expansion}
   Cun89,					 {for expansion}
   Cun90,					 {for expansion}

   Cun91,					 {for expansion}
   Cun92,					 {for expansion}
   Cun93,					 {for expansion}
   Cun94,					 {for expansion}

   Cun95,					 {for expansion}
   Cun96,					 {for expansion}
   Cun97,					 {for expansion}
   Cun98,					 {for expansion}
   Cun99,					 {for expansion}
   Cun100,					 {for expansion}
   Cun101,					 {for expansion}
   Cun102,					 {for expansion}
   Cun103,					 {for expansion}
   Cun104,					 {for expansion}
   Cun105,					 {for expansion}
   Cun106,					 {for expansion}
   Cun107,					 {for expansion}
   Cun108,					 {for expansion}
   Cun109,					 {for expansion}
   Cun110,					 {for expansion}
   Cun111,					 {for expansion}

   {These should be kept latest}
   CAbort,					     {192. Abort current operation}
   CNull,					     {193. No operation indicated}
   CNullMain					     {194. No op indicated, submenu accessible with no file open}
   );

type
  cmdString = string[4]; {Longest key sequence for a cmd}
  CMatchType = (Match, NoMatch, PartMatch); {Used in matching key sequences to editor cmds}

var
  {Keyboard-related}
  CBuf : cmdString;    {Holds current cmd until complete cmd reached}
  CmdPtr : Byte;	     {Points to last chacter in current cmd}

var
  Cchar: char;


