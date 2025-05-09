###############################################################################
#
#  Welcome to Baml! To use this generated code, please run the following:
#
#  $ pip install baml-py
#
###############################################################################

# This file was generated by BAML: please do not edit it. Instead, edit the
# BAML files and re-generate this code.
#
# ruff: noqa: E501,F401
# flake8: noqa: E501,F401
# pylint: disable=unused-import,line-too-long
# fmt: off
import baml_py
from enum import Enum
from pydantic import BaseModel, ConfigDict
from typing_extensions import TypeAlias
from typing import Dict, Generic, List, Literal, Optional, TypeVar, Union


T = TypeVar('T')
CheckName = TypeVar('CheckName', bound=str)

class Check(BaseModel):
    name: str
    expression: str
    status: str

class Checked(BaseModel, Generic[T,CheckName]):
    value: T
    checks: Dict[CheckName, Check]

def get_checks(checks: Dict[CheckName, Check]) -> List[Check]:
    return list(checks.values())

def all_succeeded(checks: Dict[CheckName, Check]) -> bool:
    return all(check.status == "succeeded" for check in get_checks(checks))



class ArticleType(str, Enum):
    
    Merger = "Merger"
    Acquisition = "Acquisition"
    Other = "Other"

class Commodity(str, Enum):
    
    Gold = "Gold"
    Silver = "Silver"
    Copper = "Copper"
    Lithium = "Lithium"
    Nickel = "Nickel"
    Cobalt = "Cobalt"
    Uranium = "Uranium"
    Zinc = "Zinc"
    Lead = "Lead"
    Other = "Other"

class Currency(str, Enum):
    
    AUD = "AUD"
    USD = "USD"
    CAD = "CAD"
    EUR = "EUR"
    GBP = "GBP"
    NZD = "NZD"
    CHF = "CHF"
    Unknown = "Unknown"

class AcquisitionInfo(BaseModel):
    parent_company: Union[str, Optional[None]] = None
    parent_company_ticker: Union[str, Optional[None]] = None
    parent_company_country: Union[str, Optional[None]] = None
    child_company: Union[str, Optional[None]] = None
    child_company_ticker: Union[str, Optional[None]] = None
    child_company_country: Union[str, Optional[None]] = None
    deal_amount: Union[str, Optional[None]] = None
    deal_currency: "Currency"

class MergerInfo(BaseModel):
    company_1: Union[str, Optional[None]] = None
    company_1_ticker: Union[str, Optional[None]] = None
    company_2: Union[str, Optional[None]] = None
    company_2_ticker: Union[str, Optional[None]] = None
    merged_entity: Union[str, Optional[None]] = None
    merged_entity_country: Union[str, Optional[None]] = None
    deal_amount: Union[str, Optional[None]] = None
    deal_currency: "Currency"
