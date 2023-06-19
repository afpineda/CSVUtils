program test201;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  CSVUtils in '..\src\CSVUtils.pas',
  CSVAssertions in 'CSVAssertions.pas';

var
  strm: TStringStream;
  reader: TStreamReader;
  csv: TCSVRecord;
  text: string;
  c: integer;

begin
  c := 0;
  text := '# commentary' + sLineBreak + 'a,b,c' + sLineBreak + sLineBreak
    + 'c,b,a';
  WriteLn('## Take note of CSV test case:');
  WriteLn(text);
  WriteLn('----------------------------');

  try
    csv := TCSVRecord.Create;
    strm := TStringStream.Create(text);
    try
      WriteLn('## Input from stream, default rules');
      dump(strm, csv);
      WriteLn('## Again (test for side effects)');
      dump(strm, csv);

      WriteLn('## Input from stream, ignore empty lines');
      csv.IgnoreEmptyLines := true;
      dump(strm, csv);

      WriteLn('## Input from stream, allow empty lines, ignore commentaries');
      csv.IgnoreEmptyLines := false;
      csv.CommentaryChar := '#';
      dump(strm, csv);

      WriteLn('## Input from stream, ignore empty lines and commentaries');
      csv.IgnoreEmptyLines := true;
      dump(strm, csv);

    finally
      strm.Free;
    end;

    csv.Free;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
  WriteLn('Paused...');
  ReadLn;

end.
