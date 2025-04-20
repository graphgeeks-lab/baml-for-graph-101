// Defining a data model.
enum ArticleType {
  Merger
  Acquisition
  Other
}

// Create a function to extract the resume from a string.
function ClassifyArticle(text: string) -> ArticleType {
  client CustomGPT4oMini
  prompt #"
    Analyze the following news article and classify it according to whether it's a "Merger" or "Acquisition".
    If it mentions a potential or failed deal, classify it as "Other".

    {{ ctx.output_format }}

    {{ _.role('user') }}
    
    {{ text }}
  "#
}


// Tests
test TestMerger {
  functions [ClassifyArticle]
  args {
    text #"
      Karora Resources shareholders have almost unanimously voted in favour of the company’s merger with Westgold. Over 99 per cent of votes recorded approved the merger, which will see Westgold takes its place as a top five Australian gold producer.
    "#
  }
  @@assert({{ this == "Merger" }})
}

test TestAcquisition {
  functions [ClassifyArticle]
  args {
    text #"
      Northern Star Resources is set to acquire De Grey Mining, owner of one of the world’s largest undeveloped gold projects, for approximately $5 billion. Under the terms of the scheme implementation deed, De Grey shareholders will be entitled to receive 0.119 new Northern Star shares for each De Grey share held at the scheme’s record date. This represents an implied offer price of $2.08 per De Grey share. 
    "#
  }
  @@assert({{ this == "Acquisition" }})
}

test TestOther {
  functions [ClassifyArticle]
  args {
    text #"
      Gold Road Resources has rejected an unsolicited takeover proposal from Gold Fields, its 50:50 joint venture partner for the Gruyere gold mine in Western Australia. The offer was received on March 7 and, if accepted, would have involved Gold Fields acquiring 100 per cent of the shares on issue in Gold Road via a scheme of arrangement for $3.05 per share, valuing Gold Road at $3.3 billion. This offer comprised $2.27 cash per share and a variable portion equal to the value of Gold Road’s shareholding in De Grey Mining. De Grey is soon set to be acquired by Northern Star Resources for $5 billion.
    "#
  }
  @@assert({{ this == "Other" }})
}