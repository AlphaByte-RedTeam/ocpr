unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnLoad: TButton;
    btnPreprocess: TButton;
    btnRecognize: TButton;
    Image1: TImage;
    imgSrc: TImage;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

