program test1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  CSVUtils in '..\src\CSVUtils.pas',
  CSVAssertions in 'CSVAssertions.pas';

var
  csv: TCSVRecord;

begin
  try
    csv := TCSVRecord.Create;

    WriteLn('## Input, RFC4180 rules');
    WriteLn;
    WriteLn('== Test valid input');
    WriteLn;

    WriteLn('-- Default property values');
    assert('Field count', csv.FieldCount, 0);
    assert('FieldEnclosure', csv.FieldEnclosure, '"');
    assert('FieldSeparator', csv.FieldSeparator, ',');
    assert('ForceFieldCount', csv.ForceFieldCount, 0);
    assert('IgnoreEmptyLines', csv.IgnoreEmptyLines, false);
    assert('IgnoreWhiteSpaces', csv.IgnoreWhiteSpaces, false);
    assert('IgnoreFieldDelimiterAtEndOfLine',
      csv.IgnoreFieldSeparatorAtEndOfLine, false);

    WriteLn('-- Parse valid text line, 3 fields, unquoted');
    csv.AsText := 'a,b, c ';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], ' c ');

    WriteLn('-- Parse valid text line, 1 field, unquoted');
    csv.AsText := 'abc';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], 'abc');

    WriteLn('-- Parse empty record');
    csv.AsText := '';
    assert('Empty record (FieldCount)', csv.FieldCount, 0);

    WriteLn('-- Parse empty field at middle, unquoted');
    csv.AsText := 'a,,c';
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], '');
    assert('Field 3', csv.Field[2], 'c');

    WriteLn('-- Parse empty field at end of line, unquoted');
    csv.AsText := 'a,b,';
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], '');

    WriteLn('-- Parse 4 empty fields, unquoted');
    csv.AsText := ',,,';
    assert('Field count', csv.FieldCount, 4);
    assert('Field 1', csv.Field[0], '');
    assert('Field 2', csv.Field[1], '');
    assert('Field 3', csv.Field[2], '');
    assert('Field 4', csv.Field[3], '');

    WriteLn('-- Parse valid text line, 1 field, quoted (spaces)');
    csv.AsText := '" a bc "';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], ' a bc ');

    WriteLn('-- Parse valid text line, 1 field, quoted (escaped)');
    csv.AsText := '"a""b""c"';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], 'a"b"c');

    WriteLn('-- Parse valid text line, 1 field, quoted (separator)');
    csv.AsText := '"a,c"';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], 'a,c');

    WriteLn('-- Parse valid text line, 1 field, quoted (new line)');
    csv.AsText := '"a' + sLineBreak + 'bc"';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], 'a'+sLineBreak+'bc');

    WriteLn('-- Parse valid text line, 3 fields, quoted');
    csv.AsText := '"a","b","c"';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], 'c');

    WriteLn('-- Parse empty field at middle, quoted');
    csv.AsText := 'a,"",c';
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], '');
    assert('Field 3', csv.Field[2], 'c');

    WriteLn('-- Parse empty field at end of line, quoted');
    csv.AsText := 'a,b,""';
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], '');

    WriteLn('-- Parse 4 empty fields, quoted');
    csv.AsText := '"","","",""';
    assert('Field count', csv.FieldCount, 4);
    assert('Field 1', csv.Field[0], '');
    assert('Field 2', csv.Field[1], '');
    assert('Field 3', csv.Field[2], '');
    assert('Field 4', csv.Field[3], '');

    WriteLn;
    WriteLn('== Test invalid input');
    WriteLn;

    WriteLn('-- Clear');
    csv.Clear;
    assert('Field count', csv.FieldCount, 0);
    assertException('index out of bounds test', EArgumentOutOfRangeException,
      procedure
      begin
        WriteLn(csv.Field[2]);
      end);

    WriteLn('-- Parse illformed unquoted field');
    assertException('a"b,cd', ECSVSyntaxError,
      procedure
      begin
        csv.AsText := 'a"b,cd';
      end);

    WriteLn('-- Parse illformed quoted field: not matching enclosure');
    assertException('"abc,e', ECSVWrongFieldEnclosing,
      procedure
      begin
        csv.AsText := '"abc,e';
      end);
    assertException('"abc"",e', ECSVWrongFieldEnclosing,
      procedure
      begin
        csv.AsText := '"abc"",e';
      end);

    WriteLn('-- Parse illformed quoted field: non escaped enclosure');
    assertException('"a"b"', ECSVSyntaxError,
      procedure
      begin
        csv.AsText := '"a"b"';
      end);

    WriteLn('-- Parse illformed quoted field: text after enclosure');
    assertException('ab,"ab" ,d', ECSVSyntaxError,
      procedure
      begin
        csv.AsText := 'ab,"ab" ,d';
      end);
    assertException('ab,"ab"c,d', ECSVSyntaxError,
      procedure
      begin
        csv.AsText := 'ab,"ab"c,d';
      end);

    csv.Free;
  except
    on E: System.SysUtils.Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Paused...');
  ReadLn;

end.
