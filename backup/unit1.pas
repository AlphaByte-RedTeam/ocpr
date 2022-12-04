unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql56conn, mysql57conn, SQLDB, DB, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, ExtDlgs, DBGrids;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnLoad: TButton;
    btnPreprocess: TButton;
    btnRecognize: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    huruf_sandi: TEdit;
    imgMod: TImage;
    imgSrc: TImage;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    conn1: TMySQL57Connection;
    MySQL57Connection2: TMySQL57Connection;
    OpenPictureDialog1: TOpenPictureDialog;
    query1: TSQLQuery;
    trans1: TSQLTransaction;
    procedure btnLoadClick(Sender: TObject);
    procedure btnPreprocessClick(Sender: TObject);
    procedure btnRecognizeClick(Sender: TObject);
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
  feature : array[1..5, 1..5] of integer;
  feature_distribution  : array[1..5, 1..5] of double;

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
      if Gray > 200 then
        bitmapBiner[x, y] := 1
      else
        bitmapBiner[x, y] := 0;
    end;
  end;

  for y := 1 to 5 do
  begin
    for x := 1 to 5 do
    begin
      feature[x,y] := 0;
    end;
  end;

  query1.Active := False;
end;

procedure TForm1.btnPreprocessClick(Sender: TObject);
var
  x, y    : integer;
  i, j    : integer;

  // Variabel Untuk Proses Scan Line
  tepi_atas_y  : integer;
  tepi_bawah_y : integer;
  tepi_kiri_x  : integer;
  tepi_kanan_x : integer;

  // Variabel Untuk Proses Ekstraksi Gambar Pertama
  feature_number : integer;
  cell_width, cell_height : integer;
  left_most_cell, right_most_cell : integer;
  top_most_cell, bottom_most_cell : integer;
  total_cells_in_1_feature : integer;

begin
(*------------------------------------*)
(*********MELAKUKAN SCAN LINE**********)
(*------------------------------------*)

  { 1. Mengambil Posisi Tepi Atas OBJEK }
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

  { 2. Mengambil Posisi Tepi Bawah Objek }
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

  { 3. Mengambil Posisi Tepi Kiri Objek }
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

  { 4. Mengambil Posisi Tepi Kanan Objek }
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

  { 6. Mengambil Nilai - Nilai Bitmap Daerah yang Dipotong }
  for j := tepi_atas_y to tepi_bawah_y do
  begin
    for i := tepi_kiri_x to tepi_kanan_x do
    begin
      bitmapBiner2[i - tepi_kiri_x, j - tepi_atas_y] := bitmapBiner[i, j];
    end;
  end;

  { 7. Mengatur Tinggi dan Lebar Gambar Setelah Dipotong }
  imgMod.Width := tepi_kanan_x - tepi_kiri_x;
  imgMod.Height := tepi_bawah_y - tepi_atas_y;

  { 8. Menampilkan Pixel ke Gambar Setelah Dipotong }
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
(*------------------------------------*)
(******MENGESKTRAKSI FITUR CITRA*******)

  { 1. menentukan lebar dan tinggi setiap cell setelah TImage dibagi menjadi matriks 5x5    }
  cell_width  := round(imgMod.Width / 5);
  cell_height := round(imgMod.Height / 5);

  // menentukan posisi paling kiri dan posisi paling kanan pixel dalam suatu daerah fitur
  left_most_cell  := 0;
  right_most_cell := 0;

  // menentukan posisi paling atas dan posisi paling bawah dalam suatu daerahfitur
  top_most_cell   := 0;
  bottom_most_cell:= 0;

  for j := 1 to 5 do
  begin
    left_most_cell  := 0;
    right_most_cell := 0;
    for i := 1 to 5 do
    begin
      for y := (top_most_cell) to (cell_height + bottom_most_cell) do
      begin
        for x := (left_most_cell) to (cell_width + right_most_cell) do
        begin
          if(bitmapBiner2[x,y] = 0) then
            feature[i,j] += 1
        end;
      end;
      left_most_cell  += cell_width;
      right_most_cell += cell_width;
    end;
    top_most_cell    += cell_height;
    bottom_most_cell += cell_height;
  end;

  total_cells_in_1_feature := (cell_width ) * (cell_height);
  for y := 1 to 5 do
  begin
    for x := 1 to 5 do
    begin
      feature_distribution[x,y] := (feature[x,y] / total_cells_in_1_feature);
    end;
  end;

  ListBox1.Clear;

  feature_number += 1;
  for y := 1 to 5 do
  begin
    for x := 1 to 5 do
    begin
      ListBox1.Items.Add('Fitur ' + IntToStr(feature_number) + ' : ' + IntToStr(round((feature_distribution[x,y]*100))) + '%');
      feature_number += 1;
    end;
  end;

end;

procedure TForm1.btnRecognizeClick(Sender: TObject);
var
  x, y : integer;

begin
  query1.SQL.Clear;
  query1.SQL.Add('INSERT INTO sample27 (abjad, fitur_1, fitur_2, fitur_3, fitur_4, fitur_5,'+
                 'fitur_6, fitur_7, fitur_8, fitur_9, fitur_10, fitur_11, fitur_12, fitur_13,'+
                 'fitur_14, fitur_15, fitur_16, fitur_17, fitur_18, fitur_19, fitur_20, fitur_21,' +
                 'fitur_22, fitur_23, fitur_24, fitur_25)' +
                 'VALUES ("F", ' +
                 quotedStr(FloatToStr(feature_distribution[1,1])) + ',' +  quotedStr(FloatToStr(feature_distribution[2,1])) + ',' + quotedStr(FloatToStr(feature_distribution[3,1])) + ',' + quotedStr(FloatToStr(feature_distribution[4,1])) + ',' + quotedStr(FloatToStr(feature_distribution[5,1])) + ',' +
                 quotedStr(FloatToStr(feature_distribution[1,2])) + ',' +  quotedStr(FloatToStr(feature_distribution[2,2])) + ',' + quotedStr(FloatToStr(feature_distribution[3,2])) + ',' + quotedStr(FloatToStr(feature_distribution[4,2])) + ',' + quotedStr(FloatToStr(feature_distribution[5,2])) + ',' +
                 quotedStr(FloatToStr(feature_distribution[1,3])) + ',' +  quotedStr(FloatToStr(feature_distribution[2,3])) + ',' + quotedStr(FloatToStr(feature_distribution[3,3])) + ',' + quotedStr(FloatToStr(feature_distribution[4,3])) + ',' + quotedStr(FloatToStr(feature_distribution[5,3])) + ',' +
                 quotedStr(FloatToStr(feature_distribution[1,4])) + ',' +  quotedStr(FloatToStr(feature_distribution[2,4])) + ',' + quotedStr(FloatToStr(feature_distribution[3,4])) + ',' + quotedStr(FloatToStr(feature_distribution[4,4])) + ',' + quotedStr(FloatToStr(feature_distribution[5,4])) + ',' +
                 quotedStr(FloatToStr(feature_distribution[1,5])) + ',' +  quotedStr(FloatToStr(feature_distribution[2,5])) + ',' + quotedStr(FloatToStr(feature_distribution[3,5])) + ',' + quotedStr(FloatToStr(feature_distribution[4,5])) + ',' + quotedStr(FloatToStr(feature_distribution[5,5])) + ')');
  query1.ExecSQL;
  trans1.Commit;

  query1.SQL.Clear;
  query1.SQL.Add('SELECT * FROM sample27');
  query1.Close;
  query1.Open;

end;

end.

