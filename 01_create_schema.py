"""
This script creates the schema for the mergers and acquisitions graph
of companies, commodities, countries, and time periods in the given dataset of news articles.
"""
import shutil
import kuzu

DB_PATH = "ex_kuzu_db"
shutil.rmtree(DB_PATH, ignore_errors=True)
db = kuzu.Database(DB_PATH)
conn = kuzu.Connection(db)

# --- Graph schema ---

# Create node tables
conn.execute(
    """
    CREATE NODE TABLE IF NOT EXISTS Article (
        id INT64 PRIMARY KEY,
        url STRING,
        title STRING,
        date DATE
    )
    """
)
conn.execute(
    """
    CREATE NODE TABLE IF NOT EXISTS Company (
        name STRING PRIMARY KEY,
        ticker STRING
    )
    """
)
conn.execute("CREATE NODE TABLE IF NOT EXISTS Country (name STRING PRIMARY KEY)")
conn.execute("CREATE NODE TABLE IF NOT EXISTS Commodity (name STRING PRIMARY KEY)")
conn.execute("CREATE NODE TABLE IF NOT EXISTS TimePeriod (month_year STRING PRIMARY KEY)")
conn.execute("CREATE REL TABLE IF NOT EXISTS MENTIONS_COMPANY (FROM Article TO Company)")
conn.execute("CREATE REL TABLE IF NOT EXISTS MENTIONS_COMMODITY (FROM Article TO Commodity)")
conn.execute("CREATE REL TABLE IF NOT EXISTS IS_FROM_COUNTRY (FROM Company TO Country)")
conn.execute("CREATE REL TABLE IF NOT EXISTS PRODUCES (FROM Company TO Commodity)")
conn.execute("CREATE REL TABLE IF NOT EXISTS CONTAINS (FROM TimePeriod TO Article)")
conn.execute("CREATE REL TABLE IF NOT EXISTS IS_FOUND_IN (FROM Commodity TO Country)")
conn.execute("CREATE REL TABLE IF NOT EXISTS MERGED_WITH (FROM Company TO Company, amount STRING, currency STRING)")
conn.execute("CREATE REL TABLE IF NOT EXISTS FORMED_NEW_ENTITY (FROM Company TO Company)")
conn.execute("CREATE REL TABLE IF NOT EXISTS ACQUIRED_BY (FROM Company TO Company, amount STRING, currency STRING)")