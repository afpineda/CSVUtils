program test101;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  CSVUtils in '..\src\CSVUtils.pas';

function GetStdHandle(nStdHandle: LongInt): LongWord; Stdcall;
  External 'Kernel32.dll';

const
  STD_OUTPUT_HANDLE = -11;

var
  strm: THandleStream;
  writer: TStreamWriter;
  csv: TCSVRecord;

begin
  csv := TCSVRecord.Create;
  try
    strm := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
    try
      writer := TStreamWriter.Create(strm);
      try
        WriteLn('## Stream output, RFC4180 rules');

        WriteLn('-- simple record');
        csv.FieldCount := 2;
        csv.field[0] := 'a';
        csv.field[1] := 'b';
        csv.Write(writer);

        WriteLn('-- Line break inside a field');

        csv.field[0] := 'line'#10#13'break';
        csv.Write(writer);

        WriteLn('-- empty field');

        csv.Clear;
        csv.Write(writer);
        WriteLn('(Ensure an empty line appears before this one)');

        WriteLn('-- ignored empty field');
        csv.IgnoreEmptyLines := true;
        csv.Write(writer);
        WriteLn('(Ensure no empty line appears before this one)');

      finally
        writer.Free;
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
