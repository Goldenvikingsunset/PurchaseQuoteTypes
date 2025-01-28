pageextension 50102 "Item Charges MOD010" extends "Item Charges"
{
    layout
    {
        addafter(Description)
        {
            field("Is Quote Type"; Rec."Is Quote Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if this item charge is used for quote types';
            }
            field("Default Cost Amount"; Rec."Default Cost Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default cost amount for this quote type';
                Visible = Rec."Is Quote Type";
            }
            field("Default Cost Split Method"; Rec."Default Cost Split Method")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how the cost should be split by default';
                Visible = Rec."Is Quote Type";
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            action(ShowQuoteTypes)
            {
                ApplicationArea = All;
                Caption = 'Show Quote Types';
                Image = FilterLines;

                trigger OnAction()
                begin
                    Rec.SetRange("Is Quote Type", true);
                end;
            }
        }
    }
}