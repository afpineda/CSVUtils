# CSVUtils.TCSVRecord

`TCSVRecord` is an abstraction of a single CSV record, both for input (parsing) and/or output. The expected CSV syntax is set through "global" properties (see below).
By default, RFC 4180 syntax rules apply.

- **Reading**:

  Text data can be read from any `TStreamReader` object by the means of `TCSVRecord.Read()`. Any concern about character encoding or line breaks should be handled at `TSreamReader`. Alternatively, text data can be parsed from a single string by writing to `TCSVRecord.AsText`. In the later case, a single record is expected. Example:

  ```pascal
  csv := TCSVRecord.Create;
  stream := TStreamReader.Create(...);
  try 
    while (csv.Read(stream)) do
    begin
        // do something with csv.Fields[]
    end;
  finally 
    csv.Free;
    stream.Free;
  end;
  ```

- **Writing**:

  Call `TCSVRecord.Clear` to start with an empty record. Then, write `TCSVRecord.FieldCount` to set a number of fields. Then, write data to the `TCSVRecord.Field[]` array. Since this array is of type [Variant](https://wiki.freepascal.org/Variant), any variant-compatible data type will be accepted. Such data will be converted to
  CSV text when reading `TCSVRecord.AsText` or calling `TCSVRecord.Write()`. Some "global" properties may affect how CSV text is generated. Example:

  ```pascal
  csv := TCSVRecord.Create;
  stream := TStreamWriter.Create(...);
  try 
    while (some_condition) do
    begin
        csv.Clear;
        csv.FieldCount := N;
        csv.Field[0] := ...
        csv.Field[1] := ...
        ...
        csv.Field[N-1] := ...
        csv.Write(stream);
    end;
  finally 
    csv.Free;
    stream.Free;
  end;
  ```

## Record properties

These properties allows access to record data and meta-data.

- `TCSVRecord.FieldCount`:

  The number of fields (or "columns") in the current record. If `TCSVRecord.ForceFieldCount` is greater than zero, this field has a fixed value and any attempt to write a different value will raise `EArgumentException`. Otherwise, any positive value can be set. Existing fields will be respected. Non-existing fields will be initialized to `Null`.

- `TCSVRecord.Field[]`:

  Read or write a single field. Index is in the range from 0 to `TCSVRecord.FieldCount` - 1.
  When parsing CSV text, there is **no typecast attempt** (by default) because the expected data type is unknown, so data is retrieved as a *string*.
  This behaviour may change by overriding `TCSVRecord.StringToField`.
  Use one of the `TCSVRecord.FieldAs*[]` properties for typecasting using `TCSVRecord.FormatSettings`.

- `TCSVRecord.FieldAsString[]`:

  The same as `TCSVRecord.Field[]` but data will be forcedly casted to *string* type using `TCSVRecord.FormatSettings`.
  Read-only. Note that `Null` values will be converted to empty strings by default.

- `TCSVRecord.FieldAsDateTime[]`:

  The same as `TCSVRecord.Field[]` but data will be forcedly casted to [TDateTime](https://wiki.freepascal.org/TDateTime) using `TCSVRecord.FormatSettings`. Read-only. May raise an exception.  

- `TCSVRecord.FieldAsFloat[]`:

  The same as `TCSVRecord.Field[]` but data will be forcedly casted to [Extended](https://wiki.freepascal.org/IEEE_754_formats#extended) using
  `TCSVRecord.FormatSettings`. Read-only. May raise an exception.

- `TCSVRecord.AsText`:

  A CSV-formatted representation of the current record. Both for reading and writing. `TCSVRecord.FormatSettings` applies. Use this property to parse or
  generate CSV text for other objects rather than streams.

## Public methods

- `TCSVRecord.Assign(const source: TCSVRecord)`: copy source to this instance.
- `TCSVRecord.Clear`: clear current data and start with a new fresh empty record.
- `TCSVRecord.ForEach(reference to procedure (field: Variant; index: integer))`: run the given procedure for each field (in ascending order of index).
- `TCSVRecord.Read(const from: TStreamReader)`: read a CSV record from the given stream. Return value is *false* at end of stream, *true* otherwise.
- `TCSVRecord.UseRFC4180`: force RFC 4180 syntax rules. A shortcut to other "global" properties.
- `TCSVRecord.Write(const to: TStreamWriter)`: write the current record as CSV-formatted text to the given stream.

## Global properties

These properties will determine the behavior of future calls to `TCSVRecord.Read`, `TCSVRecord.Write` or `TCSVRecord.AsText`. However, a change in these properties will not affect the current record.

- `TCSVRecord.FieldEnclosure`: a character used for field enclosing. By default, double-quotes.

  Field enclosing may be disabled by setting this property to `#0` (**not recommended**). `ECSVCharNotAllowed` is raised if the given character conflicts
  with other syntax rules.

- `TCSVRecord.FieldSeparator`: a character to separate one field from the next. By default, comma.

  `ECSVCharNotAllowed` is raised if the given character conflicts with other syntax rules.

- `TCSVRecord.CommentaryChar`: by default, `#0` (none).

  When reading, any text line starting with this character will be ignored as a text commentary. Set to `#0` to disable this feature.
  `ECSVCharNotAllowed` is raised if the given character conflicts with other syntax rules.

- `TCSVRecord.IgnoreEmptyLines`: by default, false.

  When *true*, `TCSVRecord.Read()` will ignore empty lines and move to the next record. `TCSVRecord.Write()` will not output empty lines from empty records.
  When *false*, an empty line will cause an empty record. This property does not apply to `TCSVRecord.AsText`.

- `TCSVRecord.IgnoreFieldSeparatorAtEndOfLine`: by default, false.

  - At reading:

    When *true*, the rightmost field separator will be ignored when followed by the end of the record. If `TCSVRecord.IgnoreWhiteSpaces` is also *true*, white spaces between such a separator and the end of the record will also be ignored. For example: `a,b,c,` will be parsed as `a,b,c`.

    When *false*, such a separator will add an empty field to the record.

  - At writing:

    When *true* a field separator will be added to the right of each field. When *false*, RFC 4180 rules apply.

- `TCSVRecord.IgnoreWhiteSpaces`: by default, false.

  - At reading:

    When *true*, any white space at the beginning of the record, the end of the record, or around a field separator will be ignored. For example,
    `     a,    "b and 1"    ,     c       ` will be parsed as `a,"b and 1",c`.

    When *false*, every white space is part of the corresponding field.

  - At writing:

    When *true*, white spaces at the beginning or the end of each **field** will be trimmed (mostly for the *string* data type). When *false*, there is no effect.

- `TCSVRecord.MaxRecordLength`: by default, zero.

  When set to *zero or negative*, this property has no effect. Any *positive* value will set a maximum size limit (in characters) for all records. This may help in the detection of non-CSV text (or ill-formed fields) at `TCSVRecord.Read()` . This property has no effect in `TCSVRecord.Write()` nor `TCSVRecord.AsText`.

- `TCSVRecord.ForceFieldCount`: by default, zero.

  When set to *zero or negative*, this property has no effect. Any *positive* value will set an exact field (or "column") count to every record. Missing fields will be added as `Null`. On the other side, rightmost extra fields will be ignored. This mode will help in reading CSV data as a relational table.
  This property applies both at reading and writing.

- `TCSVRecord.FormatSettings`: by default, current locale.
  
  Custom format settings for data-to-CSV conversion. Applies to date/time and float data, only.

## Exceptions

- `ECSVSyntaxError`: any syntax-related error at parsing.
  - `ECSVWrongFieldEnclosing`: any incorrect enclosing of a field due to non-terminating quotes, incorrectly escaped quotes, or text outside of the enclosing.
  - `ECSVMaxRecordLength`: maximum record length was exceeded at `TCSVRecord.Read()`.
- `ECSVCharNotAllowed`: syntax rules does not allow a certain character as field separator, field enclosure or commentary.
  In particular, the same character is not allowed for two of those properties.

## Protected methods

- `TCSVRecord.OnCommentaryLine(const text: string)`: may be called when parsing CSV text.

  Override this method to provide custom processing of commentary lines. Will never be called if `TCSVRecord.CommentaryChar` is `#0`.
  Otherwise, will be called on each commentary line (if any). `text` includes the leading commentary character. Default implementation does nothing.

- `TCSVRecord.StringToField(const fieldIndex: integer; const fieldText: string, const enclosed: boolean)`: called to parse a field (as text) into a variant type.

  By default, this method returns the source string "as is". Derive a new class and override this method to parse specific or custom data types.
  You should know (or guess) which data type applies to each field (or "column") in advance,
  which is not part of the CSV specification. `enclosed` is *true* if the given field was enclosed in quotation marks, *false* otherwise.
  This information may be useful. For example, you may cast *1033* into an integer variant, but *"1033"* into a string.
  Gets called when parsing CSV text at `TCSVRecord.Read` or `TCSVRecord.AsText := ...`.

- `TCSVRecord.FieldToString(const fieldIndex: integer; const field: Variant)`: used to cast any variant type to string.

  This method gets called when converting data to CSV text (`TCSVRecord.Write` or `... := TCSVRecord.AsText`) and at `TCSVRecord.FieldAsString[]`.
  Derive a new class and override this method to provide your own formatting. By default, `TCSVRecord.FormatSettings` drives the conversion of (variant) fields.
  The following data types are properly formatted:
  - Boolean
  - Date or time
  - Float number
  - Currency
  - Signed and and unsigned integers

  For other data types, [`VarToStr`](https://www.freepascal.org/docs-html/rtl/variants/vartostr.html) is used.

## Source unit

```pascal
uses
  CSVUtils;
```

## See also

- [TCSVTableRecord](TCSVTableRecord.md)

