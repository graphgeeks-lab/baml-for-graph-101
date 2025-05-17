"""
Create a subgraph of companies that have participated in acquisition events.
"""
import kuzu
import polars as pl
from typing import Any

from baml_client import b
from baml_client.config import set_log_level
from dotenv import load_dotenv

load_dotenv()
set_log_level("WARN")

def get_company_pairs() -> list[tuple[str, str]]:
    res = conn.execute(
        """
        MATCH (c1:Company), (c2:Company)
        WHERE c1.name CONTAINS c2.name
        AND c1.name <> c2.name
        RETURN c1.name, c2.name
        """
    )
    company_pairs = res.get_as_pl().rows()  # type: ignore
    return company_pairs


def get_nearest_neighbours(company_name: str) -> list[dict[str, Any]]:
    res = conn.execute(
        """
        MATCH (c1:Company)
        WHERE c1.name = $company_name
        MATCH (c1)-[r1]->(x1)
        WHERE label(x1) <> "Article"
        RETURN DISTINCT label(r1) AS rel_type, label(x1) AS node_type, COALESCE(x1.name, null) AS name
        """,
        parameters={"company_name": company_name},
    )
    result = res.get_as_pl().to_dicts()  # type: ignore
    return result


def get_pair_info(company_pairs: list[tuple[str, str]]) -> list[str]:
    entities_resolved = []
    for company_1, company_2 in company_pairs:
        company1_info = get_nearest_neighbours(company_1)
        company2_info = get_nearest_neighbours(company_2)
        c1 = []
        for company in company1_info:
            c1.append(f"({company_1}) {company['rel_type'].lower()} {company['name']}")
        c2 = []
        for company in company2_info:
            c2.append(f"({company_2}) {company['rel_type'].lower()} {company['name']}")
        company_1_neigbours = "\n".join(c1)
        company_2_neigbours = "\n".join(c2)
        entities_resolved.append((company_1, company_2, company_1_neigbours, company_2_neigbours))
    return entities_resolved


def resolve_entities(company_pairs: list[tuple[str, str]]) -> pl.DataFrame:
    entities_resolved = []
    for company_1, company_2 in company_pairs:
        result = b.ResolveEntity(company_1, company_2)
        if result:
            entities_resolved.append([company_1, company_2])
            entities_resolved.append([company_2, company_1])
    
    return pl.DataFrame(entities_resolved, schema=["node_pk", "alias"])

if __name__ == "__main__":
    DB_PATH = "ex_kuzu_db"
    db = kuzu.Database(DB_PATH)
    conn = kuzu.Connection(db)

    company_pairs = get_company_pairs()
    entities_resolved = get_pair_info(company_pairs)

    entities_resolved_df = resolve_entities(company_pairs)
    OUTPUT_PATH = "data/entities_resolved.csv"
    entities_resolved_df.write_csv(OUTPUT_PATH)

    conn.execute("CREATE REL TABLE HAS_ALIAS(FROM Company TO Company)")

    # Load entities_resolved.csv into the graph
    conn.execute(
        f"""
        LOAD FROM '{OUTPUT_PATH}' (header=true)
        MATCH (c:Company {{name: node_pk}}), (c2:Company {{name: alias}})
        SET c.alias = alias
        MERGE (c)-[:HAS_ALIAS]->(c2)
        """
    )
    print("Finished updating the graph with aliases for resolved company entities.")

