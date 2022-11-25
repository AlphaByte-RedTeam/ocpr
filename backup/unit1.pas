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
    procedure btnPreprocessClick(Sender: TObject);
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
  bitmapGray, bitmapBiner, bitmapBiner2   : array[0..1000, 0..1000] of integer;

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

procedure TForm1.btnPreprocessClick(Sender: TObject);
var
  x, y    : integer;
  i, j    : integer;
  tepi_atas_y  : integer;
  tepi_bawah_y : integer;
  tepi_kiri_x  : integer;
  tepi_kanan_x : integer;

begin
  // mengambil nilai tepi atas
  for y := 0 to imgSrc.Height - 1 do
  begin
    for x := 0 to imgSrc.Width - 1 do
    begin
      if (bitmapBiner[x, y] = 0) then
      begin
        tepi_atas_y := y;
        break;
      end;
    end;
    if (bitmapBiner[x, y] = 0) then
    begin
      break;
    end;
  end;

  // mengambil nilai tepi bawah
  for y := imgSrc.Height - 1 downto 0 do
  begin
    for x := 0 to imgSrc.Width - 1 do
    begin
      if (bitmapBiner[x, y] = 0) then
      begin
        tepi_bawah_y := y;
        break;
      end;
    end;
    if (bitmapBiner[x, y] = 0) then
    begin
      break;
    end;
  end;

  // mengambil nilai tepi kiri
  for x := 0 to imgSrc.Width - 1 do
  begin
    for y := 0 to imgSrc.Height - 1 do
    begin
      if (bitmapBiner[x, y] = 0) then
      begin
        tepi_kiri_x := x;
        break;
      end;
    end;
    if (bitmapBiner[x, y] = 0) then
    begin
      break;
    end;
  end;

  // mengambil nilai tepi kanan
  for x := imgSrc.Width - 1 downto 0 do
  begin
    for y := 0 to imgSrc.Height - 1 do
    begin
      if (bitmapBiner[x, y] = 0) then
      begin
        tepi_kanan_x := x;
        break;
      end;
    end;
    if (bitmapBiner[x, y] = 0) then
    begin
      break;
    end;
  end;

  // mengambil nilai bitmap daerah yang dipotong
  for j := tepi_atas_y to tepi_bawah_y do
  begin
    for i := tepi_kiri_x to tepi_kanan_x do
    begin
      bitmapBiner2[i - tepi_kiri_x, j - tepi_atas_y] := bitmapBiner[i, j];
    end;
  end;

  // mengatur tinggi dan lebar gambar setelah dipotong
  imgMod.Width := tepi_kanan_x - tepi_kiri_x;
  imgMod.Height := tepi_bawah_y - tepi_atas_y;

  //menampilkan pixel ke gambar setelah dipotong
  for y := 0 to imgMod.Height do
  begin
    for x := 0 to imgMod.Width do
    begin
      if (bitmapBiner2[x, y] = 0) then
        imgMod.Canvas.Pixels[x, y] := RGB(0, 0, 0)
      else
        imgMod.Canvas.Pixels[x, y] := RGB(255, 255, 255);
    end;
  end;
end;

end.

