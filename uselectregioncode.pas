unit uselectregioncode;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
  , SysUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , StdCtrls
  , DBGrids
  , ActnList
  , IBQuery
  , DB
  , LCLIntf
  , LCLType
  , LCLProc
  , LCL
  , LazUTF8
  ;

type
  { TfrmSelectRegion }

  TfrmSelectRegion = class(TForm)
    ActCbbDepartFill: TAction;
    ActBtnSelect: TAction;
    ActBtnCancel: TAction;
    ActQryLocate: TAction;
    ActQryDepart: TAction;
    actlistSelectRegion: TActionList;
    btnRight: TButton;
    btnLeft: TButton;
    cbbRegion: TComboBox;
    DSSelectRegion: TDataSource;
    grSelectRegion: TDBGrid;
    edtFilter: TEdit;
    qryDepartCode: TIBQuery;
    qryLocateCode: TIBQuery;
    lblRegion: TLabel;
    lblFilter: TLabel;
    procedure ActBtnCancelExecute(Sender: TObject);
    procedure ActBtnSelectExecute(Sender: TObject);
    procedure ActCbbDepartFillExecute(Sender: TObject);
    procedure ActQryDepartExecute(Sender: TObject);
    procedure ActQryLocateExecute(Sender: TObject);
    procedure cbbRegionChange(Sender: TObject);
    procedure edtFilterChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIDCountry: PtrInt;//ID выбранной страны
    FIDDepart: PtrInt;//ID выбранной области
    FIDRegion: PtrInt;//ID выбранного региона
  public
    property IDCountry: PtrInt read FIDCountry write FIDCountry;
    property IDRegion: PtrInt read FIDRegion write FIDRegion;
    property IDDepart: PtrInt read FIDDepart write FIDDepart;
  end;

var
  frmSelectRegion: TfrmSelectRegion;

implementation

{$R *.lfm}

{ TfrmSelectRegion }

procedure TfrmSelectRegion.ActQryDepartExecute(Sender: TObject);
begin
  with qryDepartCode do
  begin
    try
      if Active then Active:= False;
      SQL.Text:= 'SELECT ID, NAME_I18N ' +
                  'FROM TBL_DEPARTMENT ' +
                  'WHERE (ID > 0) AND (FK_COUNTRY = :prmCountry) ' +
                  'ORDER BY 1';
      Prepare;
      ParamByName('prmCountry').Value:= IDCountry;
      Active:= True;
    except
      on e:Exception do
      begin
        Active:= False;
        ShowMessage(e.Message);
      end;
    end;
  end;
end;

procedure TfrmSelectRegion.ActQryLocateExecute(Sender: TObject);
var
  b: Boolean;
begin
  try
    with qryLocateCode do
    begin
      DisableControls;
      try
        if Active then Active:= False;
        SQL.Text:=
          'SELECT ' +
            'L.ID AS ID, ' +
            'C.NAME_I18N AS COUNTRY, ' +
            'L.CODE AS LOCATE_CODE, ';

        if (cbbRegion.ItemIndex = 0)
          then
            SQL.Text:= SQL.Text + 'L.NAME_I18N ||'' (''||D.NAME_I18N||'') '' AS LOCATE_NAME '
          else
            SQL.Text:= SQL.Text + 'L.NAME_I18N AS LOCATE_NAME ';

        SQL.Text:= SQL.Text +
          'FROM TBL_DEPARTMENT D ' +
            'INNER JOIN TBL_LOCATION L ON (D.ID = L.FK_DEPART) ' +
            'INNER JOIN TBL_COUNTRY C ON (C.ID = D.FK_COUNTRY) ' +
          'WHERE (D.ID > 0) ' +
            'AND (D.FK_COUNTRY = :prmCountry) ';

        if (cbbRegion.ItemIndex > 0) then
          SQL.Text:= SQL.Text + 'AND (D.NAME_I18N CONTAINING :prmDepName) ';

        SQL.Text:= SQL.Text + 'ORDER BY LOCATE_NAME';
        Prepare;
        ParamByName('prmCountry').Value:= IDCountry;

        if (cbbRegion.ItemIndex > 0) then
          ParamByName('prmDepName').Value:= cbbRegion.Items[cbbRegion.ItemIndex];

        Active:= True;

        if not qryLocateCode.Locate('ID',IDRegion,[loCaseInsensitive])
          then qryLocateCode.First;
      except
        on e:Exception do
        begin
          Active:= False;
          ShowMessage(e.Message);
        end;
      end;
    end;
  finally
    qryLocateCode.EnableControls;

    {$IFDEF MSWINDOWS}
    btnLeft.Enabled:= (qryLocateCode.Active and not qryLocateCode.IsEmpty);
    {$ELSE}
    btnRight.Enabled:= (qryLocateCode.Active and not qryLocateCode.IsEmpty);
    {$ENDIF}

    edtFilter.Enabled:= (qryLocateCode.Active and not qryLocateCode.IsEmpty);
    grSelectRegion.Enabled:= (qryLocateCode.Active and not qryLocateCode.IsEmpty);
  end;
