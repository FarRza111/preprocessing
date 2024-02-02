from typing import Union, List, Dict, Literal, Any

import pandas as pd
from pydantic import field_validator
from pydantic import BaseModel, Field
from pydantic import field_validator, ValidationError

path = r'C:\Users\Desktop\data\test_data.csv'
data = pd.read_csv(path,low_memory=False)

class DictValidator(BaseModel):

    ID: int = Field(..., ge =1)
    PRINTIFY_ORDER: Union[str, None]
    SKU: str
    ITEM_QUANTITY: Union[int, None]
    PRODUCT_COSTS: Union[float, None]
    TOTAL_PRODUCT_COSTS: Union[int, float]
    TAX_RATE: Union[float, int, None]
    # COUNTRY: Union[str, None]
    CURRENCY: Literal[('USD','EUR','GBP','CAD')]
    DECORATOR_ID: int
    INVOICE_NO: int
    fr_status: str
    fr_country: str
    fr_handling_cost: int
    fr_order_created_date: str


    @field_validator('ITEM_QUANTITY')
    def quantiy_shouldbe_digit(cls, value):
        if not isinstance(value, int):
            raise TypeError('correcty type should be integer')
        return value

class PdVal(BaseModel):
    df_dict: List[DictValidator]


if __name__ == "__main__":
    try:
        PdVal(df_dict=data.to_dict(orient="records"))
    except ValidationError as e:
        print(e)
