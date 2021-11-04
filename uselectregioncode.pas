unit uselectregioncode;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  ActnList, IBQuery, generics.Collections, DB;

type


  { TfrmSelectRegion }

  TfrmSelectRegion = class(TForm)
    actlistSelectRegion: TActionList;
    btnRight: TButton;
    btnLeft: TButton;
    cbbRegion: TComboBox;
    chbIsMobile: TCheckBox;
    DSSelectRegion: TDataSource;
    grSelectRegion: TDBGrid;
    edtFilter: TEdit;
    lblRegion: TLabel;
    lblFilter: TLabel;
    procedure chbIsMobileChange(Sender: TObject);
  private
    FIDCountry: PtrInt;//ID выбранной страны
    FIDRegion: PtrInt;//ID выбранного региона
  public
    property IDCountry: PtrInt read FIDCountry write FIDCountry;
    property IDRegion: PtrInt read FIDRegion write FIDRegion;
  end;

var
  frmSelectRegion: TfrmSelectRegion;

implementation

{$R *.lfm}

{ TfrmSelectRegion }

procedure TfrmSelectRegion.chbIsMobileChange(Sender: TObject);
begin
  lblFilter.Visible:= not chbIsMobile.Checked;
  edtFilter.Visible:= not chbIsMobile.Checked;
end;

end.

