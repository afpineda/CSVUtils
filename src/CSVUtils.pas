{ *******************************************************

  CSV Format utilities

  *******************************************************

  2012-2023 Ángel Fernández Pineda. Madrid. Spain.

  This work is licensed under a Creative Commons
  Attribution 4.0 International License.
  To view a copy of this license,
  visit
  https://creativecommons.org/licenses/by/4.0/legalcode
  or send a letter to Creative Commons,
  444 Castro Street, Suite 900,
  Mountain View, California, 94041, USA.

  ******************************************************* }

unit CSVUtils;

interface

uses
  Classes,
  IOUtils,
  SysUtils;

type
  ECSVSyntaxError = class(Exception);
  ECSVWrongFieldEnclosing = class(ECSVSyntaxError);
  ECSVMaxRecordLength = class(ECSVSyntaxError);
  ECSVCharNotAllowed = class(Exception);

type

  TCSVRecord = class
  private
    FFields: array of Variant;
    FFieldSeparator: char;
    FFieldEnclosure: char;
    FIgnoreWhiteSpaces: boolean;
    FIgnoreFSAtEOL: boolean;
    FMaxRecordLength: integer;
    FForceFieldCount: integer;
    FIgnoreEmptyLines: boolean;
    FFormatSettings: System.SysUtils.TFormatSettings;
    FCommentaryChar: char;
  private
    function GetField(index: integer): Variant;
    function GetFieldAsDateTime(index: integer): TDateTime;
    function GetFieldAsFloat(index: integer): Extended;
    function GetFieldAsString(index: integer): string;
    function GetFieldCount: integer;
    function GetTextLine: string;
    procedure ParseTextLine(const textLine: string; const textLength: integer);
    procedure SetCommentaryChar(const value: char);
    procedure SetField(index: integer; value: Variant);
    procedure SetFieldCount(count: integer);
    procedure SetFieldEnclosure(const value: char);
    procedure SetFieldSeparator(const value: char);
    procedure SetTextLine(const text: string);
  protected
    function FieldToString(const fieldIndex: integer; const field: Variant)
      : string; virtual;
    procedure OnCommentaryLine(const text: string); virtual;
    function StringToField(const fieldIndex: integer; const fieldText: string;
      const enclosed: boolean): Variant; virtual;
  public
    constructor Create;

    procedure Assign(source: TCSVRecord);
    procedure Clear;
    procedure ForEach(proc: TProc<Variant, integer>);
    function Read(const from: TStreamReader): boolean;
    procedure UseRFC4180; virtual;
    procedure Write(const toStream: TStreamWriter);
  public
    property AsText: string read GetTextLine write SetTextLine;
    property CommentaryChar: char read FCommentaryChar write SetCommentaryChar;
    property field[index: integer]: Variant read GetField write SetField;
    property FieldAsDateTime[index: integer]: TDateTime read GetFieldAsDateTime;
    property FieldAsFloat[index: integer]: Extended read GetFieldAsFloat;
    property FieldAsString[index: integer]: string read GetFieldAsString;
    property FieldCount: integer read GetFieldCount write SetFieldCount;
    property FieldEnclosure: char read FFieldEnclosure write SetFieldEnclosure;
    property FieldSeparator: char read FFieldSeparator write SetFieldSeparator;
    property ForceFieldCount: integer read FForceFieldCount
      write FForceFieldCount;
    property FormatSettings: TFormatSettings read FFormatSettings
      write FFormatSettings;
    property IgnoreEmptyLines: boolean read FIgnoreEmptyLines
      write FIgnoreEmptyLines;
    property IgnoreFieldSeparatorAtEndOfLine: boolean read FIgnoreFSAtEOL
      write FIgnoreFSAtEOL;
    property IgnoreWhiteSpaces: boolean read FIgnoreWhiteSpaces
      write FIgnoreWhiteSpaces;
    property MaxRecordLength: integer read FMaxRecordLength
      write FMaxRecordLength;
  end;

implementation

uses
  System.Variants,
  System.StrUtils;

// ----------------------------------------------------------------------------
// Constructor / destructor
// ----------------------------------------------------------------------------

constructor TCSVRecord.Create;
begin
  FFormatSettings := TFormatSettings.Create;
  FMaxRecordLength := 0;
  FForceFieldCount := 0;
  UseRFC4180;
  Clear;
end;

// ----------------------------------------------------------------------------
// Methods
// ----------------------------------------------------------------------------

procedure TCSVRecord.OnCommentaryLine(const text: string);
begin
  // do nothing
end;

procedure TCSVRecord.UseRFC4180;
begin
  FFieldSeparator := ',';
  FFieldEnclosure := '"';
  FIgnoreFSAtEOL := false;
  FIgnoreWhiteSpaces := false;
  FIgnoreEmptyLines := false;
  FCommentaryChar := #0;
