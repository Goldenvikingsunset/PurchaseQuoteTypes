pageextension 50100 "PurchaseQuoteExt MOD010" extends "Purchase Quote"
{
    layout
    {
        addlast(General)
        {
            group(QuoteType)
            {
                Caption = 'Quote Type';

                field("Quote Type Item Charge Code"; Rec."Quote Type Item Charge Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge code representing the quote type';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Quote Type Cost Amount"; Rec."Quote Type Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost amount for this quote type';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Cost Split Method"; Rec."Cost Split Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how the quote type cost should be split across lines';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(UpdateQuoteTypeCosts)
            {
                ApplicationArea = All;
                Caption = 'Update Quote Type Costs';
                Image = Cost;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Updates the quote type costs across all lines';

                trigger OnAction()
                var
                    QuoteTypeMgmt: Codeunit "Quote Type Management MOD010";
                begin
                    QuoteTypeMgmt.UpdateQuoteTypeCosts(Rec);
                end;
            }
        }
    }
}