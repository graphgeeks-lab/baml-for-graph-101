function ResolveEntity(company_1: string, company_2: string) -> bool {
//   client CustomGPT4oMini
  client OpenRouterMistralSmall3_1_24b
  prompt #"
    Given the information about two companies, determine if they are the same company. Only return
    true if there is enough overlap in the names of the companies. 

    {{ ctx.output_format }}

    {{ _.role('user') }}
    
    Company 1:
    {{ company_1 }}

    Company 2:
    {{ company_2 }}
  "#
}


// Tests
test Test1 {
  functions [ResolveEntity]
  args {
    company_1 #"
        (Newcrest Mining Limited) acquired_by Newmont
        (Newcrest Mining Limited) produces Gold
    "#
    company_2 #"
        (Newcrest Mining) is_from_country Australia
        (Newcrest Mining) produces Gold
    "#
  }
  @@assert({{ this == true }})
}

test Test2 {
  functions [ResolveEntity]
  args {
    company_1 #"
        (Newcrest Digital) is_from_country Australia
    "#
    company_2 #"
        (Newcrest Mining) is_from_country Australia
        (Newcrest Mining) produces Gold
    "#
  }
  @@assert({{ this == false }})
}

test Test3 {
  functions [ResolveEntity]
  args {
    company_1 #"
        (NewCo) is_from_country Germany
        (NewCo) produces Lithium
    "#
    company_2 #"
        (NewCo Mining Consultancy) is_from_country Poland
    "#
  }
  @@assert({{ this == false }})
}

test Test4 {
  functions [ResolveEntity]
  args {
    company_1 #"
        (Pretium Resources Inc.) is_from_country Canada
        (Pretium Resources Inc.) produces Gold
    "#
    company_2 #"
        (Pretium Resources) is_from_country Canada
    "#
  }
  @@assert({{ this == true }})
}