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
    huruf_sandi: TEdit;
    imgMod: TImage;
    imgSrc: TImage;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    conn1: TMySQL57Connection;
    ListBox2: TListBox;
    MySQL57Connection2: TMySQL57Connection;
    OpenPictureDialog1: TOpenPictureDialog;
    query1: TSQLQuery;
    trans1: TSQLTransaction;
    procedure FormCreate(Sender: TObject);
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
  Windows, Math;

var
  bitmapR, bitmapG, bitmapB: array[0..1000, 0..1000] of integer;
  bitmapGray, bitmapBiner, bitmapBiner2: array[0..1000, 0..1000] of integer;
  feature: array[1..5, 1..5] of integer;
  feature_distribution: array[1..5, 1..5] of double;
  abjad : array[1..1, 1..150] of string;
  fitur_sample : array[1..25, 1..150] of string;
  jarak : array[1..1,1..150] of double;
  jarak_1 : array[1..150] of double;
  feature_input : array[1..25] of double;
  key_index : integer;

{ TForm1 }

procedure TForm1.btnLoadClick(Sender: TObject);
var
  x, y: integer;
  R, G, B, Gray: integer;

begin
  if (OpenPictureDialog1.Execute) then
  begin
    imgSrc.Picture.LoadFromFilE(OpenPictureDialog1.FileName);
  end;

  for y := 0 to imgSrc.Height - 1 do
  begin
    for x := 0 to imgSrc.Width - 1 do
    begin
      R := GetRValue(imgSrc.Canvas.Pixels[x, y]);
      G := GetGValue(imgSrc.Canvas.Pixels[x, y]);
      B := GetBValue(imgSrc.Canvas.Pixels[x, y]);
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
      feature[x, y] := 0;
    end;
  end;

  query1.Active := False;
end;

procedure TForm1.btnPreprocessClick(Sender: TObject);
var
  x, y: integer;
  i, j: integer;

  // Variabel Untuk Proses Scan Line
  tepi_atas_y: integer;
  tepi_bawah_y: integer;
  tepi_kiri_x: integer;
  tepi_kanan_x: integer;

  // Variabel Untuk Proses Ekstraksi Gambar Pertama
  feature_number: integer;
  cell_width, cell_height: integer;
  left_most_cell, right_most_cell: integer;
  top_most_cell, bottom_most_cell: integer;
  total_cells_in_1_feature: integer;

begin
  (*------------------------------------*)
  (*********MELAKUKAN SCAN LINE**********)
  (*------------------------------------*)

  for y := 1 to 5 do
  begin
    for x := 1 to 5 do
    begin
      feature_distribution[x,y] := 0;
    end;
  end;

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
  cell_width := round(imgMod.Width / 5);
  cell_height := round(imgMod.Height / 5);

  // menentukan posisi paling kiri dan posisi paling kanan pixel dalam suatu daerah fitur
  left_most_cell := 0;
  right_most_cell := 0;

  // menentukan posisi paling atas dan posisi paling bawah dalam suatu daerahfitur
  top_most_cell := 0;
  bottom_most_cell := 0;

  for j := 1 to 5 do
  begin
    left_most_cell := 0;
    right_most_cell := 0;
    for i := 1 to 5 do
    begin
      for y := (top_most_cell) to (cell_height + bottom_most_cell) do
      begin
        for x := (left_most_cell) to (cell_width + right_most_cell) do
        begin
          if (bitmapBiner2[x, y] = 0) then
            feature[i, j] += 1;
        end;
      end;
      left_most_cell += cell_width;
      right_most_cell += cell_width;
    end;
    top_most_cell += cell_height;
    bottom_most_cell += cell_height;
  end;

  total_cells_in_1_feature := (cell_width) * (cell_height);
  for y := 1 to 5 do
  begin
    for x := 1 to 5 do
    begin
      feature_distribution[x, y] := (feature[x, y] / total_cells_in_1_feature);
    end;
  end;

  ListBox1.Clear;

  feature_number += 1;
  for y := 1 to 5 do
  begin
    for x := 1 to 5 do
    begin
      ListBox1.Items.Add('Fitur ' + IntToStr(feature_number) + ' : ' +
        IntToStr(round((feature_distribution[x, y] * 100))) + '%');
      feature_number += 1;
    end;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  x, y : integer;

begin
  query1.SQL.Clear;
  query1.SQL.Add('SELECT * FROM sample27');
  query1.Close;
  query1.Open;

  y := 1;
  Query1.DisableControls;
  try
    Query1.First;
      begin
        while not Query1.EOF do
        begin
          abjad[1,y] := Query1.FieldByName('abjad').AsString;
          Query1.Next;
          inc(y);
        end;
        Query1.First;
        end;
  finally
    Query1.EnableControls;
  end;


  for x := 1 to 25 do
  begin
     y := 1;
     Query1.DisableControls;
     try
        Query1.First;
        begin
          while not Query1.EOF do
          begin
            fitur_sample[x,y] := Query1.FieldByName('fitur_' + IntToStr(x)).AsString;
            Query1.Next;
            inc(y);
          end;
          Query1.First;
        end;
    finally
      Query1.EnableControls;
    end;
  end;

  for y := 1 to 130 do
  begin
    ListBox2.Items.Add(fitur_sample[25,y]);
  end;
end;

procedure TForm1.btnRecognizeClick(Sender: TObject);
var
  x, y : integer;
  L1 : double;
  LValIdx: Integer;
  LMinIdx: Integer = 1;

begin
  feature_input[1]   := feature_distribution[1,1];
  feature_input[2]   := feature_distribution[1,2];
  feature_input[3]   := feature_distribution[1,3];
  feature_input[4]   := feature_distribution[1,4];
  feature_input[5]   := feature_distribution[1,5];
  feature_input[6]   := feature_distribution[2,1];
  feature_input[7]   := feature_distribution[2,2];
  feature_input[8]   := feature_distribution[2,3];
  feature_input[9]   := feature_distribution[2,4];
  feature_input[10]  := feature_distribution[2,5];
  feature_input[11]  := feature_distribution[3,1];
  feature_input[12]  := feature_distribution[3,2];
  feature_input[13]  := feature_distribution[3,3];
  feature_input[14]  := feature_distribution[3,4];
  feature_input[15]  := feature_distribution[3,5];
  feature_input[16]  := feature_distribution[4,1];
  feature_input[17]  := feature_distribution[4,2];
  feature_input[18]  := feature_distribution[4,3];
  feature_input[19]  := feature_distribution[4,4];
  feature_input[20]  := feature_distribution[4,5];
  feature_input[21]  := feature_distribution[5,1];
  feature_input[22]  := feature_distribution[5,2];
  feature_input[23]  := feature_distribution[5,3];
  feature_input[24]  := feature_distribution[5,4];
  feature_input[25]  := feature_distribution[5,5];

  L1 := 0;
  for y := 1 to 130 do
  begin
    for x := 1 to 25 do
    begin
      L1 := L1 + abs(feature_input[x] - StrToFloat(fitur_sample[x,y]));
    end;
    jarak_1[y] := L1;
    L1 := 0;
  end;

  ListBox2.Clear;
  for y := 1 to 130 do
  begin
    ListBox2.Items.Add(FloatToStr(jarak_1[y]));
  end;

  for LValIdx := 1 to 130 do
    if jarak_1[LValIdx] < jarak_1[LMinIdx] then
      LMinIdx := LValIdx;

  key_index := LMinIdx;
  ListBox1.Clear;

  ListBox1.Items.Add(IntToStr(key_index));
  huruf_sandi.Text := abjad[1,key_index];

end;

end.
