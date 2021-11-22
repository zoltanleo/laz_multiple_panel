unit uphonespanelframe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, IBQuery,
  LazUTF8, LCLType;

type

  { TfrPhonesPnl }

  TfrPhonesPnl = class(TFrame)
    Bevel1: TBevel;
    btnPnlLeft: TButton;
    btnPnlRight: TButton;
    btnSelectCountryCode: TButton;
    btnSelectRegionCode: TButton;
    chbMainContact: TCheckBox;
    chbMobile: TCheckBox;
    edtCountryCode: TEdit;
    edtNumber: TEdit;
    edtRegionCode: TEdit;
    lblCountryCode: TLabel;
    lblNumber: TLabel;
    lblRegionCode: TLabel;
    memoNote: TMemo;
    procedure edtCountryCodeKeyPress(Sender: TObject; var Key: char);
  private
    //поле, содержащее ID кода выбранной страны (по умолчанию -1)
    FCountryCode: PtrInt;
    //поле, содержащее ID кода выбранного региона страны/ОпСоСа (по умолчанию -1)
    FRegionCode: PtrInt;
  public
    property CountryCode: PtrInt read FCountryCode write FCountryCode;
    property RegionCode: PtrInt read FRegionCode write FRegionCode;
  end;

implementation

{$R *.lfm}

{ TfrPhonesPnl }

procedure TfrPhonesPnl.edtCountryCodeKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', chr(VK_BACK)]) then Key:= #0;
end;

end.