end;

procedure TCSVRecord.Clear;
begin
  SetLength(FFields, 0);
end;

procedure TCSVRecord.Assign(source: TCSVRecord);
var
  I: integer;
begin
  if (source <> nil) then
  begin
    FFieldSeparator := source.FFieldSeparator;
    FFieldEnclosure := source.FFieldEnclosure;
    FIgnoreWhiteSpaces := source.FIgnoreWhiteSpaces;
    FIgnoreFSAtEOL := source.FIgnoreFSAtEOL;
    FMaxRecordLength := source.FMaxRecordLength;
    FForceFieldCount := source.FForceFieldCount;
    FIgnoreEmptyLines := source.FIgnoreEmptyLines;
    FFormatSettings := source.FFormatSettings;
    FCommentaryChar := source.FCommentaryChar;
    FieldCount := source.FieldCount;
    for I := 0 to source.FieldCount - 1 do
      field[I] := source.field[I];
  end
  else
  begin
    FFormatSettings := TFormatSettings.Create;
    UseRFC4180;
    FMaxRecordLength := 0;
    FForceFieldCount := 0;
    Clear;
  end;
end;

procedure TCSVRecord.ForEach(proc: TProc<Variant, integer>);
var
  I: integer;
begin
  if (Assigned(proc)) then
    for I := 0 to FieldCount - 1 do
      proc(field[I], I);
end;

// ----------------------------------------------------------------------------
// Type parsing and conversion
// ----------------------------------------------------------------------------

function TCSVRecord.FieldToString(const fieldIndex: integer;
  const field: Variant): string;
begin
  case varType(field) of
    varBoolean:
      Result := BoolToStr(field, false);
    varDate:
      Result := DateTimeToStr(TVarData(field).VDate, FFormatSettings);
    varSingle, varDouble:
      Result := FloatToStr(field, FFormatSettings);
    varCurrency:
      Result := CurrToStr(field, FormatSettings);
    varShortInt, varByte:
      Result := Format('%d', [byte(field)], FormatSettings);
    varSmallInt:
      Result := Format('%d', [Int16(field)], FormatSettings);
    varInteger:
      Result := Format('%d', [integer(field)], FormatSettings);
    varInt64:
      Result := Format('%d', [Int64(field)], FormatSettings);
    varWord:
      Result := Format('%u', [UInt16(field)], FormatSettings);
    varUInt32:
      Result := Format('%u', [UInt32(field)], FormatSettings);
    varUInt64:
      Result := Format('%u', [UInt64(field)], FormatSettings);
  else
    Result := VarToStr(field);
  end;
end;

function TCSVRecord.StringToField(const fieldIndex: integer;
  const fieldText: string; const enclosed: boolean): Variant;
begin
  Result := fieldText;
end;

// ----------------------------------------------------------------------------
// Read/write from/to stream
// ----------------------------------------------------------------------------

function TCSVRecord.Read(const from: TStreamReader): boolean;
var
  textLine, newText: string;
  qCount: integer;
  enclosingOk: boolean;
  l: integer;
  mustIgnore: boolean;
