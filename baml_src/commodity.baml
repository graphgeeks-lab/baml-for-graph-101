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

function ExtractCommodityInfo(text: string) -> Commodity[] {
    client CustomGPT4oMini
    prompt #"
        For the given text, identify the commodity that the companies mentioned in the text are most
        likely producers of. If you are unsure, return "Other".

        {{ ctx.output_format }}

        {{ _.role('user') }}

        Text: {{ text }}
    "#
}


test TestOne {
  functions [ExtractCommodityInfo]
  args {
    text #"
        NewCo’s core assets will include Rock Tech’s fully permitted lithium converter in Guben, Germany, and Arcore’s lithium-boron-magnesium mining project in Lopare, Bosnia-Herzegovina, which contains an estimated 600,000 tonnes of lithium carbonate equivalent. Rock Tech CEO and chairman Dirk Harbecke: “Strong European supply chains are essential to secure the regions’ strategic autonomy, promote industrial competitiveness and enable the transformation to a climate-neutral economy. “Europe is currently heavily dependent on imports of critical raw materials such as lithium.
    "#
  }
  @@check(is_lithium, {{ this|regex_match("[lL]ithium") }} )
}

test TestTwo {
  functions [ExtractCommodityInfo]
  args {
    text #"
        Karora Resources shareholders have almost unanimously voted in favour of the company’s merger with Westgold. Over 99 per cent of votes recorded approved the merger, which will see Westgold takes its place as a top five Australian gold producer. Toronto-based Karora chair and chief executive officer Pail Andre Huet announced the company’s approval late last week.
    "#
  }
  @@check(is_gold, {{ this|regex_match("[gG]old") }} )
}

test TestThree {
  functions [ExtractCommodityInfo]
  args {
    text #"
        Company X produces gold and silver.
    "#
  }
  @@check(is_gold, {{ this|regex_match("[gG]old") }} )
  @@check(is_silver, {{ this|regex_match("[sS]ilver") }} )
}