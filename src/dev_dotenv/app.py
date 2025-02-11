from dotenv_vault import load_dotenv
import os
import streamlit as st


def run_app():
    load_dotenv()
    st.title("Dotenv vault test")
    st.write(f"Environment says: {os.getenv('GREETING', 'No greeting found!')}")


# Create a module-level function for streamlit to run
def main():
    run_app()


if __name__ == "__main__":
    main()
