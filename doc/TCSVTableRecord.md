# CSVUtils.Table.TCSVTableRecord

Up to parent: [CSVUtils.TCSVRecord](./TCSVRecord.md)

`TCSVTableRecord` is an abstraction of a single CSV record where data types are known for each field (or "column").
For this reason, the count of fields should be fixed in advance by setting `TCSVRecord.ForceFieldCount`.
However, this is not enforced for flexibility. At reading, fields are parsed using
`TCSVRecord.FormatSettings` for the previously given data type.
If no data type was given, the corresponding field is retrieved as a *string*.
Example:

```pascal
...
csv := TCSVTableRecord.Create;
csv.ForceFieldCount := 3;
csv.FieldDataType[0] := varDate;
csv.FieldDataType[1] := varUInt64;
// since not given, csv.FieldDataType[2] := varString;

while (csv.Read(streamReader)) do
try
  date := csv.Field[0];
  number := csv.Field[1];
  str := csv.Field[2];
  ...
except
   on E:EConvertError do
      // Handle typecast errors here
      ...
end;
```

At writting, this class does not differ from its parent.

## Properties

- `TCSVTableRecord.FieldDataType[]`: expected data type for a field

  You may set a data type for any non-negative field's index, including non-existing ones (no exception is raised).
  Data types are expressed as [TVarType](https://www.freepascal.org/docs-html/rtl/system/tvartype.html):
  
  | TVarType                               | Format                                                                 | Example (USA locale) |
  | -------------------------------------- | ---------------------------------------------------------------------- | -------------------- |
  | varBoolean                             | true/false or 0/-1                                                     | true                 |
  | varCurrency                            | A float number. May include a currency symbol and thousands separators | $ 1,230,300.67       |
  | varSingle/varDouble                    | A float number. May include thousands separators                       | 1230.03              |
  | varSmallInt / varShortInt / varInteger | A signed integer. May include thousands separators                     | -1,230               |
  | varUInt32 / varUInt64                  | An unsigned integer. May include thousands separators                  | 233,112,517          |
  | varNull                                | No matter the contents of the field, Null is retrieved                 | "anything"           |
  | varByte / varWord                      | An hexadecimal number. May include *$* or *0X* as prefix               | 0xFF0A               |
  | varDate                                | A date/time (driven by `TFormatSettings.ShortDateFormat`)              | 2023-06-25 16:55:00  |
  | (Other)                                | A string                                                               | This is text         |

  Note that `TCSVRecord.FormatSettings` will drive the exact format of those data types.

## Exceptions

- `EConvertError`: may be raised if the actual field does not match the expected format at `TCSVRecord.Read` or `TCSVRecord.AsText := ...`

## Source unit

```pascal
uses
  CSVUtils.Table;
```
