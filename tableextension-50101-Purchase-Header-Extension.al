tableextension 50101 "PurchaseHeaderExt MOD010" extends "Purchase Header"
{
    fields
    {
        field(50100; "Quote Type Item Charge Code"; Code[20])
        {
            Caption = 'Quote Type Item Charge Code';
            TableRelation = "Item Charge" where("Is Quote Type" = const(true));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCharge: Record "Item Charge";
                PurchLine: Record "Purchase Line";
            begin
                if "Quote Type Item Charge Code" = '' then
                    exit;

                // Get defaults from Item Charge
                if ItemCharge.Get("Quote Type Item Charge Code") then begin
                    Validate("Quote Type Cost Amount", ItemCharge."Default Cost Amount");
                    Validate("Cost Split Method", ItemCharge."Default Cost Split Method");
                end;

                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                if not PurchLine.IsEmpty then
                    if Confirm(StrSubstNo(UpdateExistingLinesQst, FieldCaption("Quote Type Item Charge Code"))) then
                        QuoteTypeMgmt.UpdateQuoteTypeCosts(Rec);
            end;
        }

        field(50101; "Quote Type Cost Amount"; Decimal)
        {
            Caption = 'Quote Type Cost Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                if "Quote Type Cost Amount" < 0 then
                    Error(NegativeCostAmountErr);

                if ("Quote Type Item Charge Code" = '') and ("Quote Type Cost Amount" <> 0) then
                    Error(MissingQuoteTypeErr);

                if "Quote Type Cost Amount" > 0 then begin
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    if not PurchLine.IsEmpty then
                        if Confirm(StrSubstNo(UpdateExistingLinesQst, FieldCaption("Quote Type Cost Amount"))) then
                            QuoteTypeMgmt.UpdateQuoteTypeCosts(Rec);
                end;
            end;
        }
        field(50102; "Cost Split Method"; Enum "Cost Split Method MOD010")
        {
            Caption = 'Cost Split Method';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                if ("Cost Split Method" <> xRec."Cost Split Method") then begin
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    if not PurchLine.IsEmpty then
                        if Confirm(StrSubstNo(UpdateExistingLinesQst, FieldCaption("Cost Split Method"))) then
                            QuoteTypeMgmt.UpdateQuoteTypeCosts(Rec);
                end;
            end;
        }
    }

    var
        QuoteTypeMgmt: Codeunit "Quote Type Management MOD010";
        UpdateExistingLinesQst: Label 'Do you want to update the %1 on the existing lines?';
        ItemChargeNotFoundErr: Label 'The specified Item Charge does not exist.';
        NegativeCostAmountErr: Label 'The Quote Type Cost Amount cannot be negative.';
        MissingQuoteTypeErr: Label 'You must specify a Quote Type Item Charge Code before entering a cost amount.';
}
