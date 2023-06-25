program test4;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.DateUtils,
  CSVAssertions in 'CSVAssertions.pas',
  CSVUtils in '..\src\CSVUtils.pas';

var
  csv: TCSVRecord;
  dt: TDateTime;
  fs: TformatSettings;

begin
  try
    csv := TCSVRecord.Create;

    WriteLn('## Output, RFC4180 rules');
    WriteLn('== Test valid input');
    WriteLn('**NOTE**: This test depends on spanish REGIONAL SETTINGS');
    WriteLn;

    WriteLn('-- no record');
    csv.Clear;
    assert('Field count', csv.FieldCount, 0);
    assert('empty record', csv.AsText, '');

    WriteLn('-- 4 empty fields');
    csv.Clear;
    csv.FieldCount := 4;
    assert('Field count', csv.FieldCount, 4);
    assert('record', csv.AsText, ',,,');

    WriteLn('-- 3 text fields no special chars, on the go');
    csv.Clear;
    csv.FieldCount := 1;
    csv.Field[0] := 'a';
    csv.FieldCount := 2;
    csv.Field[1] := 'b';
    csv.FieldCount := 3;
    csv.Field[2] := 'c';
    assert('Field count', csv.FieldCount, 3);
    assert('record', csv.AsText, 'a,b,c');

    WriteLn('-- text fields with special chars');
    csv.Clear;
    csv.FieldCount := 5;
    csv.Field[0] := ' a ';
    csv.Field[1] := '"b"';
    csv.Field[2] := 'c' + sLineBreak + 'd';
    csv.Field[3] := 'e,f';
    csv.Field[4] := '""g""';
    assert('Field count', csv.FieldCount, 5);
    assert('record', csv.AsText, '" a ","""b""","c' + sLineBreak +
      'd","e,f","""""g"""""');

    WriteLn('-- number fields');
    csv.Clear;
    csv.FieldCount := 9;
    csv.Field[0] := byte(123);
    csv.Field[1] := 42.5;
    csv.Field[2] := Int16(-16001);
    csv.Field[3] := Int32(111333444);
    csv.Field[4] := Int64(-111333444);
    csv.Field[5] := true;
    csv.Field[6] := UInt16(65530);
    csv.Field[7] := UInt32(111333444);
    csv.Field[8] := UInt64(444333222);

    assert('Field count', csv.FieldCount, 9);
    assert('record', csv.AsText,
      '123,"42,5",-16001,111333444,-111333444,-1,65530,111333444,444333222');

    WriteLn('-- date fields');
    csv.Clear;
    csv.FieldCount := 2;
    dt := EncodeDate(2023, 1, 1);
    csv.Field[0] := dt;
    dt := EncodeDateTime(2023, 1, 1, 10, 59, 2, 31);
    csv.Field[1] := dt;
    assert('Field count', csv.FieldCount, 2);
    assert('record', csv.AsText, '01/01/2023,"01/01/202310:59:02"');

    WriteLn;
    WriteLn('== Test custom locale');
    WriteLn;

    fs := TformatSettings.Create;
    fs.DateSeparator := '-';
    fs.DecimalSeparator := 'd';
    fs.ShortDateFormat := 'yyyy-mm-dd';
    csv.FormatSettings := fs;

    WriteLn('-- number fields');
    csv.Clear;
    csv.FieldCount := 2;
    csv.Field[0] := 123;
    csv.Field[1] := 42.5;
    assert('Field count', csv.FieldCount, 2);
    assert('record', csv.AsText, '123,42d5');

    WriteLn('-- date fields');
    csv.Clear;
    csv.FieldCount := 2;
    dt := EncodeDate(2023, 1, 1);
    csv.Field[0] := dt;
    dt := EncodeDateTime(2023, 1, 1, 10, 59, 2, 31);
    csv.Field[1] := dt;
    assert('Field count', csv.FieldCount, 2);
    assert('record', csv.AsText, '2023-01-01,"2023-01-01 10:59:02"');

    WriteLn;
    WriteLn('== Test custom syntax rules');
    WriteLn;

    csv.FieldCount := 5;
    csv.Field[0] := 'a';
    csv.Field[1] := 'b';
    csv.Field[2] := '  c  ';
    csv.Field[3] := '1 or 2';
    csv.Field[4] := '2+2=4';

    csv.FieldSeparator := ';';
    csv.FieldEnclosure := '=';
    csv.IgnoreWhiteSpaces := true;
    csv.IgnoreFieldSeparatorAtEndOfLine := true;

    WriteLn('-- separator, enclosure, white spaces, separator at EOL');
    assert('record', csv.AsText, 'a;b;c;=1 or 2=;=2+2==4=;');

    WriteLn('-- line commentaries');
    csv.CommentaryChar := '#';
    csv.AsText := '#,b,c';
    assert('Field count', csv.FieldCount, 0);

    csv.Free;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Paused...');
  ReadLn;

end.
