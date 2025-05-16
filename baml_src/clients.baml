// Learn more about clients at https://docs.boundaryml.com/docs/snippets/clients/overview

// Custom LLM inference server by YourTechBud (wrapper for Ollama)

client<llm> OpenRouterGPT4_1_nano {
  provider "openai-generic"
  options {
    base_url "https://openrouter.ai/api/v1"
    api_key env.OPENROUTER_API_KEY
    model "openai/gpt-4.1-nano"
    temperature 0.1
    headers {
      "HTTP-Referer" "https://thedataquarry.com" // Optional
      "X-Title" "thedataquarry" // Optional
    }
  }
}

client<llm> OpenRouterGemma_27b {
  provider "openai-generic"
  options {
    base_url "https://openrouter.ai/api/v1"
    api_key env.OPENROUTER_API_KEY
    model "google/gemma-3-27b-it"
    temperature 0.1
    headers {
      "HTTP-Referer" "https://thedataquarry.com" // Optional
      "X-Title" "thedataquarry" // Optional
    }
  }
}

client<llm> OpenRouterMistralSmall3_1_24b {
  provider "openai-generic"
  options {
    base_url "https://openrouter.ai/api/v1"
    api_key env.OPENROUTER_API_KEY
    model "mistralai/mistral-small-3.1-24b-instruct"
    temperature 0.1
    headers {
      "HTTP-Referer" "https://thedataquarry.com" // Optional
      "X-Title" "thedataquarry" // Optional
    }
  }
}

client<llm> CustomGPT4o {
  provider openai
  options {
    model "gpt-4o"
    api_key env.OPENAI_API_KEY
  }
}

client<llm> CustomGPT41Nano {
  provider openai
  retry_policy Exponential
  options {
    model "gpt-4.1-nano"
    api_key env.OPENAI_API_KEY
    temperature 0.1
  }
}

client<llm> CustomGPT4oMini {
  provider openai
  retry_policy Exponential
  options {
    model "gpt-4o-mini"
    api_key env.OPENAI_API_KEY
    temperature 0.1
  }
}

client<llm> CustomSonnet {
  provider anthropic
  options {
    model "claude-3-5-sonnet-20241022"
    api_key env.ANTHROPIC_API_KEY
  }
}


client<llm> CustomHaiku {
  provider anthropic
  retry_policy Constant
  options {
    model "claude-3-haiku-20240307"
    api_key env.ANTHROPIC_API_KEY
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/round-robin
client<llm> CustomFast {
  provider round-robin
  options {
    // This will alternate between the two clients
    strategy [CustomGPT4oMini, CustomHaiku]
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/fallback
client<llm> OpenaiFallback {
  provider fallback
  options {
    // This will try the clients in order until one succeeds
    strategy [CustomGPT4oMini, CustomGPT4oMini]
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/retry
retry_policy Constant {
  max_retries 3
  // Strategy is optional
  strategy {
    type constant_delay
    delay_ms 200
  }
}

retry_policy Exponential {
  max_retries 2
  // Strategy is optional
  strategy {
    type exponential_backoff
    delay_ms 300
    multiplier 1.5
    max_delay_ms 10000
  }
}