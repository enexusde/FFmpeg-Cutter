unit ffmpeg123cutter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, FileCtrl, StdCtrls, ComCtrls, Buttons,inifiles;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter2: TSplitter;
    Panel5: TPanel;
    Splitter3: TSplitter;
    DirectoryListBox1: TDirectoryListBox;
    Label1: TLabel;
    DriveComboBox1: TDriveComboBox;
    FileListBox1: TFileListBox;
    Label2: TLabel;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    Image1: TImage;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    Edit3: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    BitBtn7: TBitBtn;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    SaveDialog1: TSaveDialog;
    procedure DriveComboBox1Change(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar2Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    tssf:string;
    procedure repaint2();
  end;

var
  Form1: TForm1;

implementation

uses StrUtils;

{$R *.dfm}

procedure TForm1.DriveComboBox1Change(Sender: TObject);
begin
 DirectoryListBox1.Drive:=DriveComboBox1.Drive;
end;

procedure TForm1.DirectoryListBox1Change(Sender: TObject);
begin
  FileListBox1.Directory:=DirectoryListBox1.Directory;
end;

function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := '';
  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
                            nil, nil, True, 0, nil,
                            PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

function GetShortName(sLongName: string): string;
var
  sShortName    : string;
  nShortNameLen : integer;
begin
  SetLength(sShortName, MAX_PATH);
  nShortNameLen := GetShortPathName(
    PChar(sLongName), PChar(sShortName), MAX_PATH - 1
  );
  if (0 = nShortNameLen) then
  begin
    // handle errors...
  end;
  SetLength(sShortName, nShortNameLen);
  Result := sShortName;
end;

procedure TForm1.FileListBox1Change(Sender: TObject);
var t,c,p:string;
    h,m,s:integer;
    dp1,dp2,dp3,ts:cardinal;
begin
  if FileListBox1.FileName<>'' then
  begin
    c:=GetShortName (edit2.Text) + ' -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal '+GetShortName(FileListBox1.FileName);
    memo1.Lines.Add(c);
    t:=GetDosOutput(c, ExtractFilePath(Edit2.Text));
    label5.Caption:=t;
    dp1:=pos(':',t);
    dp2:=PosEx(':',t,dp1+1);
    dp3:=Pos('.',t);
    h := strtoint(copy(t,0,dp1-1));
    m := strtoint(copy(t,dp1+1,dp2-dp1-1));
    s := strtoint(copy(t,dp2+1,dp3-dp2-1));
    ts := s + m *60 + h * 60 * 60;
    TrackBar1.Max:=ts;
    TrackBar1Change(sender);
    Edit3Change(sender)
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
   edit3.Text:= inttostr(TrackBar1.Position);
end;

procedure TForm1.Edit3Change(Sender: TObject);
var pc :string;
begin
  if filelistbox1.filename<>'' then
  begin
    DeleteFile(tssf);
    pc:=GetShortName(Edit1.Text)+' -ss '+edit3.Text + ' -i ' + GetShortName(FileListBox1.FileName) +' -vframes 1 -q:v 2 '+tssf;
    Memo1.Lines.Add(pc);
    pc := GetDosOutput(pc, ExtractFilePath(Edit2.Text));
    Image1.Picture.LoadFromFile(tssf);
    TrackBar3.Min:=0;
    TrackBar3.Max:=image1.Picture.Height;
    TrackBar2.Min:=0;
    TrackBar2.Max:=image1.Picture.Width;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ini: TIniFile;
begin
  tssf:=GetShortName(ExtractFilePath(Application.ExeName))+'screenshot.bmp';
  ini:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'config.ini');
  Width := strtoint(ini.ReadString('size','width',inttostr(width)));
  height := strtoint(ini.ReadString('size','height',inttostr(height)));
  left := strtoint(ini.ReadString('pos','left',inttostr(left)));
  top := strtoint(ini.ReadString('pos','top',inttostr(top)));
  DirectoryListBox1.Directory:=ini.ReadString('file','directory',DirectoryListBox1.Directory);
end;

procedure TForm1.TrackBar1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[]) AND (TrackBar1.SelStart<>0) then
    TrackBar1.SelEnd:=TrackBar1.Position;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
