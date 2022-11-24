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
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

