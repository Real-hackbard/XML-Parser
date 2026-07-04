unit Unit1;

interface

uses
  Windows, Forms, Dialogs, ComCtrls, StdCtrls, ImgList, Controls, Messages,
  Variants, Graphics, SysUtils, Classes, Menus, ToolWin, ExtCtrls, XMLParser,
  XMLINIFile, XPMan, Printers, IniFiles, SHDocVw, MSHTML, ShellApi, Math;

type
  TForm1 = class(TForm)
    imgTree: TImageList;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    imgMenu: TImageList;
    Open1: TMenuItem;
    Save1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    TreeView1: TTreeView;
    StatusBar1: TStatusBar;
    PopupMenu1: TPopupMenu;
    S1: TMenuItem;
    C1: TMenuItem;
    P1: TMenuItem;
    C2: TMenuItem;
    N2: TMenuItem;
    C3: TMenuItem;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    FontDialog1: TFontDialog;
    SaveDialog1: TSaveDialog;
    N3: TMenuItem;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    Panel1: TPanel;
    RichEdit1: TRichEdit;
    Panel2: TPanel;
    Label1: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit7: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    Button3: TButton;
    Button1: TButton;
    Splitter1: TSplitter;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    E1: TMenuItem;
    V1: TMenuItem;
    O1: TMenuItem;
    S2: TMenuItem;
    N4: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Cut1: TMenuItem;
    N5: TMenuItem;
    Clear1: TMenuItem;
    F1: TMenuItem;
    T1: TMenuItem;
    H1: TMenuItem;
    N6: TMenuItem;
    A1: TMenuItem;
    P2: TMenuItem;
    N7: TMenuItem;
    S4: TMenuItem;
    T2: TMenuItem;
    S5: TMenuItem;
    K1: TMenuItem;
    N8: TMenuItem;
    PopupMenu2: TPopupMenu;
    E2: TMenuItem;
    C4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure P1Click(Sender: TObject);
    procedure C2Click(Sender: TObject);
    procedure C3Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure ToolButton15Click(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure T1Click(Sender: TObject);
    procedure H1Click(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure S4Click(Sender: TObject);
    procedure T2Click(Sender: TObject);
    procedure RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure S5Click(Sender: TObject);
    procedure K1Click(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure C4Click(Sender: TObject);
    procedure TreeView1CustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateFunctionsInfos;
    procedure CreateDynamicRichEdit;
    procedure DropFiles(var msg: TMessage ); message WM_DROPFILES;
  public
    { Public declarations }
  	XMLDoc: TXMLDoc;
    XMLNode: TXMLNode;
    procedure WriteOptions;
    procedure ReadOptions;
  end;

var
  Form1: TForm1;
  TIF : TIniFile;

Resourcestring
	sFiles = 'File XML (*.xml)|*.xml|File XSL (*.xsl)|*.xsl';

implementation

uses
  Keywords;

{$R *.dfm}
function MainDir : string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

procedure TForm1.WriteOptions;    // ################### Options Write
var
  OPT :string;
begin
   OPT := 'Options';

   if not DirectoryExists(MainDir + 'Data\Options\')
   then ForceDirectories(MainDir + 'Data\Options\');

   TIF := TIniFile.Create(MainDir + 'Data\Options\Options.ini');
   with TIF do
   begin
    WriteBool(OPT,'Functions',F1.Checked);
    WriteBool(OPT,'Tree',T1.Checked);
    WriteBool(OPT,'ToolBar',T2.Checked);
    WriteBool(OPT,'HighlightCode',H1.Checked);
    WriteInteger(OPT,'NonColorCode', Form2.ComboBox1.ItemIndex);
    WriteInteger(OPT,'LineFeed', ComboBox1.ItemIndex);
    WriteInteger(OPT,'Indentation', ComboBox2.ItemIndex);
    Free;
   end;
end;

procedure TForm1.ReadOptions;    // ################### Options Read
var
  OPT:string;
begin
  OPT := 'Options';
  if FileExists(MainDir + 'Data\Options\Options.ini') then
  begin
    TIF:=TIniFile.Create(MainDir + 'Data\Options\Options.ini');
    with TIF do
    begin
      F1.Checked:=ReadBool(OPT,'Functions',F1.Checked);
      T1.Checked:=ReadBool(OPT,'Tree',T1.Checked);
      T2.Checked:=ReadBool(OPT,'ToolBar',T2.Checked);
      H1.Checked:=ReadBool(OPT,'HighlightCode',H1.Checked);
      Form2.ComboBox1.ItemIndex:=ReadInteger(OPT,'NonColorCode',Form2.ComboBox1.ItemIndex);
      ComboBox1.ItemIndex:=ReadInteger(OPT,'LineFeed',ComboBox1.ItemIndex);
      ComboBox2.ItemIndex:=ReadInteger(OPT,'Indentation',ComboBox2.ItemIndex);
      Free;
    end;
  end;
end;

procedure TForm1.DropFiles(var msg: TMessage );
var
  i, count  : integer;
  dropFileName : array [0..511] of Char;
  MAXFILENAME: integer;
  s : string;
begin
  MAXFILENAME := 511;
  // we check the query for amount of files received 
  count := DragQueryFile(msg.WParam, $FFFFFFFF, dropFileName, MAXFILENAME);
  // we process them all 
  for i := 0 to count - 1 do 
  begin 
    DragQueryFile(msg.WParam, i, dropFileName, MAXFILENAME); 
     
    // dropFileName now has the current filename of dropped object.
    // ** 
    // do something :D 
    // **
    RichEdit1.Lines.LoadFromFile(dropFileName);
    Edit1.Text := dropFileName;
  end;
  // release memory used
  DragFinish(msg.WParam); 
end;

// Estimation of an approximate string search
function LevenshteinDistance(const S, T: string): Integer;
var
  d: array of array of Integer;
  i, j, cost: Integer;
begin
  SetLength(d, Length(S) + 1, Length(T) + 1);
  for i := 0 to Length(S) do d[i, 0] := i;
  for j := 0 to Length(T) do d[0, j] := j;

  for i := 1 to Length(S) do
    for j := 1 to Length(T) do
    begin
      if S[i] = T[j] then cost := 0 else cost := 1;
      d[i, j] := Min(Min(d[i - 1, j] + 1, d[i, j - 1] + 1), d[i - 1, j - 1] + cost);
    end;
  Result := d[Length(S), Length(T)];
end;

// Generate the HTML code and copy it to the clipboard.
function ClipboardToHTML(AParent: TWinControl): WideString;
var
  wb: TWebBrowser;

  function WaitDocumentReady: Boolean;
  var
    StartTime: DWORD;
  begin
    StartTime := GetTickCount;
    while wb.ReadyState <> READYSTATE_COMPLETE do
    begin
      Application.HandleMessage;
      if GetTickCount >= StartTime + 2000 then // time-out of max 2 sec
      begin
        Result := False; // time-out
        Exit;
      end;
    end;
    Result := True;
  end;
begin
  Result := '';
  // Creating a dynamic WebBrowser
  wb := TWebBrowser.Create(nil);
  try
    // completely silent (suppressing script errors and dialogue boxes)
    wb.Silent := True;
    wb.Width := 0;
    wb.Height := 0;
    // hide WebBroser
    wb.Visible := False;
    TWinControl(wb).Parent := AParent;
    { immediate creation of an underlying Windows handle object, even if
      the visual component is located on an invisible form or tab. }
    wb.HandleNeeded;
    // to verify whether the browser's Windows window exists
    if wb.HandleAllocated then
    begin
      wb.Navigate('about:blank');
      (wb.Document as IHTMLDocument2).designMode := 'on';
      if WaitDocumentReady then
      begin
        (wb.Document as IHTMLDocument2).execCommand('Paste', False, 0);
        Result := (wb.Document as IHTMLDocument2).body.innerHTML;
      end;
    end;
  finally
    // Release the web browser free.
    wb.Free;
  end;
end;

procedure TForm1.CreateDynamicRichEdit;
var
  MyRichEdit: TRichEdit;
begin
  // 1. Instantiating the component and assigning the owner (form)
  MyRichEdit := TRichEdit.Create(Self);
  MyRichEdit.MaxLength := $7FFFFFF0;
  try
    // 2. Place on the form (parent)
    MyRichEdit.Parent := Self;

    // 3. Set position and size
    MyRichEdit.Left := 0;
    MyRichEdit.Top := 0;
    MyRichEdit.Width := 1;
    MyRichEdit.Height := 1;

    // 4. Hide RichEdit
    MyRichEdit.Visible := false;

    // 5. Example of text assignment
    MyRichEdit.Lines.Add(ClipboardToHTML(Self));

    // 6. Enable scrollbars (optional but recommended)
    MyRichEdit.ScrollBars := ssBoth;

    // 7. Ignore any RTF markup and treat the content purely as unformatted text.
    MyRichEdit.PlainText :=  true;

    // 8. Save Data
    MyRichEdit.Lines.SaveToFile(SaveDialog1.FileName + '.html');
  finally
    // Ensure that memory is released in the event of errors.
    MyRichEdit.Free;
  end;
end;

// Locate a specific string within the entire text of a RichEdit control and highlight it.
procedure RE_SearchForText_AndSelect(RichEdit: TRichEdit; SearchText: string);
var
  StartPos, Position, RemainingLength,
  WordCount, TextSize, SearchSize: Integer;
begin
  if SearchText = '' then Exit;
  
  with RichEdit do
  begin
    Lines.BeginUpdate;

    // reset colors...
    SelStart:=0;
    SelLength:=Length(RichEdit.Text) - 1;
    SelAttributes.Color:=$000000;

    WordCount := 0;
    StartPos := 0;
    TextSize := Length(RichEdit.Text);
    SearchSize := Length(SearchText);
    RemainingLength := TextSize;
    Position := FindText(SearchText, StartPos, RemainingLength, []);

    if Position <> -1 then
    repeat
      // selects the word and changes color
      SelStart:=Position;
      SelLength:=SearchSize;
      SelAttributes.Color:=$0000FF;
      inc(WordCount);

      // changes startpos to after the current word
      StartPos:=Position + SearchSize;
      // Remaining Text to search for
      RemainingLength:=TextSize - StartPos;
      // find again...
      Position:=FindText(SearchText, StartPos, RemainingLength, []);
    until Position = -1;

    SelLength:=0; // reset selection...
    Lines.EndUpdate;
  end;
  // count finded strings
  Form1.StatusBar1.Panels[7].Text := SearchText + ' found ' + IntToStr(WordCount) + ' times.';
end;

procedure HightLight_Syntax(ARE : TRichEdit);
//{$REGION 'Sub-functions'}
// Sub-function visible only within HighLight_Syntax and having access to ARE.
procedure HighLight_Others(AStart, AEnd : String; AColor : TColor);
var
  iNext, iPos, iPos_End : Integer;
begin
  iNext := 0;
  iPos := ARE.FindText(AStart, iNext, Length(ARE.Text), [stMatchCase]);
  // FindText returns -1 if it does not find AStart in the RichEdit.
  while iPos <> -1 do
  begin
    // We narrow down the text to be scanned so as not to get stuck
    // in a loop on the same word.
    iNext := iPos + Length(AStart);
    // The starting position of the RichEdit is initialized.
    ARE.SelStart := iPos;
    // We are looking for the position of the second character
    // that should stop the coloring.
    iPos_End := ARE.FindText(AEnd, iNext, Length(ARE.Text), [stMatchCase]);
    if iPos_End = -1 then
      // When it involves the start of a string ('), the coloring continues
      // to the end of the line.
      if AStart = '''' then
        iPos_End := ARE.FindText(#13, iNext, Length(ARE.Text), [stMatchCase])
      else
        // By default, if the closing character is missing, coloring ends
        // at the end of the text.
        iPos_End := Length(ARE.Text);

        // You define the extent to which the text should be colored.
    ARE.SelLength := (iPos_End  - iPos) + Length(AEnd);
    // And we add color.
    ARE.SelAttributes.Color := AColor;
    if AStart = '''' then
      // When dealing with the opening of a chain, the position of the
      // next chain must begin after the closing of the last chain.
      iPos := ARE.FindText('''', iNext + iPos_End, Length(ARE.Text), [stMatchCase])
    else
      iPos := ARE.FindText(AStart, iNext, Length(ARE.Text), [stMatchCase]);
  end;
end;
//{$ENDREGION}

var
  SL_Key_Word : TStringList;
  i, iPos, iNext, iPos_Symb_Start, iPos_Symb_End, iTest : Integer;
  C_Path : string;
begin
  // Read the keywords that should not be highlighted.
  C_Path := ExtractFilePath(Application.ExeName) + 'Data\keywords.ini';
  ARE.SelectAll;

  // Color selection for the text that is not highlighted.
  case Form2.ComboBox1.ItemIndex of
    0 : ARE.SelAttributes.Color := clBlack;
    1 : ARE.SelAttributes.Color := clMaroon;
    2 : ARE.SelAttributes.Color := clGreen;
    3 : ARE.SelAttributes.Color := clOlive;
    4 : ARE.SelAttributes.Color := clNavy;
    5 : ARE.SelAttributes.Color := clPurple;
    6 : ARE.SelAttributes.Color := clTeal;
    7 : ARE.SelAttributes.Color := clGray;
    8 : ARE.SelAttributes.Color := clSilver;
    9 : ARE.SelAttributes.Color := clRed;
    10 : ARE.SelAttributes.Color := clLime;
    11 : ARE.SelAttributes.Color := clYellow;
    12 : ARE.SelAttributes.Color := clBlue;
    13 : ARE.SelAttributes.Color := clFuchsia;
    14 : ARE.SelAttributes.Color := clAqua;
    15 : ARE.SelAttributes.Color := clWhite;
  end;

  SL_Key_Word := TStringList.Create;
  try
    SL_Key_Word.LoadFromFile(C_Path);
    i := 0;
    while i < SL_Key_Word.Count do
    begin
      iNext := 0;
      // Only WHOLE words matching a keyword are sought.
      iPos := ARE.FindText(SL_Key_Word[i], iNext, Length(ARE.Text), [stWholeWord]);
      while iPos <> -1 do
      begin
        // To prevent words preceded by "_" from being colored as well
        // (FindText doesn't handle that)
        iPos_Symb_Start := ARE.FindText('_', iPos - 1, 1, [stMatchCase]);
        // If the position is 0, it means there is necessarily no "_"
        // before it. This prevents iPos - iPos_Symb_Start from equaling 1.
        if iPos = 0 then
          iTest := 0
        else
          iTest := iPos - iPos_Symb_Start;

        // To prevent words followed by "_" from being colored as well
        iPos_Symb_End := ARE.FindText('_', iPos, Length(SL_Key_Word[i]) + 1,
                                                [stMatchCase]);
        // If the word is not surrounded by "_"
        if (iTest <> 1) and (((Length(SL_Key_Word[i]) + iPos) - iPos_Symb_End) + 1 <> 1) then
        begin
          // The next search starts from the end of the last keyword found.
          iNext := iPos + Length(SL_Key_Word[i]);
          ARE.SelStart := iPos;
          ARE.SelLength := Length(SL_Key_Word[i]);
          ARE.SelAttributes.Color := clNavy;
        end
        else
          // Here, it is not a keyword.
          iNext := iPos + Length(SL_Key_Word[i]) - 1;

        // Searching for the next keyword
        iPos := ARE.FindText(SL_Key_Word[i], iNext, Length(ARE.Text), [stWholeWord]);
      end;
      inc(i);
    end;

    { If values are changed, added, or removed here, the same change must
      be applied in the
        "Keywords.pas" unit.
      Otherwise, color errors will occur. }
    HighLight_Others('<root>', #13, clRed);  //
    HighLight_Others('</root>', #13, clRed); //
    HighLight_Others('<body>', #13, $00d94fdb);  //
    HighLight_Others('</body>', #13, $00d94fdb); //
    HighLight_Others('<head>', #13, $005f912d);  //
    HighLight_Others('</head>', #13, $005f912d); //
    HighLight_Others('<?', '?>', clOlive);
    HighLight_Others('<?xml', '>', clTeal);  //
    HighLight_Others('http', '<', clNavy);   //
    HighLight_Others('<!--', '-->', clGray);
  finally
    SL_Key_Word.Free;
    Form1.RichEdit1.SelLength := 0;
  end;
end;

function GetIniFilename: string;
begin
	Result := Copy(Application.ExeName, 1, Length(Application.ExeName) - 3) + 'ini';
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  // Create scrollbars for the RichEdit component.
  ScrollBarA: array[0..3] of TScrollStyle = (ssBoth,ssHorizontal,ssNone,ssVertical);
begin
  Panel1.DoubleBuffered := true;
  Application.HintPause := 0;
  Application.HintHidePause := 50000;

  // Increase the capacity of the RichEdit component.
  RichEdit1.MaxLength := $7FFFFFF0;

  // Make the scrollbars visible.
  RichEdit1.ScrollBars := ScrollBarA[0];

  // correctly control automatic line breaks
  RichEdit1.WordWrap := False;

  // Create the parser for the XML data.
	XMLDoc := TXMLDoc.Create;

  // Enable the drag-and-drop function for the RichEdit.
  DragAcceptFiles(Handle, True);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // end the parser
	XMLDoc.Free;
end;

// To insert a line break (Line Feed, LF) into an XML document
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
	if ComboBox1.ItemIndex = 0 then
    	XMLDoc.LineFeed := flfLF
    else if ComboBox1.ItemIndex = 1 then
    	XMLDoc.LineFeed := flfCRLF
    else if ComboBox1.ItemIndex = 2 then
    	XMLDoc.LineFeed := flfCR
    else
    	XMLDoc.LineFeed := flfNone;
end;

{ XML processors enforce the standard US/English locale format, meaning
  they strictly require a period (.) as the decimal separator. If your
  application relies on a comma (,) due to regional settings (e.g., in Germany),
  XML conversion functions and database bindings will throw conversion
  exceptions or truncate decimals. }
procedure TForm1.ComboBox2Change(Sender: TObject);
begin
	if ComboBox2.ItemIndex = 0 then
    	XMLDoc.Separator := fsTab
    else if ComboBox2.ItemIndex = 1 then
    	XMLDoc.Separator := fsSpace
    else
    	XMLDoc.Separator := fsNone;
end;

function TagTypeToString(Value: TTagType): string;
begin
	Case Value of
    	ttComment: Result := 'ttComment';
        ttPI: Result := 'ttPI';
        ttCDATA: Result := 'ttCDATA';
        ttText: Result := 'ttText';
    else
    	Result := 'ttElement';
    end;
end;

// parse
procedure TForm1.ToolButton5Click(Sender: TObject);

procedure LoadItem(XMLNode: TXMLNode; Parent: TTreeNode);
var
	i: integer;
    Node, AttrNode: TTreeNode;
begin
	Node := TreeView1.Items.AddChild(Parent, XMLNode.Name);
    Node.Data := XMLNode;
    if XMLNode.HasAttributes then
    begin
    	for i := 0 to XMLNode.Attributes.Count - 1 do
        begin
        	AttrNode := TreeView1.Items.AddChild(Node, XMLNode.Attributes[i].Name + ' = "' +
        		XMLNode.Attributes[i].Value + '"');
            AttrNode.ImageIndex := 4;
            AttrNode.SelectedIndex := 4;
        end;
    end;
	Case XMLNode.TagType of
        ttComment:
        	begin
            	Node.Text := '"' + Node.Text + '"';
                Node.ImageIndex := 1;
                Node.SelectedIndex := 1;
            end;
        ttCDATA:
        	begin
            	Node.ImageIndex := 2;
                Node.SelectedIndex := 2;
            end;
        ttPI:
        	begin
            	Node.Text := Node.Text + ' (' + XMLNode.Value + ')';
                Node.ImageIndex := 5;
                Node.SelectedIndex := 5;
            end;
        ttText:
        	begin
            	Node.Text := '"' + Node.Text + '"';
                Node.ImageIndex := 3;
                Node.SelectedIndex := 3;
            end;
        else
        begin
        	if XMLNode.Count > 0 then
            begin
            	for i := 0 to XMLNode.Count - 1 do
                begin
                	LoadItem(XMLNode.Item[i], Node);
                end;
            end;
        end;
    end;
end;

var
    StartTime, EndTime: Cardinal;
    i: integer;
    Parsed: boolean;
begin
  if RichEdit1.Text = '' then
  begin
    Beep;
    MessageDlg('Not Document Data to Parse!',mtInformation, [mbOK], 0);
    Exit;
  end;

  if not FileExists(Edit1.Text) then
  begin
    RichEdit1.PlainText := true;
    RichEdit1.Lines.SaveToFile(MainDir + 'Data\Backup\_xml.xml');
    Edit1.Text := MainDir + 'Data\Backup\_xml.xml';
  end;

	Screen.Cursor := crHourglass;
  Parsed := true;
  StartTime := GetTickCount;
	try
		XMLDoc.LoadFromFile(Edit1.Text);
    except
    	On E: EXMLException do
        begin
          Parsed := false;
            MessageBox(Application.Handle,
              PChar('This is not XML data; check the content,' + #13 + #10 + E.Message + #13 + #10 + 'Line: ' + IntToStr(XMLDoc.LastLine)),
                PChar(Application.Title), MB_OK + MB_ICONERROR);
          Screen.Cursor := crDefault;
          Exit;
        end;
    end;

    EndTime := GetTickCount;
    Edit1.Text := XMLDoc.Filename;
    StatusBar1.Panels[5].Text := IntToStr(EndTime - StartTime) + ' (ms)';
    TreeView1.Items.BeginUpdate;
    TreeView1.Items.Clear;
    Button1.Enabled := false;
    Button2.Enabled := false;
    Button3.Enabled := false;
    Button4.Enabled := false;
    Button5.Enabled := false;
    if Parsed then
    begin
    	if XMLDoc.Items.Count > 0 then
    	begin
    		for i := 0 to XMLDoc.Items.Count - 1 do
        		LoadItem(XMLDoc.Items[i], nil);
        	TreeView1.Items.GetFirstNode.Expand(false);
    	end;
    	RichEdit1.Lines.Text := XMLDoc.Source;
      Edit2.Text := XMLDoc.Declaration.Version;
      Edit3.Text := XMLDoc.Declaration.Encoding;
      Edit4.Text := XMLDoc.Declaration.Standalone;
      Button1.Enabled := XMLDoc.Root <> nil;
    end
    else
    begin
    	Edit2.Text := '';
      Edit3.Text := '';
      Edit4.Text := '';
    end;
    TreeView1.Items.EndUpdate;
    if H1.Checked = true then HightLight_Syntax(RichEdit1);
    Button1.Click;
    Screen.Cursor := crDefault;
end;

procedure TForm1.UpdateFunctionsInfos;
begin
    Edit5.Text := XMLNode.Name;
    Edit6.Text := XMLNode.Value;
    Edit7.Text := TagTypeToString(XMLNode.TagType);
    Button2.Enabled := XMLNode.PreviousSibling <> nil;
    Button3.Enabled := XMLNode.NextSibling <> nil;
    Button4.Enabled := XMLNode.HasChildren;
    Button5.Enabled := XMLNode.Parent <> nil;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
	XMLNode := XMLDoc.Root;
    UpdateFunctionsInfos;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
	XMLNode := XMLNode.PreviousSibling;
    UpdateFunctionsInfos;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
	XMLNode := XMLNode.NextSibling;
    UpdateFunctionsInfos;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
	XMLNode := XMLNode.Item[0];
    UpdateFunctionsInfos;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
	XMLNode := XMLNode.Parent;
    UpdateFunctionsInfos;
end;

procedure TForm1.S1Click(Sender: TObject);
begin
  RichEdit1.SelectAll;
end;

procedure TForm1.C1Click(Sender: TObject);
begin
  RichEdit1.Perform(WM_COPY,0,0);
end;

procedure TForm1.P1Click(Sender: TObject);
begin
  RichEdit1.PasteFromClipboard;
end;

procedure TForm1.C2Click(Sender: TObject);
begin
  RichEdit1.CutToClipboard;
end;

procedure TForm1.C3Click(Sender: TObject);
begin
  RichEdit1.Clear;
  TreeView1.Items.Clear;
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
begin
  C3.Click;
  StatusBar1.Panels[1].Text := '0';
  StatusBar1.Panels[3].Text := 'X-0' + ' ' + 'Y-0';
  StatusBar1.Panels[5].Text := '0 (ms)';
  StatusBar1.Panels[7].Text := '-';
  Edit1.Clear;
end;

// reload xml data
procedure TForm1.ToolButton7Click(Sender: TObject);
begin
  RichEdit1.Lines.LoadFromFile(Edit1.Text);
  if H1.Checked = true then HightLight_Syntax(RichEdit1);
end;

// select font
procedure TForm1.ToolButton9Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    RichEdit1.SelectAll;
    Richedit1.SelAttributes.Name := FontDialog1.Font.Name;
    Richedit1.SelAttributes.Size := FontDialog1.Font.Size;
    Richedit1.SelAttributes.Style := FontDialog1.Font.Style;
  end;
end;

procedure TForm1.ToolButton8Click(Sender: TObject);
begin
  C2.Click;
end;

procedure TForm1.ToolButton10Click(Sender: TObject);
begin
  C1.Click;
end;

procedure TForm1.ToolButton11Click(Sender: TObject);
begin
  P1.Click;
end;

procedure TForm1.ToolButton13Click(Sender: TObject);
begin
  RichEdit1.SelectAll;
  RichEdit1.Paragraph.Alignment := taLeftJustify;
end;

procedure TForm1.ToolButton14Click(Sender: TObject);
begin
  RichEdit1.SelectAll;
  RichEdit1.Paragraph.Alignment := taCenter;
end;

procedure TForm1.ToolButton15Click(Sender: TObject);
begin
  RichEdit1.SelectAll;
  RichEdit1.Paragraph.Alignment := taRightJustify;
end;

procedure TForm1.S2Click(Sender: TObject);
begin
  RichEdit1.SetFocus;
  S1.Click;
end;

procedure TForm1.F1Click(Sender: TObject);
begin
  Panel2.Visible := F1.Checked;
end;

procedure TForm1.T1Click(Sender: TObject);
begin
  if T1.Checked = true then
  begin
    Splitter1.Align := alBottom;
    Panel1.Align := alTop;
    Panel1.Height := 315;
    Splitter1.Visible := true;
    TreeView1.Visible := true;
    Splitter1.Align := alTop;
    RichEdit1.Repaint;
    RichEdit1.Update;
  end else begin
    TreeView1.Visible := false;
    Panel1.Align := alClient;
    Splitter1.Visible := false;
  end;
end;

procedure TForm1.H1Click(Sender: TObject);
begin
  if H1.Checked = true then
  begin
    HightLight_Syntax(RichEdit1);
  end else begin
    RichEdit1.SelectAll;
    Richedit1.SelAttributes.Color := clBlack;
    RichEdit1.Update;
  end;
end;

procedure TForm1.A1Click(Sender: TObject);
begin
  MessageDlg('XML Parser v1.0' +chr(10)+
             'Copyright © 2026' +chr(10)+
             'github.com | Release',mtInformation, [mbOK], 0);
end;

// printing xml data
procedure TForm1.P2Click(Sender: TObject);
var
  X, Y: Integer;
  rect : TRect;
begin
  // Determine the resolution of the default printer
  X := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  Y := GetDeviceCaps(Printer.Handle, LOGPIXELSY);

  with rect do
  begin
    Left   := X;           // 1-inch left margin
    Top    := 3 * Y div 2; // 1.5-inch top margin
    Right  := Printer.PageWidth - X;
    Bottom := Printer.PageHeight - Y;
  end;

  RichEdit1.PageRect := rect;
  RichEdit1.Print('Document with margins');
end;

procedure TForm1.RichEdit1Change(Sender: TObject);
begin
  if RichEdit1.Text <> '' then
  begin
    ToolButton2.Enabled := true;
    ToolButton7.Enabled := true;
    ToolButton8.Enabled := true;
    ToolButton10.Enabled := true;
    ToolButton11.Enabled := true;
    Save1.Enabled := true;
    P2.Enabled := true;
  end else begin
    ToolButton2.Enabled := false;
    ToolButton7.Enabled := false;
    ToolButton8.Enabled := false;
    ToolButton10.Enabled := false;
    ToolButton11.Enabled := false;
    Save1.Enabled := false;
    P2.Enabled := false;
  end;
  StatusBar1.Panels[1].Text := IntToStr(RichEdit1.Lines.Count);
  StatusBar1.Panels[3].Text := 'X-'+ IntToStr(RichEdit1.CaretPos.X) + ' ' +
                               'Y-'+ IntToStr(RichEdit1.CaretPos.Y);
end;

procedure TForm1.Close1Click(Sender: TObject);
begin
  Close();
end;

procedure TForm1.S4Click(Sender: TObject);
var
  str : string;
begin
  if RichEdit1.Text = '' then
  begin
    Beep;
    MessageDlg('Not Document Data found!',mtInformation, [mbOK], 0);
    Exit;
  end;

  // get searched string
  str := InputBox('Search string','Search :','type text');
  // search string in RichEdit
  RE_SearchForText_AndSelect(RichEdit1, str);
end;

procedure TForm1.T2Click(Sender: TObject);
begin
  if T2.Checked = true then
    ToolBar1.Visible := true
  else
    ToolBar1.Visible := false;
end;

procedure TForm1.RichEdit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[3].Text := 'X-'+ IntToStr(RichEdit1.CaretPos.X) + ' ' +
                               'Y-'+ IntToStr(RichEdit1.CaretPos.Y);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteOptions;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ReadOptions;

  F1.OnClick(sender);
  T1.OnClick(sender);
  T2.OnClick(sender);
end;

procedure TForm1.S5Click(Sender: TObject);
begin
  S4.Click;
end;

procedure TForm1.K1Click(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.E2Click(Sender: TObject);
begin
  TreeView1.Items.BeginUpdate;
  try
    TreeView1.FullExpand;
  finally
    TreeView1.Items.EndUpdate;
  end;
end;

procedure TForm1.C4Click(Sender: TObject);
begin
  TreeView1.Items.BeginUpdate;
  try
    TreeView1.FullCollapse;
  finally
    TreeView1.Items.EndUpdate;
  end;
end;

// Display the selected item in the TreeView in lime and bold.
procedure TForm1.TreeView1CustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node = Sender.Selected then
    with Sender.Canvas do
    begin
      Font.Color := clLime;
      Font.Style := [fsBold];
    end;
  DefaultDraw := True;
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  FullText, SearchTerm, CurrentWord: string;
  CharIndex, WordStart: Integer;
begin
  if RichEdit1.Text = '' then
  begin
    Beep;
    MessageDlg('Not Document Data found!',mtInformation, [mbOK], 0);
    Exit;
  end;

  if Assigned(Node) then
  begin
    // Check if the TreeView node exists as a string in the RichEdit.
    LevenshteinDistance(RichEdit1.Text, Node.Text);
  end;

  FullText := RichEdit1.Text;
  SearchTerm := Node.Text;

  CharIndex := 1;
  while CharIndex <= Length(FullText) do
  begin
    // Skip spaces and delimiters
    while (CharIndex <= Length(FullText)) and (FullText[CharIndex] <= ' ') do
      Inc(CharIndex);

    if CharIndex > Length(FullText) then Break;

    WordStart := CharIndex;
    // Extract word
    while (CharIndex <= Length(FullText)) and (FullText[CharIndex] > ' ') do
      Inc(CharIndex);

    CurrentWord := Copy(FullText, WordStart, CharIndex - WordStart);

    // Remove punctuation marks at the end of the word
    while (CurrentWord <> '') and (CurrentWord[Length(CurrentWord)] in ['.', ',', '!', '?', ';', ':']) do
      Delete(CurrentWord, Length(CurrentWord), 1);

    // Fault-tolerant comparison (e.g., a maximum of 2 discrepancies)
    if LevenshteinDistance(LowerCase(CurrentWord), LowerCase(SearchTerm)) <= 2 then
    begin
      // Select text in the RichEdit (Note: SelStart is 0-based)
      RichEdit1.SelStart := WordStart - 1;
      RichEdit1.SelLength := Length(CurrentWord);
      RichEdit1.SelAttributes.Color := clRed;
      RichEdit1.SelAttributes.Style := [fsBold];
      RichEdit1.Perform(EM_SCROLLCARET, 0, 0);
      RichEdit1.SetFocus;

      // search for the strings individually
      //if MessageDlg('Find next match?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      //  Exit;
    end;
  end;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
var
 	s: string;
begin
  // Load XML data
	if PromptForFilename(s, sFiles, '.XML', 'Open a file') then
    begin
    	Edit1.Text := s;
      RichEdit1.Lines.LoadFromFile(s);

      // Display RichEdit text in color
      if H1.Checked = true then HightLight_Syntax(RichEdit1);

      // count RichEdit lines
      StatusBar1.Panels[1].Text := IntToStr(RichEdit1.Lines.Count);
      TreeView1.Items.Clear;
    end;
end;

// save data to files format
procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    if SaveDialog1.FilterIndex = 1 then
    begin
	    XMLDoc.SaveToFile(SaveDialog1.Filename + '.xml');
    end;

    if SaveDialog1.FilterIndex = 2 then
    begin
	    XMLDoc.SaveToFile(SaveDialog1.Filename + '.xsl');
    end;

    if SaveDialog1.FilterIndex = 3 then
    begin
	    XMLDoc.SaveToFile(SaveDialog1.Filename + '.rtf');
    end;

    if SaveDialog1.FilterIndex = 4 then
    begin
	    XMLDoc.SaveToFile(SaveDialog1.Filename + '.doc');
    end;

    if SaveDialog1.FilterIndex = 5 then
    begin
	    XMLDoc.SaveToFile(SaveDialog1.Filename + '.ini');
    end;

    if SaveDialog1.FilterIndex = 6 then
    begin
	    XMLDoc.SaveToFile(SaveDialog1.Filename + '.txt');
    end;

    if SaveDialog1.FilterIndex = 7 then
    begin
      RichEdit1.SelectAll;
      RichEdit1.CopyToClipboard;
      CreateDynamicRichEdit;
    end;
  end;
end;

end.