begin
  TrackBar1.SelEnd := TrackBar1.Position;
    repaint2()
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
begin
  TrackBar1.SelStart := TrackBar1.Position;
    repaint2()

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  TrackBar3.SelEnd:=TrackBar3.Position;
    repaint2()
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  TrackBar3.SelStart := TrackBar3.Position;
    repaint2()
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  TrackBar2.SelStart := TrackBar2.Position;
    repaint2()
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  TrackBar2.SelEnd:=TrackBar2.Position;
    repaint2()
end;


procedure TForm1.TrackBar3Change(Sender: TObject);

begin
  repaint2();

end;

procedure TForm1.repaint2();
var ih,iw,pw,ph, vw,vh, dt,dl :integer;
    iar,par:DOUBLE;
begin
  BitBtn7.enabled := (trackbar1.SelStart <> trackbar1.SelEnd)and(trackbar2.SelStart <> trackbar2.SelEnd) and (trackbar3.SelStart<>trackbar3.SelEnd )and( image1.Picture.width > 0);
  if image1.Picture.width=0 then exit;
  ih:=image1.Picture.Height;
  iw:=image1.Picture.Width;
  ph:=image1.Height;
  pw:=image1.Width;
  iar := ih / iw;
  par:= ph/pw;

  if iar < par then
  begin
    {top space}
    vw := pw;
    vh := round(ph * iar / par);
    dl := 0;
    dt := (ph-vh) div 2;
  end
  else
  begin
    {left space}
    vw := round(pw * par / iar);
    vh := ph;
    dl := (pw-vw) div 2;
    dt := 0;
  end;
  bevel3.Left := dl + Image1.Left + round(TrackBar2.Position / iw * vw);
  bevel2.Top := dt + Image1.Top + round(TrackBar3.Position / ih * vh);
  if (TrackBar2.SelStart <> 0) then
  begin
    bevel1.Left := dl + Image1.Left + round(TrackBar2.SelStart / iw * vw);
    bevel1.Top := dt + Image1.Top + round(TrackBar3.SelStart / ih * vh);
    bevel1.Width := dl + Image1.Left + round(TrackBar2.SelEnd / iw * vw) - bevel1.left;
    bevel1.Height := dt + Image1.Top + round(TrackBar3.SelEnd / ih * vh) - bevel1.top;
  end;
//  caption:='ih:'+inttostr(ih)+', iw:'+inttostr(iw) + ', pw:'+inttostr(pw)+', ph:'+inttostr(ph) + ', iar:'+FloatToStr(iar)+ ', vw:'+inttostr(vw)+ ', vh:'+inttostr(vh) + ', dt:'+inttostr(dt)+', dl:'+inttostr(dl);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var ini: TIniFile;
begin
  ini:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'config.ini');
  ini.WriteString('size','width',inttostr(width));
  ini.WriteString('size','height',inttostr(height));
  ini.WriteString('pos','left',inttostr(left));
  ini.WriteString('pos','top',inttostr(top));
  ini.WriteString('file','directory',DirectoryListBox1.Directory);
end;
procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  repaint2()
end;

procedure TForm1.FormResize(Sender: TObject);
begin
repaint2();
end;

procedure TForm1.BitBtn7Click(Sender: TObject);
var c:string;
begin
 if SaveDialog1.Execute then
 begin
   c:=GetShortName(edit1.Text)+' -i '+GetShortName(FileListBox1.FileName) + ' -filter:v "crop='+inttostr(TrackBar2.SelEnd - TrackBar2.SelStart)+':'+inttostr(TrackBar3.SelEnd - TrackBar3.SelStart)+':'+inttostr(TrackBar2.SelStart)+':'+inttostr(TrackBar3.SelStart)+'" -ss '+inttostr(TrackBar1.SelStart) + ' -t '+inttostr(TrackBar1.SelEnd) + ' -async 1 "'+SaveDialog1.FileName+'"';
   Memo1.Lines.add(c);
   c:=GetDosOutput(c, ExtractFilePath(Edit2.Text));
   showmessage('Finished!');
 end;
end;

end.
