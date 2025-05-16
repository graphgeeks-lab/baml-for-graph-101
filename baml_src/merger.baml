// The Currency enum is defined in the file 'acquisition.baml'

class MergerInfo {
    company_1 string | null @description("The first company in the merger")
    company_1_ticker string | null @description("The ticker of the first company")
    company_2 string | null @description("The second company in the merger")
    company_2_ticker string | null @description("The ticker of the second company")
    merged_entity string | null @description("The name of the merged entity")
    merged_entity_country string | null @description("The likely country of the merged entity")
    deal_amount string | null @description("The total monetary amount of the deal: 'm' or 'mn' is millions, 'b' or 'bn' is billions")
    deal_currency Currency @description("The likely currency of the deal based on the merged entity's country")
}

// Create a function to extract the resume from a string.
function ExtractMergerInfo(text: string) -> MergerInfo {
  client OpenRouterMistralSmall3_1_24b
  prompt #"
    From the given text about a merger between two companies, extract the relevant information. For the
    deal amount, try to infer the likely currency based on the merged entity's country. If you do not
    know the currency, mark it as "Unknown".

    {{ ctx.output_format }}

    {{ _.role('user') }}
    
    {{ text }}
  "#
}


// Tests
test Test1 {
  functions [ExtractMergerInfo]
  args {
    text #"
      Elevra: ‘A defining moment in North American lithium’
      The company to be created through the merger of ASX-listed Sayona Mining and Piedmont Lithium will be named Elevra Lithium, subject to Sayona shareholder approval. Originally announced in November 2024, the merger is set to create the largest hard-rock lithium producer in the US. The transaction will result in an approximate 50:50 equity holding for Sayona and Piedmont shareholders on a fully diluted basis following the deal’s closing, which is expected in the first half of 2025. Now the merged entity has been named, nominees for the board have been announced. The Elevra Lithium board will initially comprise eight members, including four directors to be appointed by Sayona and four directors to be appointed by Piedmont Lithium. Sayona has nominated its managing director and chief executive officer Lucas Dow, along with James Brown, Allan Buckler and Laurie Lefcourt.“I am delighted to announce the nomination of this highly experienced and capable group of leaders to form the board of Elevra Lithium,” Dow said.“Their diverse expertise across mining, legal, finance, and commercial strategy will be instrumental in steering our newly combined entity towards a successful and sustainable future.“As we integrate Sayona and Piedmont Lithium, this board will provide the strategic oversight required to unlock the full potential of our assets and deliver long-term value for our shareholders.”Piedmont has nominated its chair designate Dawne Hickton, and Christina Alvord, Jeff Armstrong and Jorge M. Beristain.“I am honoured to have been selected as chair-designate for Elevra Lithium, and we are pleased to announce the new board of directors for the merged company,” Hickton said.“I look forward to building a strong connection and leveraging our collective skills and experience to work with Elevra Lithium’s management team to devise, and deliver against, the strategy for what will become one of the world’s leading lithium companies.”Australian-based Sayona has three lithium assets in development in Québec, Canada and 12 mining leases for lithium and gold tenure in Western Australia, and US-based Piedmont has two lithium projects in North America and one in Ghana. The North American Lithium (NAL) operation in Québec is jointly owned by Sayona and Piedmont via a 75:25 partnership. NAL has produced approximately 140,000 tonnes of spodumene concentrate since its restart in March 2023. By merging, Sayona and Piedmont will consolidate NAL’s ownership.“The formation of Elevra Lithium will mark a defining moment in the North American lithium industry,” Dow said.“With a strengthened balance sheet, simplified ownership structure, and a world-class asset portfolio, we will be poised to accelerate our growth strategy and enhance our ability to meet the rising global demand for lithium.“Our commitment to operational excellence, cost reduction and innovation will drive efficiencies across our projects, ensuring that we maximise the benefits of this merger.“The synergies between Sayona and Piedmont Lithium will allow us to optimise our production capabilities, streamline logistics, and expand our reach in key markets.
    "#
  }
  @@assert({{ this.company_1 == "Sayona Mining" }})
  @@assert({{ this.company_2 == "Piedmont Lithium" }})
  @@assert({{ this.merged_entity == "Elevra Lithium" }})
}

test Test2 {
  functions [ExtractMergerInfo]
  args {
    text #"
      Karora says 'yes' to $3.4b Westgold merger
      Karora Resources shareholders have almost unanimously voted in favour of the company's merger with Westgold. Over 99 per cent of votes recorded approved the merger, which will see Westgold takes its place as a top five Australian gold producer. Toronto-based Karora chair and chief executive officer Pail Andre Huet announced the company's approval late last week."The approval by approximately 99 per cent of the votes cast on the resolutions regarding the proposed merger transaction with Westgold Resources, along with receipt of Foreign Investment Review Board approval, represent two important milestones towards the closing of this transaction," he said."We thank Karora shareholders for their overwhelming support of the combination of Westgold and Karora to create a dual ASX and TSX listed top five Australian gold producer."Westgold managing director and chief executive officer Wayne Bramwell thanked Karora shareholders for their support."The overwhelming support for this merger shown by Karora shareholders confirms the independently verified value and the compelling commercial rationale behind this transaction," he said.
    "#
  }
  @@assert({{ this.company_1 == "Karora Resources" }})
  @@assert({{ this.company_2 == "Westgold" }})
}

test Test3 {
  functions [ExtractMergerInfo]
  args {
    text #"
      Rock Tech, Arcore to merge subsidiaries to form integrated lithium company
      Canadian miner Rock Tech Lithium has signed a binding business combination agreement with Swiss junior mining company Arcore to merge their subsidiaries and establish a new European entity named NewCo. Upon completion of the transaction, Rock Tech will transfer the shares of its fully owned subsidiary, Rock Tech Guben, to NewCo in exchange for a 75% stake in NewCo's registered share capital. Arcore will contribute the shares of its wholly owned subsidiary, AR CORE, to NewCo and receive a 25% stake in NewCo's registered share capital.
    "#
  }
  @@assert({{ this.company_1 == "Rock Tech Lithium" }})
  @@assert({{ this.company_2 == "Arcore" }})
  @@assert({{ this.merged_entity == "NewCo" }})
}