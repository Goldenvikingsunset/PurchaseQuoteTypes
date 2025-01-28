codeunit 50100 "Quote Type Management MOD010"
{
    procedure UpdateQuoteTypeCosts(var PurchHeader: Record "Purchase Header")
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        PurchLine: Record "Purchase Line";
        ItemChargeLine: Record "Purchase Line";
        Currency: Record Currency;
        LineNo: Integer;
        LineCount: Integer;
        QtyPerLine: Decimal;
        RemainingQty: Decimal;
        CurrentLine: Integer;
    begin
        if not ValidateQuoteTypeSetup(PurchHeader, true) then
            exit;

        DeleteExistingAssignments(PurchHeader);

        // Create item charge line
        ItemChargeLine.Reset();
        ItemChargeLine.SetRange("Document Type", PurchHeader."Document Type");
        ItemChargeLine.SetRange("Document No.", PurchHeader."No.");
        if ItemChargeLine.FindLast() then
            ItemChargeLine."Line No." := ItemChargeLine."Line No." + 10000
        else
            ItemChargeLine."Line No." := 10000;

        // Create item charge line
        ItemChargeLine.Init();
        ItemChargeLine."Document Type" := PurchHeader."Document Type";
        ItemChargeLine."Document No." := PurchHeader."No.";
        ItemChargeLine.Type := ItemChargeLine.Type::"Charge (Item)";
        ItemChargeLine."No." := PurchHeader."Quote Type Item Charge Code";
        ItemChargeLine.Insert(true);
        ItemChargeLine.Validate(Quantity, 1);
        ItemChargeLine.Validate("Direct Unit Cost", PurchHeader."Quote Type Cost Amount");
        ItemChargeLine.Modify(true);

        // Count item lines and prepare assignments
        PurchLine.Reset();
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        LineCount := PurchLine.Count;
        if LineCount = 0 then
            exit;

        QtyPerLine := Round(1 / LineCount, 0.00001);
        RemainingQty := 1;
        CurrentLine := 1;

        // Create assignments - ensure we process each line in order
        PurchLine.FindSet();
        repeat
            ItemChargeAssgntPurch.Init();
            ItemChargeAssgntPurch."Document Type" := ItemChargeLine."Document Type";
            ItemChargeAssgntPurch."Document No." := ItemChargeLine."Document No.";
            ItemChargeAssgntPurch."Document Line No." := ItemChargeLine."Line No.";
            ItemChargeAssgntPurch."Line No." := CurrentLine;
            ItemChargeAssgntPurch."Item Charge No." := ItemChargeLine."No.";
            ItemChargeAssgntPurch."Item No." := PurchLine."No.";
            ItemChargeAssgntPurch.Description := PurchLine.Description;
            ItemChargeAssgntPurch."Applies-to Doc. Type" := PurchHeader."Document Type";
            ItemChargeAssgntPurch."Applies-to Doc. No." := PurchHeader."No.";
            ItemChargeAssgntPurch."Applies-to Doc. Line No." := PurchLine."Line No.";

            if CurrentLine = LineCount then
                ItemChargeAssgntPurch.Validate("Qty. to Assign", RemainingQty)
            else begin
                ItemChargeAssgntPurch.Validate("Qty. to Assign", QtyPerLine);
                RemainingQty -= QtyPerLine;
            end;

            ItemChargeAssgntPurch.Insert(true);
            CurrentLine += 1;
        until PurchLine.Next() = 0;
    end;

    local procedure GetNextLineNo(PurchHeader: Record "Purchase Header"): Integer
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.Reset();
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindLast() then
            exit(PurchLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure DeleteExistingAssignments(PurchHeader: Record "Purchase Header")
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::"Charge (Item)");
        PurchLine.SetRange("No.", PurchHeader."Quote Type Item Charge Code");
        if PurchLine.FindSet() then
            repeat
                ItemChargeAssgntPurch.SetRange("Document Type", PurchHeader."Document Type");
                ItemChargeAssgntPurch.SetRange("Document No.", PurchHeader."No.");
                ItemChargeAssgntPurch.SetRange("Document Line No.", PurchLine."Line No.");
                ItemChargeAssgntPurch.DeleteAll();
                PurchLine.Delete();
            until PurchLine.Next() = 0;
    end;

    local procedure ValidateQuoteTypeSetup(PurchHeader: Record "Purchase Header"; ValidateCostAmount: Boolean): Boolean
    begin
        if PurchHeader."Quote Type Item Charge Code" = '' then
            Error(MissingQuoteTypeErr);

        if ValidateCostAmount and (PurchHeader."Quote Type Cost Amount" <= 0) then
            Error(InvalidCostAmountErr);

        exit(true);
    end;

    var
        MissingQuoteTypeErr: Label 'Quote Type Item Charge Code must be specified.';
        InvalidCostAmountErr: Label 'Quote Type Cost Amount must be greater than zero.';
}