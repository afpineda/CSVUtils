program test202;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  CSVUtils in '..\src\CSVUtils.pas',
  CSVAssertions in 'CSVAssertions.pas';

var
  strm: TStringStream;
  csv: TCSVRecord;
  text: string;

begin
  text := 'a,b' + sLineBreak + '1234567890,0987654321';
  WriteLn('## Test of MaxRecordLength');
  WriteLn('## Take note of CSV test case:');
  WriteLn(text);
  WriteLn('----------------------------');

  try
    csv := TCSVRecord.Create;
    strm := TStringStream.Create(text);
    try
      WriteLn('## Input from stream, default rules, record limit = 25');
      csv.MaxRecordLength := 25;
      dump(strm, csv);

      WriteLn('## Input from stream, default rules, record limit = 10');
      csv.MaxRecordLength := 10;
      try
        dump(strm, csv);
      except
        on E: ECSVMaxRecordLength do
          WriteLn('(expected exception)');
        else
          raise;
      end;

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
