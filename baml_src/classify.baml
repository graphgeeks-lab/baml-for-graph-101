enum ArticleType {
  Merger
  Acquisition
  Other
}

function ClassifyArticle(text: string) -> ArticleType {
//   client CustomGPT4oMini
  client OpenRouterGPT4_1_nano
  prompt #"
    Analyze the following news article and classify it according to whether it's a "Merger" or "Acquisition".
    If it mentions a potential or failed deal, classify it as "Other".

    {{ ctx.output_format }}

    {{ _.role('user') }}
    
    {{ text }}
  "#
}


// Tests
test Test1 {
  functions [ClassifyArticle]
  args {
    text #"
      The company to be created through the merger of ASX-listed Sayona Mining and Piedmont Lithium will be named Elevra Lithium, subject to Sayona shareholder approval. Originally announced in November 2024, the merger is set to create the largest hard-rock lithium producer in the US. The transaction will result in an approximate 50:50 equity holding for Sayona and Piedmont shareholders on a fully diluted basis following the deal’s closing, which is expected in the first half of 2025.
    "#
  }
  @@assert({{ this == "Merger" }})
}

test Test2 {
  functions [ClassifyArticle]
  args {
    text #"
      Australia’s Newcrest Mining has closed the acquisition of Pretium Resources, which owns the Brucejack mine in the Golden Triangle region of British Columbia, Canada. Last November, Newcrest Mining had agreed to acquire the common shares it did not own in Pretium for $2.8bn (C$3.5bn) through a Canadian plan of arrangement. A high-grade gold mine, Brucejack commenced commercial production in 2017.
    "#
  }
  @@assert({{ this == "Acquisition" }})
}

test Test3 {
  functions [ClassifyArticle]
  args {
    text #"
      Gold Road Resources has rejected an unsolicited takeover proposal from Gold Fields, its 50:50 joint venture partner for the Gruyere gold mine in Western Australia. The offer was received on March 7 and, if accepted, would have involved Gold Fields acquiring 100 per cent of the shares on issue in Gold Road via a scheme of arrangement for $3.05 per share, valuing Gold Road at $3.3 billion. This offer comprised $2.27 cash per share and a variable portion equal to the value of Gold Road’s shareholding in De Grey Mining.
    "#
  }
  @@assert({{ this == "Other" }})
}

test Test4 {
  functions [ClassifyArticle]
  args {
    text #"
      Ramelius Resources is set to acquire the remaining Spartan Resources shares it does not own for approximately $2.4 billion. Under the binding transaction implementation deed, Ramelius will pay $0.25 in cash and 0.6957 Ramelius shares for each Spartan share, with an implied value of $1.78 per Spartan share. Ramelius currently holds a 19.9 per cent shareholding in Spartan.
    "#
  }
  @@assert({{ this == "Acquisition" }})
}

test Test5 {
  functions [ClassifyArticle]
  args {
    text #"
      Northern Star Resources is set to acquire De Grey Mining, owner of one of the world’s largest undeveloped gold projects, for approximately $5 billion. Under the terms of the scheme implementation deed, De Grey shareholders will be entitled to receive 0.119 new Northern Star shares for each De Grey share held at the scheme’s record date. This represents an implied offer price of $2.08 per De Grey share.
    "#
  }
  @@assert({{ this == "Acquisition" }})
}


test Test6 {
  functions [ClassifyArticle]
  args {
    text #"
      Equinox Gold (TSX: EQX; NYSE-A: EQX) agreed to buy Calibre Mining (TSX: CXB) for about $2.56 billion in stock to become Canada’s second-largest gold producer. Calibre shareholders will receive 0.31 Equinox common share for each Calibre common share held immediately before the transaction, according to a joint statement issued Sunday. At closing, existing Equinox shareholders would own about 65% of the combined company’s outstanding shares, compared with 35% for their Calibre counterparts.
    "#
  }
  @@assert({{ this == "Acquisition" }})
}


test Test7 {
  functions [ClassifyArticle]
  args {
    text #"
      Canadian miner Rock Tech Lithium has signed a binding business combination agreement with Swiss junior mining company Arcore to merge their subsidiaries and establish a new European entity named NewCo. Upon completion of the transaction, Rock Tech will transfer the shares of its fully owned subsidiary, Rock Tech Guben, to NewCo in exchange for a 75% stake in NewCo’s registered share capital. Arcore will contribute the shares of its wholly owned subsidiary, AR CORE, to NewCo and receive a 25% stake in NewCo’s registered share capital.
    "#
  }
  @@assert({{ this == "Merger" }})
}