unit uselectcountrycode;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  ActnList, IBQuery;

type

  { TfrmSelectCountry }

  TfrmSelectCountry = class(TForm)
    ActBtnSelect: TAction;
    ActBtnCancel: TAction;
    actlistSelectCountry: TActionList;
    btnRight: TButton;
    btnLeft: TButton;
    DBGrid1: TDBGrid;
    edtFilter: TEdit;
    lblFilter: TLabel;
    procedure ActBtnCancelExecute(Sender: TObject);
    procedure ActBtnSelectExecute(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FIDCountry: PtrInt;//ID выбранной страны
    FqrySelCountry: TIBQuery;//ссылка на датасет с нужным запросом
  public
    property qrySelCountry: TIBQuery read FqrySelCountry write FqrySelCountry;
    property IDCountry: PtrInt read FIDCountry write FIDCountry;
  end;

var
  frmSelectCountry: TfrmSelectCountry;

implementation

{$R *.lfm}

{ TfrmSelectCountry }

procedure TfrmSelectCountry.FormClick(Sender: TObject);
var
  x: PtrInt = -1;
  y: PtrInt = -1;
begin
  x:= Mouse.CursorPos.X;
  y:= Mouse.CursorPos.y;
  Self.Caption:= Format('%d | %d',[x,y]);
end;

procedure TfrmSelectCountry.ActBtnSelectExecute(Sender: TObject);
begin
//
end;

procedure TfrmSelectCountry.ActBtnCancelExecute(Sender: TObject);
begin
//
end;

procedure TfrmSelectCountry.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
end;

procedure TfrmSelectCountry.FormCreate(Sender: TObject);
begin
  qrySelCountry:= nil;
  FIDCountry:= -1;
  edtFilter.Clear;

  {$IFDEF MSWINDOWS}
  btnRight.Caption:= 'Отмена';
  btnLeft.Caption:= 'Выбрать';
  btnRight.OnClick:= @ActBtnCancelExecute;
  btnLeft.OnClick:= @ActBtnSelectExecute;
  {$ELSE}
  btnLeft.Caption:= 'Отмена';
  btnRight.Caption:= 'Выбрать';
  btnLeft.OnClick:= @ActBtnCancelExecute;
  btnRight.OnClick:= @ActBtnSelectExecute;
  {$ENDIF}

end;

end.

