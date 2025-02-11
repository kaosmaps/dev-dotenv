import click
import streamlit.web.cli as stcli
import sys
from pathlib import Path


@click.group()
def cli():
    """Dev dotenv CLI commands"""
    pass


@cli.command()
def serve():
    """Start the streamlit server"""
    # Get the path to our app.py
    app_path = Path(__file__).parent / "app.py"
    sys.argv = ["streamlit", "run", str(app_path)]
    sys.exit(stcli.main())
