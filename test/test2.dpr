program test2;

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
    csv.IgnoreWhiteSpaces := true;
    csv.IgnoreFieldSeparatorAtEndOfLine := true;
    csv.FieldSeparator := ';';

    WriteLn('## Input, relaxed rules, separator = ;');
    WriteLn;
    WriteLn('== Test valid input');
    WriteLn;

    WriteLn('-- Parse valid text line, 3 fields, unquoted');
    csv.AsText := 'a ; b; c ';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], 'c');

    WriteLn('-- Parse valid text line, 3 fields, quoted');
    csv.AsText := '"a " ; " b "; "c " ';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a ');
    assert('Field 2', csv.Field[1], ' b ');
    assert('Field 3', csv.Field[2], 'c ');

    WriteLn('-- Parse valid text line, 2 fields, unquoted, separator at EOL');
    csv.AsText := 'a; b;';
    assert('Field count', csv.FieldCount, 2);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');

    WriteLn('-- Parse valid text line, 2 fields, separator at EOL, white spaces');
    csv.AsText := 'a; "b";  ';
    assert('Field count', csv.FieldCount, 2);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');

    WriteLn('-- Parse valid text line, 3 fields, last empty, no separator at EOL');
    csv.AsText := 'a; "b"; "" ';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], '');

    WriteLn('-- Parse single empty field, unquoted, separator at EOL');
    csv.AsText := ';';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], '');

    WriteLn('-- Parse single empty field, quoted, separator at EOL');
    csv.Clear;
    csv.AsText := '"";';
    assert('Field count', csv.FieldCount, 1);
    assert('Field 1', csv.Field[0], '');

    WriteLn('-- Parse 3 empty fields, white spaces, separator at EOL');
    // ____________123456789
    csv.AsText := '  ;  ;  ;';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], '');
    assert('Field 2', csv.Field[1], '');
    assert('Field 3', csv.Field[2], '');

    csv.Free;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Paused...');
  ReadLn;

end.
