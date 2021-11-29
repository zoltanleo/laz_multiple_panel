unit uselectcountrycode;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
  , SysUtils
  , DB
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , StdCtrls
  , DBGrids
  , ActnList
  , LCLIntf
  , LCLType
  , LCLProc
  , LCL
  , LazUTF8
  , IBDatabase
  , IBQuery;

type

  { TfrmSelectCountry }

  TfrmSelectCountry = class(TForm)
    ActBtnSelect: TAction;
    ActBtnCancel: TAction;
    ActQrySelect: TAction;
    actlistSelectCountry: TActionList;
    btnRight: TButton;
    btnLeft: TButton;
    DSSelectCountry: TDataSource;
    grSelectCountry: TDBGrid;
    edtFilter: TEdit;
    qryCountryCode: TIBQuery;
    lblFilter: TLabel;
    procedure ActBtnCancelExecute(Sender: TObject);
    procedure ActBtnSelectExecute(Sender: TObject);
    procedure ActQrySelectExecute(Sender: TObject);
    procedure edtFilterChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIDCountry: PtrInt;//ID выбранной страны
  public
    property IDCountry: PtrInt read FIDCountry write FIDCountry;
  end;

var
  frmSelectCountry: TfrmSelectCountry;

implementation

uses uphonesedit;

{$R *.lfm}

{ TfrmSelectCountry }

procedure TfrmSelectCountry.ActBtnSelectExecute(Sender: TObject);
begin
  if qryCountryCode.IsEmpty then Exit;
  IDCountry:= qryCountryCode.FN('ID').Value;
  ModalResult:= mrOK;
end;

procedure TfrmSelectCountry.ActQrySelectExecute(Sender: TObject);
begin
  with qryCountryCode do
  begin
    DisableControls;
    try
      try
        if Active then Active:= False;
        SQL.Text:= 'SELECT ID, CODE, NAME_I18N ' +
                   'FROM TBL_COUNTRY ' +
                   'WHERE (ID > 0)';
        if (UTF8Trim(edtFilter.Text) <> '')
          then SQL.Text:= SQL.Text + ' AND (NAME_I18N CONTAINING :prmNAME)';
        Prepare;
        if (UTF8Trim(edtFilter.Text) <> '')
          then ParamByName('prmNAME').Value:= UTF8Trim(edtFilter.Text);
        Active:= True;

        if (IDCountry <> -1)
          then Locate('ID',IDCountry,[loCaseInsensitive])
          else First;
      except
        on E:Exception do
        ShowMessage(E.Message);
      end;
    finally
      EnableControls;

      {$IFDEF MSWINDOWS}
      btnLeft.Enabled:= not qryCountryCode.IsEmpty;
      {$ELSE}
      btnRight.Enabled:= not qryCountryCode.IsEmpty;
      {$ENDIF}
    end;

  end;
end;

procedure TfrmSelectCountry.edtFilterChange(Sender: TObject);
begin
  ActQrySelectExecute(Sender);
end;

procedure TfrmSelectCountry.ActBtnCancelExecute(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

procedure TfrmSelectCountry.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
end;

procedure TfrmSelectCountry.FormCreate(Sender: TObject);
begin
  FIDCountry:= -1;
  edtFilter.Clear;

  Self.FormResize(Sender);

  {$IFDEF MSWINDOWS}
  btnRight.Caption:= 'Отмена';
  btnLeft.Caption:= 'Выбрать';
  btnRight.OnClick:= @ActBtnCancelExecute;
  btnLeft.OnClick:= @ActBtnSelectExecute;

  if (UTF8LowerCase(ShortCutToText(ActBtnCancel.ShortCut)) <> 'unknown')
    then btnRight.Hint:= Format('<%s>',[ShortCutToText(ActBtnCancel.ShortCut)])
    else btnRight.Hint:= '';
  if (UTF8LowerCase(ShortCutToText(ActBtnSelect.ShortCut)) <> 'unknown')
    then btnLeft.Hint:= Format('<%s>',[ShortCutToText(ActBtnSelect.ShortCut)])
    else btnRight.Hint:= '';
  {$ELSE}
  btnLeft.Caption:= 'Отмена';
  btnRight.Caption:= 'Выбрать';
  btnLeft.OnClick:= @ActBtnCancelExecute;
  btnRight.OnClick:= @ActBtnSelectExecute;
  if (UTF8LowerCase(ShortCutToText(ActBtnCancel.ShortCut)) <> 'unknown')
    then btnLeft.Hint:= Format('<%s>',[ShortCutToText(ActBtnCancel.ShortCut)])
    else btnLeft.Hint:= '';
  if (UTF8LowerCase(ShortCutToText(ActBtnSelect.ShortCut)) <> 'unknown')
    then btnRight.Hint:= Format('<%s>',[ShortCutToText(ActBtnSelect.ShortCut)])
    else btnRight.Hint:= '';
  {$ENDIF}


end;

procedure TfrmSelectCountry.FormResize(Sender: TObject);
var
  i: PtrInt = -1;
  len: PtrInt = 0;
  VScrBarWidth: PtrInt = 0;

  function VScrBarVisible(Handle: HWnd; Style: Longint): Boolean;
  begin
     Result := (GetWindowLong(Handle, GWL_STYLE) and Style) <> 0;
  end;
begin
  { #done : взято отсюда https://delphisources.ru/pages/faq/base/get_scrollbar_width.html }
  if VScrBarVisible(grSelectCountry.Handle,WS_VSCROLL)
    then VScrBarWidth:= GetSystemMetrics(SM_CXVSCROLL);

  for i:= 0 to Pred(grSelectCountry.Columns.Count) do
  if (i <> Pred(grSelectCountry.Columns.Count))
  then
    begin
      grSelectCountry.Columns.Items[i].Width:=
                      Self.Canvas.TextWidth(grSelectCountry.Columns.Items[i].Title.Caption)
                      + Self.Canvas.TextWidth('W') * 2;
      len:= len + grSelectCountry.Columns.Items[i].Width;
    end
  else //для последнего столбца
    if (Self.Canvas.TextWidth(grSelectCountry.Columns.Items[i].Title.Caption)
                                          < (grSelectCountry.ClientWidth - len - VScrBarWidth)) then
          grSelectCountry.Columns.Items[i].Width:= (grSelectCountry.ClientWidth - len - VScrBarWidth);
end;

procedure TfrmSelectCountry.FormShow(Sender: TObject);
begin
  ActQrySelectExecute(Sender);
end;

end.

