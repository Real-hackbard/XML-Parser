unit XMLParser;
interface
uses Classes, SysUtils;
const
  cLF = #$A;	
  cCR = #$D;	
  cTab = #$9;	
  cChar = [cTab, cLF, cCR, #$20..#$FF];
  cBaseChar = [#$41..#$5A, #$61..#$7A, #$C0..#$D6, #$D8..#$F6, #$F8..#$FF];
  cDigit = [#$30..#$39];
  cNameChar = cBaseChar + cDigit + ['.', '-', '_', ':'] + [#$B7];
  cNameStart = cBaseChar + ['_' , ':'];
  cWhiteSpace = [#$20, cTab, cCR, cLF];
  cCDStart = '<![CDATA[';
  cCDEnd = ']]>';
  cQuote = ['''', '"'];
type
  TTagType = (ttElement, ttComment, ttText, ttCDATA, ttPI);
  EXMLException = class(Exception);
  TXMLAttribute = class(TObject)
  private
  	FName: string;
    FValue: string;
  public
    Constructor Create(AName: string = ''; AValue: string = '');
  	property Name: string read FName write FName;		
    property Value: string read FValue write FValue;	
  end;
  TXMLAttributes = class(TList)
  protected
    function GetItem(Index: Integer): TXMLAttribute;
    procedure SetItem(Index: Integer; Value: TXMLAttribute);
  public
  	destructor Destroy; override;
  	procedure Clear; override;
    function Add(Value: TXMLAttribute): Integer;
    procedure Delete(Index: integer);
    procedure Insert(Index: Integer; Value: TXMLAttribute);
    property Item[Index: Integer]: TXMLAttribute read GetItem write SetItem; default;
  end;
  TXMLNode = class;
  TXMLDoc = class;
  TXMLNodes = class(TList)
  private
  	FOwner: TXMLNode;
    function GetItem(Index: Integer): TXMLNode;
  public
    property Item[Index: Integer]: TXMLNode read GetItem; default;
    property Owner: TXMLNode read FOwner;
  	constructor Create(AOwner: TXMLNode);
  	destructor Destroy; override;
    procedure Clear; override;
    procedure Delete(Index: Integer);
    procedure Insert(Index: Integer; Value: TXMLNode);
    function Add(Item: TXMLNode): integer;
  end;
  TXMLNode = class(TObject)
  private
	FAttributes: TXMLAttributes;
    FItems: TXMLNodes;
  	FName: string;
    FTagType: TTagType;
    FValue: string;
    FOwner: TXMLNodes;
    function GetCount: integer;
    function GetItem(Index: integer): TXMLNode;
    function GetIndex: integer;
    function GetParent: TXMLNode;
    procedure SetName(Value: string);
    procedure SetValue(Value: string);
  public
    property Attributes: TXMLAttributes read FAttributes write FAttributes;
    property Count: integer read GetCount;
    property Index: integer read GetIndex;
    property Item[Index: integer]: TXMLNode read GetItem; default;
  	property Name: string read FName write SetName;
    property Owner: TXMLNodes read FOwner;
    property Parent: TXMLNode read GetParent;
    property TagType: TTagType read FTagType;
    property Value: string read FValue write SetValue;
    constructor Create(TagType: TTagType = ttElement);
    destructor Destroy; override;
	procedure DeleteChildren;
    function AddChild(TagType: TTagType): TXMLNode;
    function HasAttributes: boolean;
    function HasChildren: boolean;
    function NextSibling: TXMLNode;
    function PreviousSibling: TXMLNode;
    function GetElementByName(Name: string): TXMLNode;
    function ForceElementByName(Name: string): TXMLNode;
  end;
  TXMLDeclaration = class(TObject)
  private
  	FVersion: string;
    FEncoding: string;
    FStandalone: string;
    procedure SetVersion(Value: string);
    procedure SetEncoding(Value: string);
    procedure SetStandalone(Value: string);
  public
  	property Version: string read FVersion write SetVersion;
    property Encoding: string read FEncoding write SetEncoding;
    property Standalone: string read FStandalone write SetStandalone;
    procedure Clear;
  end;
  TFormatLineFeed = (flfLF, flfCRLF, flfCR, flfNone);
  TFormatSeparator = (fsTab, fsSpace, fsNone);
  TXMLDoc = class(TObject)
  private
  	FFilename: TFilename;
    FDeclaration: TXMLDeclaration;
    FTags: TXMLNodes;
    FSrcLine: integer;
    FSource: string;
  	FLineFeed: TFormatLineFeed;
    FSeparator: TFormatSeparator;
    function GetSource: string;
    procedure SetSource(Value: string);
    function OutputNode(Node: TXMLNode; Level: integer; uLF, uInd: string;
    	UseLevel: boolean = true): string;
    function GetRoot: TXMLNode;
  protected
  	FBuffer: PChar;
    FBufferSize: integer;
    CurPos: PChar;
    procedure ParseAttributes(Parent: TXMLNode);
    procedure ParseDeclaration;
    procedure ParseComment(Parent: TXMLNode);
    procedure ParsePI(Parent: TXMLNode);
    procedure ParseDTD(Parent: TXMLNode);
    procedure ParseCDATA(Parent: TXMLNode);
    procedure ParseText(Parent: TXMLNode);
    procedure ParseElement(Parent: TXMLNode);
  	procedure Parse;
    procedure RaiseException(const Msg: string);
    procedure RaiseExceptionFmt(const Msg: string; const Args: array of const);
    procedure LoadBuffer;
  public
  	constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromFile(Filename: TFilename);
    procedure SaveToFile(Filename: TFilename);
  	property Declaration: TXMLDeclaration read FDeclaration write FDeclaration;
  	property Filename: TFilename read FFilename;
    property LastLine: integer read FSrcLine;
    property Items: TXMLNodes read FTags write FTags;
    property Source: string read GetSource write SetSource;
    property Root: TXMLNode read GetRoot;
  	property LineFeed: TFormatLineFeed read FLineFeed write FLineFeed;
    property Separator: TFormatSeparator read FSeparator write FSeparator;
  end;
type
	
	TCharSet = set of Char;

implementation

resourcestring
    sDeclWrong = 'The xml declaration must have ''version'' and ''encoding'' and/or ''standalone'' in this order.';
    sDeclVerUnknown = 'Unsupported XML version, must be ''1.0''.';
    sDeclEncWrong = 'Wrong XML encoding declaration.';
    sDeclSDWrong = 'Wrong XML standalone declaration, must be ''yes'' or ''no''.';
    sDeclPos = 'The xml declaration must be on the first line and first character.';
    sPITargetMissing = 'Processing Instruction target name missing.';
    sPITargetXML = 'Processing Instruction target name is ''xml''.';
    sPITargetWrong = 'Processing Instruction target name is not valid.';
    sCommentWrong = 'Illegal sequence ''--'' in comment.';
    sCDATAWrong = 'Illegal sequence ''' + cCDEnd + ''' in CDATA.';
    sRefMissingEnd = 'Missing reference end '';''.';
    sRefWrong = 'Reference name is not valid.';
    sAttrEqual = 'Missing equal sign for an attribute.';
	sAttrQuote = 'Missing quote for an attribute''s value.';
    sAttrDouble = 'Attribute %s already used.';
    sAttrEmpty = 'Attribute''s name is empty.';
	sMainEmpty = 'The main xml document is empty.';
    sMissingEndTag = 'End of tag ''%s'' missing (%s).';
    sMissingName = 'Element name missing.';
    sWrongName = 'Invalid element name.';
function ScanStr(const FindStr: string; const From: PChar): PChar; overload;
begin
	Result := From;
	while (Result^ <> #0) and
    	(StrLComp(Result, PChar(FindStr), Length(FindStr)) <> 0) do
        Inc(Result);
end;
function ScanStr(const FindStr: string; const From: PChar;
	var Lines: integer): PChar; overload;
begin
	Result := From;
	while (Result^ <> #0) and
    	(StrLComp(Result, PChar(FindStr), Length(FindStr)) <> 0) do
    begin
    	if Result^ = cLF then
        	Inc(Lines);
        Inc(Result);
    end;
end;
procedure SkipXMLBlanks(var From: PChar); overload;
begin
	while (From^ in cWhiteSpace) and (From^ <> #0) do
    begin
        Inc(From);
    end;
end;
procedure SkipXMLBlanks(var From: PChar; var Lines: integer); overload;
begin
	while (From^ in cWhiteSpace) and (From^ <> #0) do
    begin
    	if From^ = cLF then
        	Inc(Lines);
        Inc(From);
    end;
end;
function IsXMLEq(var From: PChar): boolean; overload;
begin
	
	SkipXMLBlanks(From);
    if From^ = '=' then
    begin
    	Inc(From);
    	Result := true;
        SkipXMLBlanks(From);
    end
    else
    	Result := false;
end;
function IsXMLEq(var From: PChar; var Lines: integer): boolean; overload;
begin
	
	SkipXMLBlanks(From, Lines);
    if From^ = '=' then
    begin
    	Inc(From);
    	Result := true;
        SkipXMLBlanks(From, Lines);
    end
    else
    	Result := false;
end;
function IsXMLQuote(var From: PChar; var c: Char): boolean;
begin
	if From^ in cQuote then
    begin
    	c := From^;
        Inc(From);
        Result := true;
    end
    else
    	Result := false;
end;
function GetXMLName(var From: PChar; var ResStr: string): integer;
begin
	
	ResStr := '';
	Result := 0;
    if From^ in cNameStart then
    begin
    	
    	ResStr := ResStr + From^;
        Inc(From);
        while From^ in cNameChar do
        begin
        	ResStr := ResStr + From^;
            Inc(From);
        end;
    end
    else
    	Result := 1;
end;
function IsXMLName(s: string): boolean;
var
	i: integer;
begin
	
    Result := false;
	i := 1;
    if s[i] in cNameStart then
    begin
    	Inc(i);
        while (i <= Length(s)) and (s[i] in cNameChar) do
        	Inc(i);
        if i > Length(s) then
        	Result := true;
    end;
end;
constructor TXMLAttribute.Create(AName: string = ''; AValue : string = '');
begin
	inherited Create;
    Name := AName;
    Value := AValue;
end;
destructor TXMLAttributes.Destroy;
begin
	Clear;
    inherited Destroy;
end;
procedure TXMLAttributes.Clear;
begin
	while Self.Count > 0 do
    	Delete(Self.Count - 1);
    inherited Clear;
end;
function TXMLAttributes.GetItem(Index: Integer): TXMLAttribute;
begin
	Result := TXMLAttribute(inherited Items[Index]);
end;
procedure TXMLAttributes.SetItem(Index: Integer; Value: TXMLAttribute);
begin
	inherited Items[Index] := Value;
end;
function TXMLAttributes.Add(Value: TXMLAttribute): Integer;
var
	IsUsed: boolean;
    i: integer;
begin
	IsUsed := false;
	
    if Value.FName <> '' then
    begin
    	
        if Self.Count > 0 then
        begin
        	i := 0;
            while (i < Self.Count) and not IsUsed do
            begin
            	if Self.GetItem(i).FName = Value.FName then
                	IsUsed := true;
                Inc(i);
            end;
        end;
		if not IsUsed then
        	Result := inherited Add(Value)
        else
        	Raise EXMLException.CreateFmt(sAttrDouble, [Value.FName]);
    end 
    else
    	Raise EXMLException.Create(sAttrEmpty);
end;
procedure TXMLAttributes.Insert(Index: Integer; Value: TXMLAttribute);
begin
	inherited Insert(Index, Value);
end;
procedure TXMLAttributes.Delete(Index: integer);
begin
	if (Index > -1) and (Index < Count) then
    begin
    	TXMLAttribute(Items[Index]).Free;
        inherited Delete(Index);
    end;
end;
constructor TXMLNodes.Create(AOwner: TXMLNode);
begin
	inherited Create;
    FOwner := AOwner;
end;
destructor TXMLNodes.Destroy;
begin
	FOwner := nil;
	Clear;
    inherited Destroy;
end;
procedure TXMLNodes.Clear;
begin
	while Self.Count > 0 do
    	Delete(Self.Count - 1);
    inherited Clear;
end;
function TXMLNodes.GetItem(Index: Integer): TXMLNode;
begin
  Result := TXMLNode(inherited Items[Index]);
end;
function TXMLNodes.Add(Item: TXMLNode): integer;
begin
	Item.FOwner := Self;
	Result := inherited Add(Item);
end;
procedure TXMLNodes.Insert(Index: Integer; Value: TXMLNode);
begin
  inherited Insert(Index, Value);
end;
procedure TXMLNodes.Delete(Index: Integer);
begin
	if (Index > -1) and (Index < Count) then
    begin
    	GetItem(index).Free;
        inherited Delete(Index);
    end;
end;
constructor TXMLNode.Create(TagType: TTagType = ttElement);
begin
	inherited Create;
    FName := '';
    FOwner := nil;
    FTagType := TagType;
    FValue := '';
    if TagType = ttElement then
    	FAttributes := TXMLAttributes.Create
    else
    	FAttributes := nil;
    if TagType = ttElement then
    	FItems := TXMLNodes.Create(Self)
    else
    	FItems := nil;
end;
destructor TXMLNode.Destroy;
begin
	if FAttributes <> nil then
    	FAttributes.Free;
    if FItems <> nil then
    	FItems.Free;
    inherited Destroy;
end;
procedure TXMLNode.DeleteChildren;
begin
	if (FItems <> nil) and (FItems.Count > 0) then
    	FItems.Clear;
end;
procedure TXMLNode.SetName(Value: string);
begin
	if Value <> FName then
    begin
    	
    	if (FTagType = ttPi) and
        	((not IsXMLName(Value)) or (CompareText(Value, 'xml') = 0)) then
            Raise EXMLException.Create(sPITargetWrong)
        else if (FTagType = ttCDATA) and (Pos(cCDEnd, Value) > 0) then
        	Raise EXMLException.Create(sCDATAWrong)
        else if (FTagType = ttComment) and
        	((Pos('--', Value) > 0) or (Value[Length(Value)] = '-')) then
        	Raise EXMLException.Create(sCommentWrong)
        else
        	FName := Value;
    end;
end;
procedure TXMLNode.SetValue(Value: string);
var
	Final, s, Src: string;
    i, Minus, EndPos: integer;
begin
	if Value <> FValue then
    begin
    	
    	if FTagType = ttPI then
        	
        	FValue := Value
        else if FTagType = ttText then
        begin
        	
            Final := '';
            Src := Trim(Value);
            while Src <> '' do
            begin
            	
            	EndPos := Pos('&', Src);
                if EndPos > 0 then
                begin
                	
                    Final := Final + Copy(Src, 1, EndPos - 1);
                    Delete(Src, 1, EndPos);
                    if Src[1] = '#' then
                    begin
                    	
                        if Src[2] = 'x' then
                        begin
                        	Minus := 3;
                            i := 3;
                            while Src[i] in (cDigit + ['a'..'f', 'A'..'F']) do
                            	Inc(i);
                        end
                        else
                        begin
                        	Minus := 2;
                            i := 2;
                            while Src[i] in cDigit do
                            	Inc(i);
                        end;
                        if Src[i] = ';' then
                        begin
                        	
                            if i > Minus then
                            begin
                            	s := Copy(Src, Minus, i - Minus);
                                Delete(Src, 1, i);
                                if Minus = 3 then
                                	s := '$' + s;
                                Final := Final + Chr(StrToInt(s));
                            end
                            else
                            	Raise EXMLException.Create(sRefWrong);
                        end
                        else
                        	Raise EXMLException.Create(sRefMissingEnd);
                    end 
                    else
                    begin
                    	
                        EndPos := Pos(';', Src);
                        if EndPos > 0 then
                        begin
                        	s := Copy(Src, 1, EndPos - 1);
                            Delete(Src, 1, EndPos);
                            if IsXMLName(s) then
                            begin
                        		
                            	
                            	if s = 'lt' then
                            		Final := Final + '<'
                            	else if s = 'gt' then
                            		Final := Final + '>'
                            	else if s = 'amp' then
                            		Final := Final + '&'
                            	else if s = 'apos' then
                            		Final := Final + ''''
                            	else if s = 'quot' then
                            		Final := Final + '"'
                            	else
                        			Final := Final + '&' + s + ';';
                            end
                            else
                            	Raise EXMLException.Create(sRefWrong);
                        end
                        else
                        	Raise EXMLException.Create(sRefMissingEnd);
                    end;
                end 
                else
                begin
                	
                	Final := Final + Src;
                    Src := '';
                end;
            end; 
            FValue := Trim(Value);
            FName := Trim(Final);
        end;
    end;
end;
function TXMLNode.GetItem(Index: integer): TXMLNode;
begin
	if (Index > -1) and (Index < FItems.Count) then
    	Result := FItems[Index]
    else
    	Result := nil;
end;
function TXMLNode.GetCount: integer;
begin
	Result := FItems.Count;
end;
function TXMLNode.GetIndex : integer;
begin
	Result := -1;
	if FOwner <> nil then
    	Result := FOwner.IndexOf(Self);
end;
function TXMLNode.GetParent : TXMLNode;
begin
	Result := FOwner.FOwner;
end;
function TXMLNode.AddChild(TagType: TTagType): TXMLNode;
var
	Node: TXMLNode;
begin
	Node := TXMLNode.Create(TagType);
	FItems.Add(Node);
    Result := Node;
end;
function TXMLNode.HasAttributes: boolean;
begin
	Result := (FTagType = ttElement) and (FAttributes.Count > 0);
end;
function TXMLNode.HasChildren: boolean;
begin
	Result := (FTagType = ttElement) and (FItems.Count > 0);
end;
function TXMLNode.NextSibling: TXMLNode;
begin
	Result := nil;
	if FOwner <> nil then
    begin
    	if FOwner.IndexOf(Self) < FOwner.Count - 1 then
        	Result := FOwner.GetItem(FOwner.IndexOf(Self) + 1);
    end;
end;
function TXMLNode.PreviousSibling: TXMLNode;
begin
	Result := nil;
    if FOwner <> nil then
    begin
    	if FOwner.IndexOf(Self) > 0 then
        	Result := FOwner.GetItem(FOwner.IndexOf(Self) - 1);
    end;
end;
function TXMLNode.GetElementByName(Name: string): TXMLNode;
var
	i: integer;
begin
	Result := nil;
	if FItems.Count > 0 then
    begin
    	i := 0;
        while (i < FItems.Count) and (FItems.GetItem(i).FName <> Name) do
        	Inc(i);
        if i < FItems.Count then
        	Result := FItems.GetItem(i);
    end;
end;
function TXMLNode.ForceElementByName(Name: string): TXMLNode;
begin
	Result := GetElementByName(Name);
    if Result = nil then
    begin
    	Result := Self.AddChild(ttElement);
        Result.FName := Name;
    end;
end;
procedure TXMLDeclaration.SetVersion(Value: string);
begin
	
	if Value <> FVersion then
    begin
    	if Value = '1.0' then
        	FVersion := Value
        else
        	Raise EXMLException.Create(sDeclVerUnknown)
    end;
end;
procedure TXMLDeclaration.SetEncoding(Value: string);
var
	i: integer;
begin
	if Value <> FEncoding then
    begin
    	
        if FVersion <> '1.0' then
        	FVersion := '1.0';
        i := 1;
        if Value[i] in ['a'..'z', 'A'..'Z'] then
        begin
        	Inc(i);
            while (Value[i] in ['a'..'z', 'A'..'Z', '0'..'9', '.', '_', '-']) and
            	(i <= Length(Value)) do
                Inc(i);
            if i > Length(Value) then
            	FEncoding := Value
            else
            	Raise EXMLException.Create(sDeclEncWrong);
        end
		else
        	Raise EXMLException.Create(sDeclEncWrong);
    end;
end;
procedure TXMLDeclaration.SetStandalone(Value: string);
begin
	if Value <> FStandalone then
    begin
    	
        if FVersion <> '1.0' then
        	FVersion := '1.0';
        if (Value = 'yes') or (Value = 'no') then
        	FStandalone := Value
        else
        	Raise EXMLException.Create(sDeclSDWrong);
    end;
end;
procedure TXMLDeclaration.Clear;
begin
	FVersion := '';
    FEncoding := '';
    FStandalone := '';
end;
constructor TXMLDoc.Create;
begin
	inherited Create;
	FBuffer := nil;
    FBufferSize := 0;
    FSource := '';
    FTags := TXMLNodes.Create(nil);
    FDeclaration := TXMLDeclaration.Create;
    FLineFeed := flfLF;
    FSeparator := fsTab;
    Clear;
end;
destructor TXMLDoc.Destroy;
begin
	
	Clear;
    FTags.Free;
    inherited Destroy;
end;
procedure TXMLDoc.Clear;
begin
	
	if (FBufferSize > 0) and (FBuffer <> nil) then
    	FreeMem(FBuffer);
    FBuffer := nil;
    CurPos := nil;
    FBufferSize := 0;
    FDeclaration.Clear;
    FSource := '';
    FTags.Clear;
end;
procedure TXMLDoc.SetSource(Value: string);
begin
	
    FFilename := '';
	if Value <> FSource then
    begin
    	Clear;
        FSource := Value;
        Parse;
    end;
end;
function TXMLDoc.OutputNode(Node: TXMLNode; Level: integer; uLF, uInd: string;
	UseLevel: boolean = true): string;
	function LevelToTabs(Level: integer; TabChar: string): string;
	var
		i: integer;
	begin
		Result := '';
		if (Level > 0) and (TabChar <> '') then
    	begin
    		for i := 0 to Level - 1 do
        		Result := Result + TabChar;
    	end;
	end;
var
	i: integer;
    sBegin, sEnd: string;
    Leveled: boolean;
begin
	
    if UseLevel then
    begin
    	sBegin := LevelToTabs(Level, uInd);
        sEnd := uLF;
    end
    else
    begin
    	sBegin := '';
        sEnd := '';
    end;
    Case Node.TagType of
    	ttComment:
        	Result := sBegin + '<!--' + Node.FName + '-->' + sEnd;
        ttCDATA:
        	Result := sBegin + cCDStart + Node.FName + cCDEnd + sEnd;
        ttPI:
        	Result := sBegin + '<?' + Node.FName + '?>' + sEnd;
        ttText:
        	Result := sBegin + Node.FValue + sEnd;
    	else	
        begin
        	Result := sBegin + '<' + Node.FName;
            if Node.FAttributes.Count > 0 then
            begin
            	for i := 0 to Node.FAttributes.Count - 1 do
                begin
                	Result := Result + ' ' + Node.FAttributes[i].FName + '=';
                    if Pos('"', Node.FAttributes[i].FValue) > 0 then
                    	Result := Result + '''' + Node.FAttributes[i].FValue + ''''
                    else
                    	Result := Result + '"' + Node.FAttributes[i].FValue + '"';
                end;
            end;
            if Node.FItems.Count > 0 then
            begin
            	Result := Result + '>';
            	
                if (Node.FItems.Count = 1) and (Node.Item[0].FTagType <> ttElement) then
                	Leveled := false
                else
                begin
                	
                	Leveled := true;
                    for i := 0 to Node.FItems.Count - 1 do
                    	if Node.Item[i].FTagType = ttText then
                        	Leveled := false;
                end;
                if Leveled then
                	Result := Result + sEnd;
                for i := 0 to Node.FItems.Count - 1 do
                	Result := Result + OutputNode(Node.Item[i], Level + 1, uLF,
                    					uInd, Leveled);
                if Leveled then
                	Result := Result + sBegin;
                Result := Result + '</' + Node.FName + '>' + sEnd;
            end
            else
            	Result := Result + '/>' + sEnd;
        end;
    end;
end;
function TXMLDoc.GetSource: string;
var
    uLF, uInd: string;
    i: integer;
begin
	
	if FLineFeed = flfLF then
    	uLF := cLF
    else if FLineFeed = flfCRLF then
    	uLF := cCR + cLF
    else if FLineFeed = flfCR then
    	uLF := cCR
    else
    	uLF := '';
    if FSeparator = fsTab then
    	uInd := cTab
    else if FSeparator = fsSpace then
    	uInd := ' '
    else
    	uInd := '';
	if FDeclaration.Version <> '' then
    begin
    	Result := '<?xml version="' + FDeclaration.Version + '"';
        if FDeclaration.Encoding <> '' then
        	Result := Result + ' encoding="' + FDeclaration.Encoding + '"';
        if FDeclaration.Standalone <> '' then
        	Result := Result + ' standalone="' + FDeclaration.Standalone + '"';
        Result := Result + '?>' + uLF;
    end;
    if FTags.Count > 0 then
    begin
    	for i := 0 to FTags.Count - 1 do
        	Result := Result + OutputNode(FTags[i], 0, uLF, uInd, true);
    end;
end;
function TXMLDoc.GetRoot: TXMLNode;
var
	i: integer;
begin
	if FTags.Count > 0 then
    begin
    	i := 0;
        while (FTags.Item[i].FTagType <> ttElement) and
        	(i < FTags.Count) do
        	Inc(i);
        if i = FTags.Count then
        	Result := nil
        else
        	Result := FTags.Item[i];
    end
    else
    	Result := nil;
end;
procedure TXMLDoc.LoadFromFile(Filename: TFilename);
begin
	
	Clear;
	FFilename := Filename;
    if Filename <> '' then
    begin
    	with TFileStream.Create(Filename, fmOpenRead, fmShareDenyWrite) do
    	try
    		SetLength(FSource, Size);
        	ReadBuffer(FSource[1], Size);
    	finally
    		Free;
    	end;
    	
    	Parse;
    end;
end;
procedure TXMLDoc.SaveToFile(Filename: TFilename);
begin
	with TFileStream.Create(Filename, fmCreate) do
    try
    	WriteBuffer(Source[1],Length(Source));
        FFilename := Filename;
    finally
    	Free;
    end;
end;
procedure TXMLDoc.LoadBuffer;
var
    ss: TStringStream;
begin
    ss := TStringStream.Create(FSource);
    try
    	FBufferSize := ss.Size + 1;
        GetMem(FBuffer, FBufferSize);
        ss.ReadBuffer(FBuffer^, ss.Size);
        (FBuffer + ss.Size)^ := #0;
    finally
    	ss.Free;
    end;
end;
procedure TXMLDoc.RaiseException(const Msg: string);
begin
	
    Clear;
    Raise EXMLException.Create(Msg);
end;
procedure TXMLDoc.RaiseExceptionFmt(const Msg: string; const Args: array of const);
begin
	
    Clear;
    Raise EXMLException.CreateFmt(Msg, Args);
end;
procedure TXMLDoc.ParseAttributes(Parent: TXMLNode);
var
    ErrCode: integer;
    Search: boolean;
    Name, Value: string;
    Quote: Char;
    EndPos: PChar;
    NewAttr: TXMLAttribute;
begin
	
    Search := true;
    while Search do
    begin
    	
    	SkipXMLBlanks(CurPos, FSrcLine);
    	
        ErrCode := GetXMLName(CurPos, Name);
        if ErrCode = 0 then
        begin
            if IsXMLEq(CurPos, FSrcLine) then
            begin
            	
                if IsXMLQuote(CurPos, Quote) then
                begin
                	
                    EndPos := ScanStr(Quote, CurPos, FSrcLine);
                    if EndPos <> #0 then
                    begin
                    	SetString(Value, CurPos, EndPos - CurPos);
                        NewAttr := TXMLAttribute.Create(Name, Value);
                        try
                        	Parent.FAttributes.Add(NewAttr);
                        except
                        	On E: EXMLException do RaiseException(E.Message);
                        end;
                        CurPos := EndPos + 1;
                    end 
                    else
                    	
                        RaiseException(sAttrQuote);
                end 
                else
                	
                    RaiseException(sAttrQuote);
            end 
            else
            	
                RaiseException(sAttrEqual);
        end 
        else
        	
        	Search := false;
    end; 
end;
procedure TXMLDoc.ParseCDATA(Parent: TXMLNode);
var
    EndPos: PChar;
    s: string;
	Node: TXMLNode;
begin
	
    Inc(CurPos, Length(cCDStart));
    EndPos := ScanStr(cCDEnd, CurPos, FSrcLine);
    if EndPos^ <> #0 then
    begin
    	
        SetString(s, CurPos, EndPos - CurPos);
		
        if Parent <> nil then
        	Node := Parent.AddChild(ttCDATA)
        else
        begin
        	Node := TXMLNode.Create(ttCDATA);
            FTags.Add(Node);
        end;
        Node.FName := s;
        CurPos := EndPos + Length(cCDEnd)
    end
    else
    	
    	RaiseExceptionFmt(sMissingEndTag, [cCDStart, cCDEnd]);
end;
procedure TXMLDoc.ParseComment(Parent: TXMLNode);
var
	EndPos: PChar;
    s: string;
    Node: TXMLNode;
begin
	
    Inc(CurPos, 4);
    EndPos := ScanStr('-->', CurPos, FSrcLine);
    if EndPos^ <> #0 then
    begin
    	
        SetString(s, CurPos, EndPos - CurPos);
        if Parent <> nil then
        	Node := Parent.AddChild(ttComment)
        else
        begin
        	Node := TXMLNode.Create(ttComment);
            FTags.Add(Node);
        end;
        try
        	Node.SetName(s);
        except
        	on E: EXMLException do RaiseException(E.Message);
        end;
        CurPos := EndPos + 3;
    end
    else
    	
        RaiseExceptionFmt(sMissingEndTag, ['<!--', '-->']);
end;
procedure TXMLDoc.ParseDTD(Parent: TXMLNode);
begin
	
    RaiseException('DTD not handle in this version.');
end;
procedure TXMLDoc.ParseElement(Parent: TXMLNode);
var
    EndPos: PChar;
	s: string;
    Node: TXMLNode;
    ErrCode: integer;
    IsClosed: boolean;
begin
	
    Inc(CurPos);
	
    ErrCode := GetXMLName(CurPos, s);
    if ErrCode = 0 then
    begin
    	
        if Parent <> nil then
        	Node := Parent.AddChild(ttElement)
        else
        begin
        	Node := TXMLNode.Create(ttElement);
            FTags.Add(Node);
        end;
        Node.FName := s;
        ParseAttributes(Node);
        if StrLComp(CurPos, '/>', 2) = 0 then
        	
            Inc(CurPos, 2)
        else if CurPos^ = '>' then
        begin
        	
            Inc(CurPos);
            IsClosed := false;
            while not IsClosed and (CurPos^ <> #0) do
            begin
            	
                if StrLComp(CurPos, PChar('</' + Node.FName),
                	Length(Node.FName) + 2) = 0 then
                begin
                	
                    EndPos := CurPos + Length(Node.Name) + 2;
                    SkipXMLBlanks(EndPos);
                    if EndPos^ = '>' then
                    begin
                    	
                        Inc(CurPos, Length(Node.Name) + 2);
                        SkipXMLBlanks(CurPos, FSrcLine);
                        Inc(CurPos);
                        IsClosed := true;
                    end;
                end
                else if (StrLComp(CurPos, '<?', 2) = 0) then
                	
                    ParsePI(Node)
                else if StrLComp(CurPos, '<!--', 4) = 0 then
                	
                    ParseComment(Node)
                else if StrLComp(CurPos, cCDStart, Length(cCDStart)) = 0 then
                	
                    ParseCDATA(Node)
                else if CurPos^ = '<' then
                	
                    ParseElement(Node)
                else
                	
                	ParseText(Node);
            end; 
            if not IsClosed then
            	
                RaiseExceptionFmt( sMissingEndTag,
                			['<' + Node.FName + '>', '</' + Node.FName + '>']);
        end 
        else
        	
            RaiseExceptionFmt(sMissingEndTag, ['<', '>']);
    end 
    else
    begin
    	
        RaiseException(sWrongName);
    end;
end;
procedure TXMLDoc.ParsePI(Parent: TXMLNode);
var
	ErrCode: integer;
    Target, s: string;
    EndPos: PChar;
    Node: TXMLNode;
begin
	
    Inc(CurPos, 2);
    ErrCode := GetXMLName(CurPos, Target);
    if ErrCode = 0 then
    begin
    	
        if CompareStr(Target, 'xml') = 0 then
        	
            RaiseException(sDeclPos)
        else if CompareText(Target, 'xml') = 0 then
        	
            RaiseException(sPITargetXML)
        else
        begin
        	SkipXMLBlanks(CurPos, FSrcLine);
            EndPos := ScanStr('?>', CurPos, FSrcLine);
            if EndPos^ <> #0 then
            begin
                if Parent <> nil then
                	Node := Parent.AddChild(ttPI)
                else
                begin
                	Node := TXMLNode.Create(tTPI);
                    FTags.Add(Node);
                end;
                Node.FName := Target;
                SetString(s, CurPos, EndPos - CurPos);
                Node.FValue := s;
                CurPos := EndPos + 2;
            end
            else
            	
            	RaiseExceptionFmt(sMissingEndTag, ['<?', '?>']);
        end;
    end 
    else
    	
        RaiseException(sPITargetMissing);
end;
procedure TXMLDoc.ParseText(Parent: TXMLNode);
var
    EndPos: PChar;
    s: string;
	Node: TXMLNode;
begin
	
    EndPos := ScanStr('<', CurPos);
    if (EndPos <> CurPos) then
    begin
    	SetString(s, CurPos, EndPos - CurPos);
        if Trim(s) <> '' then
        begin
        	if Parent <> nil then
        		Node := Parent.AddChild(ttText)
        	else
        	begin
        		Node := TXMLNode.Create(ttText);
            	FTags.Add(Node);
        	end;
            try
            	Node.SetValue(s);
            except
            	On E: Exception do RaiseException(E.Message);
            end;
        end;
        while CurPos <> EndPos do
        begin
        	if CurPos^ = cLF then
            	Inc(FSrcLine);
            Inc(CurPos);
        end;
    end;
end;
procedure TXMLDoc.ParseDeclaration;
	
    procedure CheckClosed;
    begin
    	SkipXMLBlanks(CurPos, FSrcLine);
        if StrLComp(CurPos, '?>', 2) = 0 then
        	
            Inc(CurPos, 2)
        else
        	
            RaiseExceptionFmt(sMissingEndTag, ['<?xml', '?>']);
    end;
	
    procedure CheckStandalone;
    var
    	Quote: Char;
        s: string;
        EndPos: PChar;
    begin
    	
    	if StrLComp(CurPos, 'standalone', 10) = 0 then
        begin
        	Inc(CurPos, 10);
            if IsXMLEq(CurPos, FSrcLine) then
            begin
            	
                if IsXMLQuote(CurPos, Quote) then
                begin
                	EndPos := ScanStr(Quote, CurPos);
                    if EndPos <> #0 then
                    begin
                    	SetString(s, CurPos, EndPos - CurPos);
                        try
                        	FDeclaration.SetStandalone(s);
                        except
                        	On E: EXMLException do
                            	RaiseException(E.Message);
                        end;
                        CurPos := EndPos + 1;
                        CheckClosed;
                    end
                    else
                    	
                    	RaiseException(sAttrQuote);
                end
                else
                	
                    RaiseException(sAttrQuote);
            end 
            else
            	
                RaiseException(sAttrEqual);
        end 
        else
        	CheckClosed;
    end;
var
	Quote: Char;
    s: string;
    EndPos: PChar;
begin
	
    if (StrLComp(CurPos, '<?xml', 5) = 0) and ((CurPos + 5)^ in cWhiteSpace) then
    begin
    	
        Inc(CurPos, 6);
        if StrLComp(CurPos, 'version', 7) = 0 then
        begin
        	Inc(CurPos, 7);
        	
            if IsXMLEq(CurPos, FSrcLine) then
            begin
            	
                if IsXMLQuote(CurPos, Quote) then
                begin
                    SetString(s, CurPos, 3);
                    try
                    	
                    	FDeclaration.SetVersion(s);
                    except
                    	On E: EXMLException do RaiseException(E.Message);
                    end;
                    Inc(CurPos, 3);
                    if CurPos^ = Quote then
                    begin
                    	Inc(CurPos);
                        SkipXMLBlanks(CurPos, FSrcLine);
                        if StrLComp(CurPos, 'encoding', 8) = 0 then
                        begin
                        	
                            Inc(CurPos, 8);
                            if IsXMLEq(CurPos, FSrcLine) then
                            begin
                            	
                                if IsXMLQuote(CurPos, Quote) then
                                begin
                                	
                                    EndPos := ScanStr(Quote, CurPos);
                                    if EndPos <> #0 then
                                    begin
                                    	SetString(s, CurPos, EndPos - CurPos);
                                        try
                                        	FDeclaration.SetEncoding(s);
                                        except
                                        	On E: EXMLException do
                                            	RaiseException(E.Message);
                                        end;
                                        CurPos := EndPos + 1;
                                        SkipXMLBlanks(CurPos, FSrcLine);
                                        CheckStandalone;
                                    end
                                    else
                                    	
                                        RaiseException(sAttrQuote);
                                end 
                                else
                                	
                                    RaiseException(sAttrQuote);
                            end 
                            else
                            	
                                RaiseException(sAttrEqual);
                        end 
                        else
                        	
                            CheckStandalone;
                    end
                    else
                    	
                        RaiseException(sAttrQuote);
                end 
                else
                	
                    RaiseException(sAttrQuote);
            end 
            else
            	
                RaiseException(sAttrEqual);
        end 
        else
        	
            RaiseException(sDeclWrong);
    end;
end;
procedure TXMLDoc.Parse;
var
    HasBody: boolean;	
    HasDTD: boolean;    
    					
begin
	
    LoadBuffer;
	
    CurPos := FBuffer;
    if (CurPos <> nil) and (CurPos^ <> #0) then
    begin
    	
    	FSrcLine := 1;
		HasBody := false;
        HasDTD := false;
        ParseDeclaration;
        SkipXMLBlanks(CurPos, FSrcLine);
        while CurPos^ <> #0 do
        begin
        	if (StrLComp(CurPos, '<!DOCTYPE', 9) = 0) and
            	((CurPos + 9)^ in cWhiteSpace) then
            begin
            	
                if not HasDTD then
                begin
                	HasDTD := true;
                    ParseDTD(nil);
                end
                else
                	
                    RaiseException(sMainEmpty);
            end
            else if (StrLComp(CurPos, '<?', 2) = 0) then
            	
                ParsePI(nil)
            else if StrLComp(CurPos, '<!--', 4) = 0 then
            	
                ParseComment(nil)
            else if CurPos^ = '<' then
            begin
            	
                if not HasBody then
                begin
                    HasBody := true;
                	ParseElement(nil);
                end
                else
                	
                    RaiseException(sMainEmpty);
            end
            else
            	
                RaiseException(sMainEmpty);
            SkipXMLBlanks(CurPos, FSrcLine);
        end;
        if not HasBody then
        	RaiseException(sMainEmpty);
    end;
	if (FBufferSize > 0) and (FBuffer <> nil) then
    	FreeMem(FBuffer);
    FBuffer := nil;
    CurPos := nil;
    FBufferSize := 0;
    FSource := '';
end;
end.

