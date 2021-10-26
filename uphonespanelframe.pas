unit uphonespanelframe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, LazUTF8;

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
    FCountryCode: PtrInt;//поле, содержащее ID кода выбранной страны (по умолчанию -1)
  public
    property CountryCode: PtrInt read FCountryCode write FCountryCode;
  end;

implementation

{$R *.lfm}

{ TfrPhonesPnl }

procedure TfrPhonesPnl.edtCountryCodeKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9']) then Key:= #0;
end;

end.

