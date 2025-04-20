#! /bin/bash

uv run 01_create_schema.py
uv run 02_create_mergers_subgraph.py
uv run 03_create_acquisition_subgraph.py