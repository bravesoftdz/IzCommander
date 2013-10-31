unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, AdvStatusBar, Menus, ExtCtrls,
  StdCtrls, MSN, ShellCtrls, MPDrivePanel,FileCtrl,ShellAPI, AdvListV,
  WinXP, emiDriveCombo, Registry;

type

  TCustomSortStyle = (cssAlphaNum, cssNumeric, cssDateTime);

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    AdvStatusBar1: TAdvStatusBar;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    NewYachtBtn: TToolButton;
    EditYachtBtn: TToolButton;
    ViewYachtBtn: TToolButton;
    DeleteYachtBtn: TToolButton;
    ImageList1: TImageList;
    ImageList2: TImageList;
    ImageList3: TImageList;
    Mark1: TMenuItem;
    Command1: TMenuItem;
    Net1: TMenuItem;
    Show1: TMenuItem;
    Configuration1: TMenuItem;
    Start1: TMenuItem;
    Help1: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel9: TPanel;
    MPDrivePanel1: TMPDrivePanel;
    MPDrivePanel2: TMPDrivePanel;
    ImageList4: TImageList;
    Panel10: TPanel;
    Label3: TLabel;
    Panel11: TPanel;
    LeftSideDirLabel: TLabel;
    Panel12: TPanel;
    Panel13: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Panel14: TPanel;
    RightSideDirLabel: TLabel;
    EmiDriveComboBox1: TEmiDriveComboBox;
    Panel6: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    EmiDriveComboBox3: TEmiDriveComboBox;
    Panel15: TPanel;
    Label2: TLabel;
    CoolBar2: TCoolBar;
    ToolBar2: TToolBar;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    Panel7: TPanel;
    BottomDirLabel: TLabel;
    ComboBox1: TComboBox;
    ListView1: TListView;
    ListView2: TListView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);

    procedure fillLeftSide;
    procedure fillRightSide;
    procedure ListView2DblClick(Sender: TObject);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListView2CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private declarations }
    FListViewWndProc1: TWndMethod;
    FListViewWndProc2: TWndMethod;

    procedure ListViewWndProc1(var Msg: TMessage);
    procedure ListViewWndProc2(var Msg: TMessage);
  public
    { Public declarations }
    FShowHoriz: Boolean;
    FShowVert: Boolean;
  end;

var
  Form1: TForm1;
  LeftSideDir,RightSideDir : String;
  FSortColumn1,FSortColumn2: integer;

  LvSortStyle: TCustomSortStyle;
  LvSortOrder: array[0..4] of Boolean; // High[LvSortOrder] = Number of Lv Columns

implementation

{$R *.dfm}


//-------------------------------------------------------------------------------------
function GetIconIndex(Path: String): Cardinal;
var
Attribute, SHResult: Cardinal;
ShInfo1: TSHFILEINFO;
begin
Attribute := FILE_ATTRIBUTE_NORMAL;
if DirectoryExists(Path) then
  Attribute := FILE_ATTRIBUTE_DIRECTORY;
{test to see if it is a Directory and set Attibute to FILE_ATTRIBUTE_DIRECTORY.
It does NOT matter what the Items[i].Caption has, if you set the Attribute to
FILE_ATTRIBUTE_DIRECTORY, you will get a Folder Icon.
You should NOT have a \ on the end of the folder name for this}

SHResult := SHGetFileInfo(PChar(Path), Attribute, ShInfo1, SizeOf(ShInfo1),
                 SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES {or SHGFI_ICON});
{this get's the Image Index in the ShInfo1.iIcon, , EVEN if the file Does Not exist
      just so it has a file extention (gets the "Default" Icon for that file extention) }
