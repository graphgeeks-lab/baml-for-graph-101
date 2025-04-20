enum Currency {
    AUD
    USD
    CAD
    EUR
    GBP
    NZD
    CHF
    Unknown
}

class AcquisitionInfo {
    parent_company string | null
    parent_company_ticker string | null @description("The stock ticker of the parent company")
    parent_company_country string | null
    child_company string | null @description("The company that is being acquired")
    child_company_ticker string | null @description("The stock ticker of the company being acquired")
    child_company_country string | null
    deal_amount string | null @description("The total monetary amount of the deal: 'm' or 'mn' is millions, 'b' or 'bn' is billions")
    deal_currency Currency
}

// Create a function to extract the resume from a string.
function ExtractAcquisitionInfo(text: string) -> AcquisitionInfo {
  client CustomGPT4oMini
  prompt #"
    From the given text about a company acquisition, extract the relevant information. For the deal
    amount, try to infer the likely currency based on the parent company's country. If you do not
    know the currency, mark it as "Unknown".
the
    {{ ctx.output_format }}

    {{ _.role('user') }}
    
    {{ text }}
  "#
}


// Tests
test TestOne {
  functions [ExtractAcquisitionInfo]
  args {
    text #"
      Australia’s Newcrest Mining has closed the acquisition of Pretium Resources, which owns the Brucejack mine in the Golden Triangle region of British Columbia, Canada. Last November, Newcrest Mining had agreed to acquire the common shares it did not own in Pretium for $2.8bn (C$3.5bn) through a Canadian plan of arrangement. A high-grade gold mine, Brucejack commenced commercial production in 2017.
    "#
  }
}

test TestTwo {
  functions [ExtractAcquisitionInfo]
  args {
    text #"
      Northern Star Resources is set to acquire De Grey Mining, owner of one of the world’s largest undeveloped gold projects, for approximately $5 billion. Under the terms of the scheme implementation deed, De Grey shareholders will be entitled to receive 0.119 new Northern Star shares for each De Grey share held at the scheme’s record date. This represents an implied offer price of $2.08 per De Grey share. The scheme consideration represents a 37.1 per cent premium to De Grey’s last closing share price of $1.52 per share on November 29. De Grey is currently developing the Hemi gold project in the Pilbara region of Western Australia, which has a mineral resource estimate of 264 million tonnes at 1.3 grams per tonne of gold for 11.2 million ounces (Moz) and is forecasted to produce 530,000 ounces per annum over its first 10 years. Acquiring De Grey will provide Northern Star access to a low-cost, long-life and large-scale gold development project. “The acquisition of De Grey is strongly aligned with Northern Star’s strategy and contributes to our purpose of generating superior returns for shareholders,” Northern Star managing director and chief executive officer Stuart Tonkin said. “De Grey’s Hemi development project will deliver a low-cost, long-life and large-scale gold mine in the Tier 1 jurisdiction of Western Australia, enhancing the quality of Northern Star’s asset portfolio to generate cash earnings.”  Once the scheme has been implemented, Northern Star shareholders will own approximately 80.1 per cent of the combined entity and De Grey shareholders will own the balance. The scheme has been unanimously recommended by the De Grey board. “Given the high-quality nature of Hemi, De Grey is in the fortunate position to have had many avenues to progress the asset, including M&A (mergers and acquisitions),” De Grey managing director Glenn Jardine said.
    "#
  }
}