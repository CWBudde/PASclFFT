program Basic;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  clFFT in '..\..\Source\clFFT.pas',
  System.SysUtils;

var
  SetupData: TClFftSetupData;
begin
  try
    // initialize setup data
    ClFftInitSetupData(SetupData);

    // now setup library
    ClFftSetup(SetupData);

    // now tear down library
    ClFftTeardown;

    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

