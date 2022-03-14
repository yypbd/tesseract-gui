unit Form.TesseractGUIMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Process;

type

  { TFormTesseractGUIMain }

  TFormTesseractGUIMain = class(TForm)
    ButtonClipboardToText: TButton;
    ButtonImageToText: TButton;
    LabeledEditLanguageOption: TLabeledEdit;
    MemoResult: TMemo;
    OpenDialogImage: TOpenDialog;
    PanelTop: TPanel;
    procedure ButtonClipboardToTextClick(Sender: TObject);
    procedure ButtonImageToTextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function ConvertImageToText(const AImageFileName: string): string;
  public

  end;

var
  FormTesseractGUIMain: TFormTesseractGUIMain;

implementation

uses
  Clipbrd;

{$R *.lfm}

{ TFormTesseractGUIMain }

procedure TFormTesseractGUIMain.ButtonClipboardToTextClick(Sender: TObject);
var
  OutString: string;
  TempImageFileName: string;
  Bitmap: TBitmap;
begin
  if not Clipboard.HasPictureFormat then
  begin
    ShowMessage('Not image format.');
    Exit;
  end;

  TempImageFileName := GetTempDir + 'tesseractgui.bmp';
  Bitmap := TBitmap.Create;
  Clipboard.AssignTo(Bitmap);
  Bitmap.SaveToFile(TempImageFileName);
  Bitmap.Free;

  OutString := ConvertImageToText(TempImageFileName);
  MemoResult.Lines.Text := OutString;
end;

procedure TFormTesseractGUIMain.ButtonImageToTextClick(Sender: TObject);
var
  OutString: string;
begin
  if OpenDialogImage.Execute then
  begin
    OutString := ConvertImageToText(OpenDialogImage.FileName);
    MemoResult.Lines.Text := OutString;
  end;
end;

procedure TFormTesseractGUIMain.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
end;

function TFormTesseractGUIMain.ConvertImageToText(const AImageFileName: string
  ): string;
var
  OutString: string;
  ExePath: string;
begin
  // https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html

  ExePath := 'tesseract';

  {$IFDEF Darwin}
  ExePath := '/opt/homebrew/bin/tesseract';
  {$ENDIF}

  {$IFDEF Windows}
  {$ENDIF}

  {$IFDEF LINUX}
  {$ENDIF}

  Result := '';
  if Trim(LabeledEditLanguageOption.Text) = '' then
  begin
    if RunCommand(ExePath, [AImageFileName, 'stdout'], OutString) then
    begin
      Result := OutString;
    end;
  end
  else
  begin
    if RunCommand(ExePath, ['-l', Trim(LabeledEditLanguageOption.Text), AImageFileName, 'stdout'], OutString) then
    begin
      Result := OutString;
    end;
  end;
end;

end.

