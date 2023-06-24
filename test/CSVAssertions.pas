unit CSVAssertions;

interface

uses
  System.Classes,
  System.SysUtils,
  variants,
  CSVUtils;

type
  TAssertionType = (eq, notEq);

const
  lineBreak = {$IFDEF LINUX} (#10) {$ENDIF}
{$IFDEF MSWINDOWS} (#13#10) {$ENDIF};

procedure assert(const id: string; const actual, expected: Variant;
  t: TAssertionType = eq);

procedure assertException(const id: string; E: TClass; block: TProc);

procedure dump(strm: TStream; csv: TCSVRecord);

implementation

procedure assert(const id: string; const actual, expected: Variant;
  t: TAssertionType);
var
  str1, str2: string;
  comp: integer;
begin
  str1 := VarToStr(actual);
  str2 := VarToStr(expected);
  comp := CompareText(str1, str2);
  if ((comp <> 0) and (t = eq)) or ((comp = 0) and (t = notEq)) then
    WriteLn(Format('%s | Expected: %s. Found: %s', [id, str2, str1]));
end;

procedure assertException(const id: string; E: TClass; block: TProc);
begin
  try
    block;
    WriteLn(Format('%s | Exception %s expected, but not found',
      [id, E.ClassName]));
  except
    on Exc: Exception do
      if (E <> Exc.ClassType) then
        WriteLn(Format('%s | Unexpected exception %s', [id, Exc.ClassName]));
  end;
end;

procedure dump(strm: TStream; csv: TCSVRecord);
var
  reader: TStreamReader;
  c: cardinal;
  index: integer;
begin
  c := 0;
  strm.Seek(0, soBeginning);
  reader := TStreamReader.Create(strm);
  try
    while csv.Read(reader) do
    begin
      inc(c);
      Write(c);
      Write(' | ');
      for index := 0 to csv.FieldCount - 1 do
      begin
        Write(csv.FieldAsString[index]);
        Write(' | ');
      end;
      WriteLn;
    end;
    WriteLn('----------------------------');
  finally
    reader.Free;
  end;
end;

end.
