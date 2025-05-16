enum Commodity {
    Gold
    Silver
    Copper
    Lithium
    Nickel
    Cobalt
    Uranium
    Zinc
    Lead
    Other
}

function ExtractCommodityInfo(text: string) -> Commodity[] | null{
    client OpenRouterMistralSmall3_1_24b
    prompt #"
        For the given text, identify the commodity that the companies mentioned in the text are most
        likely producers of. If the name of the commodity is not mentioned explicitly,
        DO NOT GUESS - just return "Other".

        {{ ctx.output_format }}

        {{ _.role('user') }}

        Text: {{ text }}
    "#
}


test Test1 {
  functions [ExtractCommodityInfo]
  args {
    text #"
        NewCo’s core assets will include Rock Tech’s fully permitted lithium converter in Guben, Germany, and Arcore’s lithium-boron-magnesium mining project in Lopare, Bosnia-Herzegovina, which contains an estimated 600,000 tonnes of lithium carbonate equivalent. Rock Tech CEO and chairman Dirk Harbecke: “Strong European supply chains are essential to secure the regions’ strategic autonomy, promote industrial competitiveness and enable the transformation to a climate-neutral economy. “Europe is currently heavily dependent on imports of critical raw materials such as lithium.
    "#
  }
  @@assert( {{ this|regex_match("[lL]ithium") }} )
}

test Test2 {
  functions [ExtractCommodityInfo]
  args {
    text #"
        Karora Resources shareholders have almost unanimously voted in favour of the company’s merger with Westgold. Over 99 per cent of votes recorded approved the merger, which will see Westgold takes its place as a top five Australian gold producer. Toronto-based Karora chair and chief executive officer Pail Andre Huet announced the company’s approval late last week.
    "#
  }
  @@assert( {{ this|regex_match("[gG]old") }} )
}

test Test3 {
  functions [ExtractCommodityInfo]
  args {
    text #"
        Company X produces gold and silver.
    "#
  }
  @@assert( {{ this|regex_match("[gG]old") }} )
  @@assert( {{ this|regex_match("[sS]ilver") }} )
}

test Test4 {
  functions [ExtractCommodityInfo]
  args {
    text #"
        Company X is known to be an industry leader in mining and processing heavy metals.
    "#
  }
  @@assert({{ this == ["Other"] }})
}