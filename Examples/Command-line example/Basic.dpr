program Basic;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  clFFT in '..\..\Source\clFFT.pas',
  System.SysUtils;

begin
  try
    { TODO -oUser -cConsole Main : Code hier einfügen }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

