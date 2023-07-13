program test300;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Variants,
  System.DateUtils,
  CSVUtils in '..\src\CSVUtils.pas',
  CSVUtils.Table in '..\src\CSVUtils.Table.pas',
  CSVAssertions in 'CSVAssertions.pas';

var
  csv: TCSVTableRecord;
  fs: TFormatSettings;

begin
  WriteLn('## Test of TCSVTableRecord');
  try
    WriteLn('== Test valid input');

    csv := TCSVTableRecord.Create;
    fs := TFormatSettings.Create;
    fs.CurrencyString := '€';
    fs.CurrencyFormat := 3;
    fs.CurrencyDecimals := 2;
    fs.ThousandSeparator := '.';
    fs.DecimalSeparator := ',';
    fs.DateSeparator := '-';
    fs.ShortDateFormat := 'yyyy-mm-dd';
    csv.FormatSettings := fs;

    csv.FieldDataType[0] := varBoolean;
    csv.FieldDataType[1] := varByte;
    csv.FieldDataType[2] := varCurrency;
    csv.FieldDataType[3] := varSingle;
    csv.FieldDataType[4] := varInteger;
    csv.FieldDataType[5] := varInt64;
    csv.FieldDataType[6] := varUInt32;
    csv.FieldDataType[7] := varUInt64;
    csv.FieldDataType[8] := varNull;
    csv.FieldDataType[9] := varDate;

    csv.ForceFieldCount := 11;

    WriteLn('-- Parse fields with number decorations');
    csv.AsText := 'true,0xFF,"1.200,03 €","1.203,03",-1.230,' +
      '-111222333444,54.000,111222333444,' +
      'must be null,2023-03-21 15:30:00,-1.230';

    assert('field 0', csv.field[0], boolean(true));
    assert('field 1', csv.field[1], byte(255));
    assert('field 2', csv.field[2], Extended(1200.03));
    assert('field 3', csv.field[3], Extended(1203.03));
    assert('field 4', csv.field[4], integer(-1230));
    assert('field 5', csv.field[5], Int64(-111222333444));
    assert('field 6', csv.field[6], UInt32(54000));
    assert('field 7', csv.field[7], UInt64(111222333444));
    assert('field 8', csv.field[8], Null);
    assert('field 9', csv.field[9], EncodeDateTime(2023, 3, 21, 15, 30, 0, 0));
    assert('field 10', csv.field[10], '-1.230');

    csv.Free;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Paused...');
  ReadLn;

end.
