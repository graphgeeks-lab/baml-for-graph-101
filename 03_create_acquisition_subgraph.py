"""
Create a subgraph of companies that have participated in acquisition events.
"""
import kuzu
import polars as pl

from yfiles_jupyter_graphs_for_kuzu import KuzuGraphWidget

DB_PATH = "ex_kuzu_db"
db = kuzu.Database(DB_PATH)
conn = kuzu.Connection(db)
# yfiles_jupyter_graphs_for_kuzu widget for interactive graph visualization
g = KuzuGraphWidget(conn)

acquisitions_df = pl.read_json("data/acquisitions.json")

# NODE: Article
conn.execute(
    """
    LOAD FROM acquisitions_df
    WITH DISTINCT id, url, title, CAST(date AS DATE) AS date
    MERGE (a:Article {id: id})
    SET a.url = url, a.title = title, a.date = date
    """
)
# NODE: TimePeriod
conn.execute(
    """
    LOAD FROM acquisitions_df
    WITH DISTINCT time_period
    MERGE (:TimePeriod {month_year: time_period})
    """
)

# NODE: Commodity
conn.execute(
    """
    LOAD FROM acquisitions_df
    UNWIND commodities AS commodity
    WITH DISTINCT commodity
    MERGE (:Commodity {name: commodity})
    """
)

# NODE: Company
res = conn.execute(
    """
    LOAD FROM acquisitions_df
    UNWIND [parent_company, child_company] AS company
    WITH DISTINCT company
    WHERE company IS NOT NULL
    MERGE (:Company {name: company})
    """
)

# Node: Country
conn.execute(
    """
    LOAD FROM acquisitions_df
    UNWIND [parent_company_country, child_company_country] AS country
    WITH DISTINCT country
    WHERE country <> "Unknown"
    MERGE (:Country {name: country})
    """
)

# Relationships
conn.execute(
    """
    LOAD FROM acquisitions_df
    UNWIND commodities AS commodity
    MATCH (a:Article {id: id}),
          (ct:Commodity {name: commodity}),
          (c1:Company {name: parent_company}),
          (c2:Company {name: child_company}),
          (tp:TimePeriod {month_year: time_period})
    MERGE (a)-[:MENTIONS_COMMODITY]->(ct)
    MERGE (a)-[:MENTIONS_COMPANY]->(c1)
    MERGE (a)-[:MENTIONS_COMPANY]->(c2)
    MERGE (c1)-[:PRODUCES]->(ct)
    MERGE (c2)-[:PRODUCES]->(ct)
    MERGE (tp)-[:CONTAINS]->(a)
    """
)

# Country parent company-country relationships
conn.execute(
    """
    LOAD FROM acquisitions_df
    MATCH (c1:Company {name: parent_company}),
          (parent_country:Country {name: parent_company_country})
    WHERE parent_company_country <> "Unknown"
    MERGE (c1)-[:IS_FROM_COUNTRY]->(parent_country)
    """
)

# Country child company-country relationships
conn.execute(
    """
    LOAD FROM acquisitions_df
    MATCH (c2:Company {name: child_company}),
          (child_country:Country {name: child_company_country})
    WHERE child_company_country <> "Unknown"
    MERGE (c2)-[:IS_FROM_COUNTRY]->(child_country)
    """
)

# Acquisition relationships
res = conn.execute(
    """
    LOAD FROM acquisitions_df
    MATCH (c1:Company {name: parent_company}),
          (c2:Company {name: child_company})
    MERGE (c2)-[r1:ACQUIRED_BY]->(c1)
    SET r1.amount = deal_amount, r1.currency = deal_currency
    """
)

# --- Query the graph ---

# Query: Which companies produce Gold and where are they located?
res = conn.execute(
    """
    MATCH (c:Company)-[:PRODUCES]->(ct:Commodity {name: "Gold"}),
          (c)-[:IS_FROM_COUNTRY]->(country:Country)
    RETURN c.name, country.name
    """
)
print(f"Companies that produce Gold:\n{res.get_as_pl()}")  # type: ignore

# Optional: Visualize the graph using the yFiles Jupyter graphs for Kuzu widget

# g.show_cypher(
#     """
#     MATCH (a)-[b]->(c)
#     RETURN *
#     """
# )