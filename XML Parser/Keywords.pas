unit Keywords;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm2 = class(TForm)
    GroupBox1: TGroupBox;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label2: TLabel;
    StatusBar1: TStatusBar;
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

const
  COLOR_NUM = 15;
  ColorConst: array [0..COLOR_NUM] of TColor = (clBlack,
    clMaroon, clGreen, clOlive, clNavy,
    clPurple, clTeal, clGray, clSilver, clRed,
    clLime, clYellow, clBlue, clFuchsia,
    clAqua, clWhite);
  ColorNames: array [0..COLOR_NUM] of string = ('Black',
    'Maroon', 'Green', 'Olive', 'Navy',
    'Purple', 'Teal', 'Gray', 'Silver', 'Red',
    'Lime', 'Yellow', 'Blue', 'Fuchsia',
    'Aqua', 'White');

implementation

uses Unit1;

{$R *.dfm}
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
  C_Path := ExtractFilePath(Application.ExeName) + 'Data\keywords.ini';
  ARE.SelectAll;

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

procedure TForm2.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with (Control as TComboBox).Canvas do
  begin
    FillRect(Rect);
    TextOut(30, Rect.Top,
      ComboBox1.Items[Index]);
    Pen.Color   := clBlack;
    Brush.Color := ColorConst[Index];
    Rectangle(Rect.Left + 2, Rect.Top + 2, 24,
      Rect.Top + 15);
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := Low(ColorNames) to High(ColorNames) do
    ComboBox1.Items.Add(ColorNames[i]);

  Memo1.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Data\Keywords.ini');
  StatusBar1.Panels[1].Text := IntToStr(Memo1.Lines.Count);
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  SetWindowPos(Handle, HWND_TOPMOST, Left,Top, Width,Height,
             SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  Beep;
  if MessageBox(Handle,'Do you really want to save the list? : ','Confirm',MB_YESNO) = IDYES then
    BEGIN
      Memo1.Lines.SaveToFile(ExtractFilePath(Application.ExeName) +
                                        'Data\Keywords.ini');
    END;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.Memo1Change(Sender: TObject);
begin
  StatusBar1.Panels[1].Text := IntToStr(Memo1.Lines.Count);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  HightLight_Syntax(Form1.RichEdit1);
end;

end.