if SHResult = 0 then
  begin
  Result := 0;
  if Path[Length(Path)] <> '\' then
  Path := Path + '\' else
  Path[Length(Path)] := #0;
  SHResult := SHGetFileInfo(PChar(Path), Attribute, ShInfo1, SizeOf(ShInfo1),
                 SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
  if SHResult = 0 then Exit
  end;

Result := ShInfo1.iIcon;
end;
//----------------------------------

function AttrStr(Attr:integer):string;
begin
  Result := '';
  if (Attr and file_attribute_Directory)  > 0 then Result := Result + 'D';
  if (Attr and file_attribute_Archive)    > 0 then Result := Result + 'A';
  if (Attr and file_attribute_Readonly)   > 0 then Result := Result + 'R';
  if (Attr and file_attribute_System)     > 0 then Result := Result + 'S';
  if (Attr and file_attribute_Hidden)     > 0 then Result := Result + 'H';
//  if (Attr and FILE_ATTRIBUTE_COMPRESSED) > 0 then Result := Result + 'C';
  if (Attr and file_attribute_Temporary)  > 0 then Result := Result + 'T';
end;


//----------------------------------------
procedure TForm1.ListViewWndProc1(var Msg: TMessage);
begin
  ShowScrollBar(ListView1.Handle, SB_HORZ, FShowHoriz);
  ShowScrollBar(ListView1.Handle, SB_VERT, FShowVert);
  FListViewWndProc1(Msg); // process message
end;

procedure TForm1.ListViewWndProc2(var Msg: TMessage);
begin
  ShowScrollBar(ListView2.Handle, SB_HORZ, FShowHoriz);
  ShowScrollBar(ListView2.Handle, SB_VERT, FShowVert);
  FListViewWndProc2(Msg); // process message
end;

//----------------------------------------

function CustomSortProc(Item1, Item2: TListItem; SortColumn: Integer): Integer; stdcall;
var 
  s1, s2: string; 
  i1, i2: Integer; 
  r1, r2: Boolean; 
  d1, d2: TDateTime; 

  { Helper functions } 

  function IsValidNumber(AString : string; var AInteger : Integer): Boolean; 
  var 
    Code: Integer; 
  begin 
    Val(AString, AInteger, Code); 
    Result := (Code = 0); 
  end; 

  function IsValidDate(AString : string; var ADateTime : TDateTime): Boolean; 
  begin 
    Result := True; 
    try 
      ADateTime := StrToDateTime(AString); 
    except 
      ADateTime := 0; 
      Result := False; 
    end; 
  end; 

  function CompareDates(dt1, dt2: TDateTime): Integer; 
  begin 
    if (dt1 > dt2) then Result := 1 
    else 
      if (dt1 = dt2) then Result := 0 
    else 
      Result := -1; 
  end;

  function CompareNumeric(AInt1, AInt2: Integer): Integer;
  begin
    if AInt1 > AInt2 then Result := 1
    else 
      if AInt1 = AInt2 then Result := 0 
    else 
      Result := -1; 
  end; 

begin 
  Result := 0; 

  if (Item1 = nil) or (Item2 = nil) then Exit; 

  case SortColumn of 
    -1 : 
    { Compare Captions } 
    begin 
      s1 := Item1.Caption; 
      s2 := Item2.Caption; 
    end; 
    else 
    { Compare Subitems }
    begin
      s1 := '';
      s2 := ''; 
      { Check Range } 
      if (SortColumn < Item1.SubItems.Count) then 
        s1 := Item1.SubItems[SortColumn]; 
      if (SortColumn < Item2.SubItems.Count) then 
        s2 := Item2.SubItems[SortColumn] 
    end; 
  end; 

 { Sort styles } 

  case LvSortStyle of 
    cssAlphaNum : Result := lstrcmp(PChar(s1), PChar(s2)); 
    cssNumeric  : begin 
                    r1 := IsValidNumber(s1, i1); 
                    r2 := IsValidNumber(s2, i2); 
                    Result := ord(r1 or r2); 
                    if Result <> 0 then 
                      Result := CompareNumeric(i2, i1); 
                  end; 
    cssDateTime : begin 
                    r1 := IsValidDate(s1, d1); 
                    r2 := IsValidDate(s2, d2); 
                    Result := ord(r1 or r2); 
                    if Result <> 0 then 
                      Result := CompareDates(d1, d2); 
                  end; 
  end;

  { Sort direction }

  if LvSortOrder[SortColumn + 1] then
    Result := - Result;
end;

//---------------------------------------

procedure TForm1.fillLeftSide;
var
 ss:Array[0..255] of char;
 s,s1,s2,extention:String;
 de:Integer;
 sc:TSearchRec;
 i,j,k,l:integer;
 ListItem2,ListItem: TListItem;
 NewColumn: TListColumn;
 FileHandle : THandle;
 ftarih     : integer;

 Nr    : Word;
 upfolder:Boolean;
begin
 ListView1.Clear;
 ListView1.Columns[0].Caption := 'Name';
 ListView1.Columns[1].Caption := 'Ext';
 ListView1.Columns[2].Caption := 'Size';
 ListView1.Columns[3].Caption := 'Date';
 ListView1.Columns[4].Caption := 'Attr';

 LeftSideDirLabel.Caption := LeftSideDir+'\*.*';

 upfolder := FALSE;

 strpcopy(ss,LeftSideDir+'\*.*');
 de := FindFirst(ss,faAnyFile,sc);
 if de=0 then
 repeat
  if (sc.name='') or (sc.name='.') or (sc.Name='..') then
  begin
   if not upfolder then
   begin
    upfolder := TRUE;
    ListItem := ListView1.Items.Add;
    ListItem.Caption := '[..]';
    ListItem.SubItems.Add('<DIR>');
    ListItem.SubItems.Add( '' );
    ListItem.SubItems.Add( DateToStr ( FileDateToDateTime( sc.Time ) ) );
    ListItem.ImageIndex := 0;
   end;
  end else
  begin
   ListItem := ListView1.Items.Add;

   if pos('.',sc.Name)<>0 then
   begin
    s2 := sc.Name;
    i := length(s2)+1;
    repeat
     dec(i);
    until (i=1) or (s2[i]='.');
    if s2[i]='.' then
     ListItem.Caption := copy(s2,1,i-1) else
     ListItem.Caption := sc.Name;
   end else
    ListItem.Caption := sc.Name;

   ListItem.ImageIndex := 0;

   if (sc.Attr and file_attribute_Directory) > 0 then
   begin
    ListItem.Caption := '['+sc.Name+']';
    extention := '<DIR>';
   end else
   begin
    extention := copy(sc.Name,pos('.',sc.Name)+1,length(sc.Name)-pos('.',sc.Name));
   end;
   extention := UpperCase(extention);

   ListItem.SubItems.Add(extention);

   ListItem.ImageIndex := 0;
   DecimalSeparator := '.';
   ThousandSeparator := '.';
   ListItem.SubItems.Add( inttostr(sc.Size) );
   ListItem.SubItems.Add( DateToStr ( FileDateToDateTime( sc.Time ) ) );
  end;
  ListItem.SubItems.Add(AttrStr(sc.Attr));

  de := findnext(sc);
 until de<>0;

 for i := 0 to ListView1.Items.Count - 1 do
 begin
  if ListView1.Items[i].SubItems[0]='<DIR>' then
  begin
   s := ListView1.Items[i].Caption;
   delete(s,1,1);
   delete(s,length(s),1);
   ListView1.Items[i].ImageIndex := GetIconIndex(LeftSideDir+'\'+s);
  end else
   ListView1.Items[i].ImageIndex :=
    GetIconIndex(LeftSideDir+'\'+ListView1.Items[i].Caption+'.'+ListView1.Items[i].SubItems[0]);
 end;

// ListView1.SortColumn := 1;
// ListView1.Sort;
end;

procedure TForm1.fillRightSide;
var
 ss:Array[0..255] of char;
 s,s1,s2:String;
 de:Integer;
 sc:TSearchRec;
 i,j,k,l:integer;
 ListItem2,ListItem: TListItem;
 NewColumn: TListColumn;
 FileHandle : THandle;
 ftarih     : integer;

 Nr    : Word;
 upfolder:Boolean;
begin
 ListView2.Clear;
 ListView2.Columns[0].Caption := 'Name';
 ListView2.Columns[1].Caption := 'Ext';
 ListView2.Columns[2].Caption := 'Size';
 ListView2.Columns[3].Caption := 'Date';
 ListView2.Columns[4].Caption := 'Attr';

 RightSideDirLabel.Caption := RightSideDir+'\*.*';

 upfolder := FALSE;

 strpcopy(ss,LeftSideDir+'\*.*');
 de := FindFirst(ss,faAnyFile,sc);
 if de=0 then
 repeat
  if (sc.name='') or (sc.name='.') or (sc.Name='..') then
  begin
   if not upfolder then
   begin
    upfolder := TRUE;
    ListItem := ListView2.Items.Add;
    ListItem.Caption := '[..]';
    ListItem.SubItems.Add('<DIR>');
    ListItem.SubItems.Add( '' );
    ListItem.SubItems.Add( DateToStr ( FileDateToDateTime( sc.Time ) ) );
    ListItem.ImageIndex := 0;
   end;
  end else
  begin
   ListItem := ListView2.Items.Add;

   if pos('.',sc.Name)<>0 then
   begin
    s2 := sc.Name;
    i := length(s2)+1;
    repeat
     dec(i);
    until (i=1) or (s2[i]='.');
    if s2[i]='.' then
     ListItem.Caption := copy(s2,1,i-1) else
     ListItem.Caption := sc.Name;
   end else
    ListItem.Caption := sc.Name;

   ListItem.ImageIndex := 0;

   if (sc.Attr and file_attribute_Directory) > 0 then
   begin
    ListItem.Caption := '['+sc.Name+']';
    ListItem.SubItems.Add('<DIR>')
   end else
   begin
    ListItem.SubItems.Add(copy(sc.Name,pos('.',sc.Name)+1,length(sc.Name)-pos('.',sc.Name)));
   end;

   ListItem.ImageIndex := 0;

   ListItem.SubItems.Add( Format ('%10d',[sc.Size]) );
   ListItem.SubItems.Add( DateToStr ( FileDateToDateTime( sc.Time ) ) );
  end;

  de := findnext(sc);
 until de<>0;

 for i := 0 to ListView2.Items.Count - 1 do
 begin
  if ListView2.Items[i].SubItems[0]='<DIR>' then
  begin
   s := ListView2.Items[i].Caption;
   delete(s,1,1);
   delete(s,length(s),1);
   ListView2.Items[i].ImageIndex := GetIconIndex(LeftSideDir+'\'+s);
  end else
   ListView2.Items[i].ImageIndex :=
    GetIconIndex(LeftSideDir+'\'+ListView2.Items[i].Caption+'.'+ListView2.Items[i].SubItems[0]);
 end;

end;


procedure TForm1.FormCreate(Sender: TObject);
var
i, hSysIList : Integer;
ShInfo1      : TSHFILEINFO;

begin
 FShowHoriz := False; // show the horiz scrollbar
 FShowVert := True; // hide vert scrollbar

 FListViewWndProc1 := ListView1.WindowProc; // save old window proc
 ListView1.WindowProc := ListViewWndProc1; // subclass

 FListViewWndProc2 := ListView2.WindowProc; // save old window proc
 ListView2.WindowProc := ListViewWndProc2; // subclass


 LeftSideDir := 'c:';
 RightSideDir := 'c:';
 FillLeftSide;
 FillRightSide;

 with ListView1 do
 begin
  {First get the Handle of the System Large Icon Image List using the SHGFI_SYSICONINDEX or SHGFI_LARGEICON flags in the SHGetFileInfo function}
  hSysIList := SHGetFileInfo('', 0, ShInfo1, SizeOf(ShInfo1), SHGFI_SYSICONINDEX or SHGFI_LARGEICON);

  if hSysIList <> 0 then
  begin
   {you do NOT have ANY TImageList components on your Form you will create them here at run time First Create the LargeImages TImageList for the large Icons}
   LargeImages := TImageList.Create(Self);
   // Assign the system large Icon imageList to the LargeImages TImageList
   LargeImages.Handle := hSysIList;
   //Now the LargeImages IS the system large Icon imageList

   // The following prevents the image list handle from being
   // destroyed when the LargeImages component is destroyed.
   LargeImages.ShareImages := TRUE;
   {This LargeImages IS the system Image List, so do not
   try and change it, like adding images or changing it's properties}
  end;

  hSysIList := SHGetFileInfo('', 0, ShInfo1, SizeOf(ShInfo1), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  {get the Handle for the system Small Icon Image List with the SHGFI_SYSICONINDEX or SHGFI_SMALLICON flags}
  if hSysIList <> 0 then
  begin
   SmallImages := TImageList.Create(Self);
   {create a SmallImages Image List}
   // Assign the system list handle to the ListView1.SmallImages
   SmallImages.Handle := hSysIList;
   {Make Sure that you do NOT destroy the system Image List}
   SmallImages.ShareImages := TRUE;
  end;
 end;

 with ListView2 do
 begin
  {First get the Handle of the System Large Icon Image List using the SHGFI_SYSICONINDEX or SHGFI_LARGEICON flags in the SHGetFileInfo function}
  hSysIList := SHGetFileInfo('', 0, ShInfo1, SizeOf(ShInfo1), SHGFI_SYSICONINDEX or SHGFI_LARGEICON);

  if hSysIList <> 0 then
  begin
   {you do NOT have ANY TImageList components on your Form you will create them here at run time First Create the LargeImages TImageList for the large Icons}
   LargeImages := TImageList.Create(Self);
   // Assign the system large Icon imageList to the LargeImages TImageList
   LargeImages.Handle := hSysIList;
   //Now the LargeImages IS the system large Icon imageList

   // The following prevents the image list handle from being
   // destroyed when the LargeImages component is destroyed.
   LargeImages.ShareImages := TRUE;
   {This LargeImages IS the system Image List, so do not
   try and change it, like adding images or changing it's properties}
  end;

  hSysIList := SHGetFileInfo('', 0, ShInfo1, SizeOf(ShInfo1), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  {get the Handle for the system Small Icon Image List with the SHGFI_SYSICONINDEX or SHGFI_SMALLICON flags}
  if hSysIList <> 0 then
  begin
   SmallImages := TImageList.Create(Self);
   {create a SmallImages Image List}
   // Assign the system list handle to the ListView1.SmallImages
   SmallImages.Handle := hSysIList;
   {Make Sure that you do NOT destroy the system Image List}
   SmallImages.ShareImages := TRUE;
  end;
 end;

end;

procedure TForm1.ListView1DblClick(Sender: TObject);
var
 ListItem : TListItem;
 s        : String;
 i,j      : integer;
begin
 ListItem := ListView1.Selected;
 if ListItem.SubItems[0] = '<DIR>' then
 begin
  s := ListItem.Caption;
  delete(s,1,1);
  delete(s,length(s),1);
  if s='..' then
  begin
   i := length(leftsidedir)+1;
   repeat dec(i); until (i=1) or (leftsidedir[i]='\');
   if leftsidedir[i]='\' then
    LeftSideDir := copy(LeftSideDir,1,i-1) else
    LeftSideDir := 'c:';
  end else
   LeftSideDir := LeftSideDir + '\' + s;

  fillLeftSide;
 end;
end;

procedure TForm1.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
// caption := inttostr( ord(key) );
end;

procedure TForm1.ListView2DblClick(Sender: TObject);
var
 ListItem : TListItem;
begin
 ListItem := ListView2.Selected;
 if ListItem.SubItems[0] = '<DIR>' then
 begin
  RightSideDir := RightSideDir + '\' + ListItem.Caption;
  fillRightSide;
 end;
end;

procedure TForm1.ListView1CustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
vlrect : trect;
begin
(*
 if subitem=1 then
 begin
 vlRect := Item.DisplayRect(drBounds);
 vlRect.Left  := ListView1.Columns[0].Width + ListView1.Columns[1].Width + 5;
 vlRect.Right := vlRect.Left + ListView1.Columns[2].Width - (5 * 2);
 Sender.Canvas.TextRect(vlRect, vlRect.Left, vlRect.Top, Item.SubItems[1]);
 end;
*)
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  ListView1.WindowProc := FListViewWndProc1; // restore window proc
  ListView2.WindowProc := FListViewWndProc2; // restore window proc
  FListViewWndProc1 := nil;
  FListViewWndProc2 := nil;
end;

procedure TForm1.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  { determine the sort style } 
  if Column.Index in [0,1,4] then
    LvSortStyle := cssAlphaNum
  else
  if Column.Index in [2] then
    LvSortStyle := cssNumeric
  else
  if Column.Index in [3] then
    LvSortStyle := cssDateTime;

  { Call the CustomSort method }
  ListView1.CustomSort(@CustomSortProc, Column.Index -1); 

  { Set the sort order for the column} 
  LvSortOrder[Column.Index] := not LvSortOrder[Column.Index]; 
end;

procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
 with ListView1.Canvas.Brush do
  if Item.Index mod 2 = 0 then Color := clYellow;
end;

procedure TForm1.ListView2CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
 with ListView2.Canvas.Brush do
  if Item.Index mod 2 = 0 then Color := clYellow;
end;

end.

(*

 - Make sort work in both grids
 - add mark to sorted colmun
 - autosize columns to fit
 - when form resize autoresize all controls to fit
 - make changing folder work
 - make alt-f1 and alt-f2 work
 - make texts displayed on top and bottom work
 - update bottom text on selected items change
 - make ins select items
 - make * reverse selection
 - make disk drives work
 - make go back/forward buttons work (follow paths visited not folder level)
 - make commandline work
 - make quick search
 - highlight select views caption bar
 - make volum label change
 - add available menus
 - show file properties
 - edit file(s) attributes
 - be able to view report,sumary
 - have treeview window
 - refresh work
 - internal viewer / editor can be set to external
 - make enter key work when pressed on file
 - show content of zips in listview
 - copy, move, delete, shift delete, make folder, rename functions
 - create 3rd vertical window for ftp
 - special folders icons trashbin, shared folders, etc...
 - make viewed drives button pressed down
 - extended select with +,-
 - search file/content
 - syncronize folders
 - directory hotlist
 - make both sides resize to same column widths when resized with mouse
 - quick view panel
 -

*)

//http://www.afsoftware.it/delphi_tips.htm#SpecialFolder
//http://homepages.borland.com/efg2lab/Library/Delphi/IO/Directories.htm
//http://www.lawrenz.com/coolform/coding.htm
//http://www.experts-exchange.com/Programming/Programming_Languages/Delphi/Q_20793241.html
//http://www.swissdelphicenter.ch/torry/vcl.php
//http://www.swissdelphicenter.ch/torry/showcode.php?id=586
//http://www.swissdelphicenter.ch/torry/showcode.php?id=947
