unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ExtDlgs;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnLoad: TButton;
    btnPreprocess: TButton;
    btnRecognize: TButton;
    huruf_sandi: TEdit;
    imgMod: TImage;
    imgSrc: TImage;
    Label1: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure btnLoadClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  windows, math;

var
  bitmapR, bitmapG, bitmapB : array[0..1000, 0..1000] of integer;
  bitmapGray, bitmapBiner   : array[0..1000, 0..1000] of integer;

{ TForm1 }

procedure TForm1.btnLoadClick(Sender: TObject);
var
  x, y          : integer;
  R, G, B, Gray : integer;

begin
  if(OpenPictureDialog1.Execute) then
  begin
    imgSrc.Picture.LoadFromFilE(OpenPictureDialog1.FileName);
  end;

  for y := 0 to imgSrc.Height-1 do
  begin
    for x := 0 to imgSrc.Width-1 do
    begin
      R    := GetRValue(imgSrc.Canvas.Pixels[x, y]);
      G    := GetGValue(imgSrc.Canvas.Pixels[x, y]);
      B    := GetBValue(imgSrc.Canvas.Pixels[x, y]);
      Gray := (R + G + B) div 3;

      bitmapR[x, y] := R;
      bitmapG[x, y] := G;
      bitmapB[x, y] := B;

      bitmapGray[x, y] := Gray;
      if Gray > 127 then
        bitmapBiner[x, y] := 1
      else
        bitmapBiner[x, y] := 0;
    end;
  end;
end;

end.

