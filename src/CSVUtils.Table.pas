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

unit CSVUtils.Table;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  CSVUtils;

type
  TCSVTableRecord = class(TCSVRecord)
  private
    FFieldDataType: TDictionary<Integer, TVarType>;
    function GetFieldDataType(index: Integer): TVarType;
    procedure SetFieldDataType(index: Integer; dataType: TVarType);
  protected
    function ClearNumberDecorations(const text: string): string;
    function ClearCurrencyDecorations(const text: string): string;
    function ClearHexPrefix(const text: string): string;
    function StringToField(const fieldIndex: Integer; const fieldText: string;
      const enclosed: boolean): Variant; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(source: TCSVTableRecord);
    procedure ClearDataTypes;
  public
    property FieldDataType[index: Integer]: TVarType read GetFieldDataType
      write SetFieldDataType;
  end;

implementation

uses
  System.Variants,
  System.StrUtils;

// ----------------------------------------------------------------------------
// Constructor / destructor
// ----------------------------------------------------------------------------

constructor TCSVTableRecord.Create;
begin
  FFieldDataType := TDictionary<Integer, TVarType>.Create;
  inherited;
end;

destructor TCSVTableRecord.Destroy;
begin
  FFieldDataType.Free;
  inherited;
end;

// ----------------------------------------------------------------------------
// Properties
// ----------------------------------------------------------------------------

function TCSVTableRecord.GetFieldDataType(index: Integer): TVarType;
begin
  if (FFieldDataType.ContainsKey(index)) then
    Result := FFieldDataType[index]
  else
    Result := varString;
end;

procedure TCSVTableRecord.SetFieldDataType(index: Integer; dataType: TVarType);
begin
  if (index >= 0) then
    FFieldDataType.AddOrSetValue(index, dataType);
end;

// ----------------------------------------------------------------------------
// Public methods
// ----------------------------------------------------------------------------

procedure TCSVTableRecord.Assign(source: TCSVTableRecord);
begin
  inherited Assign(source);
  if (source <> nil) then
  begin
    FFieldDataType.Free;
    FFieldDataType := TDictionary<Integer, TVarType>.Create
      (source.FFieldDataType);
  end
  else
    FFieldDataType.Clear;
end;

procedure TCSVTableRecord.ClearDataTypes;
begin
  FFieldDataType.Clear;
end;

// ----------------------------------------------------------------------------
// Protected methods
// ----------------------------------------------------------------------------

function TCSVTableRecord.ClearNumberDecorations(const text: string): string;
begin
  Result := ReplaceText(text, FormatSettings.ThousandSeparator, '');
  Result := ReplaceText(Result, FormatSettings.DecimalSeparator, '.');
end;

function TCSVTableRecord.ClearCurrencyDecorations(const text: string): string;
begin
  Result := ReplaceText(text, FormatSettings.ThousandSeparator, '');
  Result := ReplaceText(Result, FormatSettings.CurrencyString, '');
  Result := ReplaceText(Result, ' ', '');
end;

function TCSVTableRecord.ClearHexPrefix(const text: string): string;
begin
  if (text.StartsWith('0x')) then
    Result := RightStr(text, Length(text) - 2);
  if (text.StartsWith('$')) then
    Result := RightStr(text, Length(text) - 1);
end;

function TCSVTableRecord.StringToField(const fieldIndex: Integer;
  const fieldText: string; const enclosed: boolean): Variant;
var
  t: TVarType;
  aux: string;
begin
  if (FFieldDataType.ContainsKey(fieldIndex)) then
  begin
    t := FFieldDataType[fieldIndex];
    case t of
      varDate:
        Result := StrToDateTime(fieldText, FormatSettings);
      varBoolean:
        Result := StrToBool(fieldText);
      varCurrency:
        Result := StrToCurr(ClearCurrencyDecorations(fieldText),
          FormatSettings);
      varSingle, varDouble:
        begin
          aux := ReplaceText(fieldText, FormatSettings.ThousandSeparator, '');
          Result := StrToFloat(aux, FormatSettings);
        end;
      varSmallInt, varShortInt, varInteger:
        Result := StrToInt(ClearNumberDecorations(fieldText));
      varInt64:
        Result := StrToInt64(ClearNumberDecorations(fieldText));
      varUInt32:
        Result := StrToUInt(ClearNumberDecorations(fieldText));
      varUInt64:
        Result := StrToUInt64(ClearNumberDecorations(fieldText));
      varNull:
        Result := Null;
      varByte, varWord:
        Result := StrToUInt('$' + ClearHexPrefix(fieldText));
    else
      Result := inherited;
    end;
  end
  else
    Result := inherited;
end;

// ----------------------------------------------------------------------------

end.