end;

procedure TfrmSelectRegion.cbbRegionChange(Sender: TObject);
begin
  edtFilter.Clear;
  ActQryLocateExecute(Sender);
end;

procedure TfrmSelectRegion.edtFilterChange(Sender: TObject);
begin
  try
    with qryLocateCode do
    begin
      DisableControls;
      try
        if Active then Active:= False;
        SQL.Text:=
          'SELECT ' +
            'L.ID AS ID, ' +
            'C.NAME_I18N AS COUNTRY, ' +
            'L.CODE AS LOCATE_CODE, ';

        if (cbbRegion.ItemIndex = 0)
          then
            SQL.Text:= SQL.Text + 'L.NAME_I18N ||'' (''||D.NAME_I18N||'') '' AS LOCATE_NAME '
          else
            SQL.Text:= SQL.Text + 'L.NAME_I18N AS LOCATE_NAME ';

        SQL.Text:= SQL.Text +
          'FROM TBL_DEPARTMENT D ' +
            'INNER JOIN TBL_LOCATION L ON (D.ID = L.FK_DEPART) ' +
            'INNER JOIN TBL_COUNTRY C ON (C.ID = D.FK_COUNTRY) ' +
          'WHERE (D.ID > 0) ' +
            'AND (D.FK_COUNTRY = :prmCountry) ';

        if (cbbRegion.ItemIndex > 0)
          then SQL.Text:= SQL.Text + 'AND (D.NAME_I18N CONTAINING :prmDepName) ';

        if (cbbRegion.ItemIndex = 0)
          then
            SQL.Text:= SQL.Text +
                  'AND (L.NAME_I18N ||'' (''||D.NAME_I18N||'') '' CONTAINING :prmLocateName) '
          else
            SQL.Text:= SQL.Text +
                  'AND (L.NAME_I18N CONTAINING :prmLocateName) ';

        SQL.Text:= SQL.Text + 'ORDER BY LOCATE_NAME';
        Prepare;
        ParamByName('prmCountry').Value:= IDCountry;
        ParamByName('prmLocateName').Value:= UTF8Trim(edtFilter.Text);

        if (cbbRegion.ItemIndex > 0) then
          ParamByName('prmDepName').Value:= cbbRegion.Items[cbbRegion.ItemIndex];

        Active:= True;
      except
        on e:Exception do
        begin
          Active:= False;
          ShowMessage(e.Message);
        end;
      end;
    end;
  finally
    qryLocateCode.EnableControls;

    {$IFDEF MSWINDOWS}
    btnLeft.Enabled:= (qryLocateCode.Active and not qryLocateCode.IsEmpty);
    {$ELSE}
    btnRight.Enabled:= (qryLocateCode.Active and not qryLocateCode.IsEmpty);
    {$ENDIF}
  end;
end;

procedure TfrmSelectRegion.ActCbbDepartFillExecute(Sender: TObject);
var
  i: PtrInt = -1;