begin
  SetLength(FFields, 0);
  Result := (from <> nil) and (not from.EndOfStream);
  if (Result) then
  begin
    // Read record
    repeat
    begin
      textLine := '';
      l := 0;
      repeat
        newText := from.ReadLine;
        l := l + Length(newText);
        if (FMaxRecordLength > 0) and (l > FMaxRecordLength) then
          raise ECSVMaxRecordLength.Create('');
        textLine := textLine + newText;
        qCount := textLine.CountChar(FFieldEnclosure);
        enclosingOk := ((qCount mod 2) = 0);
      until (from.EndOfStream) or (enclosingOk);
      mustIgnore := ((FIgnoreEmptyLines) and (l = 0)) or
        ((FCommentaryChar <> #0) and (l > 0) and
        (textLine[1] = FCommentaryChar));
    end
    until (not mustIgnore) or (from.EndOfStream);

    if (enclosingOk) then
    begin
      ParseTextLine(textLine, l);
    end
    else
      raise ECSVWrongFieldEnclosing.Create(textLine);
  end;
end;

procedure TCSVRecord.Write(const toStream: TStreamWriter);
var
  str: string;
begin
  if (toStream <> nil) then
  begin
    str := AsText;
    if (not FIgnoreEmptyLines) or (Length(str) > 0) then
      toStream.WriteLine(str);
  end;
end;

procedure TCSVRecord.ParseTextLine(const textLine: string;
  const textLength: integer);

  procedure ParseSingleField(var atIdx: integer; out fieldText: string;
    out followingSeperatorFound, enclosureFound: boolean);
  var
    fromIdx: integer;
    toIdx: integer;
  begin
    // Remove leading white spaces (if any)
    while ((FIgnoreWhiteSpaces) and (atIdx <= textLength) and
      (textLine[atIdx] = ' ')) do
      inc(atIdx);

    if (atIdx > textLength) then
    begin
      // Empty field at end of line
      followingSeperatorFound := false;
      fieldText := '';
      enclosureFound := false;
    end
    else if (textLine[atIdx] = FFieldEnclosure) then
    begin
      // Field should be enclosed
      fromIdx := atIdx + 1;
      inc(atIdx);
      repeat
        atIdx := PosEx(FFieldEnclosure, textLine, atIdx);
        if (atIdx = 0) then
          raise ECSVWrongFieldEnclosing.Create(textLine)
        else if (atIdx < textLength) and (textLine[atIdx + 1] = FFieldEnclosure)
        then
          atIdx := atIdx + 2;
      until (textLine[atIdx] = FFieldEnclosure);
      toIdx := atIdx - 1;
      inc(atIdx);

      // remove trailing white spaces (if any)
      while ((FIgnoreWhiteSpaces) and (atIdx <= textLength) and
        (textLine[atIdx] = ' ')) do
        inc(atIdx);

      // Look for field separator or end of record
      if (atIdx <= textLength) and (textLine[atIdx] <> FFieldSeparator) then
        raise ECSVSyntaxError.Create(textLine);

      // move atIdx to next field
      followingSeperatorFound := (atIdx <= textLength) and
        (textLine[atIdx] = FFieldSeparator);
      inc(atIdx);

      // Recover field text
      if (toIdx >= fromIdx) then
      begin
        fieldText := MidStr(textLine, fromIdx, toIdx - fromIdx + 1);
        fieldText := ReplaceStr(fieldText, FFieldEnclosure + FFieldEnclosure,
          FFieldEnclosure);
      end
      else
        fieldText := '';
      enclosureFound := true;
    end
    else
    begin
      // Field not enclosed
      fromIdx := atIdx;
      atIdx := PosEx(FFieldSeparator, textLine, atIdx);
      if (atIdx = 0) then
      begin
        toIdx := textLength;
        followingSeperatorFound := false;
      end
      else
      begin
        toIdx := atIdx - 1;
        followingSeperatorFound := true;
      end;
      if (toIdx >= fromIdx) then
        fieldText := MidStr(textLine, fromIdx, toIdx - fromIdx + 1)
      else
        fieldText := '';
      atIdx := toIdx + 2;
      if (ContainsStr(fieldText, FFieldEnclosure)) then
        raise ECSVSyntaxError.Create(textLine);

      if (FIgnoreWhiteSpaces) then
        fieldText := Trim(fieldText);

      enclosureFound := false;
    end; // if-then-else
  end; // procedure

var
  idx: integer;
  field: string;
  fCount: integer;
  separatorFound: boolean;
  enclosureFound: boolean;
begin
  // Initialize
  SetLength(FFields, 0);
  fCount := 0;
  idx := 1;

  // Ignore commentary lines (if any)
  if (FCommentaryChar <> #0) and (textLength > 0) and
    (textLine[1] = CommentaryChar) then
  begin
    OnCommentaryLine(textLine);
    Exit;
  end;

  // Parse
  while (idx <= textLength) do
  begin
    ParseSingleField(idx, field, separatorFound, enclosureFound);
    inc(fCount);
    SetLength(FFields, fCount);
    FFields[fCount - 1] := StringToField(fCount - 1, field, enclosureFound);
  end;
  if (not FIgnoreFSAtEOL) and separatorFound then
  begin
    inc(fCount);
    SetLength(FFields, fCount);
    FFields[fCount - 1] := Null;
  end
  else if (FIgnoreWhiteSpaces) and (not separatorFound) and (not enclosureFound)
    and (Length(FFields[fCount - 1]) = 0) then
    // Last field was empty, except for white spaces, and has no separator
    // (remove)
    SetLength(FFields, fCount - 1);
end;

// ----------------------------------------------------------------------------
// "global" properties
// ----------------------------------------------------------------------------

procedure TCSVRecord.SetCommentaryChar(const value: char);
begin
  if (value = ' ') or (value = FFieldSeparator) or (value = #10) or
    (value = #13) or ((value <> #0) and (value = FFieldEnclosure)) then
    raise ECSVCharNotAllowed.Create('Commentary char not allowed');
  FCommentaryChar := value;
end;

procedure TCSVRecord.SetFieldEnclosure(const value: char);
begin
  if (value = ' ') or (value = FFieldSeparator) or (value = #10) or
    (value = #13) or ((value <> #0) and (value = FCommentaryChar)) then
    raise ECSVCharNotAllowed.Create('Enclosure char not allowed');
  FFieldEnclosure := value;
end;

procedure TCSVRecord.SetFieldSeparator(const value: char);
begin
  if (value = ' ') or (value = FFieldEnclosure) or (value = #10) or
    (value = #13) or (value = #0) or (value = FCommentaryChar) then
    raise ECSVCharNotAllowed.Create('Field separator char not allowed');
  FFieldSeparator := value;
end;

// ----------------------------------------------------------------------------
// Properties about fields
// ----------------------------------------------------------------------------

function TCSVRecord.GetFieldCount: integer;
begin
  if (FForceFieldCount > 0) then
    Result := FForceFieldCount
  else
    Result := high(FFields) + 1;
end;

procedure TCSVRecord.SetFieldCount(count: integer);
var
  oldCount: integer;
  I: integer;
begin
  if (count < 0) or ((FForceFieldCount > 0) and (count <> FForceFieldCount))
  then
    raise EArgumentException.Create('FieldCount<>ForceFieldCount or negative')
  else
  begin
    oldCount := Length(FFields);
    SetLength(FFields, count);
    for I := oldCount to count - 1 do
      FFields[I] := Null;
  end;
end;

function TCSVRecord.GetField(index: integer): Variant;
begin
  if (FForceFieldCount > 0) and (index > high(FFields)) and
    (index < FForceFieldCount) then
    Result := Null
  else if (index < 0) or ((FForceFieldCount > 0) and (index >= FForceFieldCount)
    ) or ((FForceFieldCount = 0) and (index > high(FFields))) then
    raise EArgumentOutOfRangeException.Create('Index out of bounds')
  else
    Result := FFields[index];

  if (varType(Result) <> varNull) and (VarToStr(Result) = '') then
    Result := Null;
end;

procedure TCSVRecord.SetField(index: integer; value: Variant);
var
  count: integer;
  I: integer;
begin
  if (index < 0) or ((FForceFieldCount > 0) and (index >= FForceFieldCount)) or
    ((FForceFieldCount = 0) and (index > high(FFields))) then
    raise EArgumentOutOfRangeException.Create('Index out of bounds')
  else
  begin
    count := HIGH(FFields);
    if (index > count) then
    begin
      SetLength(FFields, index + 1);
      for I := count + 1 to index - 1 do
        FFields[I] := Null;
    end;
    FFields[index] := value;
  end;
end;

function TCSVRecord.GetFieldAsDateTime(index: integer): TDateTime;
begin
  Result := StrToDateTime(VarToStr(GetField(index)), FFormatSettings);
end;

function TCSVRecord.GetFieldAsFloat(index: integer): Extended;
begin
  Result := StrToFloat(VarToStr(GetField(index)), FFormatSettings);
end;

function TCSVRecord.GetFieldAsString(index: integer): string;
begin
  Result := FieldToString(index, GetField(index));
end;

// ----------------------------------------------------------------------------
// Properties about the record itself
// ----------------------------------------------------------------------------

procedure TCSVRecord.SetTextLine(const text: string);
begin
  ParseTextLine(text, Length(text));
end;

function TCSVRecord.GetTextLine: string;

  function FieldEnclosure(const index: integer; const field: Variant): string;
  var
    enclose: boolean;
  begin
    Result := FieldToString(index, field);
    if (FIgnoreWhiteSpaces) then
      Result := Trim(Result);

    if (FFieldEnclosure = #0) then
      Exit;

    enclose := ContainsStr(Result, ' ') or ContainsStr(Result, FFieldSeparator)
      or ContainsStr(Result, FFieldEnclosure) or ContainsStr(Result, #10) or
      ContainsStr(Result, #13);

    if enclose then
    begin
      Result := FFieldEnclosure + ReplaceStr(Result, FFieldEnclosure,
        FFieldEnclosure + FFieldEnclosure) + FFieldEnclosure;
    end
  end;

var
  I: integer;
  count: integer;
begin
  Result := '';
  count := high(FFields) + 1;
  if (FForceFieldCount > 0) and (FForceFieldCount < count) then
    count := FForceFieldCount;
  for I := 0 to count - 1 do
  begin
    if (I > 0) then
      Result := Result + FFieldSeparator;
    Result := Result + FieldEnclosure(I, FFields[I]);
  end;
  count := high(FFields) + 1;
  if (FForceFieldCount > 0) and (FForceFieldCount > count) then
    for I := count to FForceFieldCount - 1 do
    begin
      if (I > 0) then
        Result := Result + FFieldSeparator;
      Result := Result + FFieldEnclosure + FFieldEnclosure;
    end;
  if (FIgnoreFSAtEOL) then
    Result := Result + FFieldSeparator;
end;

// ----------------------------------------------------------------------------

end.
