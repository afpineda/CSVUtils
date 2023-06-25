# Comma-Separated Values (CSV) library for Delphi/FreePascal

A small object-pascal library for [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) (and the like) handling (read and write).

## Features

- Support for both [RFC 4180](https://www.rfc-editor.org/rfc/rfc4180) and other syntax rules
- Any field separator (comma by default)
- Any text enclosure qualifier (double-quotes by default) with escaping rules
- Records ending with a field separator (optional)
- Ignoring white spaces around fields (optional)
- Line breaks inside a field
- Ignoring empty lines (optional)
- Ignoring commented lines (optional)
- Variable field count on each record (optional)
- Fixed field count for all records (optional)
- Any field data type ([variant](https://wiki.freepascal.org/Variant))
- Custom locale (optional)

## Usage

Copy [CSVUtils.pas](./src/CSVUtils.pas) to your project folder, then add to your Delphi/FreePascal project file. Respect the [license](./LICENSE.md). Nothing else is required.

Automated test units are found in the [test](./test/TestSuite.groupproj) folder. No external testing library is required.

## API documentation

- [CSVUtils.TCSVRecord](./doc/TCSVRecord.md)
- [CSVUtils.Table.TCSVTableRecord](./doc/TCSVTableRecord.md)
