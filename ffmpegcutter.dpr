program ffmpegcutter;

uses
  Forms,
  ffmpeg123cutter in 'ffmpeg123cutter.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Video Cutter';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
