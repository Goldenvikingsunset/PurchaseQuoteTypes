tableextension 50102 "Item Charge MOD010" extends "Item Charge"
{
    fields
    {
        field(50100; "Is Quote Type"; Boolean)
        {
            Caption = 'Is Quote Type';
            DataClassification = CustomerContent;
        }
        field(50101; "Default Cost Amount"; Decimal)
        {
            Caption = 'Default Cost Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(50102; "Default Cost Split Method"; Enum "Cost Split Method MOD010")
        {
            Caption = 'Default Cost Split Method';
            DataClassification = CustomerContent;
        }
    }
}