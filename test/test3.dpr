program test3;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  CSVAssertions in 'CSVAssertions.pas',
  CSVUtils in '..\src\CSVUtils.pas';

var
  csv: TCSVRecord;

begin
  try

    csv := TCSVRecord.Create;
    csv.ForceFieldCount := 3;

    WriteLn('## Input, RFC4180 rules, table-like operation');
    WriteLn('== Test valid input');
    WriteLn;

    WriteLn('-- no input');
    csv.Clear;
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], '');
    assert('Field 2', csv.Field[1], '');
    assert('Field 3', csv.Field[2], '');

    WriteLn('-- more data than columns');
    csv.AsText := 'a,b,c,d,e';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], 'c');
    assertException('out of index', EArgumentOutOfRangeException,
      procedure
      begin
        WriteLn(Format('Should not see this: %s', [csv.Field[3]]));
      end);

    WriteLn('-- less data than columns');
    csv.AsText := 'a,b';
    assert('Field count', csv.FieldCount, 3);
    assert('Field 1', csv.Field[0], 'a');
    assert('Field 2', csv.Field[1], 'b');
    assert('Field 3', csv.Field[2], '');

    csv.Free;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Paused...');
  ReadLn;

end.
