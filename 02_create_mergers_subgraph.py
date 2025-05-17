"""
Create a subgraph of companies that have participated in merger events.
"""
import kuzu
import polars as pl

from yfiles_jupyter_graphs_for_kuzu import KuzuGraphWidget

DB_PATH = "ex_kuzu_db"
db = kuzu.Database(DB_PATH)
conn = kuzu.Connection(db)
# yfiles_jupyter_graphs_for_kuzu widget for interactive graph visualization
g = KuzuGraphWidget(conn)

mergers_df = pl.read_json("data/mergers.json")

# NODE: Article
conn.execute(
    """
    LOAD FROM mergers_df
    WITH id, url, title, CAST(date AS DATE) AS date
    MERGE (a:Article {id: id})
    SET a.url = url, a.title = title, a.date = date
    """
)
# NODE: TimePeriod
conn.execute(
    """
    LOAD FROM mergers_df
    WITH DISTINCT time_period
    MERGE (:TimePeriod {month_year: time_period})
    """
)

# NODE: Commodity
conn.execute(
    """
    LOAD FROM mergers_df
    UNWIND commodities AS commodity
    WITH DISTINCT commodity
    MERGE (:Commodity {name: commodity})
    """
)

# NODE: Company
res = conn.execute(
    """
    LOAD FROM mergers_df
    UNWIND [company_1, company_2, merged_entity] AS company
    WITH DISTINCT company
    WHERE company IS NOT NULL
    MERGE (:Company {name: company})
    """
)

# Node: Country
conn.execute(
    """
    LOAD FROM mergers_df
    WITH DISTINCT merged_entity_country
    MERGE (:Country {name: merged_entity_country})
    """
)

# Relationships
conn.execute(
    """
    LOAD FROM mergers_df
    UNWIND commodities AS commodity
    MATCH (a:Article {id: id}),
          (ct:Commodity {name: commodity}),
          (c1:Company {name: company_1}),
          (c2:Company {name: company_2}),
          (c3:Company {name: merged_entity}),
          (country:Country {name: merged_entity_country}),
          (tp:TimePeriod {month_year: time_period})
    MERGE (a)-[:MENTIONS_COMMODITY]->(ct)
    MERGE (a)-[:MENTIONS_COMPANY]->(c1)
    MERGE (a)-[:MENTIONS_COMPANY]->(c2)
    MERGE (a)-[:MENTIONS_COMPANY]->(c3)
    MERGE (c1)-[:PRODUCES]->(ct)
    MERGE (c2)-[:PRODUCES]->(ct)
    MERGE (c3)-[:PRODUCES]->(ct)
    MERGE (ct)-[:IS_FOUND_IN]->(country)
    MERGE (tp)-[:CONTAINS]->(a)
    MERGE (c3)-[:IS_FROM_COUNTRY]->(country)
    """
)

# Merger relationships
res = conn.execute(
    """
    LOAD FROM mergers_df
    MATCH (c1:Company {name: company_1}),
          (c2:Company {name: company_2}),
          (c3:Company {name: merged_entity})
    MERGE (c1)-[r1:MERGED_WITH]->(c2)
    SET r1.amount = deal_amount, r1.currency = deal_currency
    MERGE (c1)-[r2:FORMED_NEW_ENTITY]->(c3)
    MERGE (c2)-[r3:FORMED_NEW_ENTITY]->(c3)
    """
)

# --- Query the graph ---

# Query: Which companies produce Lithium and where are they located?
res = conn.execute(
    """
    MATCH (c:Company)-[:PRODUCES]->(ct:Commodity {name: "Lithium"}),
          (c)-[:IS_FROM_COUNTRY]->(country:Country)
    RETURN c.name, country.name
    """
)
print(f"Companies that produce Lithium:\n{res.get_as_pl()}")  # type: ignore

# Optional: Visualize the graph using the yFiles Jupyter graphs for Kuzu widget

# g.show_cypher(
#     """
#     MATCH (a)-[b]->(c)
#     RETURN *
#     """
# )