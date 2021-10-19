unit uphonespanelframe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls;

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
  private

  public

  end;

implementation

{$R *.lfm}

end.

