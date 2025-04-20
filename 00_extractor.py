import json
import re
from typing import Any
from datetime import datetime

from dotenv import load_dotenv

from baml_client import b
from baml_client.config import set_log_level

load_dotenv()
set_log_level("WARN")


def read_data(path: str) -> list[dict]:
    with open(path, "r") as f:
        return json.load(f)


def extract_first_n_sentences(text: str, num_sentences: int = 3) -> str:
    # Define sentence boundary pattern: period followed by space or newline
    pattern = r"\.(?:\s+|\n+)"

    # Split the text into sentences
    sentences = re.split(pattern, text)

    # Filter out empty sentences and join the first 3 with periods
    valid_sentences = [s.strip() for s in sentences if s.strip()]
    first_n = valid_sentences[:num_sentences]

    # Join with periods and spaces
    result = ". ".join(first_n) + "."
    return result


def classify_article(article: dict[str, str], num_sentences: int = 3) -> str:
    text = extract_first_n_sentences(article["content"], num_sentences=num_sentences)
    category = b.ClassifyArticle(text).value
    print(f"Classified article {article['id']}: {category}")
    return category


def extract_info(article: dict[str, str], category: str, num_sentences: int = 5) -> dict[str, Any]:
    title = article["title"]
    content = extract_first_n_sentences(article["content"], num_sentences=num_sentences)
    # Append the title to the content so that the model has more useful context (headers are important)
    text = f"{title}\n{content}"
    if category == "Acquisition":
        info = b.ExtractAcquisitionInfo(text)
    elif category == "Merger":
        info = b.ExtractMergerInfo(text)
    else:
        pass
    # Attach extra fields to the info
    info_dict = info.model_dump()
    info_dict["category"] = category
    # Extract time period as Month name and year from the date column
    info_dict["time_period"] = datetime.strptime(article["date"], "%Y-%m-%d").strftime("%B %Y")
    info_dict["deal_currency"] = info_dict.pop("deal_currency").value
    # Update info dict with the article dict
    info_dict.update(article)
    print(f"Extracted M&A info for article {article['id']}")
    return info_dict


def extract_commodity(text: str, info: dict[str, Any], num_sentences: int = 10) -> dict[str, Any]:
    text = extract_first_n_sentences(text, num_sentences=num_sentences)
    commodities = b.ExtractCommodityInfo(text)
    # Attach commodity fields to the info
    commodities = [c.value for c in commodities]
    info.update({"commodities": commodities})
    print(f"Extracted commodities for article {info['id']}")
    return info


def write_json(data: list[dict[str, Any]], path: str):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)


def main(data_path: str, limit: int = 0):
    articles = read_data(data_path)
    if limit > 0:
        articles = articles[:limit]

    acquisitions = []
    mergers = []
    for article in articles:
        category = classify_article(article, num_sentences=3)
        if category != "Other":
            info = extract_info(article, category, num_sentences=5)
            info_final = extract_commodity(article["content"], info, num_sentences=10)
            info_final.pop("content")
            if info_final["category"] == "Acquisition":
                acquisitions.append(info_final)
            elif info_final["category"] == "Merger":
                mergers.append(info_final)
    # Write to JSON files
    write_json(acquisitions, "data/acquisitions.json")
    write_json(mergers, "data/mergers.json")


if __name__ == "__main__":
    data_path = "data/articles.json"

    # If greater than 0, limit the number of articles to process
    LIMIT = 0
    main(data_path, limit=LIMIT)