begin
  if (qryDepartCode.Active and not qryDepartCode.IsEmpty)
  then
    begin
      cbbRegion.Clear;
      cbbRegion.Items.Add('<все регионы>');

      qryDepartCode.First;
      while not qryDepartCode.EOF do
      begin
        cbbRegion.Items.Add(qryDepartCode.FN('NAME_I18N').Value);
        qryDepartCode.Next;
      end;
    end
  else
    cbbRegion.Items.Add('нет данных');
end;

procedure TfrmSelectRegion.ActBtnSelectExecute(Sender: TObject);
begin
  if qryDepartCode.IsEmpty or qryLocateCode.IsEmpty then Exit;

  IDRegion:= qryLocateCode.FN('ID').Value;
  IDDepart:= cbbRegion.ItemIndex;

  ModalResult:= mrOK;
end;

procedure TfrmSelectRegion.ActBtnCancelExecute(Sender: TObject);
begin
  ModalResult:= mrCancel;
end;

procedure TfrmSelectRegion.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
end;

procedure TfrmSelectRegion.FormCreate(Sender: TObject);
begin
  IDCountry:= -1;
  IDRegion:= -1;
  IDDepart:= -1;
  cbbRegion.Style:= csDropDownList;
  cbbRegion.Clear;
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

procedure TfrmSelectRegion.FormResize(Sender: TObject);
var
  i: PtrInt = -1;
  len: PtrInt = 0;
  VScrBarWidth: PtrInt = 0;

  function VScrBarVisible(Handle: HWnd; Style: Longint): Boolean;
  begin
     Result := (GetWindowLong(Handle, GWL_STYLE) and Style) <> 0;
  end;
begin
  if VScrBarVisible(grSelectRegion.Handle,WS_VSCROLL)
    then VScrBarWidth:= GetSystemMetrics(SM_CXVSCROLL);

  for i:= 0 to Pred(grSelectRegion.Columns.Count) do
  if (i <> Pred(grSelectRegion.Columns.Count))
  then
    begin
      grSelectRegion.Columns.Items[i].Width:=
                      Self.Canvas.TextWidth(grSelectRegion.Columns.Items[i].Title.Caption)
                      + Self.Canvas.TextWidth('W') * 2;
      len:= len + grSelectRegion.Columns.Items[i].Width;
    end
  else //для последнего столбца
    if (Self.Canvas.TextWidth(grSelectRegion.Columns.Items[i].Title.Caption)
                                          < (grSelectRegion.ClientWidth - len - VScrBarWidth)) then
          grSelectRegion.Columns.Items[i].Width:= (grSelectRegion.ClientWidth - len - VScrBarWidth);
end;

procedure TfrmSelectRegion.FormShow(Sender: TObject);
begin
  Self.BeginFormUpdate;
  try
    ActQryDepartExecute(Sender);//читаем таблю с регионами
    ActCbbDepartFillExecute(Sender);//заполняем комб с регионами

    if (IDDepart <> -1) and (IDDepart < cbbRegion.Items.Count)
      then cbbRegion.ItemIndex:= IDDepart
      else cbbRegion.ItemIndex:= 0;

    {$IFDEF MSWINDOWS}
    btnLeft.Enabled:= (qryDepartCode.Active and not qryDepartCode.IsEmpty);
    {$ELSE}
    btnRight.Enabled:= (qryDepartCode.Active and not qryDepartCode.IsEmpty);
    {$ENDIF}

    cbbRegion.Enabled:= (qryDepartCode.Active and not qryDepartCode.IsEmpty);
    edtFilter.Enabled:= (qryDepartCode.Active and not qryDepartCode.IsEmpty);
    grSelectRegion.Enabled:= (qryDepartCode.Active and not qryDepartCode.IsEmpty);

    if not qryDepartCode.Active or qryDepartCode.IsEmpty then Exit;

    ActQryLocateExecute(Sender);//читаем и заполняем таблю с населенными пунктами
  finally
    Self.EndFormUpdate;
  end;
end;

end.

