unit XMLIniFile;
interface
uses Classes, IniFiles, XMLParser, SysUtils;
type
  TXMLIniFile = class(TCustomIniFile)
  private
    fXMLDOM: TXMLDoc;
    function GetNode(Parent: TXMLNode; Name: string; aWrite: boolean = false): TXMLNode;
    function GetTextNode(Parent: TXMLNode): TXMLNode;
  protected
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure UpdateFile; override;
    procedure Clear; virtual;
    procedure ReadSection(const Section: string; Strings: TStrings); override;
    procedure ReadSections(Strings: TStrings); override;
    procedure ReadSectionValues(const Section: string; Strings: TStrings); override;
    procedure EraseSection(const Section: string); override;
    procedure DeleteKey(const Section, Ident: String); override;
    function ReadString(const Section, Ident, Default: string): string; override;
    procedure WriteString(const Section, Ident, Value: String); override;
    property  DOM: TXMLDoc read fXMLDOM;
  end;
implementation
constructor TXMLIniFile.Create(const FileName: string);
var
	Root: TXMLNode;
begin
	inherited Create(FileName);
	fXMLDOM := TXMLDoc.Create;
    fXMLDOM.LineFeed := flfCRLF;
    fXMLDOM.Separator := fsTab;
	if FileExists(FileName) then
		fXMLDOM.LoadFromFile(FileName)
    else
    begin
    	
    	fXMLDOM.Declaration.Version := '1.0';
    	fXMLDOM.Declaration.Encoding := 'iso-8859-1';
    	fXMLDOM.Declaration.Standalone := 'yes';
    end;
    if fXMLDOM.Root = nil then
    begin
    	Root := TXMLNode.Create;
        Root.Name := 'root';
        fXMLDOM.Items.Add(Root);
    end;
end;
destructor TXMLIniFile.Destroy;
begin
	fXMLDOM.SaveToFile(FileName);
  	fXMLDOM.Free;
  	inherited Destroy;
end;
procedure TXMLIniFile.UpdateFile;
begin
	fXMLDOM.SaveToFile(FileName);
end;
procedure TXMLIniFile.Clear;
begin
	fXMLDOM.Root.DeleteChildren;
end;
function TXMLIniFile.GetNode(Parent: TXMLNode; Name: string; aWrite: boolean = false): TXMLNode;
begin
	if Parent <> nil then
    begin
		if aWrite then
    		Result := Parent.ForceElementByName(Name)
    	else
    		Result := Parent.GetElementByName(Name);
    end
    else
    	Result := nil;
end;
function TXMLIniFile.GetTextNode(Parent: TXMLNode): TXMLNode;
var
	i: integer;
begin
	Result := nil;
	if Parent.HasChildren then
	begin
    	i := 0;
        while (i < Parent.Count) and (Parent.Item[i].TagType <> ttText) do
        	Inc(i);
        if i < Parent.Count then
        	Result := Parent.Item[i];
    end;
end;
procedure TXMLIniFile.ReadSections(Strings: TStrings);
var
	i: Integer;
begin
	Strings.Clear;
    if fXMLDOM.Root.Count > 0 then
    begin
    	for i := 0 to fXMLDOM.Root.Count do
        	if fXMLDOM.Root.Item[i].TagType = ttElement then
            	Strings.Add(fXMLDOM.Root.Item[i].Name);
    end;
end;
procedure TXMLIniFile.ReadSection(const Section: string; Strings: TStrings);
var
	i: Integer;
    Node: TXMLNode;
begin
	Strings.Clear;
	Node := GetNode(fXMLDOM.Root, Section);
	if (Node <> nil) and (Node.Count > 0) then
	begin
    	for i := 0 to Node.Count - 1 do
        	if Node.Item[i].TagType = ttElement then
        		Strings.Add(Node.Item[i].Name);
	end;
end;
procedure TXMLIniFile.ReadSectionValues(const Section: string; Strings: TStrings);
var
	Node: TXMLNode;
    i: integer;
begin
	Strings.Clear;
    Node := GetNode(fXMLDOM.Root, Section);
    if (Node <> nil) and (Node.Count > 0) then
    begin
    	for i := 0 to Node.Count - 1 do
        	if Node.Item[i].TagType = ttElement then
            	Strings.Add('Node.Text');
    end;
end;
procedure TXMLIniFile.EraseSection(const Section: string);
var
	Node: TXMLNode;
begin
	Node := GetNode(fXMLDOM.Root, Section);
  	if Node <> nil then
    begin
    	Node.DeleteChildren;
    	Node.Free;
    end;
end;
procedure TXMLIniFile.DeleteKey(const Section, Ident: String);
var
	Node, Key: TXMLNode;
begin
	Node := GetNode(fXMLDOM.Root, Section);
    if Node <> nil then
    begin
    	Key := GetNode(Node, Ident);
        if Key <> nil then
        begin
        	Key.DeleteChildren;
            Key.Free;
        end;
    end;
end;
function TXMLIniFile.ReadString(const Section, Ident, Default: string): string;
var
	Node, Key, TxtNode: TXMLNode;
begin
	Result := Default;
	Node := GetNode(fXMLDOM.Root, Section);
    if Node <> nil then
    begin
    	Key := GetNode(Node, Ident);
        if Key <> nil then
        begin
        	TxtNode:= GetTextNode(Key);
            if TxtNode <> nil then
            	Result := TxtNode.Name;
        end;
    end;
end;
procedure TXMLIniFile.WriteString(const Section, Ident, Value: String);
var
	Node, Key, TxtNode: TXMLNode;
begin
	Node := GetNode(fXMLDOM.Root, Section, true);
    Key := GetNode(Node, Ident, true);
    TxtNode := GetTextNode(Key);
    if TxtNode = nil then
    	TxtNode := Key.AddChild(ttText);
    TxtNode.Value := Value;
end;
end.



